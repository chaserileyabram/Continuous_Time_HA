function [outparams, n] = overall_htm_target(param_opts)
	import params.scf2019struct
    
    scf = scf2019struct();

	shocks = [-1, -500, -5000, 1, 500, 5000];

    shared_params = param_opts;
    shared_params.mpc_shocks = shocks / (scf.quarterly_earnings * 4);
    shared_params.numeraire_in_dollars = (scf.quarterly_earnings * 4);
    shared_params.no_transitory_incrisk = false;
    shared_params.Bequests = false;
    shared_params.r_b = 0.01 / 4;

    anninc = shared_params.numeraire_in_dollars;
    shared_params.a_lb = 500 / anninc;
    
    incomedirs = {'continuous_a/no_measurement_error',...
        'continuous_b/no_measurement_error',...
        'continuous_a/measurement_error_20pc',...
        'continuous_a/measurement_error_33pc',...
        'continuous_a/measurement_error_50pc'};

    IncomeDescriptions = {'cont_a, no meas err',...
        'cont_b, no meas err',...
        'cont_a, meas err 20pc',...
        'cont_a, meas err 33pc',...
        'cont_a, meas err 50pc'};

    experiment = false;
    if experiment
        iy = 2;
        params = shared_params;
        
%         params.calibration_vars = {'rho', 'r_a'};
%         params.calibration_vars = {'rho'};
        params.calibration_vars = {'rho', 'r_a'};
        
        params.calibration_stats = {'totw', 'median_liqw'};
%         params.calibration_stats = {'totw'};
        
        params.calibration_targets = [4.1, 0.05];
%         params.calibration_targets = [4.1];
        
        params.calibration_scales = [1, 100];
%         params.calibration_scales = [1];
        
        params.income_dir = incomedirs{iy};
        params.IncomeDescr = IncomeDescriptions{iy};
        param_opts.param_index = 1;

        % Test with this at "infinity" (not not actually else issues?)
        % params.kappa1 = 2;
        params.kappa0 = 1e10;
        params.kappa1 = 1e10;
        params.kappa2 = 0.5;
        
        params.r_b = 0.01/4;
        r_b_bds = [-0.01/4, 0.02];
        

        % params.sd_r = 0.01;
        params.SDU = false;
        % params.invies = 1 / 1.5;
        % params.riskaver = 2;
        % params.kappa1 = 0.1;
        
        params.rebalance_rate = 0.25;
        params.rebalance_cost = 0.07;
%         params.rebalance_cost = 0.0014;
        
%         Computing statistics
%           -- function evaluation 48 --
%             evaluated at: rho = 0.00110607, r_a = 0.0281286
%             target variables: totw = 4.27785, median_liqw = 0.170954
%             norm: 12.096750

        params.rho = 0.0125;
        rho_bds = [-0.0045, 0.03];
        
        params.r_a = 0.0199;
        r_a_bds = [0.01/4, 0.05];
        params.KFE_maxiters = 1e6;

        % Set calibrator
        params.calibration_bounds = {rho_bds, r_b_bds};
%         params.calibration_bounds = {rho_bds};
        params.calibration_backup_x0 = {};
        params.calibration_crit = 1e-8;

        params = {params};
    else
        params = {};

        %% TARGET MEDIAN TOTAL WEALTH AND MEDIAN LIQUID WEALTH
        % Iterate over r_a, rho
        median_calibration = shared_params;
        % median_calibration.calibration_vars = {'rho', 'r_a'};
        median_calibration.calibration_vars = {'rho', 'r_b', 'r_a', 'rebalance_cost'};

        % kappa_1s = [0.2:0.2:1, 1.5:0.5:5];
        % kappa_2s = [0.25, 0.5, 1.0, 1.5];
        

        calibrations = {median_calibration};
        
        % Decent calibration to use as baseline
