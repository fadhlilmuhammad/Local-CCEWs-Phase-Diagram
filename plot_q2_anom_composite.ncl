load "diag_local_wave_phase.ncl"

; load('$NCARG_ROOT/lib/ncarg/database/rangs')
diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/dynamics/"

waves  = (/"er",  "td","mjo","mrg","td-slow"/)
; thresh = 1

scale = -10.^5
; scale = 86400./1000.

seas = "SHSummer"
; seasmon = "DJF"

type = "makeownsl.dailyanom.nofilter"
; remaptype =  "regrid"

do k =0, dimsizes(waves)-1
  ; write loop content

wave = waves(k)


if wave.eq."mjo" .or. wave.eq."er" then
  minlv = -3.
  maxlv = 3.
  intlv = .2

  vcref = 1.
  minolr = -3.
  maxolr = 3.
  intolr = .2
else if wave.eq."mrg" then
  minlv = -3.
  maxlv = 3.
  intlv = .2

    vcref = 1.
    minolr = -3.
    maxolr = 3.
    intolr = .2
else
  minlv = -3.
  maxlv = 3.
  intlv = .2

    vcref = 1.
    minolr = -3.
    maxolr = 3.
    intolr = .2
end if
end if

ref = 133

if seas.eq."SHSummer" then
  seasmon = "DJF"
else if seas.eq."SHSpring" then
  seasmon = "SON"
else if seas.eq."SHAutumn" then
  seasmon = "MAM"
else if seas.eq."SHWinter" then
  seasmon = "JJA"
else
  seasmon = seas
end if
end if
end if
end if

var2 = "q2"
; fname = wave+"_wave_composite_"+seas+"_thresh50_25km_sig90.nc"
; er_wave_composite_SHSummer_vimfc_sig95.ref133.makeown.dailyanom.nc
fname    = wave+"_wave_composite_"+seas+"_q2_sig95.ref"+ref+"."+type+".nc"
fname2   = wave+"_wave_composite_"+seas+"_"+var2+"_sig95.ref"+ref+".makeownsl.dailyanom.nofilter.nc"
; fname2  = wave+"_wave_composite_"+seas+"_vimfc_sig95.ref"+ref+".nc"

uname    = wave+"_wave_composite_"+seas+"_u850_sig95.ref"+ref+".fromera.dailyanom.nc"
vname    = wave+"_wave_composite_"+seas+"_v850_sig95.ref"+ref+".fromera.dailyanom.nc"
; fname2 = wave+"_wave_composite_"+seas+"_wdqdp_sig95.ref"+ref+".nc"
; fname = "olr_er_wave_composite.nc"

f     = addfile(diri+"gadi/"+fname, "r")
f2     = addfile(diri+"gadi/"+fname2, "r")

fu    = addfile(diri+uname, "r")
fv    = addfile(diri+vname, "r")


u_in  = short2flt(fu->composite)
v_in  = short2flt(fv->composite)

x_in  = short2flt(f->composite)
y_in  = short2flt(f2->composite)

a     = short2flt(f->alpha)
a2    = short2flt(f2->alpha)

au    = short2flt(fu->alpha)
av    = short2flt(fv->alpha)

x_in@_FillValue = default_fillvalue("float")
replace_ieeenan(x_in, default_fillvalue("float"), 0)

y_in@_FillValue = default_fillvalue("float")
replace_ieeenan(y_in, default_fillvalue("float"), 0)


; a2@_FillValue = default_fillvalue("float")
; replace_ieeenan(a2, default_fillvalue("float"), 0)

ndim = dimsizes(x_in)
; xseas = conform_dims(ndim, xavg, (/1,2/))

x     = where(x_in, x_in*scale, x_in@_FillValue)
; x     = where(a.eq.1, x, x_in@_FillValue)
; y = y_in

if var2.eq."q2" .or. var2.eq."dq_dt" .or. var2.eq."dqdtadvq" then
y     = where(a2.eq.1, y_in*scale, y_in@_FillValue)
else
y     = where(a2.eq.1, y_in*scale, y_in@_FillValue)
end if
; u     = where(au.eq.1., u_in, u_in@_FillValue)
; v     = where(av.eq.1., v_in, v_in@_FillValue)

u = u_in
v = v_in

