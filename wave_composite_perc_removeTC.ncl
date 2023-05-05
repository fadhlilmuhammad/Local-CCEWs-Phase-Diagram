load "diag_local_wave_phase.ncl"

diro     = "dataout/"
diri     = "data/precip/"
; foutname = "agcd_v1_precip_calib_r005_weekrunsum_1980-2019.nc"

; ;************************************************
; ; create Lanczos BandPass Filter
; ;************************************************
;   ihp   = 2                             ; bpf=>band pass filter
;   nWgt  = 201
;   sigma = 1.0                           ; Lanczos sigma
;   fca   = 1./80.                       ; MJO clivar
;   fcb   = 1./8.
;   wgt   = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )


waves = (/"kelvin", "er", "mrg", "td", "mjo", "td-slow"/)

startwave = 0
do k = startwave, dimsizes(waves)-1
; foutname = "rr_sacad_clean_AU.nc"
foutname = "agcd_v1_precip_calib_r005_1980-2019.regrid.nc"

perc = 95
var = "precip"
; var = "rr"

ystrt    = 1981
ylast    = 2018

ref = 130
wave     = waves(k)
season   = "SHAutumn"
f        = addfile(diri+foutname, "r")
g        = addfile(diro+"local_"+wave+"_phase_"+season+"."+ref+".nc", "r")


ftc      = asciiread("TC_dates.csv", -1, "integer")

amp_in   = g->amp
printVarSummary(amp_in)

; amp_in!0 = "time"
time     = cd_calendar(amp_in&time, 0)
; print(time)
istrt    = ind(time(:,0).eq.ystrt)
ilast    = ind(time(:,0).eq.ylast)

;selecting amplitude and phase
amp      = amp_in(istrt(0):ilast(dimsizes(ilast)-1))
delete(amp@phase)
amp@phase = amp_in@phase(istrt(0):ilast(dimsizes(ilast)-1))
delete(time)

phase    = g->phase(istrt(0):ilast(dimsizes(ilast)-1))
; print(phase&time)

x_raw        = short2flt(f->$var$(:,{-20:-10},:))
printVarSummary(x_raw)
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; x_in    = wgt_runave_n_Wrap(x_raw,wgt, 0,0)

delete(istrt)
delete(ilast)

x_in = x_raw
TIME = x_in&time
DATE = cd_calendar(TIME, 0)

istrt   = ind(DATE(:,0).eq.ystrt)
ilast   = ind(DATE(:,0).eq.ylast)

print(istrt)

time        = TIME(istrt(0):ilast(dimsizes(ilast)-1))
ymdhms      = cd_calendar(time, 0)
iseason     = choose_season(season, ymdhms)

delete(DATE)
yyyymmdd        = cd_calendar(time(iseason),-2)
yyyymmdd_x      = cd_calendar(x_in&time, -2)

indchoose   = new((/dimsizes(yyyymmdd)/),"integer")

printVarSummary(yyyymmdd)
printVarSummary(yyyymmdd_x)
do i = 0, dimsizes(yyyymmdd)-1
  indchoose(i) = ind(yyyymmdd_x.eq.yyyymmdd(i)); write loop content
end do



x_stat_inn   = percent_to_value_2d(x_in(indchoose,:,:), perc)
; x_stat_in    = where(x_stat_inn.lt.1, 1.0, x_stat_inn)
x_stat_in = x_stat_inn

copy_VarMeta(x_stat_inn,x_stat_in)
printVarSummary(x_stat_in)
xseas       = x_in(indchoose,:,:)
print(cd_calendar(xseas&time,-2))
printVarSummary(xseas)

x_stat      = conform_dims(dimsizes(xseas), x_stat_in, (/1,2/))

x_freq      = where(xseas.ge.x_stat, 1., 0.) ;* 100.
copy_VarCoords(xseas,x_freq)
nlat        = dimsizes(xseas&lat)
nlon        = dimsizes(xseas&lon)


ymdhms_p    = cd_calendar(phase&time, 0)
iseason_p   = choose_season(season, ymdhms_p)
alpha       = new((/9,nlat,nlon/),"float")

