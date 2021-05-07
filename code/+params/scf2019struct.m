function scf = scf2019struct()
    scf = struct();
    
    % Earnings
    scf.quarterly_earnings = 67131.733 / 4;
    
    % Medians
    scf.median_totw = 1.54;
    scf.median_liqw = 0.05;
    
    % Means
    scf.mean_totw = 4.1;
    scf.mean_liqw = 0.56;
    
    % Hand-to-mouth
    scf.htm = 0.39;
    scf.phtm = 0.135;

    %% Notes
    % HtM defined as household with b < y / 6
    % PHtM defined as household with (a + b) < y / 6
    
end