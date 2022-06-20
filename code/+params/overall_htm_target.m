function [outparams, n] = overall_htm_target(param_opts)
	import params.scf2019struct
    
    scf = scf2019struct();

	shocks = [-1, -500, -5000, 1, 500, 5000, 10000, 999];

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
        
        % Note: the first calibration will be the baseline
        
        
        % Iterate over r_a, rho
        median_calibration = shared_params;
        
        
        % median_calibration.calibration_vars = {'rho', 'r_a'};
        % median_calibration.calibration_vars = {'rho'};
        % median_calibration.calibration_vars = {'rho', 'r_b'};
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
        % rhos = [0.011, 0.0115, 0.012, 0.0125, 0.013];
        % rhos = [-0.002];
        % rhos = [0.012006];
        % rhos = [0.013842];
        % rhos = linspace(0.012006 * 0.7, 0.012006 * 1.3, 3);
        % rhos = [0.01063]; % 6-8-1 Spec 60
        rhos = [0.01322162677, 0.01138778959]; % Specs 74 and 88, from 6-8-21
        
        
        % Various liquid rates
        % r_bs = [-0.05, -0.04, -0.03, -0.02, -0.01, 0.0, 0.01, 0.02]/4;
        % r_bs = [-0.06, -0.05, -0.04, -0.03, -0.02, -0.01, 0.0]/4;
        % r_bs = [-0.03, -0.02, -0.01, 0.0, 0.01]/4;
        % r_bs = [-0.010, -0.007, -0.003, 0, 0.003]/4;
        % r_bs = [0.01]/4;
        % r_bs = [-0.00109423];
        % r_bs = linspace(-0.00109423 * 0.7, -0.00109423 * 1.3, 3);
        % r_bs = [-0.007105843]; % 6-8-1 Spec 60
        r_bs = [-0.007436693, -0.007406406]; % Specs 74 and 88, from 6-8-21
        
        % Various illiquid rates
        % r_as = [0.0, 0.01, 0.02, 0.03]/4;
        % r_as = [0.07, 0.075, 0.08, 0.085]/4;
        % r_as = [0.0187754];
        % r_as = linspace(0.0187754 * 0.7, 0.0187754 * 1.3, 3);
        % r_as = [0.015331601]; % 6-8-1 Spec 60
        r_as = [0.018163944, 0.01616938]; % Specs 74 and 88, from 6-8-21
        
        
        % Various adjustment costs
        % reb_costs = [100, 200, 500, 1000, 5000, 10000]/anninc;
        % reb_costs = [100, 200, 500, 1000, 5000]/anninc;
        % reb_costs = [100, 300, 700, 1000, 2000]/anninc;
        % reb_costs = [900, 950, 1000, 1050, 1100]/anninc;
        % reb_costs = [0.0148001];
        % reb_costs = linspace(0.0148001 * 0.2, 0.0148001 * 5, 33);
        % reb_costs = [1e10]; % For 1-asset
        % reb_costs = [471.1954266]./anninc; % 6-8-1 Spec 60
        % reb_costs = linspace(471.1954266 * 0.2, 471.1954266 * 5, 33)./anninc;
        reb_costs = [346.65226, 471.9471509]./anninc;
        
        % Various rebalance arrival rates
        % reb_rates = [0.05, 0.125, 0.25, 1, 3];
        % reb_rates = [0.05, 0.125, 0.25, 1];
        % reb_rates = [0.25];
        % reb_rates = [0];
        % reb_rates = linspace(0.25 * 0.0, 0.25 * 20, 100);
        reb_rates = [0.25, 1.0, 3.0];
        
        % IG
        % betas = [1.0, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99, 1.01, 1.05, 1.1, 1.5].^(0.25);
        betas = [1.0].^(0.25);
        
        
        % Calibration stats to use
        % cal_stats = {{'totw'}};
        % cal_stats = {{'totw', 'median_totw'}};
        % cal_stats = {{'totw', 'liqw'}, {'totw', 'median_liqw'}};
        % cal_stats = {{'totw', 'liqw_lt_ysixth'}};
        % cal_stats = {{'totw', 'liqw', 'w_lt_ysixth', 'liqw_lt_ysixth'}}; % Mean
        cal_stats = {{'totw', 'median_liqw', 'w_lt_ysixth', 'liqw_lt_ysixth'}}; % Median liquid
        
        % Calibration targets to use
        % cal_targets = {[scf.mean_totw]};
        % cal_targets = {[scf.mean_totw, scf.median_totw]};
        % cal_targets = {[scf.mean_totw, scf.mean_liqw], [scf.mean_totw, scf.median_liqw]};
        % cal_targets = {[scf.mean_liqw, scf.htm]};
        % cal_targets = {[scf.mean_totw, scf.mean_liqw, scf.phtm, scf.htm]}; % Mean
        cal_targets = {[scf.mean_totw, scf.median_liqw, scf.phtm, scf.htm]}; % Median liquid
        
        % Steps
        HJB_deltas = [1e3, 1e4, 1e5, 1e6];
        

