function make_plots(stats)
    % Make all plots
    plot_wdist(stats);
    


end

function plot_wdist(stats)

% Lowest income (need to normalize for proper conditioning)
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,1)./sum(stats.pmf(:,:,1,1)));
title("Wealth Distribution: Lowest Income");
saveas(gcf, "output/wdist_ylow", "epsc");


end

function plot_mpc(s)

% Size properly
mpc_ss = reshape(stats.mpcs_over_ss{5}, [stats.nb, stats.na, stats.nz, stats.ny]);

% Lowest income
surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,1))



end