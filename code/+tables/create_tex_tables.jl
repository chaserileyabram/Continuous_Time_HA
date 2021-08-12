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

# Check if in proper directory
# if pwd() != "/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-06-24-2021-07:29:39"
#     error("Not in Continuous_HA directory")
# end

# cd("/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-07-11-2021-22:49:30")
# cd("/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-07-28-2021-10:46:14")

###############
# CHANGE THIS #
###############
cd("/Users/chaseabram/UChiGit/Continuous_Time_HA/output")

# Read in data
# xf = XLSX.readdata("output_table.xlsx", "Sheet1", "A2:DT161")
###############
# CHANGE THIS #
###############
xf = XLSX.readdata("output_table_fast.xlsx", "Sheet1", "A2:AN177")
# xf = XLSX.readdata("output_table.xlsx")

for i in 1:size(xf,2)
    for j in 1:size(xf,1)

        if isa(xf[j,i], Number)
            xf[j,i] = round(xf[j,i], digits=3)
        end
        
        # Fix comment characters
        xf[j,i] = replace(string(xf[j,i]), "%" => raw"\%")
        # Fix $
        xf[j,i] = replace(string(xf[j,i]), "\$" => raw"\$")
        # Fix _ 
        if i > 1 && j > 1
            xf[j,i] = replace(string(xf[j,i]), "_" => L"\_")
        end
        # xf[j,i] = replace(string(xf[j,i]), "_" => L"\_")

        # Fix missing
        xf[j,i] = replace(string(xf[j,i]), "missing" => raw"")
    end
end

xf
##

# Create dictionary of (model, statistic) -> model statistic
# Model names MUST be unique or will get overwritten