%         ii = 1;
%         group_num = 0;
%         for icalibration = [1]
%             % for kappa2 = kappa_2s
%             for HJB_delta = HJB_deltas
%                 for cal_i = 1:1
%                     for iy = 1:1
%                         for rho = rhos
%                             for r_b = r_bs
%                                 for r_a = r_as
%                                     group_num = group_num + 1;
%             %                         for kappa1 = kappa_1s
%                                     for reb_cost = reb_costs 
%                                         for reb_rate = reb_rates
%                                             for beta = betas
%                                                 params = [params {calibrations{icalibration}}];
%                                                 % params{ii}.name = sprintf('iy=%d, kappa2=%g', iy, kappa2);
% 
%                                                 % params{ii}.kappa2 = kappa2;
%                                                 params{ii}.HJB_delta = HJB_delta;
% 
%                                                 params{ii}.income_dir = incomedirs{iy};
%                                                 params{ii}.IncomeDescr = IncomeDescriptions{iy};
%                                                 params{ii}.group_num = group_num;
% 
%                                                 if params{ii}.no_transitory_incrisk
%                                                     % params{ii}.rho = 0.001;
%                                                     % params{ii}.r_a = 0.0052;
%                                                     % params{ii}.calibration_bounds = {[0.0008, 0.003],...
%                                                     % [shared_params.r_b + 0.0003, 0.009]};
%                                                     % params{ii}.calibration_backup_x0 = {};
%                                                 else
%                                                     % disp('indicator 1 in overal_htm_target')
%                                                     % params{ii}.kappa1 = kappa1;
% 
%                                                     params{ii}.kappa0 = 1e10;
%                                                     params{ii}.kappa1 = 1e10;
% 
%                                                     % params{ii}.OneAsset = true;
% 
% 
% 
%                                                     % params{ii}.rho = 0.005;
%                                                     params{ii}.rho = rho;
%                                                     % rho_bds = [0.0005, 0.03];
%                                                     rho_bds = [-0.0045, 0.03];
% 
%                                                     params{ii}.r_b = r_b;
%                                                     r_b_bds = [-0.01, 0.02];
% 
% 
%                                                     params{ii}.r_a = r_a;
%                     %                                 params{ii}.r_a = r_a;
%                                                     % r_a_bds = [0.008, 0.02];
%                                                     r_a_bds = [0.005, 0.05];
% 
%                                                     % Rebalance cost
%                                                     params{ii}.rebalance_cost = reb_cost;
%                                                     reb_cost_bds = [1,10000]/anninc;
% 
%                                                     % Rebalancing rate
%                                                     params{ii}.rebalance_rate = reb_rate;
% 
%                                                     % IG
%                                                     params{ii}.beta = beta;
% 
%                                                     params{ii}.KFE_maxiters = 1e6;
%                                                     % params{ii}.a_lb = 0.3;
% 
%                                                     % params{ii}.rho = mean(rho_bds);
%                                                     % params{ii}.r_a = mean(r_a_bds);
% 
%                                                     % Set calibrator
%                                                     % params{ii}.calibration_bounds = {rho_bds};
%                                                     % params{ii}.calibration_bounds = {rho_bds, r_b_bds};
%                                                     params{ii}.calibration_bounds = {rho_bds, r_b_bds, r_a_bds, reb_cost_bds};
%                                                     params{ii}.calibration_backup_x0 = {};
%                                                 end
%                                                 % params{ii}.calibration_stats = {'diff_median', 'median_liqw'};
%                                                 % params{ii}.calibration_targets = [1.49, 0.05];
%                                                 % params{ii}.calibration_scales = [1, 10];
% 
%                                                 % params{ii}.calibration_stats = {'diff_mean', 'liqw'};
%                                                 % params{ii}.calibration_targets = [4.1-0.56, 0.56];
%                                                 % params{ii}.calibration_stats = {'totw', 'median_liqw'};
%                                                 params{ii}.calibration_stats = cal_stats{1, cal_i};
% 
%                                                 % params{ii}.calibration_targets = [scf.mean_totw, scf.median_liqw];
%                                                 params{ii}.calibration_targets = cal_targets{1, cal_i};
% 
%                                                 % params{ii}.calibration_scales = [100, 100];
%                                                 params{ii}.calibration_scales = [1, 1, 1, 1]; % Scales deviation for calibration
%                                                 % params{ii}.calibration_scales = [1];
% 
%                                                 params{ii}.calibration_crit = 1e-8;
% 
%                                                 % params{ii}.name = sprintf('IG beta: %d', params{ii}.beta);
%                                                 params{ii}.name = sprintf('HJB delta: %d', params{ii}.HJB_delta);
%     %                                             if cal_i == 1
%     %                                                 params{ii}.name = sprintf('cal= (mean total=%d, mean liquid=%d), r_b=%d',params{ii}.calibration_targets(1), params{ii}.calibration_targets(2), params{ii}.r_b);
%     %                                             else
%     %                                                 params{ii}.name = sprintf('cal= (mean total=%d, median liquid=%d), r_b=%d, reb_cost=%d, reb_rate=%d',params{ii}.calibration_targets(1), params{ii}.calibration_targets(2), params{ii}.r_b, reb_cost, reb_rate);
%     %                                             end
% 
%                                                 ii = ii + 1;
%                                             end
%                                         end
%                                     end
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%         end
        
        % temp change to not override new run
        ii = 0;
        % Manually set the params (so not just all permutations)
        
        % 2A Baseline (Spec 3, 6_24_21)
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii}.calibration_vars = {'rho'};
%         params{ii}.HJB_delta = 1e3;
%         % Income
%         params{ii}.income_dir = incomedirs{1};
%         params{ii}.IncomeDescr = IncomeDescriptions{1};
%         % Flow costs
%         params{ii}.kappa0 = 1e10;
%         params{ii}.kappa1 = 1e10;
%         % Calibrated
%         params{ii}.rho = 0.01295; 
%         rho_bds = [-0.45, 0.03];
%         params{ii}.r_b = -0.006421023; 
%         params{ii}.r_a = 0.017442897;
%         params{ii}.rebalance_cost = 516.9930144/anninc;
%         params{ii}.rebalance_rate = 1.0;
%         params{ii}.calibration_bounds = {rho_bds};
%         params{ii}.calibration_stats = {'totw'};
%         params{ii}.calibration_targets = [scf.mean_totw];
%         params{ii}.calibration_scales = [1];
%         if param_opts.ComputeMPCS_news
%             params{ii}.name = sprintf('Baseline 2A (with news)');
%         else
%             params{ii}.name = sprintf('Baseline 2A');
%         end
        
        % 2A Baseline (Spec 3, 9_1_21)
        
