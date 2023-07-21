
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "wkSpaceTime_mod.ncl"




lat  = 25
SEAS = "SHSummer"
diri  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/STSA/"
wkdir = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/STSA/"
f  = addfile(diri+"SpaceTime."+SEAS+"."+lat+".nc","r")

coord = f->FIG_3_SYM
x = f->FIG_3_ALL

copy_VarCoords(coord,x)
copy_VarAtts(coord,x)


nseas = 4
ndim  = dimsizes(coord)
printVarSummary(ndim)

stsa = new((/nseas, ndim(0), ndim(1)/), float)

if nseas.eq.4 then
seasname = (/"SHSummer","SHSpring", "SHAutumn", "SHWinter"/)
else
seasname = (/"MJJASO", "NDJFMA"/)
end if


do i = 0, nseas-1

  SEAS  = seasname(i)
  f  = addfile(diri+"SpaceTime."+SEAS+"."+lat+"_hann.nc","r")
  a  = f->FIG_3_ALL
  stsa(i,:,:) = (/a/)
  delete(a)

  copy_VarAtts(coord,stsa)
  copy_VarCoords(coord,stsa(i,:,:))
end do
;------------------------------------------------------------------
; ALL
;------------------------------------------------------------------

symasym = stsa

printVarSummary(symasym)

res = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/1.9, 2., 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8,2.9,3.0/)
pltColorMap  = "wind_17lev"


wavenumber  = ispan(-15,15,1)
NWVN       = dimsizes(wavenumber)         ; number of wavenumbers

x1   = wavenumber
x1!0 = "wave"
y1   = new (NWVN,float)
y1!0 = "freq"
y1   = 1./3.           ; 3 days
y2   = y1
y2   = 1./6.           ; 6 days
y3   = y1
y3   = 1./30.          ; 30 days
x2   = new(25,float)
x2   = 0.0
y4   = fspan(0.0,1.0,25)

fillVal    = 1e20           ; miscellaneous

;---------------------------------------------------------------
; dispersion: curves
;---------------------------------------------------------------

rlat           = 0.0
Ahe            = (/50.,25.,12./)
nWaveType      = 6
nPlanetaryWave = 100
nEquivDepth    = dimsizes(Ahe)
Apzwn          = new((/nWaveType,nEquivDepth,nPlanetaryWave/),"double",fillVal)
Afreq          = Apzwn
genDispersionCurves(nWaveType, nEquivDepth, nPlanetaryWave, rlat, Ahe, Afreq, Apzwn )

;---------------------------------------------------------------
; dispersion curve and text plot resources
;---------------------------------------------------------------
dcres = True
dcres@gsLineThicknessF  = 2.0
dcres@gsLineDashPattern = 0

txres = True
txres@txJust        = "CenterLeft"
txres@txPerimOn     = True
txres@txFontHeightF = 0.013
txres@txBackgroundFillColor = "Background"


;---------------------------------------------------------------
; pLOT RESOURCES
;---------------------------------------------------------------

res = True
res@gsnFrame          = False
res@gsnDraw           = False
res@gsnMaximize       = False
res@gsnPaperOrientation = "portrait"

res@gsnLeftString     = "Westward"
res@gsnRightString    = "Eastward"

;res@lbBoxMinorExtentF = 0.18
res@lbLabelFontHeightF= 0.015
res@lbOrientation     = "vertical"

res@cnFillOn          = True
res@cnLinesOn     = False
res@lbLabelBarOn  = False
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False


minfrq = 0.0
maxfrq = 0.5

res@tmYLMode          = "Explicit"
res@tmYLValues        = fspan(minfrq,maxfrq,9)
res@tmYLLabels        = decimalPlaces(fspan(minfrq,maxfrq,9),2,True)
res@tmYLMinorValues   = fspan(minfrq,maxfrq,17)

res@tmYLLabelFontHeightF = 0.015
res@tmXBLabelFontHeightF = 0.015

res@tiXAxisString     = "Zonal Wave Number"
res@tiXAxisFontHeightF= 0.015

res@tiYAxisString     = "Frequency (cpd)"
res@tiYAxisFontHeightF= 0.015


; res@tiYAxisString     = "Period (days)"
; res@tiYAxisFontHeightF= 0.015


period  = decimalPlaces(fspan(1/(minfrq+0.01),1/maxfrq,9),1,True)
period2 = fspan(1/(minfrq+0.01),1/maxfrq,17)

print(period)
; res@tmYLValues        = period
; res@tmYLLabels        = period

pltType = "png"
wks  = gsn_open_wks(pltType,wkdir+"/Fig3.symAsym."+lat+"_"+nseas+"season_hann")
gsn_define_colormap(wks,pltColorMap)

plot = new(nseas, graphic)


