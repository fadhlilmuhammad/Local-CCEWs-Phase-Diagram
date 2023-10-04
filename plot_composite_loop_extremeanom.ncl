
; load('$NCARG_ROOT/lib/ncarg/database/rangs')
diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/precip/"
; diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/precip/gadi/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/precip/"

waves  = (/"er", "kelvin",  "td","mjo","mrg","td-slow"/)
; thresh = 1
minlv = 0.
maxlv = 2.
intlv = .1

;remaptype =  "025"
; remaptype =  "check_wTC"
remaptype =  "shift1day.dailyanom"


do k =0, dimsizes(waves)-1
  ; write loop content

wave = waves(k)
seas = "SHAutumn"
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
; mjo_wave_composite_SHSummer_perc95_025_sig95.ref133.check_wTC.nc
; fname = wave+"_wave_composite_"+seas+"_perc95_025_sig95.ref"+ref+".regrid.nc"
; fname = wave+"_wave_composite_"+seas+"_perc95_025_sig95.ref"+ref+".check_wTC.nc"

perc = 90
fname  = wave+"_wave_composite_"+seas+"_perc"+perc+"_025_sig90.ref"+ref+".shift1day.nc"
fname2 = "prec_anom_"+wave+"_wave_composite_"+seas+"ref"+ref+"."+remaptype+".nc"
; fname = "er_wave_composite_SHSummer_perc95_025_sig95.ref133.regrid.nc"
; fname = wave+"_wave_composite_"+seas+"ref"+ref+"."+remaptype+".nc"
; fname = "olr_er_wave_composite.nc"

f     = addfile(diri+fname, "r")
f2    = addfile(diri+fname2, "r")

x_in  = short2flt(f->composite_anom)
x_in2 = short2flt(f2->composite)
a     = short2flt(f->alpha)
a2    = short2flt(f2->alpha)

x      = where(a.eq.1., x_in, x_in@_FillValue)
; x_anom = where(a2.eq.1., x_in2, x_in2@_FillValue)
x_anom = x_in2


copy_VarMeta(x_in, x)
copy_VarMeta(x_in2, x_anom)
; x_in   = where(x_in.gt.0., x_in, x_in@_FillValue)
copy_VarMeta(x, x_in)

printVarSummary(x)

coords_rr = wgt_areaave_Wrap(x_anom(:,{-25:-10},{112:155}),1,1,0)
mean_rr  =  tostring_with_format(decimalPlaces(wgt_areaave_Wrap(x_anom(:,{-25:-10},{112:155}), 1.,1., 0),1,False), "%2.1f")
; mean_rr   =  tostring_with_format(decimalPlaces(dim_median(dim_median(x_anom(:,{-25:-10},{112:155}))),1,False), "%2.1f")
max_rr   =  tostring_with_format(decimalPlaces(dim_max(dim_max(x_anom(:,{-25:-10},{112:155}))),1,False), "%2.1f")
min_rr   =  tostring_with_format(decimalPlaces(dim_min(dim_min(x_anom(:,{-25:-10},{112:155}))),1,False), "%2.1f")

mean_Pr  =  tostring_with_format(decimalPlaces(wgt_areaave_Wrap(x(:,{-25:-10},{112:155}), 1.,1., 0),1,False), "%2.1f")
; mean_Pr   =  tostring_with_format(decimalPlaces(dim_median(dim_median(x(:,{-25:-10},{112:155}))),1,False), "%2.1f")
max_Pr   =  tostring_with_format(decimalPlaces(dim_max(dim_max(x(:,{-25:-10},{112:155}))),1,False), "%2.1f")
min_Pr   =  tostring_with_format(decimalPlaces(dim_min(dim_min(x(:,{-25:-10},{112:155}))),1,False), "%2.1f")

;#altfix remove missing value
mean_Pr(0) = 0
max_Pr(0) = 0
min_Pr(0) = 0

;#CEK RR
do i = 0, 8
  ck_mean = tofloat(mean_rr(i)); write loop content
  ck_max  = tofloat(max_rr(i))
  ck_min  = tofloat(min_rr(i))

  if ck_mean.ge.0 then
    mean_rr(i) = "+"+tostring_with_format(abs(tofloat(mean_rr(i))), "%2.1f")
  else
    mean_rr(i) = "- "+tostring_with_format(abs(tofloat(mean_rr(i))), "%2.1f")
  end if
  if ck_max.ge.0 then
    max_rr(i) = "+"+tostring_with_format(abs(tofloat(max_rr(i))), "%2.1f")
  else
    max_rr(i) = "- "+tostring_with_format(abs(tofloat(max_rr(i))), "%2.1f")
  end if
  if ck_min.ge.0 then
    min_rr(i) = "+"+tostring_with_format(abs(tofloat(min_rr(i))), "%2.1f")
  else
    min_rr(i) = "- "+tostring_with_format(abs(tofloat(min_rr(i))), "%2.1f")
  end if
