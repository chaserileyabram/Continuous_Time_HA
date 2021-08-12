% Script for calling below functions to make tables
clear

% Need to open .mat of file(s) that will be used, then create plots.

% Load baseline 2A
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-10-2021-21:00:50/output_1.mat')

%% 1) MPC
% Load baseline 1A
cd('/Users/chaseabram/UChiGit/Discrete_HA')
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables2.mat')



%% 2) MPC with beta het


%% 3) MPC with rate of return het


%% 4) MPC with EZ, RRA = 1, IES het



%% 5) MPC surface
% Load baseline 2A
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-10-2021-21:00:50/output_1.mat')
% point in each dim
% n = 100;
% curve = 0.1;
% % b from 0 to 1
% bs = linspace(0,1,n);
% bs = bs .^ (1/curve);
% full_bs = repmat(bs', [1 3*n]);
% as = linspace(0,3,3*n);
% full_as = repmat(as, [n 1]);
% mpcs = stats.mpc_int(full_bs,full_as);
% surf(as, bs, mpcs)
% title('MPC vs. (Liquid Wealth, Illiquid Wealth)')
% xlabel('a'), ylabel('a'), zlabel('MPC (%)')
% view(130, 30);
% plot_path = sprintf('output/mpc_ab');
% saveas(gcf, plot_path, "epsc");


%% 6) MPC by total wealth (2A)
n = 100;
curve = 0.1;
ws = linspace(0,1,n);
ws = ws .^ (1/curve);
ws = ws .* 3;
mpcs_25 = mpc_wealth_quantile(stats, ws, 0.25);
mpcs_m = mpc_wealth_mean(stats, ws);
mpcs_75 = mpc_wealth_quantile(stats, ws, 0.75);

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = ((stats.bgrid + stats.agrid') > hist_chunks(i-1)) .* ((stats.bgrid + stats.agrid') <= hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_b_a .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');

p = bar(hist_locs, hist_mass);
p.FaceAlpha = 0.5;
xlim([0 3])
hold on
plot(ws,mpcs_m)
title('MPC vs. Total Wealth')
xlabel('Total Wealth')
hold on
plot(ws, mpcs_25, ':')
hold on
plot(ws, mpcs_75, '*')
legend('Mass', 'Mean', 'First Quartile', 'Third Quartile')

plot_path = sprintf('output/mpc_w');
saveas(gcf, plot_path, "epsc");

%% 7) MPC by total wealth 2A + 1A



%% 8) MPC by total wealth 2A + (1A with beta het)


%% Functions

function mpc_wq = mpc_wealth_quantile(s,ws,q)
    for i = 1:length(ws)
        bs = linspace(0,ws(i),100);
        as = ws(i) - bs;
        pmfs = s.pmf_int(bs, as);
        pmfs = pmfs ./ sum(pmfs,'all');
        mpcs = s.mpc_int(bs, as);

        cdf_int = aux.pctile_interpolant(mpcs, pmfs);

        mpc_wq(i) = cdf_int(q);
    end
end

% Need to write function for mean at w also
function mpc_w = mpc_wealth_mean(s,ws)
    for i = 1:length(ws)
        bs = linspace(0,ws(i),100);
        as = ws(i) - bs;
        pmfs = s.pmf_int(bs, as);
        pmfs = pmfs ./ sum(pmfs,'all');
        mpcs = s.mpc_int(bs, as);

        cdf_int = aux.pctile_interpolant(mpcs, pmfs);

        mpc_w(i) = sum(mpcs .* pmfs, 'all');
    end
end



%%


% function make_plots(stats, index)
%     % Make all plots
%     plot_wdist(stats, index);
%     plot_mpcs(stats, index);
%     plot_con(stats,index);
% end