printVarSummary(x)
printMinMax(x,0)
copy_VarMeta(x_in, x)
copy_VarMeta(y_in, y)
; copy_VarCoords(u_in, u)
; copy_VarCoords(v_in, v)

printVarSummary(x)
; printVarSummary(y)
printVarSummary(u)
printVarSummary(v)

printMinMax(x,0)

n      = 8
;************************************************
; create plots
;************************************************
  ; wks = gsn_open_wks("png",diro+"dyn_anom_comp_fromera_"+wave+"_"+seas+"ref"+ref)              ; send graphics to PNG file
    wks = gsn_open_wks("eps",diro+"q2_"+var2+"_comp_dailyanom_overlaid_"+wave+"_"+seas+"ref"+ref)              ; send graphics to PNG file

  cmap  = read_colormap_file("cmp_flux")
  cmap = cmap(::-1,:)
  ; cmap(9,:) = 0

  ; cmap(12:13,:) = 0
  ; ncmap = dimsizes(cmap(:,0))

  dum  = new(8, graphic)
  plot = new(n,graphic)                          ; create a plot array
  plotc = new(n, graphic)




  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
  res@cnFillPalette       = cmap
  res@lbLabelBarOn        = False            ; turn off individual cb's
  res@cnLinesOn           = False

  res@mpFillOn            = False
  res@mpMaxLatF           = -5
  res@mpMinLatF           = -25
  res@tmXBOn              = False
  res@tmXTOn              = True
  res@tmXTLabelsOn        = True

  res@mpMaxLonF           = 170
  res@mpMinLonF           = 90

  res@cnFillOpacityF      = 0.8


  ;---Set resources for better map outlines
  res@mpOutlineOn                 = True
  res@mpOutlineBoundarySets       = "AllBoundaries"
  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..4"       ; gives us some provincial boundaries


;---Increase thickness of map outlines
  res@mpPerimOn                   = True
  res@mpPerimLineThicknessF       = 1.0
  res@mpNationalLineThicknessF    = 1.0
  res@mpProvincialLineThicknessF  = 1.0
  res@mpGeophysicalLineThicknessF = 1.0
  res@mpPerimLineColor = "DarkGreen"
  ; res@g