%         Computing statistics
%           -- function evaluation 170 --
%             evaluated at: rho = 0.012006, r_b = -0.00109423, r_a = 0.0187754, rebalance_cost = 0.0148001
%             target variables: totw = 4.13288, liqw = 0.591865, w_lt_ysixth = 0.233114, liqw_lt_ysixth = 0.394206
%             norm: 0.099679
        
        
        
        % Various discount rates
        rhos = [0.0112, 0.0114, 0.0116, 0.0118, 0.012, 0.0122, 0.0124, 0.0126, 0.0128 0.013];
        
        
        % Various liquid rates
        % r_bs = [-0.05, -0.04, -0.03, -0.02, -0.01, 0.0, 0.01, 0.02]/4;
        % r_bs = [-0.06, -0.05, -0.04, -0.03, -0.02, -0.01, 0.0]/4;
        % r_bs = [-0.03, -0.02, -0.01, 0.0, 0.01]/4;
        r_bs = [-0.010, -0.007, -0.003, 0, 0.003, 0.007]/4;
        
        % Various illiquid rates
        % r_as = [0.0, 0.01, 0.02, 0.03]/4;
        r_as = [0.07, 0.075, 0.08, 0.085, 0.09]/4;
        
        
        % Various adjustment costs
        % reb_costs = [100, 200, 500, 1000, 5000, 10000]/anninc;
        % reb_costs = [100, 200, 500, 1000, 5000]/anninc;
        % reb_costs = [100, 300, 700, 1000, 2000]/anninc;
        reb_costs = [150, 200, 250, 300, 350]/anninc;
        
        % Various rebalance arrival rates
        % reb_rates = [0.05, 0.125, 0.25, 1, 3];
        % reb_rates = [0.05, 0.125, 0.25, 1];
        reb_rates = [0.25];
        
        % IG
        betas = [1.0]^(0.25);
        
        
        % Calibration stats to use
        % cal_stats = {{'totw', 'liqw'}, {'totw', 'median_liqw'}};
        cal_stats = {{'totw', 'liqw', 'w_lt_ysixth', 'liqw_lt_ysixth'}};
        
        % Calibration targets to use
        % cal_targets = {[scf.mean_totw, scf.mean_liqw], [scf.mean_totw, scf.median_liqw]};
        cal_targets = {[scf.mean_totw, scf.mean_liqw, scf.phtm, scf.htm]};
        
        

        ii = 1;
        group_num = 0;
        for icalibration = [1]
            % for kappa2 = kappa_2s
            for cal_i = 1:1
                for iy = 1:1
                    for rho = rhos
                        for r_b = r_bs
                            for r_a = r_as
                                group_num = group_num + 1;
        %                         for kappa1 = kappa_1s
                                for reb_cost = reb_costs 
                                    for reb_rate = reb_rates
                                        for beta = betas
                                            params = [params {calibrations{icalibration}}];
                                            % params{ii}.name = sprintf('iy=%d, kappa2=%g', iy, kappa2);

                                            % params{ii}.kappa2 = kappa2;


                                            params{ii}.income_dir = incomedirs{iy};
                                            params{ii}.IncomeDescr = IncomeDescriptions{iy};
                                            params{ii}.group_num = group_num;

                                            if params{ii}.no_transitory_incrisk
                                                % params{ii}.rho = 0.001;
                                                % params{ii}.r_a = 0.0052;
                                                % params{ii}.calibration_bounds = {[0.0008, 0.003],...
                                                % [shared_params.r_b + 0.0003, 0.009]};
                                                % params{ii}.calibration_backup_x0 = {};
                                            else
                                                % disp('indicator 1 in overal_htm_target')
                                                % params{ii}.kappa1 = kappa1;

                                                params{ii}.kappa0 = 1e10;
                                                params{ii}.kappa1 = 1e10;

                                                % params{ii}.OneAsset = true;

                                                

                                                % params{ii}.rho = 0.005;
                                                params{ii}.rho = rho;
                                                % rho_bds = [0.0005, 0.03];
                                                rho_bds = [-0.0045, 0.03];
                                                
                                                params{ii}.r_b = r_b;
                                                r_b_bds = [-0.01, 0.02];


                                                params{ii}.r_a = r_a;
                %                                 params{ii}.r_a = r_a;
                                                % r_a_bds = [0.008, 0.02];
                                                r_a_bds = [0.005, 0.05];

                                                % Rebalance cost
                                                params{ii}.rebalance_cost = reb_cost;
                                                reb_cost_bds = [1,10000]/anninc;

                                                % Rebalancing rate
                                                params{ii}.rebalance_rate = reb_rate;

                                                % IG
                                                params{ii}.beta = beta;

                                                params{ii}.KFE_maxiters = 1e6;
                                                % params{ii}.a_lb = 0.3;

                                                % params{ii}.rho = mean(rho_bds);
                                                % params{ii}.r_a = mean(r_a_bds);

                                                % Set calibrator
                                                % params{ii}.calibration_bounds = {rho_bds, r_a_bds};
                                                params{ii}.calibration_bounds = {rho_bds, r_b_bds, r_a_bds, reb_cost_bds};
                                                params{ii}.calibration_backup_x0 = {};
                                            end
                                            % params{ii}.calibration_stats = {'diff_median', 'median_liqw'};
                                            % params{ii}.calibration_targets = [1.49, 0.05];
                                            % params{ii}.calibration_scales = [1, 10];

                                            % params{ii}.calibration_stats = {'diff_mean', 'liqw'};
                                            % params{ii}.calibration_targets = [4.1-0.56, 0.56];
                                            % params{ii}.calibration_stats = {'totw', 'median_liqw'};
                                            params{ii}.calibration_stats = cal_stats{1, cal_i};

                                            % params{ii}.calibration_targets = [scf.mean_totw, scf.median_liqw];
                                            params{ii}.calibration_targets = cal_targets{1, cal_i};

                                            % params{ii}.calibration_scales = [100, 100];
                                            params{ii}.calibration_scales = [1, 1, 1, 1]; % Scales deviation for calibration

                                            params{ii}.calibration_crit = 1e-8;

                                            if cal_i == 1
                                                params{ii}.name = sprintf('cal= (mean total=%d, mean liquid=%d), r_b=%d',params{ii}.calibration_targets(1), params{ii}.calibration_targets(2), params{ii}.r_b);
                                            else
                                                params{ii}.name = sprintf('cal= (mean total=%d, median liquid=%d), r_b=%d, reb_cost=%d, reb_rate=%d',params{ii}.calibration_targets(1), params{ii}.calibration_targets(2), params{ii}.r_b, reb_cost, reb_rate);
                                            end

                                            ii = ii + 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    %% DO NOT CHANGE THIS SECTION
    n = numel(params);
    outparams = params{param_opts.param_index};
end