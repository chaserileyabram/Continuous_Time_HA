classdef Statistics < handle

	properties
		pmf;
		rho;
		beta_Q;
		beta_A;
		beta_A_effective;
        beta_IG;
		illiqw;
		liqw;
		totw;
		sav0;

		mpcs_over_ss;
        illiquid_mpcs_over_ss;
        
		pmf_b;
		cdf_b;
		pmf_a;
		cdf_a;
		pmf_b_a;

		lwpercentiles;
		iwpercentiles;
		wpercentiles;

		median_liqw;
		median_illiqw;
		median_totw;
		diff_median;
		diff_mean;

		w_top10share;
		w_top1share;
		lw_top10share;
		lw_top1share;
		iw_top10share
		iw_top1share
		wgini;

		constrained;
		constrained_pct;
		constrained_dollars;
		constrained_liq;
		constrained_liq_pct;
		constrained_liq_dollars;
		constrained_illiq;
		constrained_illiq_pct;
		constrained_illiq_dollars;
		
		w_lt_ysixth;
		w_lt_ytwelfth;
		liqw_lt_ysixth;
		liqw_lt_ytwelfth;

		WHtM_over_HtM_biweekly;
		WHtM_over_HtM_weekly;

		adjcosts;
        
        adj_policy;
        rebalance_frac;
        rebalance_frac_to_liq;
        rebalance_m500;
        rebalance_m5000;
        rebalance_p500;
        rebalance_p5000;
        rebalance_p10000;

		mpcs;
		illiquid_mpcs;
		mpcs_news_one_quarter;
		mpcs_news_one_year;

		decomp_norisk_completed;
		decomp_norisk;
		decomp_RA;
		decomp_baseline_present = false;

		bgrid;
		agrid;

		nb;
		na;
		nz;
		ny;

		mean_gross_y_annual;
		std_log_gross_y_annual;
		std_log_net_y_annual;

		params = struct();

		other = struct();
        
        c_KFE;
        
        apc;
        mean_apc;
        
        mpc_apc_corr;
        b_a_corr;
        mpc_income_wgt;
        mpc_income_wgt_perc;
        
        A;
        
        b_lt_ysixth_1_year;
        b_lt_ysixth_5_year;
        
        mob_mat_b;
        mob_mat_a;
        mob_mat_w;
        
        pmf_int;
        mpc_int;
        
        mpc_wmean;
	end

	properties (Access=protected)
		p;
		income;
		model;

		wealth_sorted;
		wealthmat;

		pmf_w;
	end

	methods
		function obj = Statistics(p, income, grdKFE, model, A)
			obj.p = p;
			obj.income = income;
			obj.model = model;

			obj.bgrid = grdKFE.b.vec;
			obj.agrid = grdKFE.a.vec;

			obj.na = p.na_KFE;
			obj.nb = p.nb_KFE;
			obj.nz = p.nz;
			obj.ny = income.ny;

			tmp = obj.bgrid + shiftdim(obj.agrid, -1);
			obj.wealthmat = tmp;
			obj.wealth_sorted = sortrows(tmp(:));

			obj.pmf = model.g .* grdKFE.trapezoidal.matrix;
            
            obj.c_KFE = model.c_KFE;
            
            obj.A = A;
		end

		function compute_statistics(obj)
			obj.add_params();
			obj.compute_intro_stats();
			obj.construct_distributions();
			obj.compute_percentiles();
			obj.compute_inequality();
			obj.compute_constrained();
			obj.compute_deposit_stats();
            obj.compute_apc()
            
            obj.compute_adjust();
            obj.compute_b_a_corr();
        end
        
        function compute_HtM_trans(obj)
            % Note: obj.A' is the KFE operator (\dot{g} = A'g)
            % No, it also needs the inctrans matrix
            inctrans = kron(obj.income.ytrans, speye(obj.p.nb_KFE*obj.p.na_KFE*obj.p.nz));
            A_full = obj.A + inctrans;
            
            % Need to "iterate" forward from steady-state to see how many HtM stay
            % HtM, using A and pmf_ss?
            b_lt_ysixth = (repmat(obj.bgrid, [1 obj.na obj.nz obj.ny]) ./ obj.income.y.wide) <= 1/6;
            % Need to use affine approx?
            disp('\nComputing trans_1year\n')
