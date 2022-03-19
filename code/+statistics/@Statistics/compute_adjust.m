function compute_adjust(obj)
% Get fraction of population rebalancing
% to rebalance

% Use that:
% If rebalance, you choose to have less total wealth
% weight by pmf

% Conditional on being given chance to rebalance
reb_indic = (obj.wealthmat > (obj.model.rebalance_ba(:,:,:,:,1) + obj.model.rebalance_ba(:,:,:,:,2)));
obj.adj_policy = reb_indic;
rebalance_frac = sum(reb_indic .* obj.pmf, "all");

% Multiple with arrival rate to get rebalancing quarterly
rebalance_frac = rebalance_frac * obj.p.rebalance_rate;

% Save
obj.rebalance_frac = obj.sfill(rebalance_frac, 'Fraction Rebalancing (quarterly unconditional)', 2);

% Rebalancing toward liquid
liq_indic = obj.bgrid < obj.model.rebalance_ba(:,:,:,:,1);

liq_frac = sum(liq_indic .* obj.pmf, "all");
liq_frac = liq_frac * obj.p.rebalance_rate;

obj.rebalance_frac_to_liq = obj.sfill(liq_frac, 'Fraction Rebalancing to liquid (quarterly unconditional)', 2);

% Would rebalance after -500 shock -> Must have too little b after shock
% Get index after shock
bloss = obj.bgrid - 0.0074;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_m500 = reb * obj.p.rebalance_rate;

bloss = obj.bgrid - 0.074;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_m5000 = reb * obj.p.rebalance_rate;

bloss = obj.bgrid + 0.0074;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_p500 = reb * obj.p.rebalance_rate;

bloss = obj.bgrid + 0.074;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_p5000 = reb * obj.p.rebalance_rate;

bloss = obj.bgrid + 0.148;
bnew_ind = max(sum(obj.bgrid <= bloss')',1);
indic_loss = (obj.agrid' + obj.bgrid(bnew_ind)) > (obj.model.rebalance_ba(bnew_ind,:,:,:,1) + obj.model.rebalance_ba(bnew_ind,:,:,:,2));
reb = sum(indic_loss .* obj.pmf, "all");

obj.rebalance_p10000 = reb * obj.p.rebalance_rate;


end