end do


;#CEK PR
; do i = 0, 8
;   ck_mean = tofloat(mean_Pr(i)); write loop content
;   ck_max  = tofloat(max_Pr(i))
;   ck_min  = tofloat(min_Pr(i))
;
;   print(ck_mean)
;   if ck_mean.ge.0 then
;     mean_Pr(i) = ""+tostring_with_format(abs(tofloat(mean_Pr(i))), "%2.1f")
;   else
;     mean_Pr(i) = "- "+tostring_with_format(abs(tofloat(mean_Pr(i))), "%2.1f")
;   end if
;   if ck_max.ge.0 then
;     max_Pr(i) = "+"+tostring_with_format(abs(tofloat(max_Pr(i))), "%2.1f")
;   else
;     max_Pr(i) = "- "+tostring_with_format(abs(tofloat(max_Pr(i))), "%2.1f")
;   end if
;   if ck_min.ge.0 then
;     min_Pr(i) = "+"+tostring_with_format(abs(tofloat(min_Pr(i))), "%2.1f")
;   else
;     min_Pr(i) = "- "+tostring_with_format(abs(tofloat(min_Pr(i))), "%2.1f")
;   end if
; end do

copy_VarMeta(coords_rr,mean_rr)
copy_VarMeta(coords_rr, max_rr)
copy_VarMeta(mean_rr, min_rr)


copy_VarMeta(coords_rr,mean_Pr)
copy_VarMeta(coords_rr, max_Pr)
copy_VarMeta(coords_rr, min_Pr)


print(mean_rr)

n      = 8
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("pdf",diro+"rain_anomextreme_comp_"+perc+wave+"_"+seas+"ref"+ref+"_"+remaptype)              ; send graphics to PNG file

  ; cmap  = read_colormap_file("precip_diff_12lev")
    ; cmap  = read_colormap_file("precip4_diff_19lev")
    cmap  = read_colormap_file("MPL_RdBu")
  ; cmap  = cmap(::-1,:)
  ; cmap(120:150,:) = 0
  ; cmap(7,:) = 0
  cmap(55:70,:) = 0
  ; ncmap = dimsizes(cmap(:,0))

  plot = new(n,graphic)                          ; create a plot array
  plotc = new(n, graphic)
  text_mean = new(n,graphic)
  text_max = new(n,graphic)
  text_min = new(n,graphic)

  rr_txtmean = new(n, graphic)
  rr_txtmax = new(n, graphic)
  rr_txtmin = new(n, graphic)

  Pr_txtmean = new(n, graphic)
  Pr_txtmax = new(n, graphic)
  Pr_txtmin = new(n, graphic)

  txt_title1 = new(n, graphic)
  txt_title2 = new(n, graphic)




  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
  res@cnFillPalette       = cmap
  res@lbLabelBarOn        = False            ; turn off individual cb's
  res@cnLinesOn           = False

  res@mpFillOn            = True
  res@mpMaxLatF           = -10
  res@mpMinLatF           = -25

  res@mpMaxLonF           = 155
  res@mpMinLonF           = 112

  res@tmXBMinorOn         = False
  res@tmYLMinorOn         = False

  res@tmYLLabelFontHeightF = 0.02

  res@cnLineLabelsOn = False
  res@tmYROn = False
  res@tmXTOn = False


  ;---Set resources for better map outlines
  res@mpOutlineOn                 = True
  res@mpFillOn = 0
  ; res@mpOutlineBoundarySets       = "AllBoundaries"
  ; res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  res@mpOutlineBoundarySets     = "NoBoundaries"

  res@mpOutlineSpecifiers      = (/"Australia : Northern Territory", "Australia : Queensland", "Australia : Western Australia"/)  ; continents only
  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..4"       ; gives us some provincial boundaries

  ; res@mpDataResolution            = "Coarse"


;---Increase thickness of map outlines
  res@mpPerimOn                   =False
  res@mpPerimLineThicknessF       = 0.3
  res@mpNationalLineThicknessF    = 0.5
  res@mpProvincialLineThicknessF  = 1.
  res@mpGeophysicalLineThicknessF = 0.5
  ; res@mp
  res@mpPerimLineColor = "darkgreen"
  res@mpGeophysicalLineColor = "black"
  ; res@mpNationalLineColor = "gray70"
  res@mpCountyLineColor ="gray70"
  res@mpUSStateLineColor = "gray70"
  ; res@cnFillMode = "CellFill"

  ; res@g