% function plot_wdist(stats, index)
% 
% % Lowest income (need to normalize for proper conditioning)
% surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,1)./sum(stats.pmf(:,:,1,1)));
% title("Wealth Distribution: Lowest Income");
% plot_path = sprintf('output/wdist_ylow%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Middle income (need to normalize for proper conditioning)
% yhalf = floor(stats.ny/2);
% surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,yhalf)./sum(stats.pmf(:,:,1,yhalf)));
% title("Wealth Distribution: Middle Income");
% plot_path = sprintf('output/wdist_ymid%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% 
% % Highest income (need to normalize for proper conditioning)
% surf(stats.agrid, stats.bgrid, stats.pmf(:,:,1,stats.ny)./sum(stats.pmf(:,:,1,stats.ny)));
% title("Wealth Distribution: Highest Income");
% plot_path = sprintf('output/wdist_yhigh%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% end
% 
% function plot_mpcs(stats, index)
% 
% % For middle income
% yhalf = floor(stats.ny/2);
% 
% % Liquid
% % Size properly
% mpc_ss = reshape(stats.mpcs_over_ss{5}, [stats.nb, stats.na, stats.nz, stats.ny]);
% 
% % Lowest income
% surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,1));
% title("Liquid MPCs Distribution ($500): Lowest Income");
% plot_path = sprintf('output/mpcs_ylow%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Middle income
% surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,yhalf));
% title("Liquid MPCs Distribution ($500): Middle Income");
% plot_path = sprintf('output/mpcs_ymid%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Highest income
% surf(stats.agrid, stats.bgrid, mpc_ss(:,:,1,stats.ny));
% title("Liquid MPCs Distribution ($500): Highest Income");
% plot_path = sprintf('output/mpcs_yhigh%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% 
% % Illiquid
% % Size properly
% ill_mpc_ss = reshape(stats.illiquid_mpcs_over_ss{5}, [stats.nb, stats.na, stats.nz, stats.ny]);
% 
% % Lowest income
% surf(stats.agrid, stats.bgrid, ill_mpc_ss(:,:,1,1));
% title("Illiquid MPCs Distribution ($500): Lowest Income");
% plot_path = sprintf('output/ill_mpcs_ylow%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Middle income
% surf(stats.agrid, stats.bgrid, ill_mpc_ss(:,:,1,yhalf));
% title("Illiquid MPCs Distribution ($500): Middle Income");
% plot_path = sprintf('output/ill_mpcs_ymid%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Highest income
% surf(stats.agrid, stats.bgrid, ill_mpc_ss(:,:,1,stats.ny));
% title("Illiquid MPCs Distribution ($500): Highest Income");
% plot_path = sprintf('output/ill_mpcs_yhigh%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% end
% 
% function plot_con(stats,index)
% 
% % For middle income
% yhalf = floor(stats.ny/2);
% 
% % 3D
% % Lowest income
% surf(stats.agrid, stats.bgrid, stats.c_KFE(:,:,1,1));
% title("Consumption: Lowest Income");
% plot_path = sprintf('output/con3D_ylow%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Middle income
% surf(stats.agrid, stats.bgrid, stats.c_KFE(:,:,1,yhalf));
% title("Consumption: Middle Income");
% plot_path = sprintf('output/con3D_ymid%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% % Highest income
% surf(stats.agrid, stats.bgrid, stats.c_KFE(:,:,1,stats.ny));
% title("Consumption: Highest Income");
% plot_path = sprintf('output/con3D_yhigh%d', index);
% saveas(gcf, plot_path, "epsc");
% 
% 
% 
% 
% % Slices
% 
% % For middle income
% ahalf = floor(stats.na/2);
% 
% % con_slice = sum(stats.c_KFE .* stats.pmf, 2)./sum(stats.pmf,2);
% 
%     for y = [1, yhalf, stats.ny]
%         for a = [1 , ahalf, stats.na]
% 
%             plot(stats.bgrid, stats.c_KFE(:,a,1,y));
% 
%             if y == 1
%                 y_str = "Lowest";
%                 y_path = "low";
%             elseif y == stats.ny
%                 y_str = "Highest";
%                 y_path = "high";
%             else
%                 y_str = "Middle";
%                 y_path = "mid";
%             end
% 
%             if a == 1
%                 a_str = "Lowest";
%                 a_path = "low";
%             elseif a == stats.na
%                 a_str = "Highest";
%                 a_path = "high";
%             else
%                 a_str = "Middle";
%                 a_path = "mid";
%             end
% 
%             total_str = append("Consumption: ", y_str, " Income, ", a_str, " Illiquid Wealth");
% 
%             title(total_str);
%             path_str = append('output/con_y', y_path,'_a', a_path, string(index));
%             saveas(gcf, path_str, "epsc");
%         end
%     end
% 
% 
% end