%         for reb_cost = reb_costs
            % Baseline (new)
            ii = ii + 1;
            params = [params {calibrations{1}}];
            
            params{ii}.HJB_delta = 1e3;
            % Income
            params{ii}.income_dir = incomedirs{1};
            params{ii}.IncomeDescr = IncomeDescriptions{1};
            % Flow costs
            params{ii}.kappa0 = 1e10;
            params{ii}.kappa1 = 1e10;
            % Calibrated
            params{ii}.rho = 0.0114; %0.01214; %0.01295; 
            rho_bds = [-0.45, 0.03];
%             rho_bds = [-2.0, 2.0];
    %         params{ii}.r_b = -0.006421023; 
            params{ii}.r_b = -0.005;
            params{ii}.r_a = 0.0156; %0.016340226; %0.01563035; %0.017442897;
            r_a_bds = [0, 0.04];
%             params{ii}.rebalance_cost = 516.9930144/anninc;
            params{ii}.rebalance_cost = 0.0217; %reb_cost; %1453.906838; % Was used before changes Feb 16, 2022
            reb_cost_bds = [200, 3000]/anninc;
    %         params{ii}.rebalance_rate = 1.0;
            params{ii}.rebalance_rate = 3.0;

%             params{ii}.rebalance_rate = 0.0;
            
            % Add temptation
%             params{ii}.temptation = 0.01;
            params{ii}.calibration_vars = {'rho'};
            params{ii}.calibration_bounds = {rho_bds};
            params{ii}.calibration_stats = {'totw'};
            params{ii}.calibration_targets = [scf.mean_totw];
            params{ii}.calibration_scales = [1];
            if param_opts.ComputeMPCS_news
                params{ii}.name = sprintf('Baseline 2A (with news)');
            else
                params{ii}.name = sprintf('Baseline 2A (fixed 9-14)');
            end
            
            x0 = [0.9 * params{1}.rho 1.1 * params{1}.rho];
            
            params{ii}.perc_shock = true;
%             params{ii}.na = 2;
%             params{ii}.rebalance_cost = 1e6;
%             params{ii}.rebalance_rate = 0.0;
            
            
            
            rhos = [linspace(-0.5, -0.02, 3) params{1}.rho linspace(-0.02, 0.02, 3) linspace(0.05, 1.0, 4)];
            rhos = [0 0.004 0.008 params{1}.rho];
            
            % Temptation robustness (try different rho starts)
%             tempts = [0.01, linspace(0.05,0.5,10)];
%             for type = ["totw", "liqw"]
%                 for tempt = tempts
%                     for rho = rhos
%                         ii = ii + 1;
%                         params = [params {calibrations{1}}];
%                         params{ii} = params{1};
%                         params{ii}.rho = rho;
%                         params{ii}.temptation = tempt;
%                         params{ii}.tempt_type = type;
%                         params{ii}.name = sprintf('Temptation = %d, type=%s, rho = %d', tempt, type, rho);
%                     end
%                 end
%             end
            
            
            % Variety of CRRAs
%             crras = linspace(exp(-3), exp(3), 5);
%             crras = [10];
%             for crra = crras
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.rho = rho;
%                     params{ii}.riskaver = crra;
%                     params{ii}.name = sprintf('CRRA = %d, rho = %d', crra, rho);
%                 end
%             end
            
            
            % Temptation: try calibrating r_a and reb_cost with 
%             for tempt = [0.01 0.05 0.1]
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.rho = rho;
%                     params{ii}.temptation = tempt;
%                     params{ii}.calibration_vars = {'rho', 'r_a', 'rebalance_cost'};
%                     params{ii}.calibration_stats = {'totw', 'w_lt_ysixth', 'liqw_lt_ysixth'};
%                     params{ii}.calibration_targets = [scf.mean_totw, scf.htm, scf.phtm];
%                     params{ii}.calibration_scales = [1, 1, 1];
%                     r_a_bounds = [0, 0.126];
%                     reb_bounds = [400/anninc, 600/anninc];
%                     params{ii}.calibration_bounds = {rho_bds, r_a_bounds, reb_bounds};
%                     params{ii}.name = sprintf('3cal Temptation = %d, rho = %d', tempt, rho);
%                 end
%             end
            
            % SDU
%             rras = [0.5, 1.001, 8];
%             iess = [0.25, 1.001, 2];
%             for rra = rras
%                 for ies = iess
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.SDU = true;
%                     params{ii}.riskaver = rra;
%                     params{ii}.invies = ies;
%                     params{ii}.name = sprintf('SDU, RRA=%d, IES=%d', rra, ies);
%                 end
%             end
            
            
            % Het CRRA = IES
%             rra_hets = [1,2,3];
%             for rra_het = rra_hets
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.rho = rho;
%                     params{ii}.riskaver = linspace(exp(-rra_het), exp(rra_het), 5);
%                     params{ii}.name = sprintf('het RRA exp(%d), rho=%d', rra_het, rho);
%                 end
%             end

%             for rho = rhos
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.rho = rho;
%                 risk_avergrid = [3/4 1 4/3];
%                 params{ii}.riskaver = risk_avergrid;
%                 params{ii}.name = sprintf('het RRA %d, rho=%d', 3/4, rho);
%             end
%             
%             for rho = rhos
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.rho = rho;
%                 risk_avergrid = [2/3 1 3/2];
%                 params{ii}.riskaver = risk_avergrid;
%                 params{ii}.name = sprintf('het RRA %d, rho=%d', 2/3, rho);
%             end
%             
%             for rho = rhos
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.rho = rho;
%                 risk_avergrid = [1/2 1 2];
%                 params{ii}.riskaver = risk_avergrid;
%                 params{ii}.name = sprintf('het RRA %d, rho=%d', 1/2, rho);
%             end

            rhos = linspace(-0.02, 0.02, 20);
            for rho = rhos
                ii = ii + 1;
                params = [params {calibrations{1}}];
                params{ii} = params{1};
                params{ii}.rho = rho;
                params{ii}.nb = 250;
                params{ii}.nb_KFE = 250;
                params{ii}.na = 2;
                params{ii}.na_KFE = 2;
                params{ii}.bmax = 500;
                params{ii}.rebalance_rate = 0;
                params{ii}.r_b = 0.0025;
                params{ii}.r_a = params{ii}.r_b;
                params{ii}.name = sprintf('1A baseline, rho = %d', rho);
            end
            
