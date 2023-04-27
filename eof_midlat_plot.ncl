waves  = "midlatitude Rossby"
latS = -50
latN = -15

folder = "dataout/"
fname = "eof.olr.midlatitude.rossby.nc"
; fname = "eof.olr."+waves+".20NS.nc"

f = addfile(folder+fname, "r")

eof = f->eof

ndim = dimsizes(eof)
neof = ndim(0)

do i = 0, neof-1
  x = sum(eof@pcvar(0:i))
  if x.gt.80 then
    print("eof, ke-"+(i+1))
  else
    print("var="+x)
  end if
end do

printVarSummary(eof)

; n = 0
pltDir = "tryfigure/"
;
do n = 0, neof-1
  pltName = "eof_midlatrossby_"+(n+1)
    ; pltName = "eof_"+waves+"_20NS_"+(n+1)
  pltPath = pltDir+pltName

  wks = gsn_open_wks("png",pltPath)
  ; plot = new(1,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnStringFontHeightF = 0.015         ; make larger than default

  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpCenterLonF         = 180.
  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "GreenMagenta16"     ; set color map
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's

  res@gsnLeftString        = "EOF-"+(n+1)+": "+str_upper(waves)+" Waves"
  res@gsnRightString       = eof@pcvar(n)
                                          ; set symmetric plot min/max
  ; symMinMaxPlt(eof,  8, False, res)       ; contributed.ncl

  plot=gsn_csm_contour_map_ce(wks,eof(n,:,:),res)
  draw(plot)
  frame(wks)
end do
