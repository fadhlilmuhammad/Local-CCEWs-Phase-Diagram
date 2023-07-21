
load "utils.ncl"

lonL = 140.
lonR = 150.
latS = -25.

; diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"

diri = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
; diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/precip/masked/"
; f = addfile(diri + "er_wave_composite_SHSummer_perc95_025_sig90.ref133.regrid.nc.masked.nc", "r")
fname = "agcd_v1_precip_calib_r025_daily_1981-2020.masked.nc"
; fname = "agcd_v1_precip_calib_r005_daily_1981-2020.regrid.masked.nc"
f = addfile(diri + fname, "r")

comp_in = f->precip(:,{-10:-40},{140:})
comp_i  = comp_in

comp = where(comp_i.eq.-127, comp_i@_FillValue, comp_i)

comp = comp_i
copy_VarMeta(comp_i,comp)
printVarSummary(comp)

lons = comp&lon
lats = comp&lat
; print(lats)

nlats = dimsizes(lats)
nlons = dimsizes(lons)

icoast = new((/nlats,nlons/), "float")

outcoast = coast_get(comp, 1, 5)

out = "getcoast_rain.nc"

system("rm "+ diri+out)

fout = addfile(diri+out, "c")
fout->comp = outcoast

; outcoast = comp(1,)
;
