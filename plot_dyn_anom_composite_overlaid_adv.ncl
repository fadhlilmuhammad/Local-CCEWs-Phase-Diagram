load "diag_local_wave_phase.ncl"

; load('$NCARG_ROOT/lib/ncarg/database/rangs')
diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/dynamics/"

waves  = (/"er", "kelvin",  "td","mjo","mrg","td-slow"/)
; thresh = 1
minlv = -6.
maxlv = 6.
intlv = .5
scale = 86400./1000.

seas = "SHSummer"

type = "makeown.anom30"
; remaptype =  "regrid"

do k =0, dimsizes(waves)-1
  ; write loop content

wave = waves(k)
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

; fname = wave+"_wave_composite_"+seas+"_thresh50_25km_sig90.nc"
fname   = wave+"_wave_composite_"+seas+"_imfc_adv_sig95.ref"+ref+"."+type+".nc"
fname2  = wave+"_wave_composite_"+seas+"_imfc_adv_sig95.ref"+ref+"."+type+".nc"

uname   = wave+"_wave_composite_"+seas+"_u850_sig95.ref"+ref+"."+type+".nc"
vname   = wave+"_wave_composite_"+seas+"_v850_sig95.ref"+ref+"."+type+".nc"
; fname2 = wave+"_wave_composite_"+seas+"_wdqdp_sig95.ref"+ref+".nc"
; fname = "olr_er_wave_composite.nc"

f     = addfile(diri+fname, "r")
f2     = addfile(diri+fname2, "r")

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
a2@_FillValue = default_fillvalue("float")
replace_ieeenan(a2, default_fillvalue("float"), 0)

ndim = dimsizes(x_in)
; xseas = conform_dims(ndim, xavg, (/1,2/))

x     = where(a.eq.1., -x_in*scale, x_in@_FillValue)
y     = where(a2.eq.1., -y_in*scale, y_in@_FillValue)
; u     = where(au.eq.1., u_in, u_in@_FillValue)
; v     = where(av.eq.1., v_in, v_in@_FillValue)

printMinMax(y,0)

u = u_in
v = v_in

copy_VarMeta(x_in, x)
copy_VarMeta(y_in, y)
copy_VarMeta(u_in, u)
copy_VarMeta(v_in, v)

printVarSummary(x)
printVarSummary(y)
printVarSummary(u)
printVarSummary(v)

printMinMax(x,0)

n      = 8
;************************************************
; create plots
;************************************************
  ; wks = gsn_open_wks("png",diro+"dyn_anom_comp_fromera_"+wave+"_"+seas+"ref"+ref)              ; send graphics to PNG file
    wks = gsn_open_wks("png",diro+"dyn_anom_comp_dailyanom_adv_overlaid_"+wave+"_"+seas+"ref"+ref+"."+type)              ; send graphics to PNG file

  cmap  = read_colormap_file("MPL_PuOr")
  ; cmap = cmap(::-1,:)
  ; cmap(9:10,:) = 0

  ; cmap(12:13,:) = 0
  ; ncmap = dimsizes(cmap(:,0))

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
  res@mpMinLatF           = -20
  res@tmXBOn              = False
  res@tmXTOn              = True
  res@tmXTLabelsOn        = True

  res@mpMaxLonF           = 170
  res@mpMinLonF           = 90


  ;---Set resources for better map outlines
  res@mpOutlineOn                 = True
  res@mpOutlineBoundarySets       = "AllBoundaries"
  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..4"       ; gives us some provincial boundaries


;---Increase thickness of map outlines
  res@mpPerimOn                   = True
  res@mpPerimLineThicknessF       = 1.0
  res@mpNationalLineThicknessF    = 3
  res@mpProvincialLineThicknessF  = 1.1
  res@mpGeophysicalLineThicknessF = 1.5
  res@mpPerimLineColor = "DarkGreen"
  ; res@g
