function compute_adjust(obj)
% Get fraction of population rebalancing

% Use that:
% If rebalance, you choose to have less total wealth
% weight by pmf

rebalance_frac = sum((obj.wealthmat > (obj.model.rebalance_ba(:,:,:,:,1) + obj.model.rebalance_ba(:,:,:,:,2))) .* obj.pmf, "all");
obj.rebalance_frac = obj.sfill(rebalance_frac, 'Fraction Rebalancing', 2);

end