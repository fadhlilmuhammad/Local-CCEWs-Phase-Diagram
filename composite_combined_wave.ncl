

load "diag_local_wave_phase.ncl"

diri = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diri_csv = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/local_wave_phase/combined_wave/"

diro = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"

fname = "agcd_v1_precip_calib_r025_daily_1981-2020.nc"

fls   = systemfunc("ls "+diri_csv+"*.csv")

flsname = fls
do i = 0, dimsizes(fls)-1
  flsname(i) = systemfunc("echo "+fls(i) +" | awk -F'/' ' { print $NF } ' "  )
  ; print(check)
end do


; print(flsname)


f     = addfile(diri+fname,"r")
pr    = f->precip
season = "SHSummer"
printVarSummary(pr)
;calculate daily anomaly

;***********************************************************
; Read time and create required yyyyddd
;***********************************************************
time    = pr&time                          ; time:units = "hours since 1-1-1 00:00:0.0"
TIME    = cd_calendar(time, 0)          ; type float
year    = toint( TIME(:,0) )
month   = toint( TIME(:,1) )
day     = toint( TIME(:,2) )
ddd     = day_of_year(year, month, day)
yyyyddd = year*1000 + ddd

iseason     = choose_season(season, TIME)

DATE    = cd_calendar(time(iseason), -2)
;calc anom

;***********************************************************
; Compute daily climatology: raw and then 'smoothed'
;***********************************************************
hClmDay    = clmDayTLL(pr, yyyyddd)     ; daily climatology at each grid point
printVarSummary(hClmDay)
;***********************************************************
; Compute smoothed daily climatology using 2 harmonics
;***********************************************************
; hClmDay_sm = runave_n_Wrap(hClmDay,30, 0, 0)
hClmDay_sm = smthClmDayTLL(hClmDay, 1)
printVarSummary(hClmDay_sm)

;***********************************************************
; Compute daily anomalies using raw and smoothed daily climatologies
;***********************************************************
pr_Anom      = calcDayAnomTLL (pr, yyyyddd, hClmDay)

pr_Anom_sm   = calcDayAnomTLL (pr, yyyyddd, hClmDay_sm)

pr_Anom_sm@long_name = "Anomalies from Smooth Daily Climatology"

ndim  = dimsizes(pr)
comp = new((/dimsizes(fls), ndim(1), ndim(2)/), "float", pr@_FillValue)
comp@ndays = new(dimsizes(fls),integer)
alpha = comp
;;;;START
do i = 0, dimsizes(fls)-1

  TIME2    = pr_Anom&time
  DATE2    = cd_calendar(TIME2, -2)

  print(flsname(i))
  fcsv  = asciiread(fls(i), -1, "integer")
  idate = new((/dimsizes(fcsv)/), "integer")

  ; printVarSummary(DATE)
  printVarSummary(fcsv)

  ; print(DATE2)
  do t = 0, dimsizes(idate)-1
    idate(t) = ind(fcsv(t).eq.DATE2)
  end do

  ; print(idate)
  ; print(DATE(idate(t)))
  printVarSummary(idate)

  pr_Anom_sel = pr_Anom(idate, :, :)

  comp(i, :, : ) = dim_avg_n_Wrap(pr_Anom_sel,0)

  nBoot = 1000
  sigval = 95
  optboot   = True
  optboot@sample_method = 1
  optboot@sample_size = dimsizes(idate)
  ;BootStrap  = bootstrap_stat(rain_extreme_season_phase, 0, nBoot, 0, opt )
  BootStrap  = bootstrap_stat(pr_Anom(iseason,:,:), 0, nBoot, 0, optboot )

  xBoot      = BootStrap[0]

  siglow      = (100. - sigval)/200.
  ;print(siglow)
  sighi       = (1. - siglow)
  ;print(sighi)

  xBootLow   = bootstrap_estimate(xBoot, siglow, False)   ;  2.5% lower confidence bound
  xBootHi    = bootstrap_estimate(xBoot, sighi, False)   ; 97.5% upper confidence bound

  iflag = True

  alpha(i,:,:)    = where(((comp(i,:,:).ge.xBootHi) .or. (comp(i,:,:).le.xBootLow)), 1., 0.)
  copy_VarCoords(pr(0,:,:), comp(0,:,:))
  copy_VarCoords(pr(0,:,:), alpha(0,:,:))
  comp@ndays(i) = dimsizes(idate)


  system("rm "+diro+"combined_"+flsname(i)+".nc")
  fout = addfile(diro+"combined_"+flsname(i)+".nc", "c")
  fout->composite = dim_avg_n_Wrap(pr_Anom_sel,0)
  fout->alpha = alpha


  ; delete(date_phase)
  ; delete(xphase)
  ; delete(tester)
  delete(xBoot)
  delete(BootStrap)
  delete(xBootLow)
  delete(xBootHi)
  ; delete(indactive)

  delete(pr_Anom_sel)
  delete(idate)
  delete(fcsv)

end do

comp!0 = "list"
alpha!0 = "list"

comp@desc = flsname
print(comp@desc)

system("rm "+diro+"combined_wave.nc")
fout = addfile(diro+"combined_wave.nc", "c")
fout->composite = comp
fout->alpha = alpha
