
load "utils.ncl"
load "diag_local_wave_phase.ncl"

folder  = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diro  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"
diricsv  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/local_wave_phase/combined_wave/"

regioncode = (/"TE", "CY", "KY", "QL","EC"/)
latSs = (/-17, -16, -20, -25, -23.5/)
latNs = (/-11, -10, -13.5, -20, -16./)
lonLs = (/129, 142, 120, 138, 146./)
lonRs = (/137, 146, 128, 145, 151./)

if regioncode(code).ne."EC" then
  f = addfile(folder + "agcd_v1_precip_calib_r025_daily_1981-2020.maskedshp.shift1day.nc", "r")
else
  f = addfile(folder + "agcd_eastcoast.shift1day.nc", "r")
end if

smooth = False

if season.eq."djf" then
  seas = "SHSummer"
else if season.eq."mam" then
  seas = "SHAutumn"
end if
end if

; fname = "agcd_v1_precip_calib_r025_daily_1981-2020.masked.nc"
; fcsv = "mjo_only_TE_mam"
; fcsv = "WETWET_MJO_ER"
; fcsv = "mjo_mrg_dry_without_er"
; fcsv = "mjo_mjo_wetwet_TE_mam"
; fcsv = "er_er_wetwet_TE_mam"
csv_in = asciiread(fcsv,-1,"string")
csv  = toint(csv_in(1:))
; print(csv)


date = cd_calendar(f->time, -2)
date_start = ind(date.eq.19810101)
date_end = ind(date.eq.20181231)

time = f->time(date_start:date_end)
lat = f->lat({latSs(code):latNs(code)})
lon = f->lon({lonLs(code):lonRs(code)})

prcp_in = short2flt(f->precip(time|date_start:date_end, {lat|latSs(code):latNs(code)}, {lon|lonLs(code):lonRs(code)}))


prcp_nozero = where(prcp_in.gt.1., prcp_in, prcp_in@_FillValue)
copy_VarMeta(prcp_in, prcp_nozero)

DATE = cd_calendar(prcp_in&time, 0)
iseason = choose_season(seas, DATE)

th = stat_dispersion_3D(prcp_nozero(iseason,:,:), 95)
printVarSummary(th)

prcp = where(prcp_in.ge.conform_dims(dimsizes(prcp_in),th, (/1,2/)), 1.0, 0.)
copy_VarMeta(prcp_in, prcp)


prcp_seas = dim_avg_n_Wrap(prcp(iseason, :, :),0)

;;;;;;;;;;;;;;

lat2    = prcp_in&lat
rad    = 4.0*atan(1.0)/180.0
clat   = cos(lat2*rad)

prcp_aave1 = wgt_areaave_Wrap(prcp_in, clat, 1.0, 0)
prcp_aave = where(prcp_aave1.gt.1, prcp_aave1, prcp_aave1@_FillValue)
copy_VarMeta(prcp_aave1,prcp_aave)



th_1D =percent_to_value(prcp_aave(iseason), 95)
; print(th_1D(25))
printVarSummary(prcp_aave1)
prcp_check = prcp_aave1(iseason)
print(prcp_check)
prcp_aave_ext = where(prcp_aave1.ge.th_1D, 1., 0.)
; prcp_aave_ext = where(prcp_aave_ext.ge.999,prcp_aave_ext@_FillValue,prcp_aave_ext)
copy_VarMeta(prcp_aave, prcp_aave_ext)

prcp_aave_ext_seas = prcp_aave_ext(iseason)
; print(prcp_aave_ext(iseason))
prcp_aave_seas = dim_sum_n_Wrap(prcp_aave_ext_seas, 0)/dimsizes(prcp_aave_ext_seas)

delete(date)
delete(time)


time = prcp_aave_ext_seas&time
date = cd_calendar(time,-2)

idate = new((/dimsizes(csv)/),"integer")
do i = 0, dimsizes(csv)-1
  idate(i) = ind(date.eq.csv(i))
	; print(idate(i))
end do
; print(prcp_aave(idate))
print("prcp check idate")
print(prcp_check(idate))
print(idate)

print(prcp_aave_ext(idate))
printVarSummary(prcp_aave_ext)
comp_2D = dim_avg_n_Wrap(prcp(idate,:,:), 0)/prcp_seas

print("threshold: "+th_1D)
print(dim_avg_Wrap(prcp_aave_ext(idate)))
print("seasonal prob: "+prcp_aave_seas)
print("number of events: "+dimsizes(csv))
comp    = dim_avg_n_Wrap(prcp_aave_ext_seas(idate),0)/prcp_aave_seas

; outname = diro+"prcp_"+fcsv+".nc"
; system("rm "+ outname)
; fout = addfile(outname, "c")
; fout->comp = comp_2D

print(fcsv+" "+comp)
