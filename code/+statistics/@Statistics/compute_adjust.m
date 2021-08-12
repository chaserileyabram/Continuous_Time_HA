function compute_adjust(obj)
% Get fraction of population rebalancing
% to rebalance

% Use that:
% If rebalance, you choose to have less total wealth
% weight by pmf

% Conditional on being given chance to rebalance
rebalance_frac = sum((obj.wealthmat > (obj.model.rebalance_ba(:,:,:,:,1) + obj.model.rebalance_ba(:,:,:,:,2))) .* obj.pmf, "all");

% Multiple with arrival rate to get rebalancing quarterly
rebalance_frac = rebalance_frac * obj.p.rebalance_rate;

% Save
obj.rebalance_frac = obj.sfill(rebalance_frac, 'Fraction Rebalancing (quarterly unconditional)', 2);

end