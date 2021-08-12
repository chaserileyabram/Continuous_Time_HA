function add_mpcs(obj, mpc_obj, simulated)
	if mpc_obj.options.liquid_mpc
		asset_indicator = 0;
		mpc_type = '';
	else
		asset_indicator = 2;
		mpc_type = 'illiq';
	end
	sfill2 = @(x,y) obj.sfill(x, y, asset_indicator);

	empty_stat = sfill2([], []);

	empty_mpc_struct = struct(...
		'shock_normalized', empty_stat,...
		'shock', empty_stat,...
		'quarterly', empty_stat,...
		'annual', empty_stat,...
		'quarterly_htm', empty_stat,...
		'quarterly_whtm', empty_stat,...
		'quarterly_phtm', empty_stat,...
		'annual_htm', empty_stat,...
		'annual_whtm', empty_stat,...
		'annual_phtm', empty_stat...
	);

	nshocks = numel(obj.p.mpc_shocks);
	for ishock = 1:nshocks
		shock = obj.p.mpc_shocks(ishock);
		shock_label = obj.p.quantity2label(shock);
		mpcs_stats(ishock) = empty_mpc_struct;

		mpcs_stats(ishock).shock_normalized = sfill2(...
			shock * 100, 'Shock size, (% of mean ann inc)');

		mpcs_stats(ishock).shock = sfill2(shock_label,...
			'Shock size');

% 		label = sprintf(...
% 			'Quarterly %s MPC (%%), out of %s',...
% 			mpc_type, shock_label);
% 		mpcs_stats(ishock).quarterly = sfill2(100 * mpc_obj.mpcs(ishock).quarterly(1), label);
        
        % Check if this works
        for i = 1:5
            label = sprintf(...
			'Quarterly %s MPC (%%), out of %s, t=%d',...
			mpc_type, shock_label,i);
            mpcs_stats(ishock).quarterly(i) = sfill2(100 * mpc_obj.mpcs(ishock).quarterly(i), label);
        end

		label = sprintf(...
			'Annual %s MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).annual = sfill2(100 * mpc_obj.mpcs(ishock).annual, label);

		label = sprintf(...
			'Quarterly %s HtM MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).quarterly_htm = sfill2(100 * mpc_obj.mpcs(ishock).quarterly_htm, label);

		label = sprintf(...
			'Annual %s HtM MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).annual_htm = sfill2(100 * mpc_obj.mpcs(ishock).annual_htm, label);

		label = sprintf(...
			'Quarterly %s WHtM MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).quarterly_whtm = sfill2(100 * mpc_obj.mpcs(ishock).quarterly_whtm, label);

		label = sprintf(...
			'Annual %s WHtM MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).annual_whtm = sfill2(100 * mpc_obj.mpcs(ishock).annual_whtm, label);

		label = sprintf(...
			'Quarterly %s PHtM MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).quarterly_phtm = sfill2(100 * mpc_obj.mpcs(ishock).quarterly_phtm, label);

		label = sprintf(...
			'Annual %s PHtM MPC (%%), out of %s',...
			mpc_type, shock_label);
		mpcs_stats(ishock).annual_phtm = sfill2(100 * mpc_obj.mpcs(ishock).annual_phtm, label);
	end

	if mpc_obj.options.liquid_mpc
		obj.mpcs = mpcs_stats;

		obj.mpcs_over_ss = cell(1, nshocks);
		for ishock = 1:nshocks
			obj.mpcs_over_ss{ishock} =  mpc_obj.mpcs(ishock).mpcs(:,1);
		end
	else
		obj.illiquid_mpcs = mpcs_stats;
        
        obj.illiquid_mpcs_over_ss = cell(1, nshocks);
		for ishock = 1:nshocks
			obj.illiquid_mpcs_over_ss{ishock} =  mpc_obj.mpcs(ishock).mpcs(:,1);
		end
	end
end