
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "wkSpaceTime_mod.ncl"


lat  = 25
SEAS = "SHSpring"
diri  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/STSA/"
wkdir = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/STSA/"
f  = addfile(diri+"FR04.SpaceTime."+SEAS+"."+lat+".nc","r")

coord = f->FIG_3_SYM
x = f->FIG_3_ALL

copy_VarCoords(coord,x)
copy_VarAtts(coord,x)
;------------------------------------------------------------------
; ALL
;------------------------------------------------------------------

symasym = x

printVarSummary(symasym)

res = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/0.9, 1., 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8,1.9,2.0/)
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
res@gsnMaximize       = True
res@gsnPaperOrientation = "portrait"

res@gsnLeftString     = "Westward"
res@gsnRightString    = "Eastward"

;res@lbBoxMinorExtentF = 0.18
res@lbLabelFontHeightF= 0.015
res@lbOrientation     = "vertical"

res@cnFillOn          = True
res@cnLinesOn     = False

minfrq = 0.02
maxfrq = 0.5

res@tmYLMode          = "Explicit"
res@tmYLValues        = fspan(minfrq,maxfrq,9)
res@tmYLLabels        = fspan(minfrq,maxfrq,9)
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
wks  = gsn_open_wks(pltType,wkdir+"/Fig3.symAsym."+lat+".South_"+SEAS)
gsn_define_colormap(wks,pltColorMap)
res@gsnCenterString = "OLR: "+SEAS+" Southern Hemispher"
plot = gsn_csm_contour(wks,symasym,res)


res@tmYUseLeft  =  False                 ; disassociate  YR tick marks with YL tick marks
; res@tmYROn = True
; res@tmYRLabelsOn      = True
res@tmYRMode          = "Explicit"

; res@tmYRMinorValues   = period2
; draw(plot)

addHorVertLines(wks, plot, x1,x2,y1,y2,y3,y4 ) ; add dashed lines

; draw dispersion line
gsn_polyline(wks,plot,Apzwn(3,0,:),Afreq(3,0,:),dcres)
gsn_polyline(wks,plot,Apzwn(3,1,:),Afreq(3,1,:),dcres)
gsn_polyline(wks,plot,Apzwn(3,2,:),Afreq(3,2,:),dcres)
gsn_polyline(wks,plot,Apzwn(4,0,:),Afreq(4,0,:),dcres)
gsn_polyline(wks,plot,Apzwn(4,1,:),Afreq(4,1,:),dcres)
gsn_polyline(wks,plot,Apzwn(4,2,:),Afreq(4,2,:),dcres)
; gsn_polyline(wks,plot,Apzwn(5,0,:),Afreq(5,0,:),dcres)
; gsn_polyline(wks,plot,Apzwn(5,1,:),Afreq(5,1,:),dcres)
; gsn_polyline(wks,plot,Apzwn(5,2,:),Afreq(5,2,:),dcres)

gsn_polyline(wks,plot,Apzwn(0,0,:),Afreq(0,0,:),dcres)
gsn_polyline(wks,plot,Apzwn(0,1,:),Afreq(0,1,:),dcres)
gsn_polyline(wks,plot,Apzwn(0,2,:),Afreq(0,2,:),dcres)

tdres = dcres
tdres@gsLineColor = "red"

ftd1 = 1/2.5
ftd2 = 1/5.
gsn_polyline(wks,plot,(/-15,-15/), (/ftd2,ftd1/),tdres)
gsn_polyline(wks,plot,(/-6,-6/), (/ftd2,ftd1/),tdres)
gsn_polyline(wks,plot,(/-15,-6/), (/ftd1,ftd1/),tdres)
gsn_polyline(wks,plot,(/-15,-6/), (/ftd2,ftd2/),tdres)


tdres@gsLineColor = "darkgreen"
tdres@gsLineThicknessF = 5.0
;ER
; gsn_polyline(wks,plot,Apzwn(3,0,:),Afreq(3,0,:),tdres)
; gsn_polyline(wks,plot,Apzwn(3,2,:),Afreq(3,2,:),tdres)