;
; Force both plots to have the same contour levels. This is necessary
; because the gsn_panel routine will based the labelbar on the first
; plot in the list.
;
  ; res@cnLevelSelectionMode =  "ManualLevels"
  ; res@cnMinLevelValF       =  minlv
  ; res@cnMaxLevelValF       =  maxlv
  ; res@cnLevelSpacingF      =  intlv


  res@cnLevelSelectionMode =  "ExplicitLevels"
  res@cnFillOpacityF = 0.8
  ; res@cnMinLevelValF       =  minlv
  ; res@cnMaxLevelValF       =  maxlv
  ; res@cnLevelSpacingF      =  intlv
  ; res@cnLevels = (/0.1, 0.2, 0.33, 0.5, 0.65, 0.8, 1.0,  1.25, 1.5, 2.0, 3.0, 3.5, 4.0/)
  ; res@cnLevels = (/0.005,0.01,0.02, 0.025, 0.03, 0.035,0.04,0.045, 0.05, 0.055, 0.06, 0.065, 0.07, 0.1,0.15,0.18,0.2/)
  ; res@cnLevels = (/0.2,0.3,0.4, 0.5, 0.6, 0.7,0.8,0.9, 1.0, 1.1, 1.25,1.5, 1.8, 2.,2.5,2.8,3.0/)

  res@cnLevels = (/0.2,0.3,0.4, 0.5, 0.6, 0.7,0.8, 1.0,1.25,1.4, 1.5, 1.6,1.7,1.8,2.0/)
  res@gsnAddCyclic         = False
  res@gsnLeftString        = ""
  res@gsnRightString        = ""

  plotsort = (/0,2,4,6,1,3,5,7/)

  pres               = True
  pres@gsLineColor   = "blue"
  pres@gsMarkerIndex = 16
  ; pres@gsMarkerColor = "thistle2"

  res2 = True
  res2@cnInfoLabelOn       = False            ; turn off cn info label
  res2@gsnDraw             = False
  res2@gsnFrame            = False
  res2@cnFillOn            = False             ; turn on color
  res2@lbLabelBarOn        = False            ; turn off individual cb's
  res2@cnLinesOn           = True
  res2@cnLineColor         = "black"
  ; res2@cnFillIndex         = 6
  ; res2@cnFillPattern       = 6
  res2@cnMissingValFillColor = "white"

  res2@cnLevelSelectionMode =  "ManualLevels"

  if wave.eq."er" .or. wave.eq."mjo" then
  res2@cnMinLevelValF       =  -5.
  res2@cnMaxLevelValF       =  5.
  res2@cnLevelSpacingF      =  2.
  else
  res2@cnMinLevelValF       =  -5.
  res2@cnMaxLevelValF       =  5.
  res2@cnLevelSpacingF      =  1.
  end if
  ; res2@gsnContourZeroLineThicknessF = 1.1

  ; res2@cnLevelSelectionMode =  "ExplicitLevels"
  ; res@cnMinLevelValF       =  minlv
  ; res@cnMaxLevelValF       =  maxlv
  ; res@cnLevelSpacingF      =  intlv
  res2@gsnLeftString         = ""
  ; res2@cnLevels = (/0.2,0.3,0.4, 0.5, 0.6, 0.7,0.8, 1.0,1.25,1.4, 1.5, 1.6,1.7,1.8,2.0/)
  ; 2/10,3/10,4/10,5/10,6/10,7/10,8/10,9/10,1,
  res2@gsnAddCyclic         = False
  ; res2@cnFillPalette = False
  ; res2@cnFillPattern        = 17
  ; res2@cnFillScaleF         = 1.2
  ; res2@cnMonoFillColor = True
  ; res2@cnFillColorOn        = True
  ; res2@cnFillColor          = "black"
  ; res2@cnFillDotSizeF       = 0.003
  res2@gsnRightString       = ""
  res2@cnLineLabelsOn    = True
  ; res2@cnLineLabelDensityF = 1.0
  res2@cnLineLabelPlacementMode = "constant"
  res2@cnLineDashSegLenF = 0.1
  res2@cnLineLabelInterval = 1
  ; res2@cnLineLabelConstantSpacingF =

  res@cnFillMode = "RasterFill"

  res2@cnFillMode = "RasterFill"
  res2@gsnContourNegLineDashPattern = 2
  res2@gsnContourLineThicknessesScale  = 1
  res2@gsnContourZeroLineThicknessF = 0.

  ; res2@cnLineLabel


  ; res2@gsnContourNegLineDashPattern = 2
  ; res2@gsnContourZeroLineThicknessF = 2.5

  x_con = x
  copy_VarCoords(x_in,x_con)

  do g = 0, 7
  if g.eq.4 then
    res2@cnInfoLabelOn = 0
    res2@cnInfoLabelSide    = "Top"
    res2@cnInfoLabelJust     = "TopRight"

  else
    res2@cnInfoLabelOn = False
  end if

  if g.gt.3 then
    res@tmYLOn = False
  else
    res@tmYLOn = True
  end if

    res@gsnFrame                    = False
    res@gsnLeftString = ""; x@ndays(g+1) + " )"
    res@mpLandFillColor             = "transparent"
    res@mpOceanFillColor            = "white"
    res@cnFillOpacityF              = 0.8
    res@mpFillDrawOrder             = "PostDraw"
    ; res@gsnFrame                    = True
    ; res@mpFillAreaSpecifiers        = "Oceans"
    ; res@m
    ; res@mpMaskAreaSpecifiers        = "Australia"

    res@mpAreaMaskingOn       = True            ; Indicate we want to
    res@mpMaskAreaSpecifiers  = "Australia"  ; mask land.
    res@cnFillDrawOrder             = "PreDraw"

    ; res@gsnFrame = True
    ; res@gsnDraw  = False

    x_anom_smth = smth9_Wrap(x_anom, -0.25, -0.25, False)
    plot(plotsort(g)) = gsn_csm_contour_map(wks,x_con({g+1},:,:),res)
    plotc(plotsort(g)) = gsn_csm_contour(wks, x_anom({g+1},:,:),res2)

  ;---Attach some dummy text strings
    txres               = True
    txres@txFontHeightF = 0.015
    txres@txJust        = "CenterLeft"


    txt_title1(g) = gsn_add_text(wks,plot(plotsort(g)),"RR",149.5,-11,txres)
    txt_title2(g) = gsn_add_text(wks,plot(plotsort(g)),"PR",152.5,-11,txres)

    text_mean(g) = gsn_add_text(wks,plot(plotsort(g)),"Avg",146,-12,txres)
    text_max(g)  = gsn_add_text(wks,plot(plotsort(g)),"Max ",146,-13,txres)
    text_min(g)  = gsn_add_text(wks,plot(plotsort(g)),"Min ",146,-14,txres)

    rr_txtmean(g) = gsn_add_text(wks,plot(plotsort(g)),mean_rr({g+1}),149,-12,txres)
    rr_txtmax(g)  = gsn_add_text(wks,plot(plotsort(g)),max_rr({g+1}),149,-13,txres)
    rr_txtmax(g)  = gsn_add_text(wks,plot(plotsort(g)),min_rr({g+1}),149,-14,txres)

    Pr_txtmean(g) = gsn_add_text(wks,plot(plotsort(g)),mean_Pr({g+1}),152.5,-12,txres)
    Pr_txtmax(g)  = gsn_add_text(wks,plot(plotsort(g)),max_Pr({g+1}),152.5,-13,txres)
    Pr_txtmax(g)  = gsn_add_text(wks,plot(plotsort(g)),min_Pr({g+1}),152.5,-14,txres)

    overlay(plot(plotsort(g)), plotc(plotsort(g)))


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
  if (wave) .eq. "td" then
    resP@gsnPanelMainString = str_upper(wave) + "-type waves: "+seasmon     ; set main title
  else if (wave) .eq. "mjo" then
    resP@gsnPanelMainString = str_upper(wave)+ ": "+seasmon     ; set main title
  else
    resP@gsnPanelMainString = str_upper(wave) + " waves: "+seasmon     ; set main title
  end if
  end if
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPanelFigureStrings= (/"(a) P1 ("+x@ndays(0) + ")","(e) P5 ("+x@ndays(4) + ")","(b) P2 ("+x@ndays(1) + ")","(f) P6 ("+x@ndays(5) + ")", \\
                              "(c) P3 ("+x@ndays(2) + ")","(g) P7 ("+x@ndays(6) + ")","(d) P4 ("+x@ndays(3) + ")","(h) P8 ("+x@ndays(7) + ")"/) ; add strings to panel
  resP@gsnPanelFigureStringsFontHeightF = 0.015
  resP@amJust   = "TopLeft"
  resP@lbLabelStride        = 1
  resP@lbTitleFontHeightF = 0.011
  resP@lbLabelFontHeightF = 0.011
  resP@lbTitleString  = "[ x times relative to season ]"
  resP@lbTitlePosition = "bottom"
  ; resP@lbTitleOffsetF = 0.5
  resP@lbTopMarginF    = .4
  ; resP@lbLabelOffsetF  = -1.0
  ; resP@lbBottomMarginF = 0.0001
  ; resP@pmLabelBarWidthF = 0.75
  ; resP@pmLabelBarHeightF = 0.04
  ; resP@lbTitleFontHeightF = 0.01

  ; resP@gsnPanelMainPosXF  = 0.2

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot



  txres               = True
  txres@txFontHeightF = 0.015
  ; gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end do
