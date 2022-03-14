function compute_adjust(obj)
% Get fraction of population rebalancing
% to rebalance

% Use that:
% If rebalance, you choose to have less total wealth
% weight by pmf

% Conditional on being given chance to rebalance
reb_indic = (obj.wealthmat > (obj.model.rebalance_ba(:,:,:,:,1) + obj.model.rebalance_ba(:,:,:,:,2)));
rebalance_frac = sum(reb_indic .* obj.pmf, "all");

% Multiple with arrival rate to get rebalancing quarterly
rebalance_frac = rebalance_frac * obj.p.rebalance_rate;

% Save
obj.rebalance_frac = obj.sfill(rebalance_frac, 'Fraction Rebalancing (quarterly unconditional)', 2);

% Would rebalance after -500 shock -> Must have too little b after shock
% Get index after shock
bloss = obj.bgrid - 0.0074;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb_500 = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_500 = reb_500 * obj.p.rebalance_rate;

bloss = obj.bgrid - 0.074;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb_5000 = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_5000 = reb_5000 * obj.p.rebalance_rate;


end