function decomp = decomp_baseline(s0, s1)
    % Decomposition of E[mpc1] - E[mpc0]
    % 0 is baseline
    % 1 is the experiment
    
    p0 = s0.p;
    stats0 = s0.stats;
    p1 = s1.p;
    stats1 = s1.stats;
    
    decomp.Em1_less_Em0 = NaN;
    decomp.term1 = NaN;
    decomp.term2 = NaN;
    decomp.term3 = NaN;
    decomp.term2a = NaN(numel(p0.decomp_thresholds),1);
    decomp.term2b = NaN(numel(p0.decomp_thresholds),1);
    decomp.term2c = NaN(numel(p0.decomp_thresholds),1);
    
    if isequaln(s0, s1)
        return
    end

%     bgrid = stats0.grdKFE.b.vec;
%     agrid = stats0.grdKFE.a.vec;
    bgrid = stats0.bgrid;
    agrid = stats0.agrid;
    
    ny = stats0.ny;

    reshape_dims = [p0.nb_KFE, p0.na_KFE, p0.nz*ny];

    m0 = reshape(stats0.mpcs_over_ss{5} .* 100, reshape_dims);
    pmf0 = stats0.pmf;
    
    if p0.rebalance_rate == 0
        % Fix m0 and pmf0 by adding zeros
        mpadding = zeros(stats1.nb, stats1.na - 2, stats1.ny);
        m0 = cat(2, m0, mpadding);
        ppadding = zeros(stats1.nb, stats1.na - 2, stats1.nz, stats1.ny);
        pmf0 = cat(2, pmf0, ppadding);
    end
    
    [m0_x, pmf0_x] = aux.collapse_mpcs(m0, pmf0);
    Em0 = dot(m0(:), pmf0(:));

    reshape_dims = [p1.nb_KFE, p1.na_KFE, p1.nz*ny];
    
    m1 = reshape(stats1.mpcs_over_ss{5} .* 100, reshape_dims);
    pmf1 = stats1.pmf;
    
%     if p0.rebalance_rate == 0
% %         m1 = mpc_wealth_mean(stats1,bgrid)';
% %         pmf1 = mpc_wealth_pmf(stats1,bgrid)';
% %         m1 = reshape(stats1.mpcs_over_ss{5} .* 100, reshape_dims);
% %         m1 = sum(m1 .* stats1.pmf, 2);
% %         pmf1 = sum(stats1.pmf, 2);
%         
%         % Fix m0 and pmf0 by adding zeros
%         padding = zeros(stats1.nb, stats1.na - 2, stats1.ny);
%         m0 = cat(2, m0, padding);
%         pmf0 = cat(2, pmf0, padding);
%     else
% %         m1 = reshape(stats1.mpcs_over_ss{5} .* 100, reshape_dims);
% %         pmf1 = stats1.pmf;
%     end
    
    
    
    [m1_x, pmf1_x] = aux.collapse_mpcs(m1, pmf1);
    Em1 = dot(m1(:), pmf1(:));
    
    if p0.rebalance_rate == 0
        m0_x = sum(m0_x .*pmf0_x, 2) ./ sum(pmf0_x,2);
        pmf0_x = sum(pmf0_x, 2);
        
%         m1_x = sum(m1_x .*pmf1_x, 2) ./ sum(pmf1_x,2);
%         pmf1_x = sum(pmf1_x, 2);
        
        m1_x = mpc_wealth_mean(stats1,bgrid)';
        pmf1_x = mpc_wealth_pmf(stats1,bgrid)';
        
        % Make match Em1 if aggregated
        m1_x = m1_x .* Em1 ./ sum(m1_x .* pmf1_x, 'all');
    end
    
    
    
    
    

    if p0.rebalance_rate == 0 %p0.OneAsset
        grids = {bgrid};
    else
        grids = {bgrid, agrid};
    end

    import aux.interp_integral_alt
    m0g0interp = interp_integral_alt(grids, m0_x, pmf0_x);
    m1g0interp = interp_integral_alt(grids, m1_x, pmf0_x);
    m0g1interp = interp_integral_alt(grids, m0_x, pmf1_x);
    m1g1interp = interp_integral_alt(grids, m1_x, pmf1_x);

    % Main decomposition
    decomp.Em1_less_Em0 = Em1 - Em0;
    decomp.term1 = dot(m1_x(:) - m0_x(:), pmf0_x(:)); 
    decomp.term2 = dot(m0_x(:), pmf1_x(:) - pmf0_x(:));
    decomp.term3 = dot(m1_x(:) - m0_x(:), pmf1_x(:) - pmf0_x(:));

    for ia = 1:numel(p0.decomp_thresholds)
        x = p0.decomp_thresholds(ia);

        if p0.rebalance_rate == 0 %p0.OneAsset
            b0_a0 = x;
            b0_amax = x;
            bmax_a0 = inf;
            bmax_amax = inf;
        else%if ~p0.OneAsset
            b0_a0 = [x, x];
            b0_amax = [x, inf];
            bmax_amax = [inf, inf];
            bmax_a0 = [inf, x];
        end

        decomp.term2a(ia) = m0g1interp(b0_a0) - m0g0interp(b0_a0);

        if false %p0.rebalance_rate == 0 %p0.OneAsset
%             decomp.term2b(ia) = (m0g1interp(inf) - m0g1interp(x)) ...
%                 - (m0g0interp(inf) - m0g0interp(x));
%             decomp.term2c(ia) = (m0g1interp(inf) - m0g1interp(b0_a0)) ...
%                 - (m0g0interp(b0_a0) - m0g0interp(b0_a0));
        else
            decomp.term2b(ia) = (m0g1interp(b0_amax) - m0g1interp(b0_a0)) ...
                - (m0g0interp(b0_amax) - m0g0interp(b0_a0));
            decomp.term2c(ia) = (m0g1interp(bmax_amax) - m0g1interp(b0_amax)) ...
                -(m0g0interp(bmax_amax) - m0g0interp(b0_amax));
        end
    end
end

% function for mean at w
function mpc_w = mpc_wealth_mean(s,ws)
    for i = 1:length(ws)
        bs = linspace(0,ws(i),10000);
        as = ws(i) - bs;
        pmfs = s.pmf_int(bs, as);
        pmfs = pmfs ./ sum(pmfs,'all');
        mpcs = s.mpc_int(bs, as);

%         cdf_int = aux.pctile_interpolant(mpcs, pmfs);

        mpc_w(i) = sum(mpcs .* pmfs, 'all');
    end
end

% function for pmf at w
function w_pmf = mpc_wealth_pmf(s,ws)
    for i = 1:length(ws)
        bs = linspace(0,ws(i),10000);
        as = ws(i) - bs;
        pmfs_raw = s.pmf_int(bs, as);
        pmfs = pmfs_raw ./ sum(pmfs_raw,'all');
%         mpcs = s.mpc_int(bs, as);

%         cdf_int = aux.pctile_interpolant(mpcs, pmfs);

        w_pmf(i) = sum(pmfs_raw .* pmfs, 'all');
    end
    
    w_pmf = w_pmf ./ sum(w_pmf,'all');
    
end