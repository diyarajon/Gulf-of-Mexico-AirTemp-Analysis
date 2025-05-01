# === GEODATA course UT Austin - NOAA NCEI data - Some useful resources ===
# Documentation and guides:
# https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation
# https://github.com/partytax/ncei-api-guide
# https://www.ncdc.noaa.gov/cdo-web/webservices/v2#gettingStarted
# https://developers.google.com/kml/documentation/kml_tut

# Required packages
# using Pkg
# Pkg.add("HTTP")
# Pkg.add("CSV")
# Pkg.add("DataFrames")
# Pkg.add("Dates")

using HTTP
using CSV
using DataFrames
using Dates

# Download data and create a DataFrame
# Loop over years 1950 and 2020
for cnt in 1950:2020
    println("Downloading year ", cnt)
    YearSel = cnt
    MonthSel = 8
    fromDay = Date(YearSel, MonthSel, 1)
    toDay = lastdayofmonth(fromDay)
    # fromDay = Date(cnt, 8, 1)
    # toDay = lastdayofmonth(fromDay)

    command = "https://www.ncei.noaa.gov/access/services/data/v1?" *
              "dataset=global-marine" *
              "&dataTypes=AIR_TEMP,WIND_DIR,WIND_SPEED" *
              "&startDate=" *string(fromDay)*
              "&endDate=" *string(toDay)*
              "&boundingBox=29,-85,25,-80" *
              "&units=metric"

    # command = "https://www.ncei.noaa.gov/access/services/data/v1?dataset=global-marine&dataTypes=AIR_TEMP,WIND_DIR,WIND_SPEED&startDate=2000-08-01&endDate=2000-08-31&boundingBox=29,-85,25,-80&units=metric"

            #   https://www.ncei.noaa.gov/access/services/data/v1?
            #   dataset=global-marine
            #   &dataTypes=AIR_TEMP,WIND_DIR,WIND_SPEED
            #   &startDate=2000-08-01
            #   &endDate=2000-08-31
            #   &boundingBox=30,-86,25,-80
            #   &units=metric
    headers = ["User-Agent" => "Mozilla/5.0"]
    response = HTTP.request("GET", command, headers)
    f = DataFrame(CSV.File(IOBuffer(response.body)))

    println(first(f, 5))
    if cnt ==1950
        global data = f
    else
        data = vcat(data, (f))
    end
end

CSV.write("noaa_data.csv", data)


# println(first(data, 5)) 

# # Create a KML file of all the weather stations
nameStation = string.(unique(data[:, 1]))
global io = open("WeatherStations.kml", "w")
write(io, """<?xml version="1.0" encoding="UTF-8"?>\n""")
write(io, """<kml xmlns="http://earth.google.com/kml/2.2">\n""")
write(io, " <Document>\n")
for cnt in 1:length(nameStation)
    println("Writing KML file... ", round(cnt / length(nameStation) * 100, digits=2), " %")
    ID = findall(nameStation .== nameStation[cnt])
    write(io, "  <Placemark>\n")
    write(io, "   <name>" * nameStation[cnt] * "</name>\n")
    write(io, "   <Point>\n")
    write(io, "    <coordinates>", string(data[ID[1], 4]), ",", string(data[ID[1], 3]), "</coordinates>\n")
    write(io, "   </Point>\n")
    write(io, "  </Placemark>\n")
end

write(io, " </Document>\n")
write(io, "</kml>\n")
close(io)
