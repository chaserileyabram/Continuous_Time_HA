function [Vstar, rebalance_ba] = optimal_rebalance(Vn, grd, p)
    % Computes optimal rebalancing choice
    % Chase Abram

    % Initialize Vstar (optimal value given rebalance choice)
    Vstar = Vn;
    
    % Initialize optimal b and a (will be interpolated, not on grid)
    rebalance_ba = zeros(grd.nb, grd.na, grd.nz, grd.ny, 2);
    rebalance_ba(:,:,:,:,1) = repmat(grd.b.vec, 1,grd.na,grd.nz,grd.ny);
    rebalance_ba(:,:,:,:,2) = repmat(grd.a.vec', grd.nb,1,grd.nz,grd.ny);
    
    
    % Speed up when rebalancing never allowed
    if p.rebalance_rate ~= 0
        
        for yi = 1:grd.ny
            for zi = 1:grd.nz
                
                % Construct grid of wealth levels
                bpfracs = linspace(0, 1, grd.nb);
                bpfracs = shiftdim(bpfracs, -1);
                wp = grd.b.vec + shiftdim(grd.a.vec, -1) - p.rebalance_cost;

                % Construct grids of bprime and aprime
                bprime = min(bpfracs .* (wp - grd.b.vec(1)), grd.b.vec(grd.nb));
                aprime = grd.b.vec + shiftdim(grd.a.vec, -1) - p.rebalance_cost - bprime;

                % Interpolate value function
                asset_grids = {grd.b.vec, grd.a.vec};
                vinterp = griddedInterpolant(asset_grids, Vn(:,:,zi,yi), 'linear');

                % Get rebalance values on grid
                value_bp_ap = vinterp(bprime(:), aprime(:));
                value_bp_ap = reshape(value_bp_ap, grd.nb, grd.na, grd.nb);
                
                % Get values and indices along grid
                [W, max_ind] = max(value_bp_ap, [], 3);
                Vstar(:,:,zi,yi) = W .* (W > Vn(:,:,zi,yi)) + Vn(:,:,zi,yi) .* (W <= Vn(:,:,zi,yi));
                rebalance_ba(:,:,zi,yi,1) = bprime(max_ind) .* (W > Vn(:,:,zi,yi)) + rebalance_ba(:,:,zi,yi,1) .* (W <= Vn(:,:,zi,yi));
                rebalance_ba(:,:,zi,yi,2) = aprime(max_ind) .* (W > Vn(:,:,zi,yi)) + rebalance_ba(:,:,zi,yi,2) .* (W <= Vn(:,:,zi,yi));
                
            end
        end
        
        
        

        % Grids for interpolation
%         [bg, ag] = ndgrid(grd.b.vec, grd.a.vec);
        
        % Check if dims singular
        % Build grid and interpolant
%         if grd.nz == 1 && grd.ny == 1
%             grids = {grd.b.vec, grd.a.vec};
%             Vn_int = griddedInterpolant(grids, squeeze(Vn(:,:,1,1)));
%         elseif grd.nz == 1
%             grids = {grd.b.vec, grd.a.vec, linspace(1,size(Vn,4), size(Vn,4))'};
%             Vn_int = griddedInterpolant(grids, squeeze(Vn(:,:,1,:)));
%         elseif grd.ny == 1
%             grids = {grd.b.vec, grd.a.vec, linspace(1,size(Vn,3), size(Vn,3))'};
%             Vn_int = griddedInterpolant(grids, squeeze(Vn(:,:,:,1)));
%         else
%             grids = {grd.b.vec, grd.a.vec, linspace(1,size(Vn,3), size(Vn,3))', linspace(1,size(Vn,4), size(Vn,4))'};
%             Vn_int = griddedInterpolant(grids, Vn);
%         end


%         for yi = 1:grd.ny
%             for zi = 1:grd.nz
%                 for ai = 1:grd.na
%                     for bi = 1:grd.nb
%                         
%                         % New b' grid (allows for full conversion into liquid)
%                         new_bgrid = linspace(grd.b.vec(1), min(grd.a.vec(ai) + grd.b.vec(bi) - p.rebalance_cost, ...
%                             grd.b.vec(grd.nb)), grd.nb)';
% 
%                         % a' agrid (a' + b' = a + b - rebalance_cost)
%                         new_agrid = max(grd.a.vec(ai) + grd.b.vec(bi) - p.rebalance_cost - new_bgrid, grd.a.vec(1));
%                         
%                         % Check if dim singular
%                         if grd.nz == 1 && grd.ny == 1
%                             [tmp_max, tmp_ind] = max(Vn_int(new_bgrid,new_agrid));
%                         elseif grd.nz == 1
%                             [tmp_max, tmp_ind] = max(Vn_int(new_bgrid,new_agrid, yi*ones(grd.nb,1)));
%                         elseif grd.ny == 1
%                             [tmp_max, tmp_ind] = max(Vn_int(new_bgrid,new_agrid, zi*ones(grd.nb,1)));
%                         else
%                             [tmp_max, tmp_ind] = max(Vn_int(new_bgrid,new_agrid, zi*ones(grd.nb,1), yi*ones(grd.nb,1)));
%                         end
% 
%                         % See if adjust optimal
%                         tmp_max = max(tmp_max, Vn(bi,ai,zi,yi));
% 
%                         if tmp_max ~= Vn(bi,ai,zi,yi)
%                             % Adjust
%                             Vstar(bi,ai,zi,yi) = tmp_max;
%                             rebalance_ba(bi,ai,zi,yi,:) = [new_bgrid(tmp_ind), new_agrid(tmp_ind)];
%                         end
% 
%                     end
%                 end
%             end
%         end
    end
end