"""
Diya Rajon, DR38258
Project Brief: Plots the mean air temp based of NOAA data points collected by 2910 satellites.
                Additionally plots the linear and parabolic best fit lines.
"""

using CSV
using DataFrames   
using Colors 
using Plots

# import Pkg; Pkg.add("StatsPlots")
# Pkg.add("StatsPlots"); using StatsPlots

using StatsBase
using Polynomials
using Dates


# Here you can add functions
function LoadFileCSV(fname,dirpath)
    fpath = joinpath(dirpath, fname);                           # create the path
    data=CSV.read(fpath,DataFrame,missingstring="NaN");         # read the csv
    return data                                                 # return the data
end

data= LoadFileCSV("noaa_data.csv", ".");     # load file csv

station=data[:, 1];
date=data[:,2];
lat=data[:,3];
long=data[:,4];
air_temp = data[:,5];
air_temp = tryparse.(Float64, air_temp)
air_temp = replace(air_temp, nothing => missing)
wind_dir=data[:,6];
wind_speed=data[:,7];

years = year.(date)

# println(first(air_temp, 5))
# println(first(years, 5))

data_yearly = DataFrame(year=years, air_temp=air_temp)
clean_df = dropmissing(data_yearly, [:air_temp])
grouped_data = groupby(clean_df, :year)

# println(first(grouped_data, 5))

means = []
sds = []
iqrs = []
year_labels = []


for group in grouped_data
    year_data = group[:, :year]
    air = group[:, :air_temp]
  #  println(first(air, 5))

    # Calculate the statistics
    mean_temp = mean(air)
    sd_temp = std(air)
    iqr_temp = iqr(air)
    
    # Append results
    push!(means, mean_temp)
    push!(sds, sd_temp)
    push!(iqrs, iqr_temp)
    push!(year_labels, first(year_data))
end
p1 = plot()
year_counts = combine(grouped_data, nrow => :count)
println(year_counts)



# Create a plot for the mean air temperature by year
plot!(year_labels, means, ribbon=sds ./2, label="Mean ± Stdev", linewidth=2, color=:blue, title="Gulf of Mexico Mean Air Temperature", xlabel="Year", ylabel="Temperature (°C)")
# plot!(year_labels, means .+ sds, label="Mean + SD", linewidth=1, linestyle=:dash, color=:red)
# plot!(year_labels, means .- sds, label="Mean - SD", linewidth=1, linestyle=:dash, color=:red)


# cf1 = Polynomials.fit(timeSel_year,sealevelSel_mm, 1)
# sealevelLin_mm  = [cf1(time) for time in time_year]
# # cf2 = Polynomials.fit(time_year,sealevelSel_mm, 2)
# plot!(time_year, sealevelLin_mm, color=" black", label="selected data");

year_labels = Int64.(year_labels)
means = Float64.(means)

cf2 = Polynomials.fit(year_labels,means, 1)
temp  = [cf2(time) for time in year_labels]
plot!(year_labels, temp, linewidth=2, color=" red", linestyle=:dashdotdot, label="Trendline, R²=0.21");

println(means)
println("done")

display(p1)