%             % Quadratic Utility
%             quad_bs = [1.0 0.5 0.25 0.1 0.05]; %linspace(0.5, 50.0, 20);
% %             b_bds = [0.00001, 3];
% %             rhos = [0 0.004 0.008 params{1}.rho 0.02 0.05];
%             rhos = linspace(-0.02, 0.02, 20);
%             % 1A (with 2A r_b)
%             for quad_b = quad_bs
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.rho = rho;
%                     params{ii}.nb = 250;
%                     params{ii}.nb_KFE = 250;
%                     params{ii}.bmax = 500;
%                     params{ii}.na = 2;
%                     params{ii}.na_KFE = 2;
%                     params{ii}.rebalance_rate = 0;
%                     params{ii}.quad_u = true;
%                     params{ii}.r_b = 0.0025;
%                     params{ii}.r_a = params{ii}.r_b;
%                     params{ii}.quad_b = quad_b;
%                     params{ii}.name = sprintf('1A Quad util, b = %d, rho = %d', quad_b, rho);
%                 end
%             end
%             
%             exp_as = [2.0 1.0 0.5 0.2 0.1];
%             % Exponential Utility
%             for exp_a = exp_as
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.rho = rho;
%                     params{ii}.nb = 250;
%                     params{ii}.nb_KFE = 250;
%                     params{ii}.bmax = 500;
%                     params{ii}.na = 2;
%                     params{ii}.na_KFE = 2;
%                     params{ii}.rebalance_rate = 0;
%                     params{ii}.exp_u = true;
%                     params{ii}.r_b = 0.0025;
%                     params{ii}.r_a = params{ii}.r_b;
%                     params{ii}.exp_a = exp_a;
%                     params{ii}.name = sprintf('1A Exp util, a = %d, rho = %d', exp_a, rho);
%                 end
%             end
            
            
            
            % 2A
%             for quad_b = quad_bs
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
% %                     params{ii}.calibration_vars = {'quad_b'};
% %                     params{ii}.calibration_bounds = {b_bds};
% %                     params{ii}.calibration_stats = {'totw'};
% %                     params{ii}.calibration_targets = [scf.mean_totw];
% %                     params{ii}.calibration_scales = [1];
%                     params{ii}.rho = rho;
% %                     params{ii}.na = 2;
% %                     params{ii}.rebalance_rate = 0;
%                     params{ii}.quad_u = true;
% %                     params{ii}.r_b = 0.02;
%                     params{ii}.quad_b = quad_b;
%                     params{ii}.name = sprintf('2A Quad util, b = %d, rho = %d', quad_b, rho);
%                 end
%             end
            
            disp('filler');
            
            
            % SDU with het RRA
%             rra_hets = [1,2,3];
%             iess = [0.25, 1.001, 2];
%             for rra_het = rra_hets
%                 for ies = iess
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.SDU = true;
%                     params{ii}.ies = ies;
%                     params{ii}.riskaver = linspace(exp(-rra_het), exp(rra_het), 5);
%                     params{ii}.name = sprintf('SDU, RRA het exp(%d), IES=%d', rra_het, ies);
%                 end
%             end
            

            % Het discount factors
            rho_hets = [0.001,0.005,0.01];
            for rho_het = rho_hets
                for rho = rhos
                    ii = ii + 1;
                    params = [params {calibrations{1}}];
                    params{ii} = params{1};
                    params{ii}.rho = rho;
                    params{ii}.x0 = [rho - 0.01, rho + 0.01];
%                     rho_diffs = linspace(-rho_het, rho_het, 5);
                    params{ii}.rho_grid = params{1}.rho + linspace(-rho_het, rho_het, 5)';
                    params{ii}.name = sprintf('het rho, spacing=%d, rho_cent_start=%d', rho_het, rho);
                end
            end
            
            % Temptation with different illiquid rates and different reb
            % costs
%             tempts = [0.01, 0.05, 0.1];
%             r_as = [0.005, 0.0075, 0.01, 0.0125, params{1}.r_a];
%             reb_costs = [-1000, -500, -250, 0, 250, 500, 1000] ./ anninc;
%             for tempt = tempts
%                 for r_a = r_as
%                     for reb_cost = reb_costs
%                         for rho = rhos
%                             ii = ii + 1;
%                             params = [params {calibrations{1}}];
%                             params{ii} = params{1};
%                             params{ii}.rho = rho;
%                             params{ii}.x0 = [rho - 0.01, rho + 0.01];
%                             params{ii}.temptation = tempt;
%                             params{ii}.r_a = r_a;
%                             params{ii}.rebalance_cost = params{1}.rebalance_cost + reb_cost;
%                             params{ii}.name = sprintf('Temptation=%d, r_a=%d, reb_cost=%d, rho_start=%d', tempt, r_a, params{ii}.rebalance_cost * anninc, rho);
%                         end
%                     end
%                 end
%             end
            
            
            % 1)
