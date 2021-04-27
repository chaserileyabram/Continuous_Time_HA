function [Vstar, rebalance_ba] = optimal_rebalance(Vn, grd, p)
    % Computes optimal rebalancing choice
    % Chase Abram

    % Initialize Vstar (optimal value given rebalance choice)
    Vstar = Vn;
    
    % Initialize optimal b and a (interpolated, not on grid)
    rebalance_ba = zeros(grd.nb, grd.na, grd.nz,grd.ny, 2);

    % Grids for interpolation
    [bg, ag] = ndgrid(grd.b.vec, grd.a.vec);

    
    for yi = 1:grd.ny
        for zi = 1:grd.nz

            % Interpolate Vn over assets
            Vn_int = griddedInterpolant(bg, ag, Vn(:,:,zi,yi));

            for ai = 1:grd.na
                for bi = 1:grd.nb

                    % New b' grid (allows for full conversion into liquid)
                    new_bgrid = linspace(grd.b.vec(1), min(grd.a.vec(ai) + grd.b.vec(bi) - p.rebalance_cost, ...
                        grd.b.vec(grd.nb)), grd.nb)';

                    % a' agrid (a' + b' = a + b - rebalance_cost)
                    new_agrid = max(grd.a.vec(ai) + grd.b.vec(bi) - p.rebalance_cost - new_bgrid, grd.a.vec(1));


                    % Find max over new_bgrid (if adjust)
                    [tmp_max, tmp_ind] = max(Vn_int(new_bgrid,new_agrid));
                    
                    % See if adjust optimal
                    tmp_max = max(tmp_max, Vn(bi,ai,zi,yi));
                    
                    if tmp_max ~= Vn(bi,ai,zi,yi)
                        % Adjust
                        Vstar(bi,ai,zi,yi) = tmp_max;
                        rebalance_ba(bi,ai,zi,yi,:) = [new_bgrid(tmp_ind), new_agrid(tmp_ind)];
                    else
                        % Don't adjust
                        rebalance_ba(bi,ai,zi,yi,:) = [grd.b.vec(bi), grd.a.vec(ai)];
                    end 
                end
            end
        end
    end
end