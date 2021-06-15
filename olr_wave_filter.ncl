; Author: Dr. Sandro Lubis (Jan 2020)
;         How to filter CCEW signalsa using kf_filter
;         Lubis, SW, Respati, MR. Impacts of convectively coupled 
;         equatorial waves on rainfall extremes in Java, Indonesia. 
;         Int J Climatol. 2021; 41: 2418– 2440
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "kf_filter.ncl"

begin

wave = "mjo"; input variable (mjo, kelvin, er, mrg, eig, td)

print("Reading the input file...")

f = addfile("olr.day.mean.nc", "r")

date = cd_calendar(f->time, -2)
date_start = ind(date.eq.19790101)
date_end = ind(date.eq.20181231)

time = f->time(date_start:date_end)
lat = f->lat({-20:20})
lon = f->lon

olr = short2flt(f->olr(time|date_start:date_end, {lat|-20:20}, lon|:))

print("Calculating climatology and anomaly...")

TIME = cd_calendar(time, -5)
year = TIME(:, 0)
month = TIME(:, 1)
day = TIME(:, 2)
ddd = day_of_year(year, month, day)
yyyyddd = year * 1000 + ddd

climatology = clmDayTLL(olr, yyyyddd)
anomaly = calcDayAnomTLL(olr, yyyyddd, climatology)

print("Filtering...")

filtered = new((/dimsizes(time), dimsizes(lat), dimsizes(lon)/), float, -999)

filtered!0 = "time"
filtered!1 = "lat"
filtered!2 = "lon"

filtered&time = time
filtered&lat = lat
filtered&lon = lon

filtered@units = "W/m^2"

obsPerDay = 1

mis = -999
mis@_FillValue = -999

wave_type = wave

if (wave.eq."mjo") then
	wavenumber = (/1, 5/)
	period = (/20, 100/)
	depth = (/mis, mis/)
	filtered@long_name = "Madden-Julian Oscillations in Outgoing Longwave Radiation"
else if (wave.eq."kelvin") then
	wavenumber = (/1, 14/)
	period = (/2.5, 17/)
	depth = (/8, 90/)
	filtered@long_name = "Kelvin Waves in Outgoing Longwave Radiation"
else if (wave.eq."er") then
	wavenumber = (/-10, -1/)
	period = (/9, 72/)
	depth = (/8, 90/)
	filtered@long_name = "Equatorial Rossby Waves in Outgoing Longwave Radiation"
else if (wave.eq."mrg") then
	wavenumber = (/-10, -1/)
	period = (/3, 10/)
	depth = (/8, 90/)
	filtered@long_name = "Mixed Rossby-Gravity Waves in Outgoing Longwave Radiation"
else if (wave.eq."eig") then
	wavenumber = (/1, 14/)
	period = (/1, 5/)
	depth = (/12, 50/)
	wave_type = "ig0"
	filtered@long_name = "Eastward Inertio Gravity Waves in Outgoing Longwave Radiation"
else if (wave.eq."td") then
	wavenumber = (/-20, -6/)
	period = (/2.5, 10/)
	depth = (/mis, 90/)
	wave_type = "mrg"
	filtered@long_name = "Tropical Depression-Type Waves in Outgoing Longwave Radiation"
end if
end if
end if
end if
end if
end if

do y = 0, (dimsizes(lat) - 1)
	filtered(time|:, lat|y, lon|:) = (/kf_filter(anomaly(time|:, lat|y, lon|:), obsPerDay, period(0), period(1), wavenumber(0), wavenumber(1), depth(0), depth(1), wave_type)/)
	print((/lat(y)/))
end do

printVarSummary(filtered)
printMinMax(filtered, False)

print("Opening the output file...")

system("rm olr." + wave + ".nc")
g = addfile("olr." + wave + ".nc", "c")

print("Writing the output file...")

g->$wave$ = filtered

print("Closing the output file...")

delete(g)

end