# Will need to make strings into LaTeX possibly
stats = Dict()
for i in 1:size(xf,2)
    for j in 1:size(xf,1)

        # Fill in object
        # stats[(string(xf[1,i]), string(xf[j,1]))] = xf[j,i]
        stats[(xf[1,i], xf[j,1])] = xf[j,i]
    end
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

    txt *= small_table("MPC Comparison",
    ["Discrete Baseline", "Discrete Match HtM", "Discrete Beta het", "Discrete CRRA het", "Discrete Temptation", "Baseline 2A"],
    ["1A Baseline", "1A Match HtM", "1A "*string(L"\beta")*" Het", "1A CRRA Het",
     "1A Temptation", "2A Baseline"],
    ["Quarterly  MPC (\\%), out of -\\\$5000, t=1", "Quarterly  MPC (\\%), out of -\\\$500, t=1", "Quarterly  MPC (\\%), out of -\\\$1, t=1",
    "Quarterly  MPC (\\%), out of \\\$1, t=1", "Quarterly  MPC (\\%), out of \\\$500, t=1", "Quarterly  MPC (\\%), out of \\\$5000, t=1"],
    ["Quarterly  MPC (\\%), out of -\\\$5000", "Quarterly  MPC (\\%), out of -\\\$500", "Quarterly  MPC (\\%), out of -\\\$1",
    "Quarterly  MPC (\\%), out of \\\$1", "Quarterly  MPC (\\%), out of \\\$500", "Quarterly  MPC (\\%), out of \\\$5000"])

    txt *= raw"
    \newpage"

    txt *= stat_table("Table 1: Baseline", 
    ["Baseline 1A", "Baseline 2A", "Infrequent Rebalance"], 
    ["Baseline 1-asset", "Baseline 2-asset", "Infrequent Rebalance"],
    ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "HtM 1year", "MPC APC Corr"],
    ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1", "Correlation between MPC and APC"])

    txt *= raw"
    \newpage"

    # txt *= stat_table("Income Process", 
    # ["Baseline 2A", "Cont b, rho only", "Cont b, all 500"],
    # ["Baseline 2-asset", "Cont b, rho recal", "Cont b, (rho, ra, reb\\_cost) recal"], 
    # ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # txt *= raw"
    # \newpage"

    txt *= stat_table("Table 2: Returns Robustness", 
    ["Baseline 2A", "Low r_b", "High r_b", "High r_a"], 
    ["Baseline 2A", "Low r_b", "High r_b", "High r_a"],
    ["Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "HtM 1year", "MPC APC Corr"],
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1", "Correlation between MPC and APC"])

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

    txt *= stat_table("Appendix Table: Rebalance Costs", 
    ["Baseline 2A", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    ["Baseline 2-asset", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    ["Quarterly  MPC (\\%), out of \\\$500, t=1", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly  PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "HtM 1year", "MPC APC Corr"],
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500",
    "Quarterly PHtM MPC (\\%), out of \\\$500", "Quarterly  WHtM MPC (\\%), out of \\\$500",
    "Mean MPC at Mean Wealth (\\%)", "Prob. HtM status at year t and year t+1", "Correlation between MPC and APC"])

    # txt *= raw"
    # \newpage"

    # txt *= stat_table("Instantaneous Gratification", 
    # ["Baseline 2A", "IG = 0.5, rho = 0.001, 2A", "IG = 0.2, rho = 0.001, 2A", "IG match PHtM 2A, start rho=1.000000e-03, beta=7.000000e-01"],
    # ["Baseline 2-asset", "beta_{IG} = 0.5", "beta_{IG} = 0.2", "IG match PHtM 2A"], 
    # ["beta_IG", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # [L"\beta_{IG}", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # txt *= raw"
    # \newpage"

    # txt *= stat_table("Temptation", 
    # ["Baseline 2A", "Temptation 0.05", "Temptation 0.07"],
    # ["Baseline 2-asset", L"\varphi=0.05", L"\varphi=0.07"], 
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    # ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # txt *= raw"
    # \newpage"



    # # Rebalancing Frequency Table
    # txt *= reb_table(["Baseline", "Infrequent Rebalance", "Frequent Rebalance"])

    # txt *= raw"
    # \newpage"
    
    # txt *= table2(["Baseline", "Cont b, rho only"])

    # txt *= raw"
    # \newpage"
    
    # txt *= table2(["Baseline",
    # "Cont b, all 200", "Cont b, all 300", "Cont b, all 350"])

    # txt *= raw"
    # \newpage"
    
    # txt *= table2(["Baseline", "Cont b, all 500", "Cont b, all 550"])

    # txt *= raw"
    # \newpage"
    
    # txt *= table3(["Baseline", "Low r_b", "High r_b", "Low r_a", "High r_a"])

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
        txt *= string(modelnames[i])
    end

    txt *= raw" \\
    "
    for i in 1:length(modelnames)
        txt *= " & "
        txt *= string(" (", i, ") ")
    end
    

    txt *= raw" \\
    \midrule"

    return txt
end

function endtable()
    txt = raw"
    \bottomrule
    \end{tabular}
    \end{threeparttable} %
    \end{table} %
    \clearpage"

    return txt
end


# Produce Rebalancing Frequency Table
function reb_table(models)
    txt = starttable("Rebalance Rates", models)

    # Top stats
    txt *= subtable(models,
    ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    # Calibrated Variables
    txt *= subhead("Calibrated Variables", models)
    txt *= subtable(models, 
    ["beta (annualized)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"],
    ["beta (annualized)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"])

    # Targeted Stats
    txt *= subhead("Targeted Statistics", models)
    txt *= subtable(models, 
    ["Mean total wealth",
    "Mean liquid wealth",
    "b_i <= y_i / 6",
    "w_i <= y_i / 6"],
    ["Mean total wealth",
    "Mean liquid wealth",
    L"b_i \leq y_i / 6",
    L"w_i \leq y_i / 6"])

    # MPC decomp
    txt *= subhead("MPC Decomposition", models)
    txt *= subtable(models, 
    ["E[MPC] - E[MPC_b]",
    "Effect of mpc fcn",
    "Effect of mpc fcn (\\%)",
    "Effect of distribution",
    "Effect of distribution (\\%)",
    "Distr effect, PHtM (eps = 0.05)",
    "Distr effect (\\%), PHtM (eps = 0.05)",
    "Distr effect, WHtM (eps = 0.05)",
    "Distr effect (\\%), WHtM (eps = 0.05)",
    "Distr effect, NHtM (eps = 0.05)",
    "Distr effect (\\%), NHtM (eps = 0.05)",
    "Interaction",
    "Interaction (\\%)"],
    ["E[MPC] - E[MPC_b]",
    "Effect of mpc fcn",
    "Effect of mpc fcn (\\%)",
    "Effect of distribution",
    "Effect of distribution (\\%)",
    "Distr effect, PHtM (eps = 0.05)",
    "Distr effect (\\%), PHtM (eps = 0.05)",
    "Distr effect, WHtM (eps = 0.05)",
    "Distr effect (\\%), WHtM (eps = 0.05)",
    "Distr effect, NHtM (eps = 0.05)",
    "Distr effect (\\%), NHtM (eps = 0.05)",
    "Interaction",
    "Interaction (\\%)"])

#     Effect of mpc fcn
# Effect of distribution
# Distr effect, PHtM (eps = 0.05)
# Distr effect, WHtM (eps = 0.05)
# Distr effect, NHtM (eps = 0.05)
# Interaction

#     Effect of mpc fcn (%)
# Effect of distribution (%)
# Distr effect (%), PHtM (eps = 0.05)
# Distr effect (%), WHtM (eps = 0.05)
# Distr effect (%), NHtM (eps = 0.05)
# Interaction (%)



    
    txt *= endtable()

    return txt
end

function small_table(name, models, modelnames, topstats, topstats_names)
    txt = starttable(name, modelnames)

    # Top stats
    txt *= subtable(models, topstats, topstats_names)

    txt *= endtable()
    return txt

end

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
    ["Effective discount factor",
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

    # Backup
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
    "Distributional Effect, poor hand-to-mouth",
    "Distributional Effect, wealthy hand-to-mouth",
    "Distributional Effect, non-hand-to-mouth",
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


# Produce Table 2
function table2(models)
    txt = starttable("Income Processes", models)

    # Put subtables here
    txt *= subtable(models,
    ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= subhead("Calibrated Variables", models)
    txt *= subtable(models, 
    ["beta (annualized)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"],
    ["beta (annualized)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"])

    txt *= subhead("Targeted Statistics", models)
    txt *= subtable(models, 
    ["Mean total wealth",
    "Mean liquid wealth",
    "b_i <= y_i / 6",
    "w_i <= y_i / 6"],
    ["Mean total wealth",
    "Mean liquid wealth",
    L"b_i \leq y_i / 6",
    L"w_i \leq y_i / 6"])

    
    txt *= endtable()

    return txt
end

# Produce Table 3
function table3(models)
    txt = starttable("Returns robustness", models)

    # Put subtables here
    txt *= subtable(models,
    ["Liquid asset return (quarterly)", "Illiquid asset return (quarterly)", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Liquid asset return (quarterly)", "Illiquid asset return (quarterly)", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= subhead("Calibrated Variables", models)
    txt *= subtable(models, 
    ["beta (annualized)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"],
    ["beta (annualized)",
    "Liquid asset return (quarterly)",
    "Illiquid asset return (quarterly)",
    "Rebalance cost (\\\$)"])

    txt *= subhead("Targeted Statistics", models)
    txt *= subtable(models, 
    ["Mean total wealth",
    "Mean liquid wealth",
    "b_i <= y_i / 6",
    "w_i <= y_i / 6"],
    ["Mean total wealth",
    "Mean liquid wealth",
    L"b_i \leq y_i / 6",
    L"w_i \leq y_i / 6"])

    
    txt *= endtable()

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

# txt_test = "a"
# println("before: ", txt_test)
# println(table1A(["HJB delta: 1000", "HJB delta: 10000", "HJB delta: 100000"],
#  ["Mean total wealth", "Mean liquid wealth"]))
# println("after: ", txt_test)

# table1()

# fillrow(["HJB delta: 1000", "HJB delta: 10000", "HJB delta: 100000"], "Mean total wealth")
println()
println()
println()
println(alltables())
##

function write_table()
    io = open("tables.tex", "w")
    # io = open("tables_"*Dates.format(Dates.now(), "dd_u_yyyy_HH_MM_SS"), "w")
    write(io, alltables())
    close(io)
end

write_table()
