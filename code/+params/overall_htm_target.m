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
        'continuous_a/measurement_error_20pc',...
        'continuous_a/measurement_error_33pc',...
        'continuous_a/measurement_error_50pc'};

    IncomeDescriptions = {'cont_a, no meas err',...
        'cont_a, meas err 20pc',...
        'cont_a, meas err 33pc',...
        'cont_a, meas err 50pc'};

    experiment = false;
    if experiment
        iy = 1;
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
        median_calibration.calibration_vars = {'rho', 'r_a'};
        % median_calibration.calibration_vars = {'rho'};

        % kappa_1s = [0.2:0.2:1, 1.5:0.5:5];
        % kappa_2s = [0.25, 0.5, 1.0, 1.5];
        

        calibrations = {median_calibration};
        
        % Various adjustment costs
        reb_costs = [100, 200, 500, 1000, 5000, 10000]/anninc;
        
        % Various liquid rates
        r_bs = [-0.01, 0.0, 0.01, 0.02]/4;
        
        % Various illiquid rates
        % r_as = [0.0, 0.01, 0.02, 0.03]/4;
        
        % Calibration stats to use
        cal_stats = {{'totw', 'liqw'}, {'totw', 'median_liqw'}};
        
        % Calibration targets to use
        cal_targets = {[scf.mean_totw, scf.mean_liqw], [scf.mean_totw, scf.median_liqw]};
        

        ii = 1;
        group_num = 0;
        for icalibration = [1]
            % for kappa2 = kappa_2s
            for cal_i = 1:2
                for iy = 1:1
                    for r_b = r_bs
                        group_num = group_num + 1;
                        % for kappa1 = kappa_1s
                        for reb_cost = reb_costs
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
                                
                                params{ii}.rebalance_rate = 1.0/4;
                                params{ii}.rebalance_cost = reb_cost;
%                                 params{ii}.rebalance_cost = Inf;

                                % params{ii}.rho = 0.005;
                                params{ii}.rho = 0.0125;
                                % rho_bds = [0.0005, 0.03];
                                rho_bds = [-0.0045, 0.03];
                                

                                params{ii}.r_a = 0.08/4;
%                                 params{ii}.r_a = r_a;
                                % r_a_bds = [0.008, 0.02];
                                r_a_bds = [0.005, 0.05];
                                
                                params{ii}.r_b = 0.01/4;
                                % r_b_bds = [-0.01, 0.02];
                                
                                params{ii}.KFE_maxiters = 1e6;
                                % params{ii}.a_lb = 0.3;

                                % params{ii}.rho = mean(rho_bds);
                                % params{ii}.r_a = mean(r_a_bds);

                                % Set calibrator
                                % params{ii}.calibration_bounds = {rho_bds, r_a_bds};
                                params{ii}.calibration_bounds = {rho_bds, r_a_bds};
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
                            
                            params{ii}.calibration_scales = [1, 10]; % Scales deviation for calibration
                            
                            params{ii}.calibration_crit = 1e-8;
                            
                            params{ii}.name = sprintf('cal=%d, r_a=%d, reb_cost=%d', cal_i, params{ii}.r_a, reb_cost);

                            ii = ii + 1;
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