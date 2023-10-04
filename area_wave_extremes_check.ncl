

load "diag_local_wave_phase.ncl"

regions = (/"TopEnd","CapeYork","Kimberley","Queensland","EastCoast"/)
regioncode = (/"TE", "CY", "KY", "QL","EC"/)
latSs = (/-17, -16, -20, -25, -20./)
latNs = (/-11, -10, -13.5, -20, -16./)
lonLs = (/129, 142, 120, 138, 145./)
lonRs = (/137, 146, 128, 145, 151./)

code = 4

diri = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diri_csv  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/local_wave_phase/combined_wave/"

diro = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"

if regioncode(code).ne."EC" then
fname = "agcd_v1_precip_calib_r025_daily_1981-2020.maskedshp.nc"
else
fname = "agcd_eastcoast.nc"
end if

waves = (/"er", "kelvin", "mrg","td", "mjo"/)

; flsname = fls
; do i = 0, dimsizes(fls)-1
;   flsname(i) = systemfunc("echo "+fls(i) +" | awk -F'/' ' { print $NF } ' "  )
;   ; print(check)
; end do

  if seas.eq."mam" then
    season = "SHAutumn"
  else if seas.eq."djf" then
    season = "SHSummer"
  end if
end if


  f     = addfile(diri+fname,"r")

  time = f->time
  dates = cd_calendar(time, -2)

  istrt = ind(dates.eq.19810101)
  ilast = ind(dates.eq.20181231)
  delete(time)

  pr_inn    = f->precip(istrt:ilast,{latSs(code):latNs(code)}, {lonLs(code):lonRs(code)})
  pr_in     = where(pr_inn.eq.-127, pr_inn@_FillValue, pr_inn)
  pr_in     = where(pr_in.eq.0, pr_inn@_FillValue, pr_in)

  copy_VarMeta(pr_inn,pr_in)

  lat    = pr_in&lat
  rad    = 4.0*atan(1.0)/180.0
  clat   = cos(lat*rad)

  ; pr_aave1 = dim_avg_n_Wrap(pr_in, 1)
  ; pr_aave  = dim_avg_n_Wrap(pr_aave1, 1)
  pr_aave     = wgt_areaave_Wrap(pr_in, clat, 1.0, 0)
  pr_aave_stat = where(pr_aave.le.1, pr_aave@_FillValue, pr_aave)
  copy_VarMeta(pr_aave, pr_aave_stat)

  ;***********************************************************
  ; Read time and create required yyyyddd
  ;***********************************************************
  time    = pr_aave&time                          ; time:units = "hours since 1-1-1 00:00:0.0"
  TIME    = cd_calendar(time, 0)          ; type float
  year    = toint( TIME(:,0) )
  month   = toint( TIME(:,1) )
  day     = toint( TIME(:,2) )
  ddd     = day_of_year(year, month, day)
  yyyyddd = year*1000 + ddd

  iseason     = choose_season(season, TIME)

  pr_stat   = percent_to_value(pr_aave_stat(iseason), 95.)

  printVarSummary(pr_aave)
  ;calculate daily anomaly



  DATE    = cd_calendar(time(iseason), -2)
  ;calc anom

  perc = 95
  print(pr_stat)
  pr_freq   = where(pr_aave(iseason).ge.pr_stat, 1., 0. )
  copy_VarMeta(pr_aave(iseason),pr_freq)

  do n = 0,dimsizes(waves)-1
    wave = waves(n)
    print(wave)
  fls   = systemfunc("ls "+diri_csv+regioncode(code)+"."+wave+"*."+seas+".csv")

    ; fls   = systemfunc("ls "+diri_csv+"*_"+regioncode(n)+"_"+seas+".csv")

    flsname = fls
    do i = 0, dimsizes(fls)-1
      flsname(i) = systemfunc("echo "+fls(i) +" | awk -F'/' ' { print $NF } ' "  )
      ; print(check)
    end do

  print(flsname)

  ndim  = dimsizes(pr_freq)
  printVarSummary(flsname)
  comp = new((/dimsizes(fls)/), "float", pr_aave@_FillValue)
  comp@ndays = new(dimsizes(fls),integer)
  comp@desc = new(dimsizes(fls),string)
  comp_med = comp
  alpha = comp
  alpha@ndays = new(dimsizes(fls),integer)
  ;;;;START
  do i = 0, dimsizes(fls)-1

    TIME2    = pr_freq&time
    DATE2    = cd_calendar(TIME2, -2)

    print(flsname(i))
    fcsv  = asciiread(fls(i), -1, "integer")
    idate = new((/dimsizes(fcsv)/), "integer")

    do t = 0, dimsizes(idate)-1
      idate(t) = ind(fcsv(t).eq.DATE2)
      ; print(idate(t))
      ; print(fcsv(t))
    end do

    pr_sel = pr_freq(idate)

    comp_med(i) = dim_median_n(pr_sel,0)
    comp(i) = dim_avg_n(pr_sel,0)
    ; print(comp(i))

    nBoot = 1000
    sigval = 95
    optboot   = True
    optboot@sample_method = 1
    optboot@sample_size = dimsizes(idate)
    ;BootStrap  = bootstrap_stat(rain_extreme_season_phase, 0, nBoot, 0, opt )
    BootStrap  = bootstrap_stat(pr_freq, 0, nBoot, 0, optboot )

    xBoot      = BootStrap[0]

    siglow      = (100. - sigval)/200.
    ;print(siglow)
    sighi       = (1. - siglow)
    ;print(sighi)

    xBootLow   = bootstrap_estimate(xBoot, siglow, False)   ;  2.5% lower confidence bound
    xBootHi    = bootstrap_estimate(xBoot, sighi, False)   ; 97.5% upper confidence bound

    iflag = True

    alpha(i)    = where(((comp(i).ge.xBootHi) .or. (comp(i).le.xBootLow)), 1., 0.)
    ; copy_VarCoords(pr(0), comp(0))
    ; copy_VarCoords(pr(0), alpha(0))
    comp@ndays(i) = dimsizes(idate)
    alpha@ndays(i) = dimsizes(idate)
    comp@desc(i) = flsname(i)

    ; print(dim_avg_n(pr_freq,0))
    comp(i) = comp(i)/dim_avg_n(pr_freq,0)
    print(comp(i))


    ; system("rm "+diro+"combined_"+flsname(i)+".nc")
    ; fout = addfile(diro+"combined_"+flsname(i)+".nc", "c")
    ; fout->composite = dim_avg_n_Wrap(pr_Anom_sel,0)
    ; fout->alpha = alpha


    ; delete(date_phase)
    ; delete(xphase)
    ; delete(tester)
    delete(xBoot)
    delete(BootStrap)
    delete(xBootLow)
    delete(xBootHi)
    ; delete(indactive)

    delete(pr_sel)
    delete(idate)
    delete(fcsv)

  end do
  comp!0 = "list"
  alpha!0 = "list"

  ; print(comp@desc)

  system("rm "+diro+wave+"_wave_extreme_"+regioncode(code)+"_"+seas+".nc")
  fout = addfile(diro+wave+"_wave_extreme_"+regioncode(code)+"_"+seas+".nc", "c")
  fout->composite = comp
  fout->median = comp_med
  fout->alpha = alpha

  delete(comp)
  delete(alpha)
  ; delete(lat)
  ; delete(pr_in)
  ; delete(pr_aave)
  ; delete(pr_inn)
  delete(flsname)
  ; delete(clat)
  ; delete(time)
end do
