; waves  = "kelvin"
latS = -20
latN = 20

seas = "SHSummer"

if seas.eq."SHSummer" then
  seasmon = "DJF"
else if seas.eq."SHWinter" then
  seasmon = "JJA"
end if
end if

type = "anom"
folder = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/misc/"

; fname = "eof.olr."+waves+".n40.nc"
fname = "eof.olr."+type+"."+seas+".nc"
; fname = "eof.olr."+waves+".20NS.nc"

f = addfile(folder+fname, "r")

eof = f->eof

printVarSummary(eof)

ndim = dimsizes(eof)
neof = ndim(0)
; n = 0
pltDir = ""
;

fig = (/0,2,4,6,8,10,12,14,16,18,1,3,5,7,9,11,13,15,17,19/)
  pltName = "eof_"+type+"_"+seas
    ; pltName = "eof_"+waves+"_20NS_"+(n+1)
  pltPath = pltDir+pltName

  wks = gsn_open_wks("png",diro+pltPath)
  plot = new(20,graphic)                ; create graphic array

  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnStringFontHeightF = 0.015         ; make larger than default

  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpCenterLonF         = 180.
  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "cmocean_curl"     ; set color map
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMaxLevelValF       = 0.08
  res@cnMinLevelValF       = -0.08
  res@cnLevelSpacingF      = 0.02
do n = 0, neof-1

  res@gsnLeftString        = "EOF-"+(n+1)+": Raw OLR values"
  res@gsnRightString       = sum(eof@pcvar(0:n))
                                          ; set symmetric plot min/max
  ; symMinMaxPlt(eof,  8, False, res)       ; contributed.ncl

  plot(fig(n))=gsn_csm_contour_map_ce(wks,eof(n,:,:),res)

  end do
  resP = True
  resP@gsnPanelMainString = "OLR anomalies smoothed: 1980-2018 ("+seasmon+")"

   resP@gsnPanelLabelBar    = True                ; add common colorbar
   resP@lbLabelFontHeightF  = 0.007               ; make labels smaller

   gsn_panel(wks,plot,(/10,2/),resP)               ; now draw as one plot
  ; draw(plot)
  ; frame(wks)