kend    = ind(Apzwn(3,0,:).le.-1.and.Apzwn(3,0,:).gt.-1.1)
; print(Apzwn(0,0,:))
print(kend)
gsn_polyline(wks,plot,Apzwn(3,0,kend:99),Afreq(3,0,kend:99),tdres)

; freqend = ind(Afreq(0,2,:).ge.1/3.and. Afreq(0,2,:).lt.1./3.5)

print(freqend)
print(Afreq(0,2,25))
gsn_polyline(wks,plot,Apzwn(3,2,kend:99),Afreq(3,2,kend:99),tdres)
gsn_polyline(wks,plot,(/-1,-1/),(/Afreq(3,0,kend),Afreq(3,2,kend)/),tdres)



;KELVIN

tdres@gsLineColor = "violetred4"
print(Afreq(4,0,:))
; freqend = ind(Afreq(0,0,:).le.1/18.2.and. Afreq(0,0,:).gt.1./17)

freqend = ind(Afreq(4,0,:).le.1/9..and. Afreq(4,0,:).gt.1./10)
print(freqend)
kend    = ind(Apzwn(4,0,:).ge.14.and.Apzwn(4,0,:).lt.14.5)

gsn_polyline(wks,plot,Apzwn(4,0,kend:freqend),Afreq(4,0,kend:freqend),tdres)
gsn_polyline(wks,plot,Apzwn(4,2,kend:freqend),Afreq(4,2,kend:freqend),tdres)
gsn_polyline(wks,plot,(/Apzwn(0,0,kend),Apzwn(0,0,kend)/),(/Afreq(4,0,kend),Afreq(4,2,kend)/),tdres)
gsn_polyline(wks,plot,(/Apzwn(0,0,freqend),Apzwn(0,0,freqend)/),(/Afreq(4,0,freqend),Afreq(4,2,freqend)/),tdres)

; ; gsn_polyline(wks,plot,Apzwn(5,0,:),Afreq(5,0,:),tdres)
; ; gsn_polyline(wks,plot,Apzwn(5,1,:),Afreq(5,1,:),tdres)
; ; gsn_polyline(wks,plot,Apzwn(5,2,:),Afreq(5,2,:),tdres)

;MRG=
; print(Afreq(0,0,:))
; print(Apzwn(0,0,:))

tdres@gsLineColor = "purple"
freqend = ind(Afreq(0,0,:).ge.1/10.1.and. Afreq(0,0,:).lt.1./10)
kend    = ind(Apzwn(0,0,:).le.-1.and.Apzwn(0,0,:).gt.-1.1)
; print(Apzwn(0,0,:))
print(kend)
gsn_polyline(wks,plot,Apzwn(0,0,kend:99),Afreq(0,0,kend:99),tdres)

; freqend = ind(Afreq(0,2,:).ge.1/3.and. Afreq(0,2,:).lt.1./3.5)

print(freqend)
print(Afreq(0,2,25))
gsn_polyline(wks,plot,Apzwn(0,2,kend:99),Afreq(0,2,kend:99),tdres)
gsn_polyline(wks,plot,(/-1,-1/),(/Afreq(0,0,kend),Afreq(0,2,kend)/),tdres)

;MJO
tdres@gsLineColor = "saddlebrown"

