function compute_apc(obj)
    obj.apc = obj.c_KFE ./ (obj.income.y.wide + obj.p.r_b .* repmat(obj.bgrid, [1 obj.na obj.nz obj.ny]));
    
    obj.mean_apc = obj.sfill(sum(obj.apc .* obj.pmf, 'all'), 'Mean APC');
end