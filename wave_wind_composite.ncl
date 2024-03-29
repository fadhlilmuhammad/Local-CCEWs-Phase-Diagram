

load "diag_local_wave_phase.ncl"

; diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/olr_filtered/"
diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"


waves = (/ "er","kelvin", "mrg", "td", "mjo"/)

ystrt = 1981
ylast = 2018

plev = 500
startwave = 0
do k = startwave, dimsizes(waves)-1

  wave     = waves(k)
  var      = "u"
  ; fname    = var+"850."+wave+".25.nc"
  fname    = var+"_era5_daily.nc"
  f        = addfile(diri+fname, "r")

  ; x        = f->$wave$
  x        = f->$var$(:,{plev},:,:)

  ref = 133
  season   = "SHSummer"
  g        = addfile(diro+"/local_wave_phase/local_"+wave+"_phase_"+season+"."+ref+".noTC.nc", "r")
  ; ftc      = asciiread(diri+"TC_dates.csv", -1, "integer")

  amp_in   = g->amp
  printVarSummary(amp_in)

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

  TIME = x&time
  DATE = cd_calendar(TIME, 0)

  istrt   = ind(DATE(:,0).eq.ystrt)
  ilast   = ind(DATE(:,0).eq.ylast)

  ; printVarSummary(TIME(13879))
  print(istrt(0))
  ; print(istrt)

  time        = TIME(istrt(0):ilast(dimsizes(ilast)-1))
  ymdhms      = cd_calendar(time, 0)
  iseason     = choose_season(season, ymdhms)

  delete(DATE)
  yyyymmdd        = cd_calendar(time(iseason),-2)
  yyyymmdd_x      = cd_calendar(x&time, -2)

  indchoose   = new((/dimsizes(yyyymmdd)/),"integer")

  printVarSummary(yyyymmdd)
  printVarSummary(yyyymmdd_x)
  do i = 0, dimsizes(yyyymmdd)-1
    indchoose(i) = ind(yyyymmdd_x.eq.yyyymmdd(i)); write loop content
  end do


  x_seaschoose     = x(indchoose,:,:)
  nlat        = dimsizes(x_seaschoose&lat)
  nlon        = dimsizes(x_seaschoose&lon)
  print(cd_calendar(x_seaschoose&time,-2))
  printVarSummary(x_seaschoose)


  ymdhms_p    = cd_calendar(phase&time, 0)
  iseason_p   = choose_season(season, ymdhms_p)
  alpha       = new((/9,nlat,nlon/),"float")

  phase_seas = phase(iseason_p)
  comp = composite_waves(x_seaschoose,phase, amp, season)
  x_seas      = dim_avg_n_Wrap(x_seaschoose(:,:,:),0)


  do i = 0, 7
    print("phase-"+(i+1))
    nphase  = i+1
    date_phase        = cd_calendar(x_seaschoose&time, -2)
    indactive         = lookup_phase_index(phase_seas,amp, date_phase, nphase )
    printVarSummary(indactive)
    ; print(num(indactive))
    xphase            = x_seaschoose(indactive,:,:)

    ; pall     =
    nBoot = 1000
    sigval = 95
    optboot   = True
    optboot@sample_method = 1
    optboot@sample_size = dimsizes(indactive)
    ;BootStrap  = bootstrap_stat(rain_extreme_season_phase, 0, nBoot, 0, opt )
    BootStrap  = bootstrap_stat(x_seaschoose, 0, nBoot, 0, optboot )

    xBoot      = BootStrap[0]

    siglow      = (100. - sigval)/200.
    print(siglow)
    sighi       = (1. - siglow)
    print(sighi)

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

  ; copy_VarCoords(xseas, x_seas)
  printVarSummary(x_seas)

  copy_VarCoords(x, alpha)

  foutname = wave+"_wave_composite_"+season+"_"+var+plev+"_sig"+sigval+".ref"+ref+".nc"
  ; foutname = wave+"_wave_composite_"+season+"_perc"+perc+".nc"
  system("rm "+diro+"dynamics/"+foutname)

  fout = addfile(diro+"dynamics/"+foutname,"c")
  fout->composite = comp
  fout->alpha = alpha

  ; foutseas = wave+"_"+season+"_x_sig"+sigval+".nc"
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
