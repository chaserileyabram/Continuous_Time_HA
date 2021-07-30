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
cd("/Users/chaseabram/UChiGit/Continuous_Time_HA/output/server-07-28-2021-10:46:14")
# Read in data
# xf = XLSX.readdata("output_table.xlsx", "Sheet1", "A2:DT161")
xf = XLSX.readdata("output_table.xlsx", "Sheet1", "A2:N161")
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

    txt *= stat_table("Rebalancing Frequency", 
    ["Baseline", "Infrequent Rebalance", "Frequent Rebalance"], 
    ["Baseline", "Infrequent Rebalance", "Frequent Rebalance"],
    ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Rebalance arrival rate", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"

    txt *= stat_table("Income Process", 
    ["Baseline", "Cont b, rho only", "Cont b, all 500"],
    ["Baseline", "Cont b, rho recal", "Cont b, (rho, ra, reb\\_cost) recal"], 
    ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Income Process", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"

    txt *= stat_table("Returns Robustness", 
    ["Baseline", "Low r_b", "High r_b", "Low r_a", "High r_a"],
    ["Baseline", "Low r_b", "High r_b", "Low r_a", "High r_a"], 
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"

    txt *= stat_table("Rebalance Costs", 
    ["Baseline", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    ["Baseline", "Reb cost \\\$250", "Reb cost \\\$1000", "Reb cost \\\$2000"],
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"

    txt *= stat_table("Instantaneous Gratification", 
    ["Baseline", "IG = 0.5, rho = 0.001", "IG = 0.2, rho = 0.001"],
    ["Baseline", "beta_{IG} = 0.5", "beta_{IG} = 0.2"], 
    ["beta_IG (annualized)", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"],
    [L"\beta_{IG}"*" annualized", "Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500"])

    txt *= raw"
    \newpage"



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
    \caption{"
    
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

    for m in modelnames
        txt *= " & "
        txt *= string(m)
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

function stat_table(name, models, modelnames, topstats, topstats_names)
    txt = starttable(name, modelnames)

    # Top stats
    txt *= subtable(models, topstats, topstats_names)

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

    # Other Wealth Stats
    txt *= subhead("Wealth Statistics", models)
    txt *= subtable(models, 
    ["w, median",
    "b, median",
    "s = 0",
    "b <= 0\\% mean ann inc",
    "w <= 0\\% mean ann inc",
    "b <= \\\$1000",
    "w <= \\\$1000",
    "b <= \\\$2000",
    "w <= \\\$2000",
    "b <= \\\$5000",
    "w <= \\\$5000",
    "b <= \\\$10000",
    "w <= \\\$10000",
    "w, Top 10\\% share",
    "w, Top 1\\% share",
    "Gini coefficient, wealth"],
    ["Median total wealth",
    "Median liquid wealth",
    L"s = 0",
    L"b \leq 0",
    L"w \leq 0",
    L"b \leq \$1000",
    L"w \leq \$1000",
    L"b \leq \$2000",
    L"w \leq \$2000",
    L"b \leq \$5000",
    L"w \leq \$5000",
    L"b \leq \$10000",
    L"w \leq \$10000",
    "Wealth, Top 10\\% share",
    "Wealth, Top 1\\% share",
    "Gini coefficient, wealth"])

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