dum = new(32*nseas+1,graphic)
dom = new((/nseas, 7/), graphic)
j=0
print(j)
do i = 0, nseas-1
res@gsnCenterStringFontHeightF = 0.023
res@gsnCenterString = "OLR: "+seasname(i)+" "+lat+"N-"+lat+"S"
plot(i) = gsn_csm_contour(wks,symasym(i,:,:),res)
;
; res@tmYUseLeft  =  False                 ; disassociate  YR tick marks with YL tick marks
; ; res@tmYROn = True
; ; res@tmYRLabelsOn      = True
; res@tmYRMode          = "Explicit"

; res@tmYRMinorValues   = period2
; draw(plot(i)(i))

dom(i,:) = addHorVertLines_panel(wks, plot(i), x1,x2,y1,y2,y3,y4 ) ; add dashed lines

; draw dispersion line
dum(j) = gsn_add_polyline(wks,plot(i),Apzwn(3,0,:),Afreq(3,0,:),dcres)
dum(j+1) = gsn_add_polyline(wks,plot(i),Apzwn(3,2,:),Afreq(3,2,:),dcres)
dum(j+2) = gsn_add_polyline(wks,plot(i),Apzwn(4,0,:),Afreq(4,0,:),dcres)
dum(j+3) = gsn_add_polyline(wks,plot(i),Apzwn(4,1,:),Afreq(4,1,:),dcres)
dum(j+4) = gsn_add_polyline(wks,plot(i),Apzwn(4,2,:),Afreq(4,2,:),dcres)
dum(j+5) = gsn_add_polyline(wks,plot(i),Apzwn(0,0,:),Afreq(0,0,:),dcres)
dum(j+6) = gsn_add_polyline(wks,plot(i),Apzwn(0,1,:),Afreq(0,1,:),dcres)
dum(j+7) = gsn_add_polyline(wks,plot(i),Apzwn(0,2,:),Afreq(0,2,:),dcres)

tdres = dcres
tdres@gsLineColor = "red"

ftd1 = 1/2.5
ftd2 = 1/5.
dum(j+8) = gsn_add_polyline(wks,plot(i),(/-15,-15/), (/ftd2,ftd1/),tdres)
dum(j+9) = gsn_add_polyline(wks,plot(i),(/-6,-6/), (/ftd2,ftd1/),tdres)
dum(j+10) = gsn_add_polyline(wks,plot(i),(/-15,-6/), (/ftd1,ftd1/),tdres)
dum(j+11) = gsn_add_polyline(wks,plot(i),(/-15,-6/), (/ftd2,ftd2/),tdres)


tdres@gsLineColor = "darkgreen"
tdres@gsLineThicknessF = 5.0
;ER
; gsn_add_polyline(wks,plot(i),Apzwn(3,0,:),Afreq(3,0,:),tdres)
; gsn_add_polyline(wks,plot(i),Apzwn(3,2,:),Afreq(3,2,:),tdres)


kend    = ind(Apzwn(3,0,:).le.-1.and.Apzwn(3,0,:).gt.-1.1)
; print(Apzwn(0,0,:))
; print(kend)
dum(j+12) = gsn_add_polyline(wks,plot(i),Apzwn(3,0,kend:99),Afreq(3,0,kend:99),tdres)

; freqend = ind(Afreq(0,2,:).ge.1/3.and. Afreq(0,2,:).lt.1./3.5)

; print(freqend)
; print(Afreq(0,2,25))
dum(j+13) = gsn_add_polyline(wks,plot(i),Apzwn(3,2,kend:99),Afreq(3,2,kend:99),tdres)
dum(j+14) = gsn_add_polyline(wks,plot(i),(/-1,-1/),(/Afreq(3,0,kend),Afreq(3,2,kend)/),tdres)



;KELVIN

tdres@gsLineColor = "violetred4"
; print(Afreq(4,0,:))
; freqend = ind(Afreq(0,0,:).le.1/18.2.and. Afreq(0,0,:).gt.1./17)

freqend = ind(Afreq(4,0,:).le.1/9..and. Afreq(4,0,:).gt.1./10)
; print(freqend)
kend    = ind(Apzwn(4,0,:).ge.14.and.Apzwn(4,0,:).lt.14.5)

dum(j+15) = gsn_add_polyline(wks,plot(i),Apzwn(4,0,kend:freqend),Afreq(4,0,kend:freqend),tdres)
dum(j+16) = gsn_add_polyline(wks,plot(i),Apzwn(4,2,kend:freqend),Afreq(4,2,kend:freqend),tdres)
dum(j+17) = gsn_add_polyline(wks,plot(i),(/Apzwn(0,0,kend),Apzwn(0,0,kend)/),(/Afreq(4,0,kend),Afreq(4,2,kend)/),tdres)
dum(j+18) = gsn_add_polyline(wks,plot(i),(/Apzwn(0,0,freqend),Apzwn(0,0,freqend)/),(/Afreq(4,0,freqend),Afreq(4,2,freqend)/),tdres)

