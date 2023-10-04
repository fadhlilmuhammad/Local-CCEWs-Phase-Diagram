
folder  = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diro  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"
diricsv  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/local_wave_phase/combined_wave/"
f = addfile(folder + "VIMFC_ERA5_MAKEOWN_1980-2019.nc", "r")

smooth = False

fcsv = "er_mrg_wetwet_TE_mam"
csv_in = asciiread(diricsv+fcsv+".csv",-1,"string")
csv  = toint(csv_in(1:))
print(csv)

x  = f->vimfc

date = cd_calendar(f->time, -2)
date_start = ind(date.eq.19800101)
date_end = ind(date.eq.20191231)

latN = -5
latS = -25

time = f->time(date_start:date_end)
lat = f->latitude({latS:latN})
lon = f->longitude


vimfc= short2flt(f->vimfc(time|date_start:date_end, {latitude|latS:latN}, longitude|:))

print("Calculating climatology and anomaly...")

TIME = cd_calendar(time, -5)
year = TIME(:, 0)
month = TIME(:, 1)
day = TIME(:, 2)
ddd = day_of_year(year, month, day)
yyyyddd = year * 1000 + ddd

if smooth then
	nhar = 1 ; ONLY CONSIDER ANNUal cycle
	climday     = clmDayTLL(vimfc, yyyyddd)
	climatology = smthClmDayTLL(climday,nhar)
	anomaly = calcDayAnomTLL(vimfc, yyyyddd, climatology)
else
	climatology = clmDayTLL(vimfc, yyyyddd)
	anomaly = calcDayAnomTLL(vimfc, yyyyddd, climatology)
end if

delete(date)
delete(time)

time = anomaly&time
date = cd_calendar(time,-2)

idate = new((/dimsizes(csv)/),"integer")
do i = 0, dimsizes(csv)-1
  idate(i) = ind(date.eq.csv(i))
end do

comp = dim_avg_n_Wrap(anomaly(idate,:,:), 0)

outname = diro+"vimfc_"+fcsv+".nc"
system("rm "+ outname)
fout = addfile(outname, "c")
fout->comp = comp
