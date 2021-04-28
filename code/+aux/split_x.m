function [x1, x2, xmix] = split_x(x, xgrid)
    % Maps x not in grid to grid indices by weighting nearest 2 points
    
    % Use different weights for degenerate cases to make errors easier to
    % catch
    if ismember(x,xgrid)
        x1 = sum(xgrid <= x);
        x2 = x1;
        xmix = 0.1;
    elseif x < min(xgrid)
        x1 = 1;
        x2 = 1;
        xmix = 0.2;
    elseif x > max(xgrid)
        x1 = length(xgrid);
        x2 = length(xgrid);
        xmix = 0.3;
    else
        x1 = sum(xgrid < x);
        x2 = x1 + 1;
        disp(x1)
        disp(x2)
        xmix = (xgrid(x2) - x)/(xgrid(x2) - xgrid(x1));
    end
end