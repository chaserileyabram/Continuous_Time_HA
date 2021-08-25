# using Base: Number
# Chase Abram

# For converting .xlsx output files into TeX for tables

# Plan
# write function for each table that write the proper text
# also a function for header, footer, etc.

# Want to be able to take the raw table (no editing)
# and spit out a text/tex file that works with pdflatex

# Packages
# using Pkg
using Dates
using XLSX
using LaTeXStrings


###############
# CHANGE THIS #
###############

# Make tables for slides?
for_slides = false

# Go directory with .xlsx
# table_type = 2
# cd("/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final/Two_Asset")
# xf = XLSX.readdata("output_table.xlsx", "Sheet1", "A2:AF177")

table_type = 1
cd("/Users/chaseabram/Dropbox/AnnualReviewsMPC/Results/Final/One_Asset")
xf = XLSX.readdata("1A_tables.xlsx", "Sheet1", "A2:AX102")

###############
# CHANGE THIS #
###############
# Read in data (be sure to put the proper rows and columns)
# xf = XLSX.readdata("output_table_fast.xlsx", "Sheet1", "A2:AN177")

shares = ["a_i <= y_i / 6", "a_i <= y_i / 12",
"a <= \\\$1000", "a <= \\\$5000", "a <= \\\$10000", "a <= \\\$50000", "a <= \\\$100000",
"Wealth, top 10\\% share"]

two_dec = ["Beta (annualized)", "Effective discount rate"]

# Fix some characters for tex
for i in 1:size(xf,2)
    for j in 1:size(xf,1)

        # Round the numbers

        if isa(xf[j,i], Number)
            if xf[j,1] in shares
                xf[j,i] = Int64(round(100*xf[j,i], digits=0))
            elseif xf[j,1] in two_dec
                xf[j,i] = round(xf[j,i], digits=2)
            else
                xf[j,i] = round(xf[j,i], digits=1)
            end
        end
        
        # Fix comment characters
        xf[j,i] = replace(string(xf[j,i]), "%" => raw"\%")
        # Fix $
        xf[j,i] = replace(string(xf[j,i]), "\$" => raw"\$")
        # Fix _ 
        if i > 1 && j > 1
            xf[j,i] = replace(string(xf[j,i]), "_" => L"\_")
        end

        # Fix missing
        xf[j,i] = replace(string(xf[j,i]), "missing" => raw"")
    end
end


##

# Create dictionary of (model, statistic) -> model statistic
# Model names MUST be unique or will get overwritten

# Initialize
stats = Dict()

# Read over data
for i in 1:size(xf,2)
    for j in 1:size(xf,1)
        # Fill in object
        stats[(xf[1,i], xf[j,1])] = xf[j,i]
    end
end

##
# Rounding corrections
# println(stats[("Baseline","Quarterly MPC (\\%), out of \\\$500")])

# Write text to tex file with table name
function write_text(text, name)
    io = open("table_"*name*".tex", "w")
    write(io, text)
    close(io)
end

##

# Make header
function header()
    txt = raw"\documentclass[9pt]{extarticle}
    \usepackage{booktabs}
    \usepackage{amsmath}
    \usepackage[tableposition=top]{caption}
    \usepackage{geometry}
    \usepackage{pdflscape}
    \usepackage{threeparttable}
    \usepackage{ifthen}
    \addtolength{\topmargin}{-0.75in}
    \addtolength{\textheight}{1.5in}
    \addtolength{\hoffset}{-0.5in}
    \addtolength{\textwidth}{1in}
    \begin{document}"

    return txt
end

# End doc
function footer()
    return raw"
    \end{document}"
end

# Single row of stat for given models
function fillrow(models,stat, statname)
    txt = raw"
    "

    txt *= string(statname)

    # Add for each model
    for m in models
        txt *= raw" & "
        txt *= string(stats[(m, stat)])
    end

    txt *= raw" \\ "

    return txt
end