;
; Force both plots to have the same contour levels. This is necessary
; because the gsn_panel routine will based the labelbar on the first
; plot in the list.
;
  res@cnLevelSelectionMode =  "ManualLevels"
  ; res@cnMinLevelValF       =  minlv
  ; res@cnMaxLevelValF       =  maxlv
  ; res@cnLevelSpacingF      =  intlv

  res@cnMinLevelValF       =  minolr
  res@cnMaxLevelValF       =  maxolr
  res@cnLevelSpacingF      =  intolr

  res@gsnAddCyclic         = False
  res@cnLineColors   = "darkgreen"
  res@gsnLeftString        = ""
  res@gsnRightString        = ""

  plotsort = (/0,2,4,6,1,3,5,7/)

  pres               = True
  pres@gsLineColor   = "blue"
  pres@gsMarkerIndex = 16
  pres@gsMarkerColor = "green"

  res2 = True
  ; res2@cnInfoLabelOn       = False            ; turn off cn info label
  ; res2@gsnDraw             = False
  ; res2@gsnFrame            = False
  ; res2@cnFillOn            = False             ; turn on color
  ; res2@lbLabelBarOn        = True           ; turn off individual cb's
  ; res2@cnLinesOn           = True
  ; res2@gsnContourNegLineDashPattern = 3
  ; res2@gsnContourPosLineDashPattern = 1

  res2@cnInfoLabelOn       = False            ; turn off cn info label
  res2@gsnDraw             = False
  res2@gsnFrame            = False
  res2@cnFillOn            = True             ; turn on color
  res2@lbLabelBarOn        = False            ; turn off individual cb's
  res2@cnLinesOn           = False
  res2@cnFillIndex         = 6
  res2@cnFillPattern       = 3
  ; res@cnMissingValFillColor = "grey"
  res2cnFillColor = "black"

  ; res2@cnFillIndex         = 6
  ; res2@cnFillPattern       = 6
  ; res2@cnFillOpacityF      = 0.9
  ; res2@cnFillScaleF        = .5         ; add extra density
  ; res2@cnLineThicknessF    = 1.2
  ; res2@cnLineColor = "darkgreen"
  ; res2@cnLevelSelectionMode =  "ManualLevels"


  ; res2@cnMinLevelValF       =  minlv
  ; res2@cnMaxLevelValF       =  maxlv
  ; res2@cnLevelSpacingF      =  intlv

  ; res@cnFillOn = False

  res2@gsnAddCyclic         = False
  ; res2@cnFillPalette         = "NCV_blu_red"
  res2@cnInfoLabelOn        = False
  res2@cnLineLabelsOn        = False
  ; res2@cnFillColor          = "gray60"
  res2@gsnLeftString        = ""
  res2@gsnRightString        = ""
  res2@pmLabelBarHeightF    = 0.1
  res2@lbLabelFontHeightF   = 0.01

  res2@gsnContourNegLineDashPattern = 2
  res2@gsnContourZeroLineThicknessF = 2.5

  x_con = x
  copy_VarCoords(x_in,x_con)

  do g = 0, 7

    if g.eq.0 then
    res2@cnInfoLabelOn        = False
    res@vcRefAnnoOn          = True
    else
    res2@cnInfoLabelOn       = False
    res@vcRefAnnoOn          = False
    end if


    res@gsnFrame                    = False
    res@gsnRightString = x@ndays(g+1) + " days"
    res@mpLandFillColor             = "transparent"
    res@mpOceanFillColor            = "white"
    res@cnFillOpacityF              = 0.85
    res@gsnRightStringFontHeightF   = 0.017
    res@tmXTLabelFontHeightF    = 0.017
    res@tmYLLabelFontHeightF    = 0.017
    res@mpFillDrawOrder             = "PreDraw"
    res@gsnScalarContour            = True
    res@vcRefMagnitudeF          = vcref             ; define vector ref mag
    res@vcRefLengthF             = 0.045            ; define length of vec ref
    res@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
    res@vcMinDistanceF           = 0.023            ; thin vectors
    res@vcRefAnnoString2On = True
    res@vcRefAnnoString2   = "ms~S1~- ~S1~1"
    res@vcRefAnnoOrthogonalPosF  = -.9               ; move ref vector down
    res@cnInfoLabelOn = False
    res@cnLineLabelsOn = False
    res2@cnInfoLabelOn = False
    res2@cnFillOpacityF = 1.
    res2@lbLabelBarOn = False
    ; res@gsnFrame                    = True
    ; res@mpFillAreaSpecifiers        = "Oceans"
    ; res@m
    ; res@mpMaskAreaSpecifiers        = "Australia"

    res@mpAreaMaskingOn       = False            ; Indicate we want to
    res@mpMaskAreaSpecifiers  = "Australia"  ; mask land.

    if g.eq.4 then
      res2@cnInfoLabelFontHeightF = 0.008
      res2@cnInfoLabelParallelPosF = 0.3
      ; res2@cnInfoLabelJust  = "BottomLeft"
      res2@cnInfoLabelOn = False
    else
      res2@cnInfoLabelOn  = False
    end if
    ; res@cnFillDrawOrder             = "PreDraw"


    if g.eq.1 then
      ; res@gsnLeftString = "VIMFC (contour): [ kgm~S1~- ~S1~2 s~S1~- ~S1~1 "+" x 10~S1~- ~S1~5 "+" ]";"OLR (contour): Wm~S1~- ~S1~2"
      res@gsnLeftStringFontHeightF = 0.012
    else
      res@gsnLeftString = ""
    end if

    if g.eq.0.or.g.eq.4 then
      res@tmXTLabelsOn = True
    else
      res@tmXTLabelsOn = False
    end if

    if g.eq.3.or.g.eq.7 then
      res@tmXBOn = True
      res@tmXBLabelsOn = True
    else
      res@tmXBOn = False
      res@tmXBLabelsOn = False
    end if

    if g.le.3 then
      res@tmYLLabelsOn = True
    else
      res@tmYLLabelsOn = False
    end if
    ; res@gsnFrame = True
    ; res@gsnDraw  = False
    plot(plotsort(g)) = gsn_csm_vector_scalar_map(wks,u({g+1}, {-25:5}, {90:170}),v({g+1}, {-25:5}, {90:170}),x({g+1}, {-25:5}, {90:170}),res)
    plotc(plotsort(g)) = gsn_csm_contour(wks, y({g+1}, {-25:5}, {90:170}),res2)

    ;
    ; Create some dummy data for adding several polymarkers to plot, each
    ; set with a different color and marker style.
    ;

    overlay(plot(plotsort(g)), plotc(plotsort(g)))

    ; res@gsnDraw                     = True

    ; plot(plotsort(g)) = gsn_csm_contour_map(wks,x({g+1},:,:),res)
    ; print("Adding polygons...")
    ; poly(plotsort(g)) = gsn_add_shapefile_polylines(wks,plot(plotsort(g)),"AUS_2021_AUST_SHP_GDA2020/AUS_2021_AUST_GDA2020.shp",pres)

  end do