; ; gsn_add_polyline(wks,plot(i),Apzwn(5,0,:),Afreq(5,0,:),tdres)
; ; gsn_add_polyline(wks,plot(i),Apzwn(5,1,:),Afreq(5,1,:),tdres)
; ; gsn_add_polyline(wks,plot(i),Apzwn(5,2,:),Afreq(5,2,:),tdres)

;MRG=
; print(Afreq(0,0,:))
; print(Apzwn(0,0,:))

tdres@gsLineColor = "purple"
freqend = ind(Afreq(0,0,:).ge.1/10.1.and. Afreq(0,0,:).lt.1./10)
kend    = ind(Apzwn(0,0,:).le.-1.and.Apzwn(0,0,:).gt.-1.1)
; print(Apzwn(0,0,:))
; print(kend)
dum(j+19) = gsn_add_polyline(wks,plot(i),Apzwn(0,0,kend:99),Afreq(0,0,kend:99),tdres)

; freqend = ind(Afreq(0,2,:).ge.1/3.and. Afreq(0,2,:).lt.1./3.5)

; print(freqend)
; print(Afreq(0,2,25))
dum(j+20) = gsn_add_polyline(wks,plot(i),Apzwn(0,2,kend:99),Afreq(0,2,kend:99),tdres)
dum(j+21) = gsn_add_polyline(wks,plot(i),(/-1,-1/),(/Afreq(0,0,kend),Afreq(0,2,kend)/),tdres)

;MJO
tdres@gsLineColor = "saddlebrown"

fmjo1 = 1/20.
fmjo2 = 1/100.
dum(j+22) = gsn_add_polyline(wks,plot(i),(/1,1/), (/fmjo2,fmjo1/),tdres)
dum(j+23) = gsn_add_polyline(wks,plot(i),(/5,5/), (/fmjo2,fmjo1/),tdres)
dum(j+24) = gsn_add_polyline(wks,plot(i),(/1,5/), (/fmjo1,fmjo1/),tdres)
dum(j+25) = gsn_add_polyline(wks,plot(i),(/1,5/), (/fmjo2,fmjo2/),tdres)
;



fer1 = 1/7.
fer2 = 1/12.
res_poly = True
res_poly@gsFillColor = "black"
dum(j+26) = gsn_add_polygon(wks,plot(i),(/12,15,15,12,12/),(/fer1,fer1,fer2,fer2,fer1/),res_poly)

; dispersion labels

dum(j+27) = gsn_add_text(wks,plot(i),"MRG",-10.0,.15,txres)
; gsn_text(wks,plot(i),"n=2 IG",-3.0,.58,txres)
; gsn_text(wks,plot(i),"n=0 EIG",9.5,.50,txres)
; gsn_text(wks,plot(i),"h=50",-10.0,.78,txres)
; gsn_text(wks,plot(i),"h=25",-10.0,.63,txres)
; gsn_text(wks,plot(i),"h=12",-10.0,.51,txres)
dum(j+28) = gsn_add_text(wks,plot(i),"TD-type",-10.0,.3,txres)

dum(j+29) = gsn_add_text(wks,plot(i),"Kelvin",11.0,.40,txres)
dum(j+30) = gsn_add_text(wks,plot(i),"n=1 ER",-10.7,.07,txres)
; gsn_text(wks,plot(i),"n=1 IG",-3.0,.45,txres)
; gsn_text(wks,plot(i),"h=50",-14.0,.78,txres)
; gsn_text(wks,plot(i),"h=25",-14.0,.60,txres)
; gsn_text(wks,plot(i),"h=12",-14.0,.46,txres)
dum(j+31) = gsn_add_text(wks,plot(i),"TD-type",-10.0,.3,txres)
dum(j+32) = gsn_add_text(wks,plot(i),"MJO",6.0,.03,txres)

j = j+32
end do

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot(i)
  resP@gsnFrame         = False                  ; don't advance panel plot(i)
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  resP@gsnPanelMainString = ""     ; set main title
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@cnLabelBarEndLabelsOn  = True
  resP@lbOrientation   = "vertical"

  if nseas.eq.4 then
  resP@amJust   = "TopLeft"
  resP@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/) ; add strings to panel
  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot(i)
  else
  resP@amJust   = "TopLeft"
  resP@gsnPanelFigureStrings= (/"a)","b)"/) ; add strings to panel
  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot(i)

  end if


  txres               = True
  txres@txFontHeightF = 0.015



frame(wks)