phase_seas = phase(iseason_p)
; print(cd_calendar(x_freq&time,-2))
comp = composite_waves(x_freq,phase, amp, season)
; comp@ndays = new((/9/),"integer")
; print(phase_seas)
x_seas      = dim_avg_n_Wrap(x_freq(:,:,:),0)


do i = 0, 7
  print("phase-"+(i+1))
  nphase  = i+1
  date_phase        = cd_calendar(x_freq&time, -2)
  indactive         = lookup_phase_index_rmvtc(phase_seas,amp, date_phase, nphase,ftc )
  printVarSummary(indactive)
  ; print(indactive)
  print(num(indactive))
  ; comp@ndays(i+1)   = num(indactive)
  xphase            = x_freq(indactive,:,:)

  ; pall     =
  nBoot = 1000
  sigval = 90
  optboot   = True
  optboot@sample_method = 1
  optboot@sample_size = dimsizes(indactive)
  ;BootStrap  = bootstrap_stat(rain_extreme_season_phase, 0, nBoot, 0, opt )
  BootStrap  = bootstrap_stat(x_freq, 0, nBoot, 0, optboot )

  xBoot      = BootStrap[0]

  siglow      = (100. - sigval)/200.
  print(siglow)
  sighi       = (1. - siglow)
  print(sighi)

  xBootLow   = bootstrap_estimate(xBoot, siglow, False)   ;  2.5% lower confidence bound
  xBootHi    = bootstrap_estimate(xBoot, sighi, False)   ; 97.5% upper confidence bound

  ; tester     = dim_avg_n_Wrap(xphase,0)
  print(comp(i+1,20:35,94:124))
  print(xBootLow(20:35,94:124))
  print(xBootHi(20:35,94:124))
  iflag = True

  alpha(i+1,:,:)    = where(((comp(i+1,:,:).ge.xBootHi) .or. (comp(i+1,:,:).le.xBootLow)), 1., 0.)
  ; print(alpha(0:10,0:10,0:10))

  ; alpha(i+1,:,:)    = bootstrap_sigtest(xphase, 90, indactive, 500,False)
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

copy_VarCoords(xseas, x_freq)
printVarSummary(x_freq)

copy_VarCoords(x_freq(0,:,:), x_seas)

; copy_VarMeta(x_in,x)
; delete(x_in)
; delete(x_seas)
printVarSummary(x_seas)

printVarSummary(amp)
; printVarSummary(x)



pall = conform_dims(dimsizes(comp), x_seas, (/1,2/))
; pall = where(pall.eq.0, 1., pall)
copy_VarAtts(comp, pall)
printVarSummary(comp)

pnon = conform_dims(dimsizes(comp), comp(0,:,:), (/1,2/))
pnon = where(pnon.eq.0, pnon@_FillValue, pnon)
copy_VarAtts(comp,pnon)

x      = comp/pall
copy_VarMeta(comp, x)

x2     = comp/pnon
copy_VarMeta(comp, x2)

; opt    = True
; opt@maskfile = "landsea_hires.nc"
; opt@var = "LSMASK"
; x      = custom_mask(x_nomask,x_nomask&lat, x_nomask&lon, opt )
; copy_VarMeta(comp, x)

copy_VarCoords(x, alpha)

foutname = wave+"_wave_composite_"+season+"_perc"+perc+"_25km_sig"+sigval+".ref"+ref+".nc"
; foutname = wave+"_wave_composite_"+season+"_perc"+perc+".nc"
system("rm "+diro+foutname)

fout = addfile(diro+foutname,"c")
fout->composite = comp
fout->composite_anom = x
fout->composite_anom_non = x2
fout->alpha = alpha

foutseas = wave+"_"+season+"_perc"+perc+"_25km_sig"+sigval+".nc"
system("rm "+diro+foutseas)

fout2 = addfile(diro+foutseas,"c")
fout2->seas = dim_avg_n_Wrap(x_freq,0)
; fout2->seas_med = dim_median_n(xseas,0)
fout2->seas_th = x_stat_in
fout2->seas_avg = dim_avg_n_Wrap(x_in(indchoose,:,:), 0)

delete(time)
delete(istrt)
delete(ilast)
delete(indchoose)
end do
