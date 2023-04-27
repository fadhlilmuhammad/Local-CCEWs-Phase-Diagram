
begin

waves = (/"kelvin", "er", "mjo", "mrg", "eig", "wig","td", "td-slow"/)
outdir  = "dataout/"
outfile = "waves.northAU.nc"

xout = new((/dimsizes(waves),15706, 144/), float, default_fillvalue("float")) ; waves,time,lon
printVarSummary(xout)

do i = 0, dimsizes(waves)-1

  wave = waves(i)

  if wave.eq."kelvin" then
    latN = 15.0
    latS = -15.
  else
    latN = -10.0
    latS = -20.
  end if

  f = addfile(outdir+"olr."+wave+".20NS.nc", "r")

  x = f->$wave$(:,{latS:latN},:)

  lat = x&lat
  rad    = 4.0*atan(1.0)/180.0
  clat   = cos(lat*rad)

  x_avg = dim_avg_wgt_n_Wrap(x, clat, 1, 1)
  printVarSummary(x_avg)
  xout(i,:,:) = x_avg

  copy_VarCoords(x_avg,xout(i,:,:))
  copy_VarMeta(x_avg,xout(i,:,:))

  delete(x_avg)
  delete(x)
  delete(f)
  delete(lat)
  delete(clat)

end do

system("rm "+outdir+outfile)
fout = addfile(outdir+outfile, "c")


do i = 0, dimsizes(waves)-1
  wave = waves(i)
  fout->$wave$ = xout(i,:,:)

end do

end
