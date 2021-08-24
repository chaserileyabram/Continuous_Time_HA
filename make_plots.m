% Script for calling below functions to make tables
clear

% Need to open .mat of file(s) that will be used, then create plots.

%% 1a) MPC
clear
% Load baseline 1A
cd('/Users/chaseabram/UChiGit/Discrete_HA')
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables2.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = sum(results.stats.pmf, 2);


mpcs_b = sum(mpcs .* results.stats.pmf, 2) ./ pmf_b;

bg = ndgrid(results.stats.agrid);

pmf_htm = sum(results.stats.pmf .* (bg < 1000/Sparams.numeraire_in_dollars), 2)./ sum(results.stats.pmf .* (bg < 1000/Sparams.numeraire_in_dollars), 'all');

mpc_int = griddedInterpolant(bg, mpcs_b,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0.6,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;


% Make histogram data
m = 40;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_mass_htm = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass(i-1) = sum(pmf_b .* in_chunk, 'all');
    hist_mass_htm(i-1) = sum(pmf_htm .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_mass_htm(m-1) = 1 - sum(hist_mass_htm(1:m-2), 'all');
hist_mass_htm = hist_mass_htm .* sum(results.stats.pmf .* (bg < 1000/Sparams.numeraire_in_dollars), 'all');
hist_mass = hist_mass - hist_mass_htm;

total_mass = [hist_mass_htm hist_mass];

p = bar(hist_locs, total_mass, 'stacked', 'BarWidth', 1);
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;
xlim([0 3])
ylim([0 1.0])
hold on
plot(bs, mpc_int(bs), 'LineWidth', 5, 'color', 'black');
% title('Baseline 1A');
xlabel('Wealth');
legend('HtM', 'Non NHtM', 'MPC', 'Location', 'north');
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_1A_base.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 1b) MPC with Ea = 0.56
clear
% Load baseline 1A
cd('/Users/chaseabram/UChiGit/Discrete_HA')
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables10.mat')
disp(Sparams.descr{1})
mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = sum(results.stats.pmf, 2);

mpcs_b = sum(mpcs .* results.stats.pmf, 2) ./ pmf_b;

bg = ndgrid(results.stats.agrid);

pmf_htm = sum(results.stats.pmf .* (bg < 1000/Sparams.numeraire_in_dollars), 2)./ sum(results.stats.pmf .* (bg < 1000/Sparams.numeraire_in_dollars), 'all');

mpc_int = griddedInterpolant(bg, mpcs_b,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0.6,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;


% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_mass_htm = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass(i-1) = sum(pmf_b .* in_chunk, 'all');
    hist_mass_htm(i-1) = sum(pmf_htm .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_mass_htm(m-1) = 1 - sum(hist_mass_htm(1:m-2), 'all');
hist_mass_htm = hist_mass_htm .* sum(results.stats.pmf .* (bg < 1000/Sparams.numeraire_in_dollars), 'all');
hist_mass = hist_mass - hist_mass_htm;

total_mass = [hist_mass_htm hist_mass];

p = bar(hist_locs, total_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;
xlim([0 3])
ylim([0 0.7])
hold on
plot(bs, mpc_int(bs), 'LineWidth', 5, 'color', 'black');
% title('1A, E[a] = 0.56');
xlabel('Wealth');
legend('HtM', 'Non HtM', 'MPC', 'Location', 'north');
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_1A_Ea056.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);


%% 2a) MPC with beta het
clear
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables22.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = results.stats.pmf_a;
pmf_low = sum(results.stats.pmf(:,:,:,1:2), [2 4]) ./ sum(results.stats.pmf(:,:,:,1:2), 'all'); 

mpcs_low = sum(mpcs(:,:,:,1:2) .* results.stats.pmf(:,:,:,1:2), [2 4]) ./ sum(results.stats.pmf(:,:,:,1:2), [2 4]);
% mpcs_mid = sum(mpcs(:,:,:,3) .* results.stats.pmf(:,:,:,3), 2) ./ sum(results.stats.pmf(:,:,:,3), 2);
mpcs_high = sum(mpcs(:,:,:,5) .* results.stats.pmf(:,:,:,5), 2) ./ sum(results.stats.pmf(:,:,:,5), 2);

bg = ndgrid(results.stats.agrid);

mpc_int_low = griddedInterpolant(bg, mpcs_low,'linear','none');
% mpc_int_mid = griddedInterpolant(bg, mpcs_mid,'linear','none');
mpc_int_high = griddedInterpolant(bg, mpcs_high,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0.6,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;


% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_low_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass(i-1) = sum(pmf_b .* in_chunk, 'all');
    hist_low_mass(i-1) = sum(pmf_low .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_low_mass(m-1) = 1 - sum(hist_low_mass(1:m-2), 'all');


hist_low_mass = hist_low_mass .* sum(results.stats.pmf(:,:,:,1:2), 'all');

hist_mass = hist_mass - hist_low_mass;

total_hist = [hist_low_mass hist_mass];

p = bar(hist_locs, total_hist, 'stacked');

% p = bar(hist_locs, hist_mass);
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;
xlim([0 3])
ylim([0 0.7])
hold on
% p2 = bar(hist_locs, hist_low_mass);
% p2.FaceAlpha = 0.5;
% hold on
plot(bs, mpc_int_low(bs), 'LineWidth', 5, 'color', 'black');
hold on
% plot(bs, mpc_int_mid(bs), 'LineWidth', 5, 'color', 'black');
% hold on
plot(bs, mpc_int_high(bs), 'LineWidth', 5, 'LineStyle', '--', 'color', 'black');
legend('Low \beta s', 'Other \beta s', 'MPC Low \beta s', 'MPC High \beta', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
% title('Heterogeneous Discount Factor');
xlabel('Wealth');

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_beta_het.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 2b) MPC with beta het, betaH cal to hit total wealth (and does well on MPC)
clear
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables55.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = results.stats.pmf_a;
pmf_low = sum(results.stats.pmf(:,:,:,1), 2) ./ sum(results.stats.pmf(:,:,:,1), 'all'); 

mpcs_low = sum(mpcs(:,:,:,1) .* results.stats.pmf(:,:,:,1), 2) ./ sum(results.stats.pmf(:,:,:,1), 2);
mpcs_high = sum(mpcs(:,:,:,2) .* results.stats.pmf(:,:,:,2), 2) ./ sum(results.stats.pmf(:,:,:,2), 2);

bg = ndgrid(results.stats.agrid);

mpc_int_low = griddedInterpolant(bg, mpcs_low,'linear','none');
p_low = polyfit(bg(1:175), mpcs_low(1:175), 80);
mpc_int_low = @(x) polyval(p_low, x);
mpc_int_high = griddedInterpolant(bg, mpcs_high,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;


% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_low_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass(i-1) = sum(pmf_b .* in_chunk, 'all');
    hist_low_mass(i-1) = sum(pmf_low .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_low_mass(m-1) = 1 - sum(hist_low_mass(1:m-2), 'all');


hist_low_mass = hist_low_mass .* sum(results.stats.pmf(:,:,:,1), 'all');

hist_mass = hist_mass - hist_low_mass;

total_hist = [hist_low_mass hist_mass];

p = bar(hist_locs, total_hist, 'stacked');

% p = bar(hist_locs, hist_mass);
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;
xlim([0.07 3])
ylim([0 0.7])
hold on
% p2 = bar(hist_locs, hist_low_mass);
% p2.FaceAlpha = 0.5;
% hold on
% cut = 82;
% bs1 = bs(1:cut);
% bs2 = bs(cut+1:end);
% plot(bs1, mpc_int_low(bs1), 'LineWidth', 5, 'color', 'black');
% hold on
% plot(bs2, mpc_int_low(bs2), 'LineWidth', 5, 'LineStyle', ':', 'color', 'black');
% hold on
% plot(bs, mpc_int_mid(bs), 'LineWidth', 5, 'color', 'black');
% hold on
plot(bs, mpc_int_high(bs), 'LineWidth', 5, 'LineStyle', '--', 'color', 'black');
legend('Spender', 'Saver', 'MPC Saver', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
% title('Heterogeneous Discount Factor');
xlabel('Wealth');

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_beta_het_Hcal.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);


%% 3) MPC with CRRA het
clear
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables30.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = results.stats.pmf_a;
% pmf_low = sum(results.stats.pmf(:,:,:,1), 2) ./ sum(results.stats.pmf(:,:,:,1), 'all'); 
pmf_high = sum(results.stats.pmf(:,:,:,5), 2) ./ sum(results.stats.pmf(:,:,:,5), 'all'); 

mpcs_low = sum(mpcs(:,:,:,1) .* results.stats.pmf(:,:,:,1), 2) ./ sum(results.stats.pmf(:,:,:,1), 2);
mpcs_mid = sum(mpcs(:,:,:,3) .* results.stats.pmf(:,:,:,3), 2) ./ sum(results.stats.pmf(:,:,:,3), 2);
mpcs_high = sum(mpcs(:,:,:,5) .* results.stats.pmf(:,:,:,5), 2) ./ sum(results.stats.pmf(:,:,:,5), 2);

bg = ndgrid(results.stats.agrid);

mpc_int_low = griddedInterpolant(bg, mpcs_low,'linear','none');
mpc_int_mid = griddedInterpolant(bg, mpcs_mid,'linear','none');
mpc_int_high = griddedInterpolant(bg, mpcs_high,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0.6,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;


% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);
% hist_low_mass = zeros(m-1,1);
hist_high_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass(i-1) = sum(pmf_b .* in_chunk, 'all');
%     hist_low_mass(i-1) = sum(pmf_low .* in_chunk, 'all');
    hist_high_mass(i-1) = sum(pmf_high .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
% hist_low_mass(m-1) = 1 - sum(hist_low_mass(1:m-2), 'all');
hist_high_mass(m-1) = 1 - sum(hist_high_mass(1:m-2), 'all');

hist_high_mass = hist_high_mass .* sum(results.stats.pmf(:,:,:,5), 'all');
hist_mass = hist_mass - hist_high_mass;

total_mass = [hist_high_mass hist_mass];

p = bar(hist_locs, total_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;

% p = bar(hist_locs, hist_mass);
% p.FaceAlpha = 0.5;
xlim([0 3])
ylim([0 0.7])
hold on
% p2 = bar(hist_locs, hist_low_mass);
% p2 = bar(hist_locs, hist_high_mass);
% p2.FaceAlpha = 0.5;
% hold on
plot(bs, mpc_int_low(bs), 'LineWidth', 3, 'LineStyle', '--', 'color', 'black');
hold on
plot(bs, mpc_int_mid(bs), 'LineWidth', 3, 'color', 'black');
hold on
plot(bs, mpc_int_high(bs), 'LineWidth', 3, 'LineStyle', ':', 'color', 'black');
legend('High RRA', 'Other RRA', 'MPC Low RRA', 'MPC Middle RRA', 'MPC High RRA', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
% title('Heterogeneous RRA=IES');
xlabel('Wealth');

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_rra_het.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);


%% 4) MPC with EZ, RRA = 1, IES het
clear
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables37.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = results.stats.pmf_a;
% pmf_low = sum(results.stats.pmf(:,:,:,1), 2) ./ sum(results.stats.pmf(:,:,:,1), 2);
pmf_high = sum(results.stats.pmf(:,:,:,5), 2) ./ sum(results.stats.pmf(:,:,:,5), 'all');

mpcs_low = sum(mpcs(:,:,:,1) .* results.stats.pmf(:,:,:,1), 2) ./ sum(results.stats.pmf(:,:,:,1), 2);
% mpcs_mid = sum(mpcs(:,:,:,3) .* results.stats.pmf(:,:,:,3), 2) ./ sum(results.stats.pmf(:,:,:,3), 2);
mpcs_high = sum(mpcs(:,:,:,5) .* results.stats.pmf(:,:,:,5), 2) ./ sum(results.stats.pmf(:,:,:,5), 2);

bg = ndgrid(results.stats.agrid);

mpc_int_low = griddedInterpolant(bg, mpcs_low,'linear','none');
% mpc_int_mid = griddedInterpolant(bg, mpcs_mid,'linear','none');
mpc_int_high = griddedInterpolant(bg, mpcs_high,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0.6,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;


% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);
% hist_low_mass = zeros(m-1,1);
hist_high_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass(i-1) = sum(pmf_b .* in_chunk, 'all');
%     hist_low_mass(i-1) = sum(pmf_low .* in_chunk, 'all');
    hist_high_mass(i-1) = sum(pmf_high .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_high_mass(m-1) = 1 - sum(hist_high_mass(1:m-2), 'all');


hist_high_mass = hist_high_mass .* sum(results.stats.pmf(:,:,:,5), 'all');
hist_mass = hist_mass - hist_high_mass;

total_mass = [hist_high_mass hist_mass];

p = bar(hist_locs, total_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;

% p = bar(hist_locs, hist_mass);
% p.FaceAlpha = 0.5;
xlim([0 3])
ylim([0 0.7])
hold on
% bar(hist_locs, hist_low_mass);
% p2 = bar(hist_locs, hist_high_mass);
% p2.FaceAlpha = 0.5;
% hold on
plot(bs, mpc_int_high(bs), 'LineWidth', 3, 'color', 'black');
hold on
% plot(bs, mpc_int_mid(bs), 'LineWidth', 3, 'color', 'black');
% hold on
plot(bs, mpc_int_low(bs), 'LineWidth', 3, 'LineStyle', '--', 'color', 'black');
legend('High IES', 'Other IES', 'MPC High IES', 'MPC Low IES', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
% title('Epstein-Zin, Heterogeneous IES');
xlabel('Wealth');

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_ez_het_ies.pdf');
saveas(gcf, plot_path);
% saveas(gcf, plot_path, "epsc");


%% 5) MPC surface
clear
% Load baseline 2A
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')
% point in each dim
n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0,1,n);
bs = bs .^ (1/curve);
full_bs = repmat(bs', [1 3*n]);
as = linspace(0,1,3*n);
as = as .^ (1/curve);
as = 3 .* as;
full_as = repmat(as, [n 1]);
mpcs = stats.mpc_int(full_bs,full_as);
p = surf(as, bs, mpcs, 'edgecolor', 'none');
% title('MPC vs. (Liquid Wealth, Illiquid Wealth)')
xlabel('a'), ylabel('b'), zlabel('MPC (%)')
ax = gca;
ax.FontSize = 14;
% set(p, 'Xdir', 'reverse');
view(220, 30);
% view(30, 30);

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_ab.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);


%% 6a) MPC by total wealth (2A)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

n = 100;
curve = 0.1;
ws = linspace(0,1,n);
ws = ws .^ (1/curve);
ws = ws .* 3;
mpcs_25 = mpc_wealth_quantile(stats, ws, 0.25) ./ 100;
mpcs_m = mpc_wealth_mean(stats, ws) ./ 100;
mpcs_75 = mpc_wealth_quantile(stats, ws, 0.75) ./ 100;

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = ((stats.bgrid + stats.agrid') >= hist_chunks(i-1)) .* ((stats.bgrid + stats.agrid') < hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_b_a .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');

p = bar(hist_locs, hist_mass);
p.FaceAlpha = 0.5;
xlim([0 3])
ylim([0 0.7])
hold on
plot(ws, mpcs_25, 'LineWidth', 3, 'LineStyle', '--', 'color', 'black')
% title('MPC vs. Total Wealth')
xlabel('Total Wealth')
hold on
plot(ws,mpcs_m, 'LineWidth', 3, 'color', 'black')
hold on
plot(ws, mpcs_75, 'LineWidth', 3, 'LineStyle', ':', 'color', 'black')
legend('Mass','MPC First Quartile', 'MPC Mean', 'MPC Third Quartile', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
xlabel('Wealth');

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_w_2A.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 6a (avg above) MPC by total wealth (2A)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

n = 100;
curve = 0.1;
ws = linspace(0,1,n);
ws = ws .^ (1/curve);
ws = ws .* 3;
mpcs_25 = mpc_wealth_quantile(stats, ws, 0.25) ./ 100;
mpcs_m = mpc_wealth_mean(stats, ws) ./ 100;
mpcs_75 = mpc_wealth_quantile(stats, ws, 0.75) ./ 100;

% Last point
[bg, ag] = ndgrid(stats.bgrid, stats.agrid);
last_mpc = sum(stats.mpc_int(bg,ag) ./ 100 .* stats.pmf_b_a .* ((bg + ag) >= 3), 'all') ./ sum(stats.pmf_b_a .* ((bg + ag) >= 3), 'all');

mpcs_m(end) = last_mpc;

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass = zeros(m-1,1);

for i = 2:m
    in_chunk = ((stats.bgrid + stats.agrid') >= hist_chunks(i-1)) .* ((stats.bgrid + stats.agrid') < hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_b_a .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');

p = bar(hist_locs, hist_mass);
p.FaceAlpha = 0.5;
xlim([0 3])
ylim([0 0.7])
hold on
plot(ws, mpcs_25, 'LineWidth', 3, 'LineStyle', '--', 'color', 'black')
% title('MPC vs. Total Wealth (include above MPCs)')
xlabel('Total Wealth')
hold on
plot(ws,mpcs_m, 'LineWidth', 3, 'color', 'black')
hold on
plot(ws, mpcs_75, 'LineWidth', 3, 'LineStyle', ':', 'color', 'black')
legend('Mass','MPC First Quartile', 'MPC Mean', 'MPC Third Quartile', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
xlabel('Wealth');

cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_w_2A_above.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 6bi) MPC by liquid wealth (with HtM bars) (2A)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

n = 100;
max_l = 3.0;
curve = 0.1;
bs = linspace(0,1,n);
bs = bs .^ (1/curve);
bs = bs .* max_l;
mpc_l = mpc_liquid_mean(stats,bs) ./ 100;

[bg, ag, yg] = ndgrid(stats.bgrid, stats.agrid, income.y.vec);
pmf_b_a_y = squeeze(stats.pmf);

% htm_thresh = 1000/p.numeraire_in_dollars;
htm_thresh = yg/6;

% pmf_htm = stats.pmf_b_a .* (bg <= HtM_1000) ./ sum(stats.pmf_b_a .* (bg <= HtM_1000), 'all');
% pmf_htm = pmf_b_a_y .* (bg <= yg/6) ./ sum(pmf_b_a_y .* (bg <= yg/6), 'all');
pmf_htm = pmf_b_a_y .* (bg <= htm_thresh) ./ sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');
pmf_htm = sum(pmf_htm, [2 3]);


% Make histogram data
m = 8;
hist_chunks = linspace(0,max_l,m);
hist_locs = linspace(max_l/(2*m),max_l - max_l/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_mass_htm = zeros(m-1,1);

for i = 2:m
    in_chunk = (stats.bgrid >= hist_chunks(i-1)) .* (stats.bgrid < hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_b .* in_chunk, 'all');
    hist_mass_htm(i-1) = sum(pmf_htm .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_mass_htm(m-1) = 1 - sum(hist_mass_htm(1:m-2), 'all');

hist_mass_htm = hist_mass_htm .* sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');

hist_mass = hist_mass - hist_mass_htm;

total_mass = [hist_mass_htm hist_mass];

p = bar(hist_locs, total_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;

xlim([0 max_l])
ylim([0 0.9])
hold on
plot(bs, mpc_l, 'LineWidth', 3, 'color', 'black')
% title('MPC vs. Liquid Wealth')
xlabel('Liquid Wealth')
legend('HtM', 'Non HtM','MPC', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_l_2A.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 6bii) MPC by liquid wealth (with HtM bars), fixed rb (2A)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-22-2021-23:02:15/output_20.mat')

n = 100;
max_l = 3.0;
curve = 0.1;
bs = linspace(0,1,n);
bs = bs .^ (1/curve);
bs = bs .* max_l;
mpc_l = mpc_liquid_mean(stats,bs) ./ 100;

[bg, ag, yg] = ndgrid(stats.bgrid, stats.agrid, income.y.vec);
pmf_b_a_y = squeeze(stats.pmf);

% htm_thresh = 1000/p.numeraire_in_dollars;
htm_thresh = yg/6;

% pmf_htm = stats.pmf_b_a .* (bg <= HtM_1000) ./ sum(stats.pmf_b_a .* (bg <= HtM_1000), 'all');
% pmf_htm = pmf_b_a_y .* (bg <= yg/6) ./ sum(pmf_b_a_y .* (bg <= yg/6), 'all');
pmf_htm = pmf_b_a_y .* (bg <= htm_thresh) ./ sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');
pmf_htm = sum(pmf_htm, [2 3]);


% Make histogram data
m = 8;
hist_chunks = linspace(0,max_l,m);
hist_locs = linspace(max_l/(2*m),max_l - max_l/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_mass_htm = zeros(m-1,1);

for i = 2:m
    in_chunk = (stats.bgrid >= hist_chunks(i-1)) .* (stats.bgrid < hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_b .* in_chunk, 'all');
    hist_mass_htm(i-1) = sum(pmf_htm .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_mass_htm(m-1) = 1 - sum(hist_mass_htm(1:m-2), 'all');

hist_mass_htm = hist_mass_htm .* sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');

hist_mass = hist_mass - hist_mass_htm;

total_mass = [hist_mass_htm hist_mass];

p = bar(hist_locs, total_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;

xlim([0 max_l])
ylim([0 0.9])
hold on
plot(bs, mpc_l, 'LineWidth', 3, 'color', 'black')
% title('MPC vs. Liquid Wealth')
xlabel('Liquid Wealth')
legend('HtM', 'Non HtM','MPC', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_l_2A_rbgap.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 6c) MPC by illiquid wealth (2A)
% clear
% cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
% load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')
% 
% n = 100;
% max_i = 3.0;
% curve = 0.1;
% as = linspace(0.6,1,n);
% as = as .^ (1/curve);
% as = as .* max_i;
% mpc_i = mpc_illiquid_mean(stats,as) ./ 100;
% 
% % Make histogram data
% m = 8;
% hist_chunks = linspace(0,max_i,m);
% hist_locs = linspace(max_i/(2*m),max_i - max_i/(2*m),m-1);
% hist_mass = zeros(m-1,1);
% 
% for i = 2:m
%     in_chunk = (stats.agrid >= hist_chunks(i-1)) .* (stats.agrid < hist_chunks(i));
%     hist_mass(i-1) = sum(stats.pmf_a .* in_chunk, 'all');
% end
% 
% hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
% 
% p = bar(hist_locs, hist_mass);
% p.FaceAlpha = 0.5;
% xlim([0 max_i])
% ylim([0 0.7])
% hold on
% plot(as, mpc_i, 'LineWidth', 3, 'color', 'black')
% % title('MPC vs. Liquid Wealth')
% xlabel('Illiquid Wealth')
% legend('Mass','Mean', 'Location', 'north')
% ax = gca;
% ax.FontSize = 14;
% cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
% plot_path = sprintf('Figures/mpc_i_2A.pdf');
% % saveas(gcf, plot_path, "epsc");
% saveas(gcf, plot_path);

%% 6di) MPC by illiquid wealth with HtM bars (2A)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

n = 100;
max_i = 3.0;
curve = 0.1;
as = linspace(0.6,1,n);
as = as .^ (1/curve);
as = as .* max_i;
mpc_i = mpc_illiquid_mean(stats,as) ./ 100;

[bg, ag, yg] = ndgrid(stats.bgrid, stats.agrid, income.y.vec);
pmf_b_a_y = squeeze(stats.pmf);

% htm_thresh = 1000/p.numeraire_in_dollars;
htm_thresh = yg/6;

% pmf_htm = stats.pmf_b_a .* (bg <= HtM_1000) ./ sum(stats.pmf_b_a .* (bg <= HtM_1000), 'all');
% pmf_htm = pmf_b_a_y .* (bg <= yg/6) ./ sum(pmf_b_a_y .* (bg <= yg/6), 'all');
pmf_htm = pmf_b_a_y .* (bg <= htm_thresh) ./ sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');
pmf_htm = sum(pmf_htm, [1 3]);


% Make histogram data
m = 8;
hist_chunks = linspace(0,max_i,m);
hist_locs = linspace(max_i/(2*m),max_i - max_i/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_mass_htm = zeros(m-1,1);

for i = 2:m
    in_chunk = (stats.agrid >= hist_chunks(i-1)) .* (stats.agrid < hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_a .* in_chunk, 'all');
    hist_mass_htm(i-1) = sum(pmf_htm' .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_mass_htm(m-1) = 1 - sum(hist_mass_htm(1:m-2), 'all');

hist_mass_htm = hist_mass_htm .* sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');

hist_mass = hist_mass - hist_mass_htm;

both_mass = [hist_mass_htm hist_mass];

p = bar(hist_locs, both_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;

% p = bar(hist_locs, hist_mass);
% p.FaceAlpha = 0.5;
xlim([0 max_i])
ylim([0 0.7])
hold on
plot(as, mpc_i, 'LineWidth', 3, 'color', 'black')
% title('MPC vs. Liquid Wealth')
xlabel('Illiquid Wealth')
legend('HtM', 'Non HtM','MPC Mean', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_i_2A_HtM.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 6dii) MPC by illiquid wealth with HtM bars, fixed rb (2A)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-22-2021-23:02:15/output_20.mat')

n = 100;
max_i = 3.0;
curve = 0.1;
as = linspace(0.6,1,n);
as = as .^ (1/curve);
as = as .* max_i;
mpc_i = mpc_illiquid_mean(stats,as) ./ 100;

[bg, ag, yg] = ndgrid(stats.bgrid, stats.agrid, income.y.vec);
pmf_b_a_y = squeeze(stats.pmf);

% htm_thresh = 1000/p.numeraire_in_dollars;
htm_thresh = yg/6;

% pmf_htm = stats.pmf_b_a .* (bg <= HtM_1000) ./ sum(stats.pmf_b_a .* (bg <= HtM_1000), 'all');
% pmf_htm = pmf_b_a_y .* (bg <= yg/6) ./ sum(pmf_b_a_y .* (bg <= yg/6), 'all');
pmf_htm = pmf_b_a_y .* (bg <= htm_thresh) ./ sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');
pmf_htm = sum(pmf_htm, [1 3]);


% Make histogram data
m = 8;
hist_chunks = linspace(0,max_i,m);
hist_locs = linspace(max_i/(2*m),max_i - max_i/(2*m),m-1);
hist_mass = zeros(m-1,1);
hist_mass_htm = zeros(m-1,1);

for i = 2:m
    in_chunk = (stats.agrid >= hist_chunks(i-1)) .* (stats.agrid < hist_chunks(i));
    hist_mass(i-1) = sum(stats.pmf_a .* in_chunk, 'all');
    hist_mass_htm(i-1) = sum(pmf_htm' .* in_chunk, 'all');
end

hist_mass(m-1) = 1 - sum(hist_mass(1:m-2), 'all');
hist_mass_htm(m-1) = 1 - sum(hist_mass_htm(1:m-2), 'all');

hist_mass_htm = hist_mass_htm .* sum(pmf_b_a_y .* (bg <= htm_thresh), 'all');

hist_mass = hist_mass - hist_mass_htm;

both_mass = [hist_mass_htm hist_mass];

p = bar(hist_locs, both_mass, 'stacked');
p(1).FaceAlpha = 0.5;
p(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p(1).FaceColor = orange;
p(2).FaceColor = blue;

% p = bar(hist_locs, hist_mass);
% p.FaceAlpha = 0.5;
xlim([0 max_i])
ylim([0 0.7])
hold on
plot(as, mpc_i, 'LineWidth', 3, 'color', 'black')
% title('MPC vs. Liquid Wealth')
xlabel('Illiquid Wealth')
legend('HtM', 'Non HtM','MPC Mean', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_i_2A_HtM_rbgap.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% 7) MPC by total wealth 2A + 1A
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

n = 100;
curve = 0.1;
ws = linspace(0,1,n);
ws = ws .^ (1/curve);
ws = ws .* 3;
mpcs_2A = mpc_wealth_mean(stats, ws) ./ 100;

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs_2A = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass_2A = zeros(m-1,1);

for i = 2:m
    in_chunk = ((stats.bgrid + stats.agrid') >= hist_chunks(i-1)) .* ((stats.bgrid + stats.agrid') < hist_chunks(i));
    hist_mass_2A(i-1) = sum(stats.pmf_b_a .* in_chunk, 'all');
end

hist_mass_2A(m-1) = 1 - sum(hist_mass_2A(1:m-2), 'all');


% Load baseline 1A
cd('/Users/chaseabram/UChiGit/Discrete_HA')
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables2.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = sum(results.stats.pmf, 2);

mpcs_b = sum(mpcs .* results.stats.pmf, 2) ./ pmf_b;

bg = ndgrid(results.stats.agrid);

mpcs_1A_int = griddedInterpolant(bg, mpcs_b,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0.6,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs_1A = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass_1A = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass_1A(i-1) = sum(pmf_b .* in_chunk, 'all');
end

hist_mass_1A(m-1) = 1 - sum(hist_mass_1A(1:m-2), 'all');

both_mass = [hist_mass_2A, hist_mass_1A];

p2 = bar(hist_locs_2A, both_mass, 'stacked');
p2(1).FaceAlpha = 0.5;
p2(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p2(1).FaceColor = orange;
p2(2).FaceColor = blue;

% p2 = bar(hist_locs_2A, hist_mass_2A);
% p2.FaceAlpha = 0.5;
xlim([0 3])
% ylim([0 0.7])
hold on
% p1 = bar(hist_locs_1A, hist_mass_1A);
% p1.FaceAlpha = 0.5;
% xlim([0 3])
% hold on
plot(ws, mpcs_2A, 'LineWidth', 3, 'color', 'black');
hold on
plot(bs, mpcs_1A_int(bs), 'LineWidth', 3, 'LineStyle', '--', 'color', 'black');
% title('Baseline 2A and 1A');
xlabel('Wealth');
legend('2A', '1A', 'MPC Mean 2A', 'MPC 1A', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_2A_1A.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);


%% 8) MPC by total wealth 2A + (1A with beta het)
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

n = 100;
curve = 0.1;
ws = linspace(0,1,n);
ws = ws .^ (1/curve);
ws = ws .* 3;
mpcs_2A = mpc_wealth_mean(stats, ws) ./ 100;

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs_2A = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass_2A = zeros(m-1,1);

for i = 2:m
    in_chunk = ((stats.bgrid + stats.agrid') >= hist_chunks(i-1)) .* ((stats.bgrid + stats.agrid') < hist_chunks(i));
    hist_mass_2A(i-1) = sum(stats.pmf_b_a .* in_chunk, 'all');
end

hist_mass_2A(m-1) = 1 - sum(hist_mass_2A(1:m-2), 'all');


% Load 1A with beta het
cd('/Users/chaseabram/UChiGit/Discrete_HA')
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables22.mat')

mpcs = reshape(results.mpcs(5).mpcs_1_t{1}, size(results.stats.pmf));

pmf_b = sum(results.stats.pmf, [2 4]);

mpcs_b = sum(mpcs .* results.stats.pmf, [2 4]) ./ pmf_b;

bg = ndgrid(results.stats.agrid);

mpcs_1A_int = griddedInterpolant(bg, mpcs_b,'linear','none');

n = 100;
curve = 0.1;
% b from 0 to 1
bs = linspace(0,1,n);
bs = bs .^ (1/curve);
bs = bs .* 3;

% Make histogram data
m = 8;
hist_chunks = linspace(0,3,m);
hist_locs_1A = linspace(3/(2*m),3 - 3/(2*m),m-1);
hist_mass_1A = zeros(m-1,1);

for i = 2:m
    in_chunk = (bg >= hist_chunks(i-1)) .* (bg < hist_chunks(i));
    hist_mass_1A(i-1) = sum(pmf_b .* in_chunk, 'all');
end

hist_mass_1A(m-1) = 1 - sum(hist_mass_1A(1:m-2), 'all');

both_mass = [hist_mass_2A, hist_mass_1A];

p2 = bar(hist_locs_2A, both_mass, 'stacked');
p2(1).FaceAlpha = 0.5;
p2(2).FaceAlpha = 0.5;
orange = [0.8500, 0.3250, 0.0980];
blue = [0, 0.4470, 0.7410];
p2(1).FaceColor = orange;
p2(2).FaceColor = blue;

% p2 = bar(hist_locs_2A, hist_mass_2A);
% p2.FaceAlpha = 0.5;
xlim([0 3])
% ylim([0 0.7])
hold on
% p1 = bar(hist_locs_1A, hist_mass_1A);
% p1.FaceAlpha = 0.5;
% xlim([0 3])
% hold on
plot(ws, mpcs_2A, 'LineWidth', 3, 'color', 'black');
hold on
plot(bs, mpcs_1A_int(bs), 'LineWidth', 3, 'LineStyle', '--', 'color', 'black');
% title('Baseline 2A and (1A with discount factor heterogeneity)');
xlabel('Wealth');
legend('2A', '1A', 'MPC Mean 2A', 'MPC 1A', 'Location', 'north')
ax = gca;
ax.FontSize = 14;
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_2A_1A_beta_het.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);

%% Intertemporal MPCs
clear
cd('/Users/chaseabram/UChiGit/Discrete_HA')
load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables2.mat')
tmp = results;
tmp = [results.mpcs(5).avg_s_t{5,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,4}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,4}.value];
base1A = [tmp results.mpcs(5).avg_s_t{1,5}.value];

load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables10.mat')
tmp = results;
tmp = [results.mpcs(5).avg_s_t{5,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,4}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,4}.value];
Ea56 = [tmp results.mpcs(5).avg_s_t{1,5}.value];

load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables22.mat')
tmp = results;
tmp = [results.mpcs(5).avg_s_t{5,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,4}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,4}.value];
beta_het = [tmp results.mpcs(5).avg_s_t{1,5}.value];

load('/Users/chaseabram/Dropbox/AnnualReviewsFiles/variables55.mat')
tmp = results;
tmp = [results.mpcs(5).avg_s_t{5,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{5,4}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,1}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,2}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,3}.value];
tmp = [tmp results.mpcs(5).avg_s_t{1,4}.value];
spend_sav = [tmp results.mpcs(5).avg_s_t{1,5}.value];

cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')
base2A = [4.2 4.5 5.2 6.5 stats.mpcs(5).quarterly.value] ./ 100;



ts = [-4:1:4];
plot(ts, base1A, 'LineWidth', 3);
hold on
% plot(ts, Ea56, 'LineWidth', 3);
% hold on
% plot(ts, beta_het, 'LineWidth', 3);
% hold on
plot(ts, spend_sav, 'LineWidth', 3);
hold on
% plot(ts(5:9), base2A, 'LineWidth', 3)
plot(ts, base2A, 'LineWidth', 3)
hold on
xlabel('Time')
ylim([0 0.2]);
% legend('Baseline 1A', 'E[a] = 0.56', '\beta het', 'Spender-saver', 'Baseline 2A');
legend('One Asset', 'Spender Saver', 'Two Asset');
ax = gca;
ax.FontSize = 14;
grid on
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_intertemp.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);
hold off

ts = [-4:1:4];
plot(ts, base1A, 'LineWidth', 3);
hold on
% plot(ts, Ea56, 'LineWidth', 3);
% hold on
% plot(ts, beta_het, 'LineWidth', 3);
% hold on
plot(ts, spend_sav, 'LineWidth', 3);
hold on
plot(ts(1:5), base2A(1:5), 'LineWidth', 3, 'LineStyle', '--')
burnt_yellow = [0.9290, 0.6940, 0.1250];
plot(ts(5:9), base2A(5:9), 'LineWidth', 3, 'color', burnt_yellow)
hold on
xlabel('Time')
ylim([0 0.2]);
% legend('Baseline 1A', 'E[a] = 0.56', '\beta het', 'Spender-saver', 'Baseline 2A');
legend('One Asset', 'Spender Saver', '', 'Two Asset');
ax = gca;
ax.FontSize = 14;
grid on
cd('/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final');
plot_path = sprintf('Figures/mpc_intertemp_fake.pdf');
% saveas(gcf, plot_path, "epsc");
saveas(gcf, plot_path);





%% Extra stats
clear
cd('/Users/chaseabram/UChiGit/Continuous_Time_HA')
load('/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-all-08-15-2021-00:22:19/output_1.mat')

liq_wealth_quantile(stats,[4.1],0.0)
liq_wealth_quantile(stats,[4.1],0.25)
liq_wealth_quantile(stats,[4.1],0.5)
liq_wealth_quantile(stats,[4.1],0.75)
liq_wealth_quantile(stats,[4.1],1.0)


% mpc_ill_nn(stats)




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

function lw_q = liq_wealth_quantile(s,ws,q)
    for i = 1:length(ws)
        bs = linspace(0,ws(i),100);
        as = ws(i) - bs;
        pmfs = s.pmf_int(bs, as);
        pmfs = pmfs ./ sum(pmfs,'all');

        b_int = aux.pctile_interpolant(bs, pmfs);

        lw_q(i) = b_int(q);
    end
end


% function for mean at w
function mpc_w = mpc_wealth_mean(s,ws)
    for i = 1:length(ws)
        bs = linspace(0,ws(i),100);
        as = ws(i) - bs;
        pmfs = s.pmf_int(bs, as);
        pmfs = pmfs ./ sum(pmfs,'all');
        mpcs = s.mpc_int(bs, as);

%         cdf_int = aux.pctile_interpolant(mpcs, pmfs);

        mpc_w(i) = sum(mpcs .* pmfs, 'all');
    end
end

function mpc_l = mpc_liquid_mean(s,ls)

%     pmf_l = sum(s.pmf, [2 3 4 5]);
%     pmf_int = griddedInterpolant(s.bgrid, pmf_l,'linear','none');
    
    [bg, ag] = ndgrid(s.bgrid, s.agrid);
    mpc_tmp = sum(s.mpc_int(bg, ag) .* s.pmf_b_a, 2) ./ sum(s.pmf_b_a, 2);
    
    mpc_int = griddedInterpolant(s.bgrid, mpc_tmp,'linear','none');
    
    mpc_l = mpc_int(ls);
end

function mpc_i = mpc_illiquid_mean(s,is)

%     pmf_i = sum(s.pmf, [1 3 4 5]);
%     pmf_int = griddedInterpolant(s.agrid, pmf_i,'linear','none');
    
    [bg, ag] = ndgrid(s.bgrid, s.agrid);
    mpc_tmp = sum(s.mpc_int(bg, ag) .* s.pmf_b_a, 1) ./ sum(s.pmf_b_a, 1);
    
    mpc_int = griddedInterpolant(s.agrid, mpc_tmp,'linear','none');
    
    mpc_i = mpc_int(is);
end

% MPC out of illiquid wealth, no negative shocking allowed
% function mpc_ill_nn = mpc_ill_nn(s)
%     ill_ss = reshape(s.illiquid_mpcs_over_ss{5}, [s.nb s.na s.nz s.ny]);
%     mpc_ill_nn = sum(ill_ss .* s.pmf, 'all');
% 
% end


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