fmjo1 = 1/20.
fmjo2 = 1/100.
gsn_polyline(wks,plot,(/1,1/), (/fmjo2,fmjo1/),tdres)
gsn_polyline(wks,plot,(/5,5/), (/fmjo2,fmjo1/),tdres)
gsn_polyline(wks,plot,(/1,5/), (/fmjo1,fmjo1/),tdres)
gsn_polyline(wks,plot,(/1,5/), (/fmjo2,fmjo2/),tdres)
;
; fmrg1 = 1/3.
; fmrg2 = 1/10.
; kmrg1 = -1
; kmrg2 = -10
; gsn_polyline(wks,plot,(/kmrg1,kmrg1/), (/fmrg2,fmrg1/),tdres)
; gsn_polyline(wks,plot,(/kmrg2,kmrg2/), (/fmrg2,fmrg1/),tdres)
; gsn_polyline(wks,plot,(/kmrg1,kmrg2/), (/fmrg1,fmrg1/),tdres)
; gsn_polyline(wks,plot,(/kmrg1,kmrg2/), (/fmrg2,fmrg2/),tdres)
;
;
; ferw1 = 1/9.
; ferw2 = 1/72.
; kerw1 = -1
; kerw2 = -10
; gsn_polyline(wks,plot,(/kerw1,kerw1/), (/ferw2,ferw1/),tdres)
; gsn_polyline(wks,plot,(/kerw2,kerw2/), (/ferw2,ferw1/),tdres)
; gsn_polyline(wks,plot,(/kerw1,kerw2/), (/ferw1,ferw1/),tdres)
; gsn_polyline(wks,plot,(/kerw1,kerw2/), (/ferw2,ferw2/),tdres)
;
;
; fklv1 = 1/3.
; fklv2 = 1/10.
; kklv1 = 1
; kklv2 = 14
; gsn_polyline(wks,plot,(/kklv1,kklv1/), (/fklv2,fklv1/),tdres)
; gsn_polyline(wks,plot,(/kklv2,kklv2/), (/fklv2,fklv1/),tdres)
; gsn_polyline(wks,plot,(/kklv1,kklv2/), (/fklv1,fklv1/),tdres)
; gsn_polyline(wks,plot,(/kklv1,kklv2/), (/fklv2,fklv2/),tdres)



fer1 = 1/7.
fer2 = 1/12.
res_poly = True
res_poly@gsFillColor = "black"
gsn_polygon(wks,plot,(/12,15,15,12,12/),(/fer1,fer1,fer2,fer2,fer1/),res_poly)

; gsn_polyline(wks,plot,)
; gsn_polyline(wks,plot,Apzwn(1,0,:),Afreq(1,0,:),dcres)
; gsn_polyline(wks,plot,Apzwn(1,1,:),Afreq(1,1,:),dcres)
; gsn_polyline(wks,plot,Apzwn(1,2,:),Afreq(1,2,:),dcres)
; gsn_polyline(wks,plot,Apzwn(2,0,:),Afreq(2,0,:),dcres)
; gsn_polyline(wks,plot,Apzwn(2,1,:),Afreq(2,1,:),dcres)
; gsn_polyline(wks,plot,Apzwn(2,2,:),Afreq(2,2,:),dcres)

; dispersion labels

gsn_text(wks,plot,"MRG",-10.0,.15,txres)
; gsn_text(wks,plot,"n=2 IG",-3.0,.58,txres)
; gsn_text(wks,plot,"n=0 EIG",9.5,.50,txres)
; gsn_text(wks,plot,"h=50",-10.0,.78,txres)
; gsn_text(wks,plot,"h=25",-10.0,.63,txres)
; gsn_text(wks,plot,"h=12",-10.0,.51,txres)
gsn_text(wks,plot,"TD-type",-10.0,.3,txres)

gsn_text(wks,plot,"Kelvin",11.0,.40,txres)
gsn_text(wks,plot,"n=1 ER",-10.7,.07,txres)
; gsn_text(wks,plot,"n=1 IG",-3.0,.45,txres)
; gsn_text(wks,plot,"h=50",-14.0,.78,txres)
; gsn_text(wks,plot,"h=25",-14.0,.60,txres)
; gsn_text(wks,plot,"h=12",-14.0,.46,txres)
gsn_text(wks,plot,"TD-type",-10.0,.3,txres)
gsn_text(wks,plot,"MJO",6.0,.03,txres)

frame(wks)
