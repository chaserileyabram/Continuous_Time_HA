function scf = scf2019struct()
    scf = struct();
    
    % Check do file...these seem to have changed?
    % -> truncation was turned off when I looked
    
    % Earnings
    scf.quarterly_earnings = 67131.733 / 4;
    
    % Medians
    scf.median_totw = 1.54;
    scf.median_liqw = 0.046;
    
    % Means
    scf.mean_totw = 4.11;
    scf.mean_liqw = 0.562;
    
    % Hand-to-mouth
    scf.htm = 0.409; % 0.399;
    scf.phtm = 0.142; % 0.135;

    %% Notes
    % HtM defined as household with b < y / 6
    % PHtM defined as household with (a + b) < y / 6
    
end