%             trans_1year = eye(size(obj.A')) + obj.A' .* 4;
%             trans_1year = expm(obj.A' .* 4);
%             rem_pmf_1year = trans_1year * (obj.pmf(:) .* b_lt_ysixth(:)) ./ sum(obj.pmf(:) .* b_lt_ysixth(:), 'all');
%             obj.b_lt_ysixth_1_year = obj.sfill(sum(rem_pmf_1year .* b_lt_ysixth(:)), 'HtM 1year');
%             obj.b_lt_ysixth_1_year = obj.sfill(0, 'HtM 1year');
            htm_dist = (obj.pmf(:) .* b_lt_ysixth(:)) ./ sum(obj.pmf(:) .* b_lt_ysixth(:), 'all');
            outflow = (speye(length(htm_dist)) - A_full' .* 4) \ htm_dist;
            obj.b_lt_ysixth_1_year = obj.sfill(sum(outflow .* b_lt_ysixth(:), 'all'), 'HtM 1year');

            disp('\nComputing trans_5year\n')
%             trans_5year = eye(size(obj.A')) + obj.A' .* 20;
%             trans_5year = expm(obj.A' .* 20);
%             rem_pmf_5year = trans_5year * (obj.pmf(:) .* b_lt_ysixth(:)) ./ sum(obj.pmf(:) .* b_lt_ysixth(:), 'all');
%             obj.b_lt_ysixth_5_year = obj.sfill(sum(rem_pmf_5year .* b_lt_ysixth(:)), 'HtM 5year');
%             obj.b_lt_ysixth_5_year = obj.sfill(0, 'HtM 5year');
            htm_dist = (obj.pmf(:) .* b_lt_ysixth(:)) ./ sum(obj.pmf(:) .* b_lt_ysixth(:), 'all');
            outflow = (speye(length(htm_dist)) - A_full' .* 20) \ htm_dist;
            obj.b_lt_ysixth_5_year = obj.sfill(sum(outflow .* b_lt_ysixth(:), 'all'), 'HtM 5year');
            
        end
        
        function compute_mobility_mats(obj)
            % Want to compute wealth state mobility for each quintile
            disp('\nComputing trans_quintile\n')
            
            % Full transition matrix (choices + income changes)
            inctrans = kron(obj.income.ytrans, speye(obj.p.nb_KFE*obj.p.na_KFE*obj.p.nz));
            A_full = obj.A + inctrans;
            
            % Time steps
            t_steps = linspace(0,60,61);
            
            
            % Liquid
            obj.mob_mat_b = zeros(5,5,5);
            
            % Get quintile cutoffs
            quints = [0.2, 0.4, 0.6, 0.8, 1.0];
            q_cuts = zeros(5,1);
            for i = 1:5
                q_cuts(i) = sum(cumsum(obj.pmf_b) <= quints(i));
            end
            
            % liquid fit to full grid
            b_full = repmat(obj.bgrid, [1 obj.na obj.nz obj.ny]);
            
            b_cond = zeros(5, length(obj.pmf(:)));
            for i = 1:5
                if i == 1 && (q_cuts(i) > 0)
                    % Make conditional pmfs for each quintile
                    b_temp = (b_full <= obj.bgrid(q_cuts(i)));
                    b_cond(i, :) = b_temp(:);
                elseif (i > 1) && (q_cuts(i-1) > 0)
                    b_temp = (b_full > obj.bgrid(q_cuts(i-1))) & (b_full <= obj.bgrid(q_cuts(i)));
                    b_cond(i, :) = b_temp(:);
                elseif (q_cuts(i) > 0)
                    b_temp = (b_full <= obj.bgrid(q_cuts(i)));
                    b_cond(i, :) = b_temp(:);
                end
            end
            
            for i = 1:5
                
                pmf_cond_i = obj.pmf(:) .* b_cond(i,:)';
                pmf_cond_i = pmf_cond_i / sum(pmf_cond_i, 'all');

                for t = 2:length(t_steps)
                    % Step forward (implicit method)
                    pmf_cond_i = (speye(length(obj.pmf(:))) - (t_steps(t) - t_steps(t-1)) .* A_full') \ pmf_cond_i;
                    
                    % Update mobilty entries if relevant time step
                    if t == 4 % 1 year
                        for j = 1:5
                            obj.mob_mat_b(i,j,1) = sum(pmf_cond_i(:) .* b_cond(j,:)', 'all');
                        end
                    elseif t == 2 
                        for j = 1:5
                            obj.mob_mat_b(i,j,2) = sum(pmf_cond_i(:) .* b_cond(j,:)', 'all');
                        end
                    elseif t == 20
                        for j = 1:5
                            obj.mob_mat_b(i,j,3) = sum(pmf_cond_i(:) .* b_cond(j,:)', 'all');
                        end
                    elseif t == 40
                        for j = 1:5
                            obj.mob_mat_b(i,j,4) = sum(pmf_cond_i(:) .* b_cond(j,:)', 'all');
                        end
                    elseif t == 60
                        for j = 1:5
                            obj.mob_mat_b(i,j,5) = sum(pmf_cond_i(:) .* b_cond(j,:)', 'all');
                        end
                    end
                end
            end
            
            % Illiquid
            obj.mob_mat_a = zeros(5,5,5);
            
            % Get quintile cutoffs
            quints = [0.2, 0.4, 0.6, 0.8, 1.0];
            q_cuts = zeros(5,1);
            for i = 1:5
                q_cuts(i) = sum(cumsum(obj.pmf_a) <= quints(i));
            end
            
            % illiquid fit to full grid
            a_full = repmat(obj.agrid', [obj.nb 1 obj.nz obj.ny]);
            
            a_cond = zeros(5, length(obj.pmf(:)));
            for i = 1:5
                if i == 1 && (q_cuts(i) > 0)
                    % Make conditional pmfs for each quintile
                    a_temp = (a_full <= obj.agrid(q_cuts(i)));
                    a_cond(i, :) = a_temp(:);
                elseif (i > 1) && (q_cuts(i-1) > 0)
                    a_temp = (a_full > obj.agrid(q_cuts(i-1))) & (a_full <= obj.agrid(q_cuts(i)));
                    a_cond(i, :) = a_temp(:);
                elseif (q_cuts(i) > 0)
                    a_temp = (a_full <= obj.agrid(q_cuts(i)));
                    a_cond(i, :) = a_temp(:);
                end
            end
            
            for i = 1:5
                
                pmf_cond_i = obj.pmf(:) .* a_cond(i,:)';
                pmf_cond_i = pmf_cond_i / sum(pmf_cond_i, 'all');

                for t = 2:length(t_steps)
                    % Step forward (implicit method)
                    pmf_cond_i = (speye(length(obj.pmf(:))) - (t_steps(t) - t_steps(t-1)) .* A_full') \ pmf_cond_i;
                    
                    % Update mobilty entries if relevant time step
                    if t == 4
                        for j = 1:5
                            obj.mob_mat_a(i,j,1) = sum(pmf_cond_i(:) .* a_cond(j,:)', 'all');
                        end
                    elseif t == 8
                        for j = 1:5
                            obj.mob_mat_a(i,j,2) = sum(pmf_cond_i(:) .* a_cond(j,:)', 'all');
                        end
                    elseif t == 20
                        for j = 1:5
                            obj.mob_mat_a(i,j,3) = sum(pmf_cond_i(:) .* a_cond(j,:)', 'all');
                        end
                    elseif t == 40
                        for j = 1:5
                            obj.mob_mat_a(i,j,4) = sum(pmf_cond_i(:) .* a_cond(j,:)', 'all');
                        end
                    elseif t == 60
                        for j = 1:5
                            obj.mob_mat_a(i,j,5) = sum(pmf_cond_i(:) .* a_cond(j,:)', 'all');
                        end
                    end
                end
            end
            
            % Total
            obj.mob_mat_w = zeros(5,5,5);
            
            % total wealth full grid
            w_full = b_full + a_full;
            
            % Get quintile cutoffs
            quints = [0.2, 0.4, 0.6, 0.8, 1.0];
            q_vals = zeros(5,1);
            
            % cdf of totw
            [w_vec, sortid_w] = sort(w_full(:), 'ascend');
            pmf_vec = obj.pmf(sortid_w);
            
            
            for i = 1:5
%                 q_vals(i) = sum(cumsum(obj.pmf_a) <= quints(i));
                % find cutoff for pmf_vec
                ind = sum(cumsum(pmf_vec) <= quints(i));
                % use to find wealth cutoff value
                if ind > 0
                    q_vals(i) = w_vec(ind);
                end
            end
            
            
            w_cond = zeros(5, length(obj.pmf(:)));
            for i = 1:5
                if i == 1 && (q_vals(i) > 0)
                    % Make conditional pmfs for each quintile
                    w_cond(i, :) = (w_full(:) <= q_vals(i));
                elseif (i > 1) && (q_vals(i-1) > 0)
                    w_cond(i, :) = (w_full(:) > q_vals(i-1)) & (w_full(:) <= q_vals(i));
                elseif (q_vals(i) > 0)
                    w_cond(i, :) = (w_full(:) <= q_vals(i));
                end
            end
            
            for i = 1:5
                
                pmf_cond_i = obj.pmf(:) .* w_cond(i,:)';
                pmf_cond_i = pmf_cond_i / sum(pmf_cond_i, 'all');

                for t = 2:length(t_steps)
                    % Step forward (implicit method)
                    pmf_cond_i = (speye(length(obj.pmf(:))) - (t_steps(t) - t_steps(t-1)) .* A_full') \ pmf_cond_i;
                    
                    % Update mobilty entries if relevant time step
                    if t == 4
                        for j = 1:5
                            obj.mob_mat_w(i,j,1) = sum(pmf_cond_i(:) .* w_cond(j,:)', 'all');
                        end
                    elseif t == 8
                        for j = 1:5
                            obj.mob_mat_w(i,j,2) = sum(pmf_cond_i(:) .* w_cond(j,:)', 'all');
                        end
                    elseif t == 20
                        for j = 1:5
                            obj.mob_mat_w(i,j,3) = sum(pmf_cond_i(:) .* w_cond(j,:)', 'all');
                        end
                    elseif t == 40
                        for j = 1:5
                            obj.mob_mat_w(i,j,4) = sum(pmf_cond_i(:) .* w_cond(j,:)', 'all');
                        end
                    elseif t == 60
                        for j = 1:5
                            obj.mob_mat_w(i,j,5) = sum(pmf_cond_i(:) .* w_cond(j,:)', 'all');
                        end
                    end
                end
            end
            
            
        end
        
        function compute_mpc_apc_corr(obj)
            mpcs = reshape(obj.mpcs_over_ss{5}, [obj.nb obj.na obj.nz obj.ny]);
            cov_mpc_apc = sum(obj.pmf .* obj.apc .* mpcs, 'all') - sum(obj.pmf .* obj.apc, 'all')*sum(obj.pmf .* mpcs, 'all');
            var_mpc = sum(obj.pmf .* mpcs.^2, 'all') - sum(obj.pmf .* mpcs, 'all')^2;
            var_apc = sum(obj.pmf .* obj.apc.^2, 'all') - sum(obj.pmf .* obj.apc, 'all')^2;
            
            obj.mpc_apc_corr = obj.sfill(cov_mpc_apc/(var_mpc^0.5 * var_apc^0.5), 'MPC APC Corr');
        end
        
        function compute_b_a_corr(obj)
            [bg, ag] = ndgrid(obj.bgrid, obj.agrid);
            pmf_ba = sum(obj.pmf, [3 4]);
            
            cov_b_a = sum(pmf_ba .* bg .* ag, 'all') - sum(pmf_ba .* bg, 'all')*sum(pmf_ba .* ag, 'all');
            var_b = sum(pmf_ba .* bg.^2, 'all') - sum(pmf_ba .* bg, 'all')^2;
            var_a = sum(pmf_ba .* ag.^2, 'all') - sum(pmf_ba .* ag, 'all')^2;
            
            obj.b_a_corr = obj.sfill(cov_b_a / (var_b^0.5 * var_a^0.5), 'Liquid-Illiquid Corr');
        end
        
        % Income weighted MPC
        function compute_mpc_income_wgt(obj)
            mpcs = reshape(obj.mpcs_over_ss{5}, [obj.nb obj.na obj.nz obj.ny]);
            num = sum(obj.income.y.wide .* obj.pmf .* mpcs, 'all');
            denom = sum(obj.income.y.wide .* obj.pmf, 'all');
            
            obj.mpc_income_wgt = obj.sfill(num / denom, 'MPC (Income Weighted)');
        end
        
        % Income weighted MPC, where each gets 1% shock
        function compute_mpc_income_wgt_perc(obj)
            mpcs = reshape(obj.mpcs_over_ss{7}, [obj.nb obj.na obj.nz obj.ny]);
            num = sum(obj.income.y.wide .* obj.pmf .* mpcs, 'all');
            denom = sum(obj.income.y.wide .* obj.pmf, 'all');
            
            obj.mpc_income_wgt_perc = obj.sfill(num / denom, 'MPC (Income Weighted, 1% shock)');
        end
        
        
        
        function compute_mpc_w(obj)
            % Get MPCs
            mpcs = reshape(obj.mpcs_over_ss{5}, [obj.nb obj.na obj.nz obj.ny]);
            [bg, ag] = ndgrid(obj.bgrid, obj.agrid);
            % interpolate pmf and mpcs
            % Get pmf over (b,a)
            pmf_ba = sum(obj.pmf,[3 4]);
            obj.pmf_int = griddedInterpolant(bg, ag, pmf_ba,'linear','none');
            % get MPCs over (b,a)
            % (convert decimal to % by doing *100)
            mpc_ba = sum(mpcs .* obj.pmf, [3 4]) ./ pmf_ba .* 100;
            obj.mpc_int = griddedInterpolant(bg, ag, mpc_ba,'linear','none');
            
            % Get at mean wealth (need to make into percent to match other
            % stats?)
            
            obj.mpc_wmean = obj.sfill(obj.mpc_wealth_mean(4.11), 'Mean MPC at Mean Wealth (%)');
            
%             wmean = 4.11;
%             bs = linspace(0, wmean, 100);
%             as = wmean - bs;
%             mpc_wmean = sum(obj.mpc_int(bs,as) .* obj.pmf_int(bs,as), 'all') / sum(obj.pmf_int(bs,as), 'all');
%             obj.mpc_wmean = obj.sfill(mpc_wmean, 'Mean MPC at Mean Wealth (%)');
        end
        
        function mpc_wq = mpc_wealth_quantile(obj,w,q)
            bs = linspace(0,w,100);
            as = w - bs;
            pmfs = obj.pmf_int(bs, as);
            pmfs = pmfs ./ sum(pmfs,'all');
            mpcs = obj.mpc_int(bs, as);

            cdf_int = aux.pctile_interpolant(mpcs, pmfs);

            mpc_wq = cdf_int(q);
        end
        
        % Need to write function for mean at w also
        function mpc_w = mpc_wealth_mean(obj,w)
            bs = linspace(0,w,100);
            as = w - bs;
            pmfs = obj.pmf_int(bs, as);
            pmfs = pmfs ./ sum(pmfs,'all');
            mpcs = obj.mpc_int(bs, as);

            mpc_w = sum(mpcs .* pmfs, 'all');
        end
        
        
        
        

		function add_params(obj)
			obj.params.group_num = obj.sfill(obj.p.group_num,...
				'Experiment group no.');
			obj.params.bmax = obj.sfill(obj.p.bmax,...
				'Max liquid assets, parameter');
			obj.params.amax = obj.sfill(obj.p.amax,...
				'Max illiquid assets, parameter', 2);
			obj.params.bequests = obj.sfill(obj.p.Bequests,...
				'Bequests, on or off');
			obj.params.deathrate = obj.sfill(obj.p.deathrate,...
				'Death rate (quarterly)');
			obj.params.r_b = obj.sfill(obj.p.r_b,...
				'Liquid asset return (quarterly)');
			obj.params.r_a = obj.sfill(obj.p.r_a,...
				'Illiquid asset return (quarterly)', 2);
			obj.params.borrowlim = obj.sfill(obj.p.bmin,...
				'Borrowing limit');
			obj.params.riskaver = obj.sfill(obj.p.riskaver,...
				'CRRA coefficient');
			obj.params.numeraire = obj.sfill(obj.p.numeraire_in_dollars,...
				'Value of the numeraire, mean annual earning, in $');
			obj.params.income_descr = obj.sfill(obj.p.IncomeDescr,...
				'Income Process');
		end

		function clean(obj)
			obj.p = [];
			obj.income = [];
			obj.model = [];
			obj.wealthmat = [];
			obj.wealth_sorted = [];
			obj.pmf_w = [];
		end
	end

	methods (Access=protected)
		function compute_intro_stats(obj)
			obj.rho = obj.sfill(obj.p.rho, 'rho');
		    obj.beta_Q = obj.sfill(exp(-obj.p.rho), 'beta (quarterly)');
		    obj.beta_A = obj.sfill(exp(-4 * obj.p.rho), 'beta (annualized)');
		    obj.beta_A_effective = obj.sfill(exp(-4 * obj.p.rho - 4 * obj.p.deathrate),...
		    	'Effective discount rate');
            
            obj.beta_IG = obj.sfill(obj.p.beta, 'beta_IG');

		    tmp = obj.expectation(shiftdim(obj.agrid, -1));
		    obj.illiqw = obj.sfill(tmp, 'Mean illiquid wealth', 2);

		    tmp = obj.expectation(obj.bgrid);
		    obj.liqw = obj.sfill(tmp, 'Mean liquid wealth');

		    tmp = obj.expectation(...
		    	obj.bgrid + shiftdim(obj.agrid, -1));
		    obj.totw = obj.sfill(tmp, 'Mean total wealth', 2);

		    obj.diff_mean = obj.sfill(obj.totw.value - obj.liqw.value, 'NA', 2);

		    tmp = obj.expectation(obj.model.s==0);
		    obj.sav0 = obj.sfill(tmp, 's = 0');

		    obj.mean_gross_y_annual = obj.sfill(NaN, 'Mean gross annual income');
			obj.std_log_gross_y_annual = obj.sfill(NaN, 'Stdev log gross annual income');
			obj.std_log_net_y_annual = obj.sfill(NaN, 'Stdev log net annual income');
		end

		function construct_distributions(obj)
			import aux.multi_sum

		    [obj.pmf_b, obj.cdf_b] = obj.marginal_dists(1);
		    [obj.pmf_a, obj.cdf_a] = obj.marginal_dists(2);
		    obj.pmf_w = obj.marginal_dists([1, 2]);
		    obj.pmf_b_a = multi_sum(obj.pmf, [3, 4]);
		end

		function out = expectation(obj, vals)
			import aux.repmat_auto
			if numel(vals(:)) == numel(obj.pmf(:))
				out = dot(obj.pmf(:), vals(:));
			else
				tmp = repmat_auto(vals, size(obj.pmf));
				out = dot(obj.pmf(:), tmp(:));
			end
		end

		function [pmf_x, cdf_x] = marginal_dists(obj, dims)
			import aux.multi_sum

			sum_dims = 1:4;
			sum_dims = sum_dims(~ismember(sum_dims, dims));

			flatten = true;
			pmf_x = multi_sum(obj.pmf, sum_dims, flatten);
			cdf_x = cumsum(pmf_x);
		end
	end

	methods (Static)
		function out = sfill(value, label, asset_indicator)
			% 0 - both assets
			% 1 asset only
			% 2 asset only

			if nargin < 3
				asset_indicator = 0;
			end

			out = struct(...
				'value', value,...
				'label', label,...
				'indicator', asset_indicator...
			);
		end

		function out = empty_stat(varargin)
			out = statistics.Statistics.sfill(NaN, varargin{:});
		end
	end
end