load "diag_local_wave_phase.ncl"

diro     = "dataout/"
diri     = "data/precip/"


waves = (/"er", "kelvin", "mrg", "td","mjo","td-slow"/)
do k = 0, dimsizes(waves)-1

wave     = waves(k)
foutname =  "agcd_v1_precip_calib_r005_1980-2019.regrid.nc"

ref = 130
seas = "SHAutumn"
ystrt    = 1981
ylast    = 2018

f        = addfile(diri+foutname, "r")
g        = addfile(diro+"local_"+wave+"_phase_"+seas+"."+ref+".nc", "r")

ftc      = asciiread("TC_dates.csv", -1, "integer")

amp_in   = g->amp
phase_in = g->phase
time     = cd_calendar(amp_in&time, 0)
; print(time)
istrt    = ind(time(:,0).eq.ystrt)
ilast    = ind(time(:,0).eq.ylast)

; print(istrt)

;selecting amplitude and phase
amp      = amp_in(istrt(0):ilast(dimsizes(ilast)-1))
delete(amp@phase)
amp@phase = amp_in@phase(istrt(0):ilast(dimsizes(ilast)-1))
delete(time)

; phase = amp@phase

phase = phase_in(istrt(0):ilast(dimsizes(ilast)-1))

printVarSummary(f)
var = "precip"
x_in        = f->$var$
nlat = dimsizes(x_in&lat)
nlon = dimsizes(x_in&lon)
; x           = runave_n_Wrap(x_in/stddev(x_in),7,0, 0)
x           = x_in
copy_VarMeta(x_in,x)

TIME      = x&time
DATE      = cd_calendar(TIME, -2)
ymdStrt   = 19810101
ymdLast   = 20181231

iStrt     = ind(DATE.eq.ymdStrt)
print(iStrt)
iLast     = ind(DATE.eq.ymdLast)

time        = x&time(iStrt:iLast)
ymdhms      = cd_calendar(time, 0)
iseason     = choose_season(seas, ymdhms)

x_sel = x_in(iStrt:iLast,:,:)
print(cd_calendar(x_sel&time,-2))
x_seas = dim_avg_n(x_sel(iseason,:,:),0)
; x = x_in
xavg = conform_dims(dimsizes(x_sel), x_seas, (/1,2/))
printVarSummary(xavg)
printVarSummary(x_sel)

delete(x)
x      = x_sel - xavg

copy_VarMeta(x_sel,x)
; delete(x_sel)
; delete(x_seas)


printVarSummary(amp)
printVarSummary(x)

alpha       = new((/9,nlat,nlon/),"float")


comp = composite_waves(x, phase, amp, seas)

print(ftc)

do i = 0, 7
  print("phase-"+(i+1))
  nphase  = i+1
  date_phase        = cd_calendar(x&time, -2)
  indactive         = lookup_phase_index_rmvtc(phase,amp, date_phase, nphase,ftc )
  printVarSummary(indactive)
  ; print(indactive)
  ; print(num(indactive))
  ; comp@ndays(i+1)   = num(indactive)
  xphase            = x(indactive,:,:)

  ; pall     =
  nBoot = 1000
  sigval = 90
  optboot   = True
  optboot@sample_method = 1
  optboot@sample_size = dimsizes(indactive)
  ;BootStrap  = bootstrap_stat(rain_extreme_season_phase, 0, nBoot, 0, opt )
  BootStrap  = bootstrap_stat(x, 0, nBoot, 0, optboot )

  xBoot      = BootStrap[0]

  siglow      = (100. - sigval)/200.
  print(siglow)
  sighi       = (1. - siglow)
  print(sighi)

  xBootLow   = bootstrap_estimate(xBoot, siglow, False)   ;  2.5% lower confidence bound
  xBootHi    = bootstrap_estimate(xBoot, sighi, False)   ; 97.5% upper confidence bound

  ; tester     = dim_avg_n_Wrap(xphase,0)
  ; print(comp(i+1,20:35,94:124))
  ; print(xBootLow(20:35,94:124))
  ; print(xBootHi(20:35,94:124))
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

delete(time)
delete(phase)
delete(amp)
delete(x_in)
delete(x)
printVarSummary(comp)

foutname = "prec_anom_"+wave+"_wave_composite_"+seas+"ref"+ref+".nc"
system("rm "+diro+foutname)

fout = addfile(diro+foutname,"c")
fout->composite = comp
fout->alpha = alpha

end do