%             tempt = 0.01;
%             r_as = [0.0075 0.008 0.0085 0.009 0.0095];
%             reb_costs = [2300 2400 2500 2600] ./anninc;
%             for r_a = r_as
%                 for reb_cost = reb_costs
%                     for rho = rhos
%                         ii = ii + 1;
%                         params = [params {calibrations{1}}];
%                         params{ii} = params{1};
%                         params{ii}.rho = rho;
%                         params{ii}.x0 = [rho - 0.01, rho + 0.01];
%                         params{ii}.temptation = tempt;
%                         :q
%                         params{ii}.r_a = r_a;
%                         params{ii}.rebalance_cost = reb_cost;
%                         params{ii}.name = sprintf('1 Temptation=%d, r_a=%d, reb_cost=%d, rho_start=%d', tempt, r_a, params{ii}.rebalance_cost * anninc, rho);
%                     end
%                 end
%             end
%             
%             % 2)
%             tempt = 0.015;
%             r_as = [params{1}.r_a 0.0075 0.008 0.0085 0.009 0.0095];
%             reb_costs = [params{1}.rebalance_cost 2300 2400 2500 2600] ./anninc;
%             for r_a = r_as
%                 for reb_cost = reb_costs
%                     for rho = rhos
%                         ii = ii + 1;
%                         params = [params {calibrations{1}}];
%                         params{ii} = params{1};
%                         params{ii}.rho = rho;
%                         params{ii}.x0 = [rho - 0.01, rho + 0.01];
%                         params{ii}.temptation = tempt;
%                         params{ii}.r_a = r_a;
%                         params{ii}.rebalance_cost = reb_cost;
%                         params{ii}.name = sprintf('2 Temptation=%d, r_a=%d, reb_cost=%d, rho_start=%d', tempt, r_a, params{ii}.rebalance_cost * anninc, rho);
%                     end
%                 end
%             end
%             
%             % 3)
%             tempts = [0.0125 0.015 0.0175 0.02 0.0225 0.025];
%             r_as = [params{1}.r_a 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.011];
% %             reb_costs = [params{1}.rebalance_cost 2300 2400 2500 2600] ./anninc;
%             for r_a = r_as
%                 for tempt = tempts
%                     for rho = rhos
%                         ii = ii + 1;
%                         params = [params {calibrations{1}}];
%                         params{ii} = params{1};
%                         params{ii}.rho = rho;
%                         params{ii}.x0 = [rho - 0.01, rho + 0.01];
%                         params{ii}.temptation = tempt;
%                         params{ii}.r_a = r_a;
% %                         params{ii}.rebalance_cost = params{1}.rebalance_cost + reb_cost;
%                         params{ii}.name = sprintf('3 Temptation=%d, r_a=%d, reb_cost=%d, rho_start=%d', tempt, r_a, params{ii}.rebalance_cost * anninc, rho);
%                     end
%                 end
%             end
            
            % 3b)
%             tempt = 0.015;
%             r_as = [params{1}.r_a 0.005 0.0055 0.006 0.0065 0.007];
%             reb_costs = [params{1}.rebalance_cost 2300 2400 2500 2600 2700 2800 2900 3000] ./anninc;
%             for r_a = r_as
%                 for reb_cost = reb_costs
%                     for rho = rhos
%                         ii = ii + 1;
%                         params = [params {calibrations{1}}];
%                         params{ii} = params{1};
%                         params{ii}.rho = rho;
%                         params{ii}.x0 = [rho - 0.01, rho + 0.01];
%                         params{ii}.temptation = tempt;
%                         params{ii}.r_a = r_a;
%                         params{ii}.rebalance_cost = reb_cost;
%                         params{ii}.name = sprintf('3b Temptation=%d, r_a=%d, reb_cost=%d, rho_start=%d', tempt, r_a, params{ii}.rebalance_cost * anninc, rho);
%                     end
%                 end
%             end
          
            
            



            
            
            % SDU with het IES
            % Not yet
            
            
            rhos = linspace(-0.05, 0.1, 10);
            rhos = [params{1}.rho rhos];
            
            % IG
%             betas = [0.9, 0.8, 0.7];
%             for beta = betas
%                 for rho = rhos
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.rho = rho;
%                     params{ii}.beta = beta;
%                     params{ii}.name = sprintf('IG=%d, rho=%d', beta, rho);
%                 end
%             end
            
            
            
            
            
            
%         end
        
%         rhos = linspace(-0.01, 0.01, 5);
%         rhos = [0.01214 rhos];
        
        
        

%         for rho = rhos
            % Less frequent arrivals
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.rebalance_rate = 1.0;
%             params{ii}.name = sprintf('Quarterly Rebalance');
% 
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.rebalance_rate = 0.25;
%             params{ii}.name = sprintf('Annual Rebalance');


            r_as = [0.075, 0.05, 0.04, 0.03]./4;
            % ra robustness
            for r_a = r_as
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.calibration_vars = {'rho', 'rebalance_cost'};
%                     params{ii}.calibration_bounds = {rho_bds, reb_cost_bds};
%                     params{ii}.calibration_stats = {'totw', 'liqw_lt_ysixth'};
%                     params{ii}.calibration_targets = [scf.mean_totw, scf.htm];
%                     params{ii}.calibration_scales = [1,1];
%                     params{ii}.r_a = r_a;
%                     params{ii}.rebalance_cost = reb_cost;
%                     params{ii}.name = sprintf('r_a=%d, rho=%d rho reb_cost robustness', r_a, rho);

