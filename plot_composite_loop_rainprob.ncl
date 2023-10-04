
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
remaptype =  "shift1day"


do k =0, dimsizes(waves)-1
  ; write loop content

wave = waves(k)
seas = "SHSummer"
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

fname = wave+"_wave_composite_"+seas+"_wetdays_025_sig95.ref"+ref+".shift1day.nc"
; fname = "er_wave_composite_SHSummer_perc95_025_sig95.ref133.regrid.nc"
; fname = wave+"_wave_composite_"+seas+"ref"+ref+"."+remaptype+".nc"
; fname = "olr_er_wave_composite.nc"

f     = addfile(diri+fname, "r")
x_in  = short2flt(f->composite_anom)
a     = short2flt(f->alpha)
x     = where(a.eq.1., x_in, x_in@_FillValue)
copy_VarMeta(x_in, x)
printVarSummary(x)

n      = 8
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png",diro+"rainprob_comp_"+wave+"_"+seas+"ref"+ref+"_"+remaptype)              ; send graphics to PNG file

  cmap  = read_colormap_file("hotcold_18lev")
  ; cmap  = cmap(::-1,:)
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

  res@mpFillOn            = True
  res@mpMaxLatF           = -10
  res@mpMinLatF           = -25

  res@mpMaxLonF           = 155
  res@mpMinLonF           = 112


  ;---Set resources for better map outlines
  res@mpOutlineOn                 = True
  res@mpOutlineBoundarySets       = "AllBoundaries"
  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..4"       ; gives us some provincial boundaries


;---Increase thickness of map outlines
  res@mpPerimOn                   = True
  res@mpPerimLineThicknessF       = 2.0
  res@mpNationalLineThicknessF    = 3
  res@mpProvincialLineThicknessF  = 1.1
  res@mpGeophysicalLineThicknessF = 1.5
  res@mpPerimLineColor = "DarkGreen"
  ; res@cnFillMode = "CellFill"

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


  ; res@cnLevelSelectionMode =  "ExplicitLevels"
  ; res@cnMinLevelValF       =  minlv
  ; res@cnMaxLevelValF       =  maxlv
  ; res@cnLevelSpacingF      =  intlv
  ; res@cnLevels = (/0.2, 0.33, 0.5, 0.65, 0.8, 0.9, 1.0, 1.11, 1.25, 1.5, 2.0, 3.0, 5.0/)
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
  res2@cnFillOn            = True             ; turn on color
  res2@lbLabelBarOn        = False            ; turn off individual cb's
  res2@cnLinesOn           = False
  ; res2@cnFillIndex         = 6
  res2@cnFillPattern       = 6
  res@cnMissingValFillColor = "grey"
  res2@cnLevelSelectionMode =  "ManualLevels"
  ; res2@cnMinLevelValF       =  res@cnMinLevelValF
  ; res2@cnMaxLevelValF       =  res@cnMaxLevelValF
  ; res2@cnLevelSpacingF      =  res@cnLevelSpacingF

  ; res2@cnLevelSelectionMode =  "ExplicitLevels"
  res@cnMinLevelValF       =  minlv
  res@cnMaxLevelValF       =  maxlv
  res@cnLevelSpacingF      =  intlv
  ; res2@cnLevels = (/0.2,0.33,0.4, 0.5, 0.6, 0.7,0.8, 0.9, 1.0, 1.25, 1.5,1.8, 2.0, 2.2,2.5,2.8,3.0/)
  ; 2/10,3/10,4/10,5/10,6/10,7/10,8/10,9/10,1,
  res2@gsnAddCyclic         = False
  res@cnFillPalette         = cmap
  res2@cnInfoLabelOn        = False
  res2@cnLineLabelsOn        = False
  ; res2@cnFillColor          = "gray60"
  res2@gsnLeftString        = ""
  res2@gsnRightString        = ""

  res2@gsnContourNegLineDashPattern = 2
  res2@gsnContourZeroLineThicknessF = 2.5


  ; res2@gsnContourNegLineDashPattern = 2
  ; res2@gsnContourZeroLineThicknessF = 2.5

  x_con = x
  copy_VarCoords(x_in,x_con)

  do g = 0, 7

    res@gsnFrame                    = False
    res@gsnLeftString = x@ndays(g+1) + " days"
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
    plot(plotsort(g)) = gsn_csm_contour_map(wks,x_in({g+1},:,:),res)
    plotc(plotsort(g)) = gsn_csm_contour(wks, x_con({g+1},:,:),res2)

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
  resP@gsnPanelFigureStrings= (/"P1)","P5)","P2)","P6)","P3)","P7)","P4)","P8)"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  resP@lbLabelStride        = 1
  resP@lbTitleString  = "[ x times relative to season ]"
  resP@lbTitlePosition = "bottom"
  resP@lbTopMarginF    = 0.4
  resP@lbBottomMarginF = 0.005
  resP@lbTitleFontHeightF = 0.01

  ; resP@gsnPanelMainPosXF  = 0.2

  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot



  txres               = True
  txres@txFontHeightF = 0.015
  ; gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end do
