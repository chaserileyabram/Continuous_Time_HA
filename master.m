%% TWO-ASSET HOUSEHOLD MODEL
% This is the main script for this code repository
% HA model with a liquid asset and an illiquid asset
%
% Prior to running this script (THE FOLLOWING DOCUMENTATION MAY BE OUTDATED):
%
% (1) Set options in the section below.
%
% (2) Modify the parameters script 'code/+setup/+params/get_params.m' and make sure that 
% run_opts.mode is equal to 'get_params'. Note that all parameter defaults
% are set in the file +model_objects/ParamsDefaults.m, and get_params.m overrides
% these defaults. Any parameters not in get_params.m are set to their
% defaults. See the attributes of Params.m for a list of all
% parameters.
%
% (3) Set run_opts.param_index equal to the index of the parameterization
% you would like to run in the parameters file (1,2,...).
%
% (4) cd into the Continuous_Time_HA directory.
%
% RUNNING ON THE SERVER: To run in batch on the server, use 
% code/batch/server.sbatch as a template. That script sends an array to SLURM 
% that runs all of the requested parameterizations in get_params.m. Output files
% are stored in the Output directory

clear all
warning('off', 'MATLAB:nearlySingularMatrix')

%% ------------------------------------------------------------------------
% SET OPTIONS
% -------------------------------------------------------------------------

param_opts.calibrate = true;
param_opts.fast = false; % use small grid for debugging
param_opts.ComputeMPCS = true;
param_opts.ComputeMPCS_illiquid = true;
param_opts.SimulateMPCS = false; % also estimate MPCs by simulation
param_opts.ComputeMPCS_news = false;
param_opts.SimulateMPCS_news = false;
param_opts.DealWithSpecialCase = false; % need to recode this
param_opts.param_index = 25;
param_opts.makePlots = false; % not coded yet -> coded, but not through this option

run_opts.check_nparams = false;
run_opts.param_script = 'overall_htm_target';

%% ------------------------------------------------------------------------
% HOUSEKEEPING, DO NOT CHANGE
% -------------------------------------------------------------------------
[~, currdir] = fileparts(pwd());
if ~strcmp(currdir, 'Continuous_Time_HA')
    msg = 'The user must cd into the Continuous_Time_HA directory';
    bad_dir = MException('Continuous_Time_HA:master', msg);
    throw(bad_dir);
end

taskid_from_server = str2num(getenv('SLURM_ARRAY_TASK_ID'));

% When running on server
if ~isempty(taskid_from_server)
	param_opts.param_index = taskid_from_server;
	param_opts.fast = false; % Don't accidentally go fast...
    param_opts.calibrate = true; % ... or forget to calibrate
    run_opts.check_nparams = false;
end

% News only for first
% if taskid_from_server == 1
%     param_opts.calibrate = false;
%     param_opts.ComputeMPCS_news = true;
% end

addpath('code');
addpath('factorization_lib');

warning('off', 'MATLAB:MKDIR:DirectoryExists')
mkdir('temp');
mkdir('output');

%% --------------------------------------------------------------------
% GET PARAMETERS
% ---------------------------------------------------------------------
[p, nparams] = params.(run_opts.param_script)(param_opts);
if run_opts.check_nparams
    fprintf('Parameters script contains %d specifications\n', nparams)
    return
end

% Create Params object
p = model_objects.Params(p);
p.print();

%% ------------------------------------------------------------------------
% CALIBRATING WITH SOLVER
% -------------------------------------------------------------------------
runFinal = true;
if ~isempty(p.calibrator)
    options = optimoptions(@lsqnonlin,...
	    	'MaxFunctionEvaluations', p.calibration_maxiters,...
	    	'FunctionTolerance', p.calibration_crit,...
	    	'OptimalityTolerance', p.calibration_crit,...
            'StepTolerance', p.calibration_steptol);
        
    options_fs = optimoptions(@fsolve,...
        'MaxFunctionEvaluations', p.calibration_maxiters,...
        'FunctionTolerance', p.calibration_crit,...
        'OptimalityTolerance', p.calibration_crit,...
        'StepTolerance', p.calibration_steptol); %,...
        % 'FiniteDifferenceStepSize', 1e-10);
        
    options_fz = optimset('Display', 'iter');
        
	resnorm = 100;
	while (resnorm >= 1e-4)
	    x0 = p.calibrator.get_next_x0();
        
%         x0 = p.x0;
        if isempty(x0)
            break;
        end

% 	    [calibrated_params, resnorm] = ...
% 	    	lsqnonlin(p.calibrator.solver_handle, x0,...
%                 p.calibrator.lbounds, p.calibrator.ubounds, options);
        
%         [calibrated_params, resnorm] = ...
% 	    	fsolve(p.calibrator.solver_handle, x0, options_fs);
        
        [calibrated_params, resnorm] = ...
	    	fzero(p.calibrator.solver_handle, x0, options_fz);
	end

    % if (p.calibrator.dnorm >= 1e-3)
    %     error('Could not match targets')
    %     runFinal = false;
    % end

    if ~p.OneAsset
        zval = p.calibrator.target_result;
        z1bad = (zval(1) < 4) || (zval(1) > 4.2);
        % z2bad = (zval(2) < 0.035) || (zval(2) > 0.055);
        z2bad = false; % temp fix so I can see single calibrations in 2 asset mode

        if z1bad || z2bad
            runFinal = false;
        end
    end
end

if runFinal
    stats = main(p, 'final', true, 'quiet', false);

    table_gen = tables.StatsTable(p, {stats});
    results_table = table_gen.create(p, {stats})
    
    % Plots here?
%     make_plots(stats, p.param_index);
    

    xlx_path = sprintf('run%d_table.xlsx', p.param_index);
    xlx_path = fullfile('output', xlx_path);
    writetable(results_table, xlx_path, 'WriteRowNames', true)
end