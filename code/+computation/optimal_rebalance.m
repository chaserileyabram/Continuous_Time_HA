function [Vstar] = optimal_rebalance(Vn, grd, p)
% Computes optimal rebalancing choice, given that rebalancing is occuring
% Chase Abram

rebalancecost = 0.5;

tmpF = griddedInterpolant(tmpb,tmpa,Vn(:,:,1,1))

for yi = 1:grd.ny
    for zi = 1:grd.nz
        for ai = 1:grd.na
            for bi = 1:grd.nb
                
                new_bgrid = linspace(grd.b.vec(1), grd.a.vec(ai) + grd.b.vec(bi) - rebalancecost, numel(grd.b.vec))';
        
        
        






end