%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.calibration_vars = {'rho'};
%                 params{ii}.calibration_bounds = {rho_bds};
%                 params{ii}.calibration_stats = {'totw'};
%                 params{ii}.calibration_targets = [scf.mean_totw];
%                 params{ii}.calibration_scales = [1];
%                 params{ii}.rho = rho;
%                 params{ii}.r_a = r_a;
% %                 params{ii}.rebalance_cost = reb_cost; %1453.906838;
%                 params{ii}.name = sprintf('r_a=%d, rho=%d, rho robustness', r_a, rho);
                
                for rho=[0.0001, 0.001, 0.005, 0.0114]
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.r_a = r_a;
%                     params{ii}.rho = rho;
%                     params{ii}.name = sprintf('r_a = %d, rho=%d', r_a, rho);
                end
            end

            r_bs = [-0.03, -0.01, 0]/4;
            % rb robustness
            for r_b = r_bs
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.calibration_vars = {'rho'};
%                 params{ii}.calibration_bounds = {rho_bds};
%                 params{ii}.calibration_stats = {'totw'};
%                 params{ii}.calibration_targets = [scf.mean_totw];
%                 params{ii}.calibration_scales = [1];
%                 params{ii}.rho = rho;
%                 params{ii}.r_b = r_b;
% %                 params{ii}.rebalance_cost = reb_cost; %1453.906838;
%                 params{ii}.name = sprintf('r_b=%d, rho=%d, rho robustness', r_b, rho);
                
                for rho=[0.0001, 0.001, 0.005, 0.0114]
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.r_b = r_b;
%                     params{ii}.rho = rho;
%                     params{ii}.name = sprintf('r_b = %d, rho=%d', r_b, rho);
                end
            end

            reb_costs = [0, 500, 1000, 2000, 2500, 3000]./anninc;
            
            % reb_cost robustness
            for reb_cost = reb_costs
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.calibration_vars = {'rho'};
%                 params{ii}.calibration_bounds = {rho_bds};
%                 params{ii}.calibration_stats = {'totw'};
%                 params{ii}.calibration_targets = [scf.mean_totw];
%                 params{ii}.calibration_scales = [1];
%     %                 params{ii}.rho = rho;
%     %                 params{ii}.r_a = r_a;
%                 params{ii}.rebalance_cost = reb_cost; %1453.906838;
%                 params{ii}.name = sprintf('reb_cost=%d, rho=%d, rho robustness', reb_cost, rho);
                
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.rebalance_cost = reb_cost;
%                 params{ii}.name = sprintf('reb_cost = %d', reb_cost);
            end
%         end
        
%         rhos = [0.005, 0.01, 0.012, 0.013, 0.015];
        
        
        % 2A Baseline Alternative
%         for r_b = [-0.0025, -0.005]
%             for r_a = [0.005, 0.01, 0.012, 0.0125, 0.015]
%                 for reb_cost = [500/anninc, 516/anninc, 550/anninc]
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.r_b = r_b;
%                     params{ii}.r_a = r_a;
%                     r_a_bounds = [0, 0.126];
%                     params{ii}.rebalance_cost = reb_cost;
%                     reb_bounds = [400/anninc, 600/anninc];
%                     params{ii}.calibration_vars = {'rho', 'r_a', 'rebalance_cost'};
%                     params{ii}.calibration_bounds = {rho_bds, r_a_bounds, reb_bounds};
%                     params{ii}.calibration_stats = {'totw', 'liqw_lt_ysixth', 'w_lt_ysixth'};
%                     params{ii}.calibration_targets = [scf.mean_totw, scf.htm, scf.phtm];
%                     params{ii}.calibration_scales = [1, 1, 1];
%                     params{ii}.name = sprintf('Baseline 2A Alt, r_b=%d, r_a start=%d, reb_cost start=%d', params{ii}.r_b, params{ii}.r_a, params{ii}.rebalance_cost);
%                 end
%             end
%         end
%         
%         % 2A Baseline Alternative with temptation
%         for r_b = [-0.0025, -0.005]
%             for r_a = [0.005, 0.01, 0.012, 0.0125, 0.015]
%                 for reb_cost = [500/anninc, 516/anninc, 550/anninc]
%                     ii = ii + 1;
%                     params = [params {calibrations{1}}];
%                     params{ii} = params{1};
%                     params{ii}.r_b = r_b;
%                     params{ii}.r_a = r_a;
%                     r_a_bounds = [0, 0.126];
%                     params{ii}.rebalance_cost = reb_cost;
%                     reb_bounds = [400/anninc, 600/anninc];
%                     params{ii}.calibration_vars = {'rho', 'r_a', 'rebalance_cost'};
%                     params{ii}.calibration_bounds = {rho_bds, r_a_bounds, reb_bounds};
%                     params{ii}.calibration_stats = {'totw', 'liqw_lt_ysixth', 'w_lt_ysixth'};
%                     params{ii}.calibration_targets = [scf.mean_totw, scf.htm, scf.phtm];
%                     params{ii}.calibration_scales = [1, 1, 1];
%                     params{ii}.temptation = 0.05;
%                     params{ii}.name = sprintf('Temptation 2A Alt, r_b=%d, r_a start=%d, reb_cost start=%d', params{ii}.r_b, params{ii}.r_a, params{ii}.rebalance_cost);
%                 end
%             end
%         end
        
        
        
        
        
        
        
%         % 1A Baseline
%         rhos = [-0.0013 rhos];
%         rhos = linspace((0.0025 - 1/200), (0.0025 - 1/200) + 1/200, 10);
%         quad_bs = [0.001, 0.01, 0.1, 1.0]; %[1/(10*2.09)]; % b = 1/(10*max(y))
%         for rho = [-0.004] %, -0.003, -0.002, -0.001, 0, 0.001, 0.002]
%             ii = ii + 1;
%             ii1A = ii;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
% %             params{ii}.OneAsset = true;
%             params{ii}.na = 2;
%             params{ii}.na_KFE = 2;
%             params{ii}.rebalance_rate = 0;
%             params{ii}.r_b = 0.0025;
%             params{ii}.r_a = params{ii}.r_b;
%             params{ii}.ComputeMPCS_illiquid = false;
%             params{ii}.rho = rho;
%             params{ii}.name = sprintf('Baseline 1A, rho=%d', params{ii}.rho);
%         end
%         
%         for rho = rhos %[-0.004] %, -0.003, -0.002, -0.001, 0, 0.001, 0.002]
%             for quad_b = quad_bs
%                 ii = ii + 1;
%                 ii1A = ii;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
% %                 params{ii}.calibration_vars = {'quad_b'};
% %                 params{ii}.calibration_bounds = {b_bds};
% %                 params{ii}.calibration_stats = {'totw'};
% %                 params{ii}.calibration_targets = [scf.mean_totw];
% %                 params{ii}.calibration_scales = [1];
% %                 params{ii}.OneAsset = true;
%                 params{ii}.na = 2;
%                 params{ii}.na_KFE = 2;
%                 params{ii}.rebalance_rate = 0;
%                 params{ii}.r_b = 0.0025;
%                 params{ii}.r_a = params{ii}.r_b * 0.9;
%                 params{ii}.ComputeMPCS_illiquid = false;
%                 params{ii}.rho = rho;
%                 params{ii}.quad_u = true;
%                 params{ii}.quad_b = quad_b;
%                 params{ii}.name = sprintf('Baseline 1A w/ with quad_b=%d, rho=%d', quad_b, rho);
%             end
%         end
%         
%         disp('filler');
            
            % Temptation robust to scaling of rho?
