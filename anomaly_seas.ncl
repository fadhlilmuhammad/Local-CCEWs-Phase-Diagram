
load "diag_local_wave_phase.ncl"
data = "fromera"
type = "seasanom"

diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"

; fname    = "VIMFC_ERA5_MAKEOWN_1980-2019.nc"
fname    = "mvimd.daily.regrid.era5.1980-2019.nc"
f = addfile(diri+ fname, "r")

; var = "vimfc"
var = "mvimd"
x_raw = f->$var$

x  = x_raw * 86400.
copy_VarMeta(x_raw,x)

x@_FillValue = default_fillvalue("float")
replace_ieeenan(x, default_fillvalue("float"),0)
seasons = (/"SHSummer", "SHAutumn","SHWinter", "SHSpring"/)

nseas = dimsizes(seasons)
ndim  = dimsizes(x)

ystrt = 1981
ylast = 2018

ntim  = ndim(0)
nlat  = ndim(1)
nlon  = ndim(2)


TIME = x&time
DATE = cd_calendar(TIME, 0)

istrt   = ind(DATE(:,0).eq.ystrt)
ilast   = ind(DATE(:,0).eq.ylast)

print(istrt(0))

time        = TIME(istrt(0):ilast(dimsizes(ilast)-1))
ymdhms      = cd_calendar(time, 0)
; print(ymdhms)

raw = new((/nseas, nlat, nlon/), "float", x@_FillValue)

do i = 0, nseas-1
  foutname = var + "_anom_"+seasons(i)+"."+ystrt+"-"+ylast+"."+data+"."+type+".nc"
  iseason     = choose_season(seasons(i), ymdhms)

  ; xcheck = x(iseason,:,:)
  ; print(cd_calendar(xcheck&time, -2))
  ;
  ; delete(xcheck)
  printVarSummary(iseason)

  raw(i,:,:)  = dim_avg_n_Wrap(x(iseason,:,:), 0)
  anom= x(iseason,:,:) - conform_dims(dimsizes(x(iseason,:,:)), raw(i,:,:), (/1,2/))

  copy_VarCoords(x(0,:,:), raw(i,:,:))
  ; copy_VarCoords(x(iseason,:,:), anom(:,:,:))

  anom!0 = "time"
  anom!1 = "lat"
  anom!2 = "lon"

  anom&time = time(iseason)
  anom&lat = x&lat
  anom&lon = x&lon

  anom@units = "[mm/day]"
  anom@long_name = "seasonal anomaly during "+seasons(i)

  varout = var+"_anom"
  system("rm "+diro+foutname)
  fout = addfile(diro+foutname, "c")
  fout->$varout$ = anom

  delete(fout)
  delete(iseason)
  delete(anom)


end do

raw!0 = "seasons"
raw&seasons = (/1,2, 3, 4/)
raw@seasons = "1:DJF, 2:MAM, 3:JJA, 4:SON"
raw@units = ["mm/day"]

foutname = var + "_clim_seasonal"+"."+ystrt+"-"+ylast+"."+data+"."+type+".nc"

varout = var+"_seas"
system("rm "+diro+foutname)
printVarSummary(raw)
fout = addfile(diro+foutname, "c")
fout->$varout$ = raw
