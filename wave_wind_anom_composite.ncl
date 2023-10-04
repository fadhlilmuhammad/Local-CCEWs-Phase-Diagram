

load "diag_local_wave_phase.ncl"

diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"
diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"

; fname    = "VIMFC_ERA5_MAKEOWN_1980-2019.nc"
; fname = "mvimd.day.anomalies.1980-2019.nc"

type = "dailyanom"
; type = "seasanom"
; var = "mvimd_anom"
var = "u"
plev = 850
varout = var+plev
data = "fromera"

season = "SHSummer"

waves = (/ "er","kelvin", "mrg", "td", "mjo"/)

ystrt = 1981
ylast = 2018

; fname = var+"_"+season+"."+ystrt+"-"+ylast+"."+data+"."+type+".nc"
fname = diri + var+"_era5_daily.nc"
startwave = 0


; f        = addfile(diro+"dynamics/"+fname, "r")
f = addfile(fname,"r")
vimfc    = f->$var$(:,{plev},:,:)


;***********************************************************
; Read time and create required yyyyddd
;***********************************************************
   time    = vimfc&time                          ; time:units = "hours since 1-1-1 00:00:0.0"
   TIME    = cd_calendar(time, 0)          ; type float
   year    = toint( TIME(:,0) )
   month   = toint( TIME(:,1) )
   day     = toint( TIME(:,2) )
   ddd     = day_of_year(year, month, day)
   yyyyddd = year*1000 + ddd

;calc anom

;***********************************************************
; Compute daily climatology: raw and then 'smoothed'
;***********************************************************
   hClmDay    = clmDayTLL(vimfc, yyyyddd)     ; daily climatology at each grid point
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
    vimfc_Anom      = calcDayAnomTLL (vimfc, yyyyddd, hClmDay)
    printVarSummary(hAnom_sm)
    printMinMax(hAnom, 0)

    vimfc_Anom_sm   = calcDayAnomTLL (vimfc, yyyyddd, hClmDay_sm)

    hAnom_sm@long_name = "Anomalies from Smooth Daily Climatology"
    printVarSummary(hAnom_sm)
    printMinMax(hAnom_sm, 0)

delete(vimfc)
vimfc = vimfc_Anom_sm

delete(time)
delete(TIME)
delete(yyyyddd)