%             tempt_scales = linspace(10,100,10);
%             tempt_scales = [tempt_scales linspace(200,1000,9)];
%             for tempt_scale = tempt_scales
%                 for rho = rhos
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{ii1A};
%                 params{ii}.rho = rho;
%                 params{ii}.temptation = 0.05;
%                 params{ii}.tempt_scale = tempt_scale;
%                 params{ii}.name = sprintf('Tempt 1A, tempt=%d, scale=%d, rho=%d', 0.05, tempt_scale, rho);
%                 end
%             end
            
            
            




%         
%         % Infrequent rebalance arrival
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.rebalance_rate = 0.25;
%         params{ii}.name = sprintf('Infrequent Rebalance');
%         
%         % Frequent rebalance arrival
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.rebalance_rate = 3.0;
%         params{ii}.name = sprintf('Frequent Rebalance');
%         
%         % Continuous b, rho only
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.income_dir = incomedirs{2};
%         params{ii}.IncomeDescr = IncomeDescriptions{2};
%         params{ii}.name = sprintf('Cont b, rho only');
%         
%         % Continuous b, all
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.income_dir = incomedirs{2};
%         params{ii}.IncomeDescr = IncomeDescriptions{2};
%         params{ii}.calibration_vars = {'rho', 'r_a', 'rebalance_cost'};
%         r_b_bds = [-0.01, 0.02];
%         r_a_bds = [0.005, 0.05];
%         reb_cost_bds = [1,10000]/anninc;
%         params{ii}.calibration_bounds = {rho_bds, r_a_bds, reb_cost_bds};
%         params{ii}.calibration_stats = {'totw', 'w_lt_ysixth', 'liqw_lt_ysixth'};
%         params{ii}.calibration_targets = [scf.mean_totw, scf.phtm, scf.htm];
%         params{ii}.calibration_scales = [1, 1, 1];
%         params{ii}.rebalance_cost = 500.0/anninc;
%         params{ii}.HJB_delta = 1e6;
%         params{ii}.name = sprintf('Cont b, all 500');
%         
%         % Low r_b
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.r_b = -0.01; 
%         params{ii}.name = sprintf('Low r_b');
%         
%         % High r_b
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.r_b = 0.00;
%         params{ii}.name = sprintf('High r_b');
%         
%         % Low r_a
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.r_a = 0.013;
%         params{ii}.name = sprintf('Low r_a');
%         
%         % High r_a
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.r_a = 0.02;
%         params{ii}.name = sprintf('High r_a');
%         
%         % IG 0.5 2A
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.beta = 0.5;
%         params{ii}.rho = 0.001;
%         params{ii}.name = sprintf('IG = 0.5, rho = 0.001, 2A');
%         
%         % IG 0.2 2A
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.beta = 0.2;
%         params{ii}.rho = 0.001;
%         params{ii}.name = sprintf('IG = 0.2, rho = 0.001, 2A');

        % IG 0.7 2A
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.beta = 0.7;
%         params{ii}.rho = 0.001;
%         params{ii}.name = sprintf('IG = 0.7, rho start = 0.001, 2A');
%         
%         % IG 0.8 2A
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.beta = 0.8;
%         params{ii}.rho = 0.001;
%         params{ii}.name = sprintf('IG = 0.8, rho start = 0.001, 2A');
%         
%         % IG 0.9 2A
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.beta = 0.9;
%         params{ii}.rho = 0.001;
%         params{ii}.name = sprintf('IG = 0.9, rho start = 0.001, 2A');
        
        
        
%         rhos = linspace(-0.005,-0.004,150);
        rhos = linspace(-0.005, -0.001, 10);
        for rho = rhos
            
            % IG 0.95 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{2};
%             params{ii}.beta = 0.95;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
% %             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
%             
%             
%             % IG 0.9 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{2};
%             params{ii}.beta = 0.9;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
% %             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
%             
%             % IG 0.85 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{2};
%             params{ii}.beta = 0.85;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
% %             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
%             
%             % IG 0.8 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{2};
%             params{ii}.beta = 0.8;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
% %             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
%             
%             % IG 0.75 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{2};
%             params{ii}.beta = 0.75;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
% %             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
            
            % IG 0.7 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{2};
%             params{ii}.beta = 0.7;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
% %             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
            
            % IG 0.6 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.beta = 0.6;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025;
%             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
            
            % IG 0.5 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.beta = 0.5;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025; % 0.01
%             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
% 
%             % IG 0.2 1A
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.beta = 0.2;
%             params{ii}.rho = rho;
%             params{ii}.r_b = 0.0025; % 0.01
%             params{ii}.OneAsset = true;
%             params{ii}.name = sprintf('IG = %d, rho = %d, 1A', params{ii}.beta, params{ii}.rho);
        end
        
        
