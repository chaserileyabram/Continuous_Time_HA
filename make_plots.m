% Script for calling below functions to make tables

% Need to open .mat of file(s) that will be used, then create plots.



function make_plots(stats, index)
    % Make all plots
    plot_wdist(stats, index);
    plot_mpcs(stats, index);
    plot_con(stats,index);
end

function plot_wdist(stats, index)

% Lowest income (need to normalize for proper conditioning)
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,1)./sum(stats.pmf(:,:,1,1)));
title("Wealth Distribution: Lowest Income");
plot_path = sprintf('output/wdist_ylow%d', index);
saveas(gcf, plot_path, "epsc");

% Middle income (need to normalize for proper conditioning)
yhalf = floor(stats.ny/2);
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,yhalf)./sum(stats.pmf(:,:,1,yhalf)));
title("Wealth Distribution: Middle Income");
plot_path = sprintf('output/wdist_ymid%d', index);
saveas(gcf, plot_path, "epsc");


% Highest income (need to normalize for proper conditioning)
surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,stats.ny)./sum(stats.pmf(:,:,1,stats.ny)));
title("Wealth Distribution: Highest Income");
plot_path = sprintf('output/wdist_yhigh%d', index);
saveas(gcf, plot_path, "epsc");

end

function plot_mpcs(stats, index)

% For middle income
yhalf = floor(stats.ny/2);

% Liquid
% Size properly
mpc_ss = reshape(stats.mpcs_over_ss{5}, [stats.nb, stats.na, stats.nz, stats.ny]);

% Lowest income
surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,1));
title("Liquid MPCs Distribution ($500): Lowest Income");
plot_path = sprintf('output/mpcs_ylow%d', index);
saveas(gcf, plot_path, "epsc");

% Middle income
surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,yhalf));
title("Liquid MPCs Distribution ($500): Middle Income");
plot_path = sprintf('output/mpcs_ymid%d', index);
saveas(gcf, plot_path, "epsc");

% Highest income
surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,stats.ny));
title("Liquid MPCs Distribution ($500): Highest Income");
plot_path = sprintf('output/mpcs_yhigh%d', index);
saveas(gcf, plot_path, "epsc");


% Illiquid
% Size properly
ill_mpc_ss = reshape(stats.illiquid_mpcs_over_ss{5}, [stats.nb, stats.na, stats.nz, stats.ny]);

% Lowest income
surf(stats.agrid, stats.bgrid, ill_mpc_ss(:,:,1,1));
title("Illiquid MPCs Distribution ($500): Lowest Income");
plot_path = sprintf('output/ill_mpcs_ylow%d', index);
saveas(gcf, plot_path, "epsc");

% Middle income
surf(stats.agrid, stats.bgrid, ill_mpc_ss(:,:,1,yhalf));
title("Illiquid MPCs Distribution ($500): Middle Income");
plot_path = sprintf('output/ill_mpcs_ymid%d', index);
saveas(gcf, plot_path, "epsc");

% Highest income
surf(stats.agrid, stats.bgrid, ill_mpc_ss(:,:,1,stats.ny));
title("Illiquid MPCs Distribution ($500): Highest Income");
plot_path = sprintf('output/ill_mpcs_yhigh%d', index);
saveas(gcf, plot_path, "epsc");

end

function plot_con(stats,index)

% For middle income
yhalf = floor(stats.ny/2);

% 3D
% Lowest income
surf(stats.agrid, stats.bgrid, stats.c_KFE(:,:,1,1));
title("Consumption: Lowest Income");
plot_path = sprintf('output/con3D_ylow%d', index);
saveas(gcf, plot_path, "epsc");

% Middle income
surf(stats.agrid, stats.bgrid, stats.c_KFE(:,:,1,yhalf));
title("Consumption: Middle Income");
plot_path = sprintf('output/con3D_ymid%d', index);
saveas(gcf, plot_path, "epsc");

% Highest income
surf(stats.agrid, stats.bgrid, stats.c_KFE(:,:,1,stats.ny));
title("Consumption: Highest Income");
plot_path = sprintf('output/con3D_yhigh%d', index);
saveas(gcf, plot_path, "epsc");




% Slices

% For middle income
ahalf = floor(stats.na/2);

% con_slice = sum(stats.c_KFE .* stats.pmf, 2)./sum(stats.pmf,2);

    for y = [1, yhalf, stats.ny]
        for a = [1 , ahalf, stats.na]

            plot(stats.bgrid, stats.c_KFE(:,a,1,y));

            if y == 1
                y_str = "Lowest";
                y_path = "low";
            elseif y == stats.ny
                y_str = "Highest";
                y_path = "high";
            else
                y_str = "Middle";
                y_path = "mid";
            end

            if a == 1
                a_str = "Lowest";
                a_path = "low";
            elseif a == stats.na
                a_str = "Highest";
                a_path = "high";
            else
                a_str = "Middle";
                a_path = "mid";
            end

            total_str = append("Consumption: ", y_str, " Income, ", a_str, " Illiquid Wealth");

            title(total_str);
            path_str = append('output/con_y', y_path,'_a', a_path, string(index));
            saveas(gcf, path_str, "epsc");
        end
    end


end