do k = startwave, dimsizes(waves)-1

  print(waves(k))
  ref = 133
  wave     = waves(k)
  g        = addfile(diro+"/local_wave_phase/local_"+wave+"_phase_"+season+"."+ref+".nc", "r")
  ftc      = asciiread(diri+"TC_dates.csv", -1, "integer")

  amp_in   = g->amp
  ; printVarSummary(amp_in)

  time     = cd_calendar(amp_in&time, 0)
  istrt    = ind(time(:,0).eq.ystrt)
  ilast    = ind(time(:,0).eq.ylast)

  ;selecting amplitude and phase
  amp      = amp_in(istrt(0):ilast(dimsizes(ilast)-1))
  delete(amp@phase)
  amp@phase = amp_in@phase(istrt(0):ilast(dimsizes(ilast)-1))
  delete(time)

  phase    = g->phase(istrt(0):ilast(dimsizes(ilast)-1))

  delete(istrt)
  delete(ilast)

  TIME = vimfc&time
  DATE = cd_calendar(TIME, 0)

  istrt   = ind(DATE(:,0).eq.ystrt)
  ilast   = ind(DATE(:,0).eq.ylast)

  ; printVarSummary(TIME(13879))
  ;print(ilast)
  ; ;print(istrt)

  time        = TIME
  ymdhms      = cd_calendar(time, 0)
  iseason     = choose_season(season, ymdhms)

  delete(DATE)
  yyyymmdd        = cd_calendar(time(iseason),-2)
  yyyymmdd_x      = cd_calendar(vimfc&time, -2)

  indchoose   = new((/dimsizes(yyyymmdd)/),"integer")

  printVarSummary(yyyymmdd)
  printVarSummary(yyyymmdd_x)
  do i = 0, dimsizes(yyyymmdd)-1
    indchoose(i) = ind(yyyymmdd_x.eq.yyyymmdd(i)); write loop content
  end do


  vimfc_seaschoose     = vimfc(indchoose,:,:)
  nlat        = dimsizes(vimfc_seaschoose&lat)
  nlon        = dimsizes(vimfc_seaschoose&lon)
  ; ;print(cd_calendar(vimfc_seaschoose&time,-2))
  printVarSummary(vimfc_seaschoose)


  ymdhms_p    = cd_calendar(phase&time, 0)
  iseason_p   = choose_season(season, ymdhms_p)
  alpha       = new((/9,nlat,nlon/),"float")

  phase_seas = phase(iseason_p)
  comp = composite_waves(vimfc_seaschoose,phase, amp, season)
  ; vimfc_seas      = dim_avg_n_Wrap(vimfc_seaschoose(:,:,:),0)


  do i = 0, 7
    print("phase-"+(i+1))
    nphase  = i+1
    date_phase        = cd_calendar(vimfc_seaschoose&time, -2)
    indactive         = lookup_phase_index_rmvtc(phase_seas,amp, date_phase, nphase,ftc )
    printVarSummary(indactive)
    ; ;print(num(indactive))
    xphase            = vimfc_seaschoose(indactive,:,:)

    ; pall     =
    nBoot = 1000
    sigval = 95
    optboot   = True
    optboot@sample_method = 1
    optboot@sample_size = dimsizes(indactive)
    ;BootStrap  = bootstrap_stat(rain_extreme_season_phase, 0, nBoot, 0, opt )
    BootStrap  = bootstrap_stat(vimfc_seaschoose, 0, nBoot, 0, optboot )

    xBoot      = BootStrap[0]

    siglow      = (100. - sigval)/200.
    ;print(siglow)
    sighi       = (1. - siglow)
    ;print(sighi)

    xBootLow   = bootstrap_estimate(xBoot, siglow, False)   ;  2.5% lower confidence bound
    xBootHi    = bootstrap_estimate(xBoot, sighi, False)   ; 97.5% upper confidence bound

    iflag = True

    alpha(i+1,:,:)    = where(((comp(i+1,:,:).ge.xBootHi) .or. (comp(i+1,:,:).le.xBootLow)), 1., 0.)

    delete(date_phase)
    delete(xphase)
    ; delete(tester)
    delete(xBoot)
    delete(BootStrap)
    delete(xBootLow)
    delete(xBootHi)
    delete(indactive)
    ; write loop content
  end do

  alpha!0 = "phase"
  alpha&phase = (/0,1,2,3,4,5,6,7,8/)

  ; copy_VarCoords(xseas, vimfc_seas)
  ; printVarSummary(vimfc_seas)

  copy_VarCoords(vimfc, alpha)

  ; foutname = wave+"_wave_composite_"+season+"_vimfc_sig"+sigval+".ref"+ref+".fromera"+type+".nc"
  foutname = wave+"_wave_composite_"+season+"_"+varout+"_sig"+sigval+".ref"+ref+"."+data+"."+type+".nc"
  ; foutname = wave+"_wave_composite_"+season+"_perc"+perc+".nc"
  system("rm "+diro+"dynamics/"+foutname)

  fout = addfile(diro+"dynamics/"+foutname,"c")
  fout->composite = comp
  fout->alpha = alpha

  ; foutseas = wave+"_"+season+"_vimfc_sig"+sigval+".nc"
  ; system("rm "+diro+"dynamics/"+foutseas)

  ; fout2 = addfile(diro+"precip/"+foutseas,"c")
  ; fout2->seas = dim_avg_n_Wrap(x_freq,0)
  ; ; fout2->seas_med = dim_median_n(xseas,0)
  ; fout2->seas_th = x_stat_in
  ; fout2->seas_avg = dim_avg_n_Wrap(x_in(indchoose,:,:), 0)

  delete(time)
  delete(istrt)
  delete(ilast)
  delete(indchoose)

end do