%         % IG match PHtM 2-asset
%         for rho = [0.001, 0.005, 0.01]
%             for beta = [0.1, 0.3, 0.5, 0.7, 1.0]
%                 
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.calibration_vars = {'rho', 'beta'};
%                 params{ii}.calibration_stats = {'totw', 'w_lt_ysixth'};
%                 params{ii}.calibration_targets = [scf.mean_totw, scf.phtm];
%                 params{ii}.calibration_scales = [1, 1];
%                 % Start here
%                 params{ii}.rho = rho;
%                 params{ii}.beta = beta;
%                 beta_bds = [0.01, 1.3];
%                 params{ii}.calibration_bounds = {rho_bds, beta_bds};
%                 params{ii}.name = sprintf('IG match PHtM 2A, start rho=%d, beta=%d', params{ii}.rho, params{ii}.beta);
%             end
%         end
%         
%         % IG match PHtM 1-asset
%         for rho = [-0.0005, -0.002, -0.001, 0.0, 0.001, 0.002, 0.005, 0.01]
%             for beta = [0.8, 0.9]
%                 
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.calibration_vars = {'rho', 'beta'};
%                 params{ii}.calibration_stats = {'totw', 'w_lt_ysixth'};
%                 params{ii}.calibration_targets = [scf.mean_totw, scf.phtm];
%                 params{ii}.calibration_scales = [1, 1];
%                 
% %                 params{ii}.calibration_vars = {'rho'};
% %                 params{ii}.calibration_stats = {'totw'};
% %                 params{ii}.calibration_targets = [scf.mean_totw];
% %                 params{ii}.calibration_scales = [1];
%                 % Start here
%                 params{ii}.r_b = 0.0025; % 0.01
%                 params{ii}.OneAsset = true;
%                 params{ii}.rho = rho; % 0.003
%                 params{ii}.beta = beta; % 0.8
%                 beta_bds = [0.01, 1.3];
%                 params{ii}.calibration_bounds = {rho_bds, beta_bds};
% %                 params{ii}.calibration_bounds = {rho_bds};
%                 params{ii}.name = sprintf('IG match PHtM 1A, start rho=%d, beta=%d', params{ii}.rho, params{ii}.beta);
%             end
%         end
%         
%         % Reb cost 250
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.rebalance_cost = 250.0/anninc;
%         params{ii}.name = sprintf('Reb cost $250');
%         
%         % Reb cost 1000
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.rebalance_cost = 1000.0/anninc;
%         params{ii}.name = sprintf('Reb cost $1000');
%         
%         % Reb cost 2000
%         ii = ii + 1;
%         params = [params {calibrations{1}}];
%         params{ii} = params{1};
%         params{ii}.rebalance_cost = 2000.0/anninc;
%         params{ii}.name = sprintf('Reb cost $2000');
%         
%         
%         for rho = [0.002, 0.01]
%             % Temptation 0.05
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.calibration_vars = {'rho', 'r_b', 'r_a'};
%             r_b_bds = [-0.01, 0.02];
%             r_a_bds = [0.005, 0.05];
%             params{ii}.calibration_bounds = {rho_bds, r_b_bds, r_a_bds};
%             params{ii}.calibration_stats = {'totw', 'liqw_lt_ysixth', 'w_lt_ysixth'};
%             params{ii}.calibration_targets = [scf.mean_totw, scf.htm, scf.phtm];
%             params{ii}.calibration_scales = [1, 1, 1];
%             params{ii}.rho = rho;
%     %         params{ii}.r_b = 0.005;
%     %         params{ii}.r_a = 0.03;
%             params{ii}.temptation = 0.05;
%             params{ii}.name = sprintf('Temptation %d, rho=%d', params{ii}.temptation, params{ii}.rho);
% 
% 
%             % Temptation 0.07
%             ii = ii + 1;
%             params = [params {calibrations{1}}];
%             params{ii} = params{1};
%             params{ii}.calibration_vars = {'rho', 'r_b', 'r_a'};
%             r_b_bds = [-0.01, 0.02];
%             r_a_bds = [0.005, 0.05];
%             params{ii}.calibration_bounds = {rho_bds, r_b_bds, r_a_bds};
%             params{ii}.calibration_stats = {'totw', 'liqw_lt_ysixth', 'w_lt_ysixth'};
%             params{ii}.calibration_targets = [scf.mean_totw, scf.htm, scf.phtm];
%             params{ii}.calibration_scales = [1, 1, 1];
%             params{ii}.rho = rho;
%     %         params{ii}.r_b = 0.01;
%     %         params{ii}.r_a = 0.03;
%             params{ii}.temptation = 0.07;
%             params{ii}.name = sprintf('Temptation %d, rho=%d', params{ii}.temptation, params{ii}.rho);
%         end
        
          % For tempt with exog rb and ra
%         for rho = [-0.01, -0.005, -0.001, 0, 0.001, 0.002, 0.005, 0.01]
%             for r_a = [0.005, 0.01, 0.015, 0.02]
%                 % Temptation 0.05
%                 ii = ii + 1;
%                 params = [params {calibrations{1}}];
%                 params{ii} = params{1};
%                 params{ii}.calibration_vars = {'rho'};
% %                 r_b_bds = [-0.01, 0.02];
% %                 r_a_bds = [0.005, 0.05];
%                 params{ii}.calibration_bounds = {rho_bds};
%                 params{ii}.calibration_stats = {'totw'};
%                 params{ii}.calibration_targets = [scf.mean_totw];
%                 params{ii}.calibration_scales = [1];
%                 params{ii}.rho = rho;
%                 params{ii}.r_b = 0.0;
%                 params{ii}.r_a = r_a;
%                 params{ii}.temptation = 0.05;
%                 params{ii}.name = sprintf('Temptation %d, rho start=%d', params{ii}.temptation, params{ii}.rho);
%             end
%         end
        
    end
    
    %% DO NOT CHANGE THIS SECTION
    n = numel(params);
    outparams = params{param_opts.param_index};
end