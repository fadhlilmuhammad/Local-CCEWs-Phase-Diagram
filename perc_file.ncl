
load "utils.ncl"
load "diag_local_wave_phase.ncl"


diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
fname = "agcd_v1_precip_calib_r025_daily_1981-2020.maskedshp.shift1day.nc"

f = addfile(diri+fname, "r")

t = f->time
T = cd_calendar(t, -2)
istrt = ind(T.eq.19810101)
ilast = ind(T.eq.20181231)

x = f->precip(istrt:ilast,:,:)
perc = 95

x_th = where(x.gt.1, x, x@_FillValue)
copy_VarMeta(x,x_th)
season = "SHSummer"

if season.eq."SHSummer" then
  seasmon = "djf"
else if season.eq."SHAutumn" then
  seasmon = "mam"
end if
end if

time    = x_th&time
TIME    = cd_calendar(time,0)
iseason = choose_season(season, TIME)

x_season = x_th(iseason,:,:)

; pctl = percentile(x_season, perc)
; print(x_season)

pctl = new((/dimsizes(x_th&lat), dimsizes(x_th&lon)/),typeof(x_th), x_th@_FillValue)

do j = 0, dimsizes(x_th&lat)-1
  do i = 0, dimsizes(x_th&lon)-1
    if (.not.all(ismissing(x_season(:,j,i)))) then
    pctl(j,i) = percentile(x_season(:,j,i),perc)
    end if
    ; print(val)
  end do
end do

; pctl = stat_dispersion_3D(x_season, perc)

foutname    = "agcd_"+seasmon+"_"+perc+"_ncl.nc"

system("rm "+diri+foutname)
fout  = addfile(diri+foutname,"c")
fout->precip = pctl
