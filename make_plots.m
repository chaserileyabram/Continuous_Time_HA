function make_plots(stats, index)
    % Make all plots
    plot_wdist(stats, index);
    


end

function plot_wdist(stats, index)

% Lowest income (need to normalize for proper conditioning)
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,1)./sum(stats.pmf(:,:,1,1)));
title("Wealth Distribution: Lowest Income");
plot_path = sprintf('output/wdist_ylow%d', index);
saveas(gcf, plot_path, "epsc");

% Middle income (need to normalize for proper conditioning)
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,floor(stats.ny/2))./sum(stats.pmf(:,:,1,floor(stats.ny/2))));
title("Wealth Distribution: Middle Income");
plot_path = sprintf('output/wdist_ymid%d', index);
saveas(gcf, plot_path, "epsc");


% Highest income (need to normalize for proper conditioning)
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,stats.ny)./sum(stats.pmf(:,:,1,stats.ny)));
title("Wealth Distribution: Highest Income");
plot_path = sprintf('output/wdist_yhigh%d', index);
saveas(gcf, plot_path, "epsc");

end

function plot_mpc(s)

% Size properly
mpc_ss = reshape(stats.mpcs_over_ss{5}, [stats.nb, stats.na, stats.nz, stats.ny]);

% Lowest income
surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,1))



end