# Make subheading within table
function subhead(s, models)
    txt = raw"
    \toprule
    \multicolumn{"
    
    txt *= string(length(models) + 1)
    
    txt *= raw"}{c}{\textbf{"
    txt *= s
    txt *= raw"}} \\
    \midrule"

    return txt
end

# String of full tex
function alltables()
    txt = raw""

    # Header
    txt *= header()

    # MPC Comparison
    txt *= small_table("MPC Comparison",
    ["Discrete Baseline", "Discrete Match HtM", "Discrete Beta het", "Discrete CRRA het", "Discrete Temptation", "Baseline 2A"],
    ["Baseline 1A", "1A Match HtM", "1A "*string(L"\beta")*" Het", "1A CRRA Het",
     "1A Temptation", "2A Baseline"],
    ["Quarterly  MPC (\\%), out of -\\\$5000, t=1", "Quarterly  MPC (\\%), out of -\\\$500, t=1", "Quarterly  MPC (\\%), out of -\\\$1, t=1",
    "Quarterly  MPC (\\%), out of \\\$1, t=1", "Quarterly  MPC (\\%), out of \\\$500, t=1", "Quarterly  MPC (\\%), out of \\\$5000, t=1"],
    ["Quarterly  MPC (\\%), out of -\\\$5000", "Quarterly  MPC (\\%), out of -\\\$500", "Quarterly  MPC (\\%), out of -\\\$1",
    "Quarterly  MPC (\\%), out of \\\$1", "Quarterly  MPC (\\%), out of \\\$500", "Quarterly  MPC (\\%), out of \\\$5000"])

    txt *= raw"
    \newpage"

    if for_slides
        # Table 1
        txt *= stat_table("Table 1: Baseline", 
        ["Baseline 1A, rho=-4.000000e-03", "Baseline 2A"], 
        ["Baseline 1-asset", "Baseline 2-asset"],
        ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
        "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
        "Mean MPC at Mean Wealth (\\%)", "HtM 1year"],
        ["Rebalance arrival rate", "Quarterly  MPC (\\%)", "Annual  MPC (\\%)",
        "Quarterly PHtM MPC (\\%)", "Quarterly WHtM MPC (\\%)",
        "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1"])
    else
        # Table 1
        txt *= stat_table("Table 1: Baseline", 
        ["Baseline 1A, rho=-4.000000e-03", "Baseline 2A", "Infrequent Rebalance"], 
        ["Baseline 1-asset", "Baseline 2-asset", "Infrequent Rebalance"],
        ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
        "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
        "Mean MPC at Mean Wealth (\\%)", "HtM 1year"],
        ["Rebalance arrival rate", "Quarterly  MPC (\\%)", "Annual  MPC (\\%)",
        "Quarterly PHtM MPC (\\%)", "Quarterly WHtM MPC (\\%)",
        "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1"])
    end

    txt *= raw"
    \newpage"

    # txt *= stat_table("Income Process", 
    # ["Baseline 2A", "Cont b, rho only", "Cont b, all 500"],
    # ["Baseline 2-asset", "Cont b, rho recal", "Cont b, (rho, ra, reb\\_cost) recal"], 
    # ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # txt *= raw"
    # \newpage"

    # Table 2
    txt *= stat_table("Table 2: Returns Robustness", 
    ["Baseline 2A", "Low r_b", "High r_b", "Low r_a", "High r_a"], 
    ["Baseline 2A", "Low r_b", "High r_b", "Low r_a", "High r_a"],
    ["Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "HtM 1year"],
    ["Quarterly  MPC (\\%)", "Annual  MPC (\\%)",
    "Quarterly PHtM MPC (\\%)", "Quarterly  WHtM MPC (\\%)",
    "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1"])

    # txt *= raw"
    # \newpage"

    # txt *= stat_table("Returns Robustness", 
    # ["Baseline 2A", "Low r_b", "High r_b", "Low r_a", "High r_a"],
    # ["Baseline 2-asset", "Low r_b", "High r_b", "Low r_a", "High r_a"], 
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"

    # txt *= stat_table("Rebalance Costs", 
    # ["Baseline 2A", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    # ["Baseline 2-asset", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # Appendix
    txt *= stat_table("Appendix Table: Rebalance Costs", 
    ["Baseline 2A", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    ["Baseline 2-asset", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    ["Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "HtM 1year"],
    ["Quarterly  MPC (\\%)", "Annual  MPC (\\%)",
    "Quarterly PHtM MPC (\\%)", "Quarterly  WHtM MPC (\\%)",
    "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1"])

    # txt *= raw"
    # \newpage"

    # txt *= stat_table("Instantaneous Gratification", 
    # ["Baseline 2A", "IG = 0.5, rho = 0.001, 2A", "IG = 0.2, rho = 0.001, 2A", "IG match PHtM 2A, start rho=1.000000e-03, beta=7.000000e-01"],
    # ["Baseline 2-asset", "beta_{IG} = 0.5", "beta_{IG} = 0.2", "IG match PHtM 2A"], 
    # ["beta_IG", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # [L"\beta_{IG}", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"

    txt *= stat_table("Appendix Table: Temptation", 
    ["Baseline 2A", "Temptation 5.000000e-02, rho=1.000000e-02", "Temptation 5.000000e-02, rho=1.000000e-02"],
    ["Baseline 2-asset", "Temptation 0.05", "Temptation 0.07"],
    ["Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "HtM 1year"],
    ["Quarterly  MPC (\\%)", "Annual  MPC (\\%)",
    "Quarterly PHtM MPC (\\%)", "Quarterly  WHtM MPC (\\%)",
    "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1"])

    # txt *= stat_table("Temptation", 
    # ["Baseline 2A", "Temptation 0.05", "Temptation 0.07"],
    # ["Baseline 2-asset", L"\varphi=0.05", L"\varphi=0.07"], 
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # txt *= raw"
    # \newpage"

    # Footer
    txt *= footer()
    return txt
end

# String of full tex
function alltables1A()
    txt = raw""

    # Header
    txt *= header()

    # MPC Comparison
    # txt *= small_table("MPC Comparison",
    # ["Discrete Baseline", "Discrete Match HtM", "Discrete Beta het", "Discrete CRRA het", "Discrete Temptation", "Baseline 2A"],
    # ["1A Baseline", "1A Match HtM", "1A "*string(L"\beta")*" Het", "1A CRRA Het",
    #  "1A Temptation", "2A Baseline"],
    # ["Quarterly  MPC (\\%), out of -\\\$5000, t=1", "Quarterly  MPC (\\%), out of -\\\$500, t=1", "Quarterly  MPC (\\%), out of -\\\$1, t=1",
    # "Quarterly  MPC (\\%), out of \\\$1, t=1", "Quarterly  MPC (\\%), out of \\\$500, t=1", "Quarterly  MPC (\\%), out of \\\$5000, t=1"],
    # ["Quarterly  MPC (\\%), out of -\\\$5000", "Quarterly  MPC (\\%), out of -\\\$500", "Quarterly  MPC (\\%), out of -\\\$1",
    # "Quarterly  MPC (\\%), out of \\\$1", "Quarterly  MPC (\\%), out of \\\$500", "Quarterly  MPC (\\%), out of \\\$5000"])

    # txt *= raw"
    # \newpage"

    if for_slides
        txt *= stat_table_1A("Table 1", "table",
        ["Baseline",
        "Calibration to total wealth, E[a] = 0.5617",
        "Calibration to PHtM, HtM = 0.142"], 
        ["Baseline",
        "E[a] = 0.5617", "HtM = 0.142"],
        ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
        "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
        "Effective discount rate"],
        ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
        "Quarterly MPC of the HtM (\\%)", "Share HtM (\\%)",
        "Effective discount rate"])
    else
    # Table 1
        tmp_tab = stat_table_1A("Table 1", "table_baseline",
        ["Data", "Baseline", "Calibration to total wealth, E[a] = 9.4", "Calibration to liquid wealth, median(a) = 1.54",
        "Calibration to total wealth, E[a] = 0.5617", "Calibration to liquid wealth, median(a) = 0.046",
        "Calibration to PHtM, HtM = 0.142"], 
        ["Data", "Baseline", "E[a]", "Median(a)",
        "E[a]", "Median(a)", "HtM"],
        ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
        "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
        "Effective discount rate"],
        ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
        "Quarterly MPC of the HtM (\\%)", "Share HtM",
        "Effective discount rate"])

        write_text(tmp_tab, "1_1A")

        txt *= tmp_tab
    end

    txt *= raw"
    \newpage"

    # Table 2
    tmp_tab = stat_table_1A("Table 2", "table_r_rra",
    ["Baseline", "r = 0\\% p.a.", "r = 5\\% p.a.",
    "CRRA 0.5", "CRRA 6"], 
    ["Baseline", "r = 0\\% p.a.", "r = 5\\% p.a.",
    "CRRA 0.5", "CRRA 6"],
    ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])

    write_text(tmp_tab, "2_1A")

    txt *= tmp_tab

    txt *= raw"
    \newpage"

    if for_slides
        # Table 3
        txt *= stat_table_1A("Table 3", "table",
        ["Baseline", "p = 0, spacing = 0.01",
        "p = 0.02, spacing = 0.01"], 
        ["Baseline", "Fixed \\beta",
        "Small, Stochastic \\beta"],
        ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
        "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
        "Effective discount rate"],
        ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
        "Quarterly MPC of the HtM (\\%)", "Share HtM",
        "Effective discount rate"])
    else
            # Table 3
            txt *= stat_table_1A("Table 3", "table",
            ["Baseline", "p = 0, spacing = 0.005", "p = 0, spacing = 0.01",
            "p = 0.02, spacing = 0.01", "p = 0.1, spacing = 0.01",
            "r in {-1, 1, 3}", "r in {-3,1,5}"], 
            ["Baseline", " Het \\beta", 
            "Het \\beta",
            "Het \\beta", "Het \\beta",
            "Het r", "Het r"],
            ["beta het", "pswitch", "r het", "Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
            "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
            "Effective discount rate"],
            ["Set of \\beta", "Switch probability \\beta", "Set of r", "Quarterly MPC (\\%)", "Annual MPC (\\%)",
            "Quarterly MPC of the HtM (\\%)", "Share HtM",
            "Effective discount rate"])
    end

    txt *= raw"
    \newpage"

    if for_slides
        # Table 4
        txt *= stat_table_1A("Table 4", "table",
        ["Baseline", "RA = 1, IES = exp(-3), ..., exp(3)", 
        "Temptation = 0.05"], 
        ["Baseline", "IES Large", 
        "Temptation = 0.05"],
        ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
        "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
        "Effective discount rate"],
        ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
        "Quarterly MPC of the HtM (\\%)", "Share HtM",
        "Effective discount rate"])
    else
            # Table 4
        txt *= stat_table_1A("Table 4", "table",
        ["Baseline", "RA = 1, IES = exp(-1), ..., exp(1)",
        "RA = 1, IES = exp(-2), ..., exp(2)", "RA = 1, IES = exp(-3), ..., exp(3)",
        "Temptation = 0.01", "Temptation = 0.05", "Temptation in {0, 0.05, 0.1}"], 
        ["Baseline", "Het IES", "Het IES", "Het IES",
        "Temptation", "Temptation", "Het Temptation"],
        ["ies het", "tempt het", "Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
        "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
        "Effective discount rate"],
        ["Set of IES", "Set of Temptation", "Quarterly MPC (\\%)", "Annual MPC (\\%)",
        "Quarterly MPC of the HtM (\\%)", "Share HtM",
        "Effective discount rate"])
    end

    txt *= raw"
    \newpage"

    # Appendix Table 1
    txt *= stat_table_1A("Appendix Table 1", "table",
    ["Baseline", "Baseline Annual", "Baseline 1A, rho=-4.000000e-03"], 
    ["Baseline", "Baseline Annual", "Baseline Continuous"],
    ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])

    txt *= raw"
    \newpage"

    # Appendix Table 2
    txt *= stat_table_1A("Appendix Table 2", "table",
    ["Baseline", "With Bequests", "No Death", "Annuities"], 
    ["Baseline", "With Bequests", "No Death", "Annuities"],
    ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])

    txt *= raw"
    \newpage"

    # Appendix Table 3
    txt *= stat_table_1A("Appendix Table 3", "table",
    ["Baseline", "no_trans_shocks", "quart_c", "KMP", "quart_a", "Carrol process",
    "High persistence", "FE heterogeneity"], 
    ["Baseline", "no trans shocks", "quart_c", "KMP", "quart_a", "Carrol",
    "High persistence", "FE het"],
    ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])

    txt *= raw"
    \newpage"

    # Appendix Table 4
    txt *= stat_table_1A("Appendix Table 4", "table",
    ["Baseline", "RA = 1, IES = 2", "RA = 1, IES = 0.25", "RA = 8, IES = 1", 
    "RA = 0.5, IES = 1"], 
    ["Baseline", "RA=1, IES=2", "RA=1, IES=0.25", "RA=8, IES=1", 
    "RA=0.5, IES=1"],
    ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])

    # Appendix Table 6
    txt *= stat_table_1A("Appendix Table 5", "table",
    ["Baseline 1A, rho=-4.000000e-03", "IG = 9.000000e-01, rho = -4.111111e-03, 1A", 
    "IG = 8.000000e-01, rho = -4.111111e-03, 1A", 
    "IG = 7.000000e-01, rho = -4.111111e-03, 1A"], 
    ["Baseline", "\\beta_{IG} = 0.9", "\\beta_{IG} = 0.8", "\\beta_{IG} = 0.7"],
    ["Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])

    # Appendix Table 6
    txt *= stat_table_1A("Appendix Table 6", "table",
    ["Baseline", "RA = exp(-2), ..., exp(2), IES = 1", 
    "RA = exp(-3), ..., exp(3), IES = 1"], 
    ["Baseline", "Het CRRA", "Het CRRA"],
    ["crra het", "Quarterly MPC (\\%), out of \\\$500", "Annual MPC (\\%), out of \\\$500",
    "Quarterly HtM1 MPC (\\%), out of \\\$500", "a_i <= y_i / 6",
    "Effective discount rate"],
    ["Set of CRRA", "Quarterly MPC (\\%)", "Annual MPC (\\%)",
    "Quarterly MPC of the HtM (\\%)", "Share HtM",
    "Effective discount rate"])


    # Footer
    txt *= footer()
    return txt
end

function starttable(name, modelnames)
    txt = raw"
    "

    txt *= raw"\begin{table}[ht] %
    \caption*{"
    
    txt *= name

    txt *= raw"} %
    \centering
    \begin{threeparttable} %
    \begin{tabular}{l"
    for i in 1:length(modelnames)
        txt *= "c"
    end
    txt *= raw"}
    \toprule
    {}"

    for i in 1:length(modelnames)
        txt *= " & "
        txt *= string(" (", i, ") ")
    end

    txt *= raw" \\
    "

    for i in 1:length(modelnames)
        txt *= " & "
        txt *= string(modelnames[i])
    end
    

    txt *= raw" \\
    \midrule"

    return txt
end

function endtable(label)
    txt = raw"
    \bottomrule
    \end{tabular}
    \end{threeparttable} %
    \label{tab:"

    txt *= label

    txt *= raw"}
    \end{table} %"
    # \clearpage"

    return txt
end


# Don't throw on the full stats
function small_table(name, models, modelnames, topstats, topstats_names)
    txt = starttable(name, modelnames)

    # Top stats
    txt *= subtable(models, topstats, topstats_names)

    txt *= endtable()
    return txt

end

# Full stats 2A
function stat_table(name, models, modelnames, topstats, topstats_names)
    txt = starttable(name, modelnames)

    # Top stats
    txt *= subtable(models, topstats, topstats_names)

    # Calibrated Variables
    txt *= subhead("Panel A: Calibrated Variables", models)
    txt *= subtable(models, 
    ["Effective discount rate",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"],
    ["Effective discount factor (annual)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"])

    # Targeted Stats
    txt *= subhead("Panel B: Targeted Statistics", models)
    txt *= subtable(models, 
    ["Mean total wealth",
    "Mean liquid wealth",
    "b_i <= y_i / 6",
    "w_i <= y_i / 6"],
    ["Mean total wealth",
    "Mean liquid wealth",
    "Share hand-to-mouth",
    "Share poor hand-to-mouth"])

    # Backup ref
    # L"b_i \leq y_i / 6",
    # L"w_i \leq y_i / 6"

    # MPC decomp
    txt *= subhead("Panel C: Decomposition", models)
    txt *= subtable(models, 
    ["E[MPC] - E[MPC_b]",
    "Effect of mpc fcn",
    "Effect of distribution",
    "Distr effect, PHtM (eps = 0.05)",
    "Distr effect, WHtM (eps = 0.05)",
    "Distr effect, NHtM (eps = 0.05)",
    "Interaction"],
    ["Gap with Baseline MPC",
    "Effect of MPC function",
    "Distributional Effect",
    "\\quad Poor hand-to-mouth",
    "\\quad Wealthy hand-to-mouth",
    "\\quad Non-hand-to-mouth",
    "Interaction"])

    # Other Wealth Stats
    txt *= subhead("Panel D: Wealth Statistics", models)
    txt *= subtable(models, 
    ["w, median",
    "b, median",
    "b <= \\\$1000",
    "b <= \\\$5000",
    "b <= \\\$10000",
    "w <= \\\$1000",
    "w <= \\\$5000",
    "w <= \\\$10000",
    "w <= \\\$50000",
    "w <= \\\$100000",
    "w, Top 10\\% share",
    "w, Top 1\\% share",
    "Gini coefficient, wealth"],
    ["Median total wealth",
    "Median liquid wealth",
    L"b \leq \$1000",
    L"b \leq \$5000",
    L"b \leq \$10000",
    L"w \leq \$1000",
    L"w \leq \$5000",
    L"w \leq \$10000",
    L"w \leq \$50000",
    L"w \leq \$100000",
    "Wealth, Top 10\\% share",
    "Wealth, Top 1\\% share",
    "Gini coefficient, total wealth"])

    txt *= endtable()
    return txt
end

# Full stats 1A
function stat_table_1A(name, label, models, modelnames, topstats, topstats_names)
    txt = starttable(name, modelnames)

    # Top stats
    txt *= subtable(models, topstats, topstats_names)

    # Panel A: Decomposition
    txt *= subhead("Panel A: Decomposition", models)
    txt *= subtable(models, 
    ["E[MPC] - E[MPC_baseline]", "Effect of MPC fcn", "Effect of distr",
    "Effect of distr, HtM (a <= 0.0148961)", "Effect of distr, NHtM (a > 0.0148961)",
    "Interaction of MPCs and distr"],
    ["Gap with Baseline MPC", "Effect of MPC Function", "Effect of Distribution",
    "\\quad Hand-to-mouth", "\\quad Non-hand-to-mouth", "Interaction"])

    # Wealth stats
    txt *= subhead("Panel B: Wealth Statistics", models)
    txt *= subtable(models, 
    ["Mean wealth", "Median wealth",
    "a <= \\\$1000", "a <= \\\$5000", "a <= \\\$10000", 
    "a <= \\\$50000", "a <= \\\$100000", "Wealth, top 10\\% share"],
    ["Mean wealth", "Median wealth",
    L"a \leq \$1000", L"a \leq \$5000", L"a \leq \$10000", 
    L"a \leq \$50000", L"a \leq \$100000", "Wealth, top 10\\% share"])

    # Backup ref
    # L"b_i \leq y_i / 6",
    # L"w_i \leq y_i / 6"

    # MPC decomp
    # txt *= subhead("Panel C: Decomposition", models)
    # txt *= subtable(models, 
    # ["E[MPC] - E[MPC_b]",
    # "Effect of mpc fcn",
    # "Effect of distribution",
    # "Distr effect, PHtM (eps = 0.05)",
    # "Distr effect, WHtM (eps = 0.05)",
    # "Distr effect, NHtM (eps = 0.05)",
    # "Interaction"],
    # ["Gap with Baseline MPC",
    # "Effect of MPC function",
    # "Distributional Effect",
    # "Distributional Effect, poor hand-to-mouth",
    # "Distributional Effect, wealthy hand-to-mouth",
    # "Distributional Effect, non-hand-to-mouth",
    # "Interaction"])

    # # Other Wealth Stats
    # txt *= subhead("Panel D: Wealth Statistics", models)
    # txt *= subtable(models, 
    # ["w, median",
    # "b, median",
    # "b <= \\\$1000",
    # "b <= \\\$5000",
    # "b <= \\\$10000",
    # "w <= \\\$1000",
    # "w <= \\\$5000",
    # "w <= \\\$10000",
    # "w <= \\\$50000",
    # "w <= \\\$100000",
    # "w, Top 10\\% share",
    # "w, Top 1\\% share",
    # "Gini coefficient, wealth"],
    # ["Median total wealth",
    # "Median liquid wealth",
    # L"b \leq \$1000",
    # L"b \leq \$5000",
    # L"b \leq \$10000",
    # L"w \leq \$1000",
    # L"w \leq \$5000",
    # L"w \leq \$10000",
    # L"w \leq \$50000",
    # L"w \leq \$100000",
    # "Wealth, Top 10\\% share",
    # "Wealth, Top 1\\% share",
    # "Gini coefficient, total wealth"])

    txt *= endtable(label)
    return txt
end



# Makes a subtable: col -> model, row -> stat
function subtable(models, stats, statnames)
    txt = raw""

    for i in 1:length(stats)
        txt *= fillrow(models,stats[i],statnames[i])
    end

    txt *= "
    "

    for i in 1:length(models)
        txt *= " &"
    end

    txt *= raw" \\ "

    return txt
end

# Spot check
println()
println()
println()

if table_type == 2
    println(alltables())
else
    println(alltables1A())
end
##

# Write out

# Write all tables
function write_all_tables()
    if for_slides
        io = open("tables_"*string(table_type)*"_slides.tex", "w")
    else
        io = open("tables_"*string(table_type)*".tex", "w")
    end
    # io = open("tables_"*Dates.format(Dates.now(), "dd_u_yyyy_HH_MM_SS"), "w")

    if table_type == 2
        write(io, alltables())
    else
        write(io, alltables1A())
    end
    close(io)
end

write_all_tables()


