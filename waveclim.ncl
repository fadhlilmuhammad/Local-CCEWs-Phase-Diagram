
load "diag_local_wave_phase.ncl"

diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/olr_filtered/"
; diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/olr_filtered/"

wave = "mrg"
f = addfile(diri + "olr."+wave+".25.nc", "r")

x = f->$wave$
; x    = dim_stddev_n_Wrap(x_in, 0)

if wave.eq."kelvin" then
  latS = -15
  latN = -10
else
  latS = -25
  latN = -10
end if

printVarSummary(x)

TIME        = x&time
DATE        = cd_calendar(TIME, -2)
ymdStrt     = 19810101
ymdLast     = 20181231

iStrt       = ind(DATE.eq.ymdStrt)
iLast       = ind(DATE.eq.ymdLast)

time        = x&time(iStrt:iLast)
ymdhms      = cd_calendar(time, 0)

seas_djf    = choose_season("SHSummer", ymdhms)
seas_mam    = choose_season("SHAutumn", ymdhms)
seas_son    = choose_season("SHSpring", ymdhms)
seas_jja    = choose_season("SHWinter", ymdhms)

mam = x(seas_mam,:,:)
djf = x(seas_djf,:,:)
son = x(seas_son,:,:)
jja = x(seas_jja,:,:)

variance_mam = dim_variance_n_Wrap(mam, 0)
variance_djf = dim_variance_n_Wrap(djf, 0)
variance_son = dim_variance_n_Wrap(son, 0)
variance_jja = dim_variance_n_Wrap(jja, 0)

printVarSummary(variance_mam)
printVarSummary(variance_djf)
printVarSummary(variance_son)
printVarSummary(variance_jja)

system("rm "+diri + "avariance.olr."+wave+".25.nc")
fout = addfile(diri + "avariance.olr."+wave+".25.nc", "c")
fout->mam = variance_mam
fout->djf = variance_djf
fout->son = variance_son
fout->jja = variance_jja

latvariance_mam = dim_variance_n_Wrap(variance_mam({latS:latN},:), 0)
latvariance_djf = dim_variance_n_Wrap(variance_djf({latS:latN},:), 0)
latvariance_son = dim_variance_n_Wrap(variance_son({latS:latN},:), 0)
latvariance_jja = dim_variance_n_Wrap(variance_jja({latS:latN},:), 0)

system("rm "+diri + "latvariance.olr."+wave+".25.nc")
fout2 = addfile(diri + "latvariance.olr."+wave+".25.nc", "c")
fout2->mam = latvariance_mam
fout2->djf = latvariance_djf
fout2->son = latvariance_son
fout2->jja = latvariance_jja

lonvariance_mam = dim_variance_n_Wrap(variance_mam(:,{113:153.5}), 0)
lonvariance_djf = dim_variance_n_Wrap(variance_djf(:,{113:153.5}), 0)
lonvariance_son = dim_variance_n_Wrap(variance_son(:,{113:153.5}), 0)
lonvariance_jja = dim_variance_n_Wrap(variance_jja(:,{113:153.5}), 0)

system("rm "+diri + "lonvariance.olr."+wave+".25.nc")
fout3 = addfile(diri + "lonvariance.olr."+wave+".25.nc", "c")
fout3->mam = lonvariance_mam
fout3->djf = lonvariance_djf
fout3->son = lonvariance_son
fout3->jja = lonvariance_jja

printVarSummary(x)
monval = calculate_monthly_values(x(iStrt:iLast,:,:), "var", 0, False)
printVarSummary(monval)

mon = clmMonTLL(monval)
; std = stdMonTLL(monval)
printVarSummary(mon)

system("rm "+diri+"clmmon.var.olr."+wave+".25.nc")
fout4 = addfile(diri+"clmmon.var.olr."+wave+".25.nc", "c")
fout4->clm = mon


;;;;;;;;;;;;;;;;;;;;;;;
coords = x(:,{latS:latN},:)
lat = coords&lat
; lat   = latis({latS:latN})
rad    = 4.0*atan(1.0)/180.0
clat   = cos(lat*rad)

latmon = dim_avg_n_Wrap(mon(:,{latS:latN},:), 1)

system("rm "+diri+"latclm.var.olr."+wave+".25.nc")
fout5 = addfile(diri+"latclm.var.olr."+wave+".25.nc", "c")
fout5->clm_latvariance = latmon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clm_lonvariance = dim_avg_n_Wrap(mon(:,:,{113:153.5}), 2)

system("rm "+diri+"lonclm.var.olr."+wave+".25.nc")
fout6 = addfile(diri+"lonclm.var.olr."+wave+".25.nc", "c")
fout6->clm_lonvariance = clm_lonvariance