; do g = 0, 7
;
; ; if g.eq.0 then
; ;   lonL = 150
; ;   lonR = 170
; ; else if g.eq.1 then
; ;   lonL = 140
; ; else if g.eq.2 then
; ;   lonL = 130
; ; else if g.eq.3 then
; ;   lonL = 125
; ;   lonR = 155
; ; else if g.eq.4 then
; ;   lonL = 120
; ;   lonR = 150
; ; else if g.eq.5 then
; ;   lonL = 110
; ;   lonR = 140
; ; else if g.eq.6 then
; ;   lonL = 100
; ;   lonR = 130
; ; else
; ;   lonL = 100
; ;   lonR = 130
; ; end if
; ; end if
; ; end if
; ; end if
; ; end if
; ; end if
; ; end if
;
;
; lonL = 100
; lonR = 170
;
; xuse =  y({g+1}, {-25:-10}, {lonL:lonR})
; ; onedval = ndtooned(xuse)
; ; dsizes_a = dimsizes(xuse)
; ; indices  = ind_resolve(maxind(onedval), dsizes_a)
; ;
; ; print(indices)
;   pmres = True
; pmres@gsMarkerColor = "red"
; pmres@gsMarkerIndex = 12
; pmres@gsMarkerSizeF = 15.
; pmres@gsMarkerThicknessF = 1.2
; ;
; ; txres = True
; ; txres@txFontColor = "black"
; ; txres@txPerimColor = "black"
; ; txres@txFontHeightF = .02
; ;
;
; indices = local_max(xuse, 0, 0.1)
; ; print(indices@maxval)
;
;
; if max(indices@maxval).gt.0 then
; imax  = ind(max(indices@maxval).eq.indices@maxval)
; print(imax)
;
; lons = indices@xi
; lats = indices@yi
;
; ; lonval = xuse&longitude(indices(0,1))
; ; latval = xuse&latitude(indices(0,0))
;
; lonval = xuse&longitude(lons(imax))
; latval = xuse&latitude(lats(imax))
;
;
; dum(plotsort(g)) = gsn_add_polymarker(wks, plot(plotsort(g)), lonval,latval, pmres)
;
;
; delete(xuse)
; delete(lons)
; delete(lats)
; ; delete(onedval)c
;
; else
;   ;
;   delete(xuse)
;   ; delete(lons)
;   ; delete(lats)
; end if

; end do



do g = 0, 7

; if g.eq.0 then
;   lonL = 150
;   lonR = 170
; else if g.eq.1 then
;   lonL = 140
; else if g.eq.2 then
;   lonL = 130
; else if g.eq.3 then
;   lonL = 125
;   lonR = 155
; else if g.eq.4 then
;   lonL = 120
;   lonR = 150
; else if g.eq.5 then
;   lonL = 110
;   lonR = 140
; else if g.eq.6 then
;   lonL = 100
;   lonR = 130
; else
;   lonL = 100
;   lonR = 130
; end if
; end if
; end if
; end if
; end if
; end if
; end if


lonL = 100
lonR = 170

xuse =  y({g+1}, {-25:-10}, {lonL:lonR})
; onedval = ndtooned(xuse)
; dsizes_a = dimsizes(xuse)
; indices  = ind_resolve(maxind(onedval), dsizes_a)
;
; print(indices)
  pmres = True
pmres@gsMarkerColor = "red"
pmres@gsMarkerIndex = 12
pmres@gsMarkerSizeF = 15.
pmres@gsMarkerThicknessF = 1.2
;
; txres = True
; txres@txFontColor = "black"
; txres@txPerimColor = "black"
; txres@txFontHeightF = .02
;

