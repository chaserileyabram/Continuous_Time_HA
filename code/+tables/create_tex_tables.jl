using Base: Number
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

# Read in data
xf = XLSX.readdata("output_table.xlsx", "Sheet1", "A2:DT161")
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

    # Table 1
    txt *= table1(["HJB delta: 1000", "HJB delta: 10000"])

    # Footer
    txt *= footer()
    return txt
end

function starttable(s, models)
    txt = raw"
    "

    txt *= raw"\begin{table}[ht] %
    \caption{"
    
    txt *= s

    txt *= raw"} %
    \centering
    \begin{threeparttable} %
    \begin{tabular}{l"
    for i in 1:length(models)
        txt *= "c"
    end
    txt *= raw"}
    \toprule
    {}"

    for m in models
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


# Produce Table 1
function table1(models)
    txt = starttable("Baselines", models)

    # Put subtables here
    txt *= subtable(models,
    ["Quarterly  MPC (\\%), out of \\\$500", "Annual  MPC (\\%), out of \\\$500", "beta (annualized)"])

    # some formatting stuff here
    # txt *= subhead("Panel A: Income Statistics", models)
    # txt *= subtable(models, 
    # ["Mean gross annual income",
    # "Stdev log gross annual income",
    # "Stdev log net annual income"])

    # txt *= subhead("Panel B: Wealth Statistics", models)
    # txt *= subtable(models, 
    # ["Mean total wealth", 
    # "Mean liquid wealth"])

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
