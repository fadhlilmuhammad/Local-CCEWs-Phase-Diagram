

load "/scratch/w40/fm6730/script/diag_local_wave_phase.ncl"

diro     = "/scratch/w40/fm6730/era5/composite/"
diri     = "/scratch/w40/fm6730/era5/q/"

ls_name    = systemfunc("ls /scratch/w40/fm6730/era5/q/q_era5_oper_*")

fname    = ls_name(in-1:in+2)
print(fname)

type = "makeown.anom30"
var = "q"
varout = "dqdt"
f = addfiles(fname, "r")

x = f[:]->$var$
printVarSummary(x)

waves = (/"er", "kelvin", "mrg", "td", "mjo"/)

ystrt = 1980
ylast = 2019

t    = x&time
dqdt = center_finite_diff_n(x, t, False, 0, 0)
copy_VarCoords(x, dqdt)
copy_VarAtts(x, dqdt)


printVarSummary(dqdt)
;***********************************************************
; Read time and create required yyyyddd
;***********************************************************
time    = dqdt&time                          ; time:units = "hours since 1-1-1 00:00:0.0"
TIME    = cd_calendar(time, 0)          ; type float
year    = toint( TIME(:,0) )
month   = toint( TIME(:,1) )
day     = toint( TIME(:,2) )
ddd     = day_of_year(year, month, day)
yyyyddd = year*1000 + ddd

;***********************************************************
; Compute daily climatology: raw and then 'smoothed'
;***********************************************************
xClmDay    = clmDayTLL(dqdt, yyyyddd)     ; daily climatology at each grid point
printVarSummary(xClmDay)
;***********************************************************
; Compute smoothed daily climatology using 2 harmonics
;***********************************************************
xClmDay_sm = runave_n_Wrap(xClmDay,30, 0, 0)
printVarSummary(xClmDay_sm)

;***********************************************************
; Compute daily anomalies using raw and smoothed daily climatologies
;***********************************************************
x_Anom      = calcDayAnomTLL (dqdt, yyyyddd, xClmDay)
printVarSummary(hAnom_sm)
printMinMax(hAnom, 0)

x_Anom_sm   = calcDayAnomTLL (dqdt, yyyyddd, xClmDay_sm)

xAnom_sm@long_name = "Anomalies from Smooth Daily Climatology"
printVarSummary(xAnom_sm)
printMinMax(xAnom_sm, 0)

delete(x)
x = x_Anom_sm


startwave = 0
do k = startwave, dimsizes(waves)-1


  ref = 133
  wave     = waves(k)
  season   = "SHSummer"
  g        = addfile(diro+"/local_wave_phase/local_"+wave+"_phase_"+season+"."+ref+".nc", "r")
  ftc      = asciiread(diro+"TC_dates.csv", -1, "integer")

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

  time        = TIME(istrt(0):ilast(dimsizes(ilast)-1))
  ymdhms      = cd_calendar(time, 0)
  iseason     = choose_season(season, ymdhms)

  delete(DATE)
  yyyymmdd        = cd_calendar(time(iseason),-2)
  yyyymmdd_x      = cd_calendar(x&time, -2)

  indchoose   = new((/dimsizes(yyyymmdd)/),"integer")
  printVarSummary(indchoose)

  printVarSummary(yyyymmdd)
  printVarSummary(yyyymmdd_x)
  do i = 0, dimsizes(yyyymmdd)-1
    indchoose(i) = ind(yyyymmdd_x.eq.yyyymmdd(i)); write loop content
  end do


  x_seaschoose     = x(indchoose,:,:,:)
  nlat        = dimsizes(x_seaschoose&latitude)
  nlon        = dimsizes(x_seaschoose&longitude)
  printVarSummary(x_seaschoose)


  ymdhms_p    = cd_calendar(phase&time, 0)
  iseason_p   = choose_season(season, ymdhms_p)
  alpha       = new((/9,dimsizes(plev),nlat,nlon/),"float")

  phase_seas = phase(iseason_p)
  comp = composite_waves_4D(x_seaschoose,phase, amp, season)
  x_seas      = dim_avg_n_Wrap(x_seaschoose,0)


  do i = 0, 7
    print("phase-"+(i+1))
    nphase  = i+1
    date_phase        = cd_calendar(x_seaschoose&time, -2)
    indactive         = lookup_phase_index_rmvtc(phase_seas,amp, date_phase, nphase,ftc )
    printVarSummary(indactive)
    xphase            = x_seaschoose(indactive,:,:,:)

    ; pall     =
    nBoot = 1000
    sigval = 95
    optboot   = True
    optboot@sample_method = 1
    optboot@sample_size = dimsizes(indactive)
    BootStrap  = bootstrap_stat(x_seaschoose, 0, nBoot, 0, optboot )

    xBoot      = BootStrap[0]

    siglow      = (100. - sigval)/200.
    ;print(siglow)
    sighi       = (1. - siglow)
    ;print(sighi)

    xBootLow   = bootstrap_estimate(xBoot, siglow, False)   ;  2.5% lower confidence bound
    xBootHi    = bootstrap_estimate(xBoot, sighi, False)   ; 97.5% upper confidence bound

    iflag = True

    alpha(i+1,:,:)    = where(((comp(i+1,:,:,:).ge.xBootHi) .or. (comp(i+1,:,:,:).le.xBootLow)), 1., 0.)

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

  printVarSummary(x_seas)

  copy_VarCoords(x, alpha)

  foutname = wave+"_wave_composite_"+season+"_"+varout+"_sig"+sigval+".ref"+ref+"."+type+".nc"
  system("rm "+diro+"dynamics/"+foutname)

  fout = addfile(diro+"dynamics/"+foutname,"c")
  fout->composite = comp
  fout->alpha = alpha

  delete(time)
  delete(istrt)
  delete(ilast)
  delete(indchoose)

end do