indices = local_max(xuse, 0, 0.1)
; print(indices@maxval)


if max(indices@maxval).gt.0 then
imax  = ind(max(indices@maxval).eq.indices@maxval)
print(imax)

lons = indices@xi
lats = indices@yi

; lonval = xuse&longitude(indices(0,1))
; latval = xuse&latitude(indices(0,0))

lonval = xuse&longitude(lons(imax))
latval = xuse&latitude(lats(imax))


dum(plotsort(g)) = gsn_add_polymarker(wks, plot(plotsort(g)), lonval,latval, pmres)


delete(xuse)
delete(lons)
delete(lats)
; delete(onedval)c

else
  ;
  delete(xuse)
  ; delete(lons)
  ; delete(lats)
end if

end do


;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  txres = True
  txres@txFuncCode    = ":"

  ; eqs = "( ~F18~-~F18~O~F18~t~F18~V"+"qV~F18~P )"
  eqs = "~F18~(~F21~Q~B~2~E~  /L~F18~ ="
  eqs2 = " ~F18~-~F18~O~F8~~H6~~V10~~F18~s~F10~q~H-40~~V-1~~F21~__~H-35~~V-30~~F18~s~F10~t~V+20~~H+10~~F18~P'~F18~-"
  eqs3 = "~F18~OtV"+"~F10~(Vq)~F18~P'"
  eqs4 = "~F18~-~F18~O~F10~w~F8~~H6~~V10~~F18~s~F10~q~H-40~~V-1~~F21~__~H-35~~V-30~~F18~s~F10~p~V+20~~H+10~~F18~P'~F18~)"
  ; eqs3 = " ~F18~-~F18~O~F8~~H6~~V10~~F18~s~F10~q~H-40~~V-1~~F21~__~H-35~~V-30~~F18~s~F10~t~V+20~~H+10~~F18~P'~F18~)"
  ; eqs2 = "~F18~-~F18~O~F18~t~F18~V"+"~F10~q~F10~V~F18~P' ~F10~&"
  ; eqs2 = " (~F18~-~F18~O~F8~~H6~~V10~~F18~s~F10~q~H-40~~V-1~~F21~__~H-35~~V-30~~F18~s~F10~t~V+20~~H+10~~F18~P'~F18~)"

  if (wave) .eq. "td" then
    resP@gsnPanelMainString = eqs+eqs2+eqs3+eqs4   ; set main title
    ; resP@gsnPanelMainString = ""

    resP@gsnPanelFigureStrings= (/"P1) "+str_upper(wave) + "-type waves: "+seasmon + " ","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel

  else if (wave) .eq. "mjo" then
    resP@gsnPanelMainString = eqs+eqs2+eqs3+eqs4   ; set main title
    ; resP@gsnPanelMainString = ""
    resP@gsnPanelFigureStrings= (/"P1) "+str_upper(wave) + ": "+seasmon + " ","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel

  else
    resP@gsnPanelMainString = eqs+eqs2+eqs3+eqs4   ; set main title
    ; resP@gsnPanelMainString = ""
    resP@gsnPanelFigureStrings= (/"P1) "+str_upper(wave) + " waves: "+seasmon + " ","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel

  end if
  end if

  resP@gsnPanelBottom   = 0.                   ; add space at bottom
  ; resP@gsnPanelFigureStrings= (/"P1)","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF  = 0.0076
  resP@amJust   = "TopLeft"
  resP@lbLabelStride        = 2
  resP@lbTitleString  ="[ kgm~S1~- ~S1~2 s~S1~- ~S1~1 "+" x 10~S1~- ~S1~5 "+" ]" ;"[ Wm~S1~- ~S1~2 "+" ]"
  resP@lbTitlePosition = "bottom"
  resP@lbTopMarginF    = 0.
  resP@lbOrientation = "Horizontal"
  resP@pmLabelBarHeightF = 0.04
  resP@pmLabelBarWidthF = 0.7
  resP@lbLabelFontHeightF = 0.01
  resP@lbBottomMarginF = -0.9
  resP@lbTitleFontHeightF = 0.01

  ; resP@gsnPanelMainPosXF  = 0.2

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot



  txres               = True
  txres@txFontHeightF = 0.015
  ; gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end do