;
; Force both plots to have the same contour levels. This is necessary
; because the gsn_panel routine will based the labelbar on the first
; plot in the list.
;
  res@cnLevelSelectionMode =  "ManualLevels"
  res@cnMinLevelValF       =  minlv
  res@cnMaxLevelValF       =  maxlv
  res@cnLevelSpacingF      =  intlv
  res@gsnAddCyclic         = False
  res@gsnLeftString        = ""
  res@gsnRightString        = ""

  plotsort = (/0,2,4,6,1,3,5,7/)

  pres               = True
  pres@gsLineColor   = "blue"
  pres@gsMarkerIndex = 16
  pres@gsMarkerColor = "green"

  res2 = True
  res2@cnInfoLabelOn       = False            ; turn off cn info label
  res2@gsnDraw             = False
  res2@gsnFrame            = False
  res2@cnFillOn            = False             ; turn on color
  res2@lbLabelBarOn        = True           ; turn off individual cb's
  res2@cnLinesOn           = True
  ; res2@gsnContourNegLineDashPattern = 3
  ; res2@gsnContourPosLineDashPattern = 1
  res2@cnFillIndex         = 6
  res2@cnFillPattern       = 6
  res2@cnFillOpacityF      = 1.0
  res2@cnFillScaleF        = .5         ; add extra density
  res2@cnLineThicknessF    = 1.2
  res2@cnLevelSelectionMode =  "ManualLevels"
  res2@cnMinLevelValF       =  res@cnMinLevelValF
  res2@cnMaxLevelValF       =  res@cnMaxLevelValF
  res2@cnLevelSpacingF      =  res@cnLevelSpacingF
  res2@gsnAddCyclic         = False
  res2@cnFillPalette         = "sunshine_diff_12lev"
  res2@cnLineLabelDensityF  = 2.
  res2@cnLineLabelPlacementMode  = "computed"


  res2@cnLineLabelsOn        = True
  res2@gsnContourZeroLineThicknessF = 2.

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
    res2@cnInfoLabelOn        = True
    res@vcRefAnnoOn          = True
    else
    res2@cnInfoLabelOn       = False
    res@vcRefAnnoOn          = False
    end if


    res@gsnFrame                    = False
    res@gsnRightString = x@ndays(g+1) + " days"
    res@mpLandFillColor             = "transparent"
    res@mpOceanFillColor            = "white"
    res@cnFillOpacityF              = 2.0
    res@gsnRightStringFontHeightF   = 0.017
    res@tmXTLabelFontHeightF    = 0.017
    res@tmYLLabelFontHeightF    = 0.017
    res@mpFillDrawOrder             = "PostDraw"
    res@gsnScalarContour            = True
    res@vcRefMagnitudeF          = 2.0             ; define vector ref mag
    res@vcRefLengthF             = 0.045            ; define length of vec ref
    res@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
    res@vcMinDistanceF           = 0.023            ; thin vectors
    res@vcRefAnnoString2On = True
    res@vcRefAnnoString2   = "m/s"
    res@vcRefAnnoOrthogonalPosF  = -.9               ; move ref vector down

    if g.eq.0.or.g.eq.4 then
      res@tmXTLabelsOn = True
    else
      res@tmXTLabelsOn = False
    end if

    if g.le.3 then
      res@tmYLLabelsOn = True
    else
      res@tmYLLabelsOn = False
    end if
    ; res@gsnFrame                    = True
    ; res@mpFillAreaSpecifiers        = "Oceans"
    ; res@m
    ; res@mpMaskAreaSpecifiers        = "Australia"

    res@mpAreaMaskingOn       = False            ; Indicate we want to
    res@mpMaskAreaSpecifiers  = "Australia"  ; mask land.
    ; res@cnFillDrawOrder             = "PreDraw"

    ; res@gsnFrame = True
    ; res@gsnDraw  = False
    plot(plotsort(g)) = gsn_csm_vector_scalar_map(wks,u({g+1},:,:),v({g+1},:,:),y({g+1},:,:),res)
    plotc(plotsort(g)) = gsn_csm_contour(wks, x_con({g+1},{-20:-5},:),res2)

    ; plotc(plotsort(g)) = ColorNegDashZeroPosContour(plotc(plotsort(g)),"darkbrown","magenta","darkgreen")
    ; overlay(plot(plotsort(g)), plotc(plotsort(g)))


    ; res@gsnDraw                     = True

    ; plot(plotsort(g)) = gsn_csm_contour_map(wks,x({g+1},:,:),res)
    ; print("Adding polygons...")
    ; poly(plotsort(g)) = gsn_add_shapefile_polylines(wks,plot(plotsort(g)),"AUS_2021_AUST_SHP_GDA2020/AUS_2021_AUST_GDA2020.shp",pres)

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
  eqs = "~F18~(~F18~-~F18~O~F10~V~F18~V"+"~F18~t~F10~q~F18~P'"
  eqs2 = "~F18~)"

  if (wave) .eq. "td" then
    resP@gsnPanelMainString = eqs +eqs2   ; set main title
    resP@gsnPanelFigureStrings= (/"P1) "+str_upper(wave) + "-type waves: "+seasmon + " ","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel

  else if (wave) .eq. "mjo" then
    resP@gsnPanelMainString = eqs +eqs2   ; set main title
    resP@gsnPanelFigureStrings= (/"P1) "+str_upper(wave) + " "+seasmon + " ","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel

  else
    resP@gsnPanelMainString = eqs +eqs2   ; set main title
    resP@gsnPanelFigureStrings= (/"P1) "+str_upper(wave) + " waves: "+seasmon + " ","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel

  end if
  end if


  resP@gsnPanelBottom   = 0.                   ; add space at bottom
  ; resP@gsnPanelFigureStrings= (/"P1)","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF  = 0.0076
  resP@amJust   = "TopLeft"
  resP@lbLabelStride        = 2
  resP@lbTitleString  = "[mm/day]"
  resP@lbTitlePosition = "bottom"
  resP@lbTopMarginF    = 0.9
  resP@lbOrientation = "vertical"
  resP@pmLabelBarHeightF = 0.35
  resP@pmLabelBarWidthF = 0.06
  resP@lbLabelFontHeightF = 0.01
  resP@lbBottomMarginF = 0.015
  resP@lbTitleFontHeightF = 0.01

  ; resP@gsnPanelMainPosXF  = 0.2

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot



  txres               = True
  txres@txFontHeightF = 0.015
  ; gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end do
