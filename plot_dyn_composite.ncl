load "diag_local_wave_phase.ncl"

; load('$NCARG_ROOT/lib/ncarg/database/rangs')
diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/dynamics/"

waves  = (/"er", "kelvin",  "td","mjo","mrg","td-slow"/)
; thresh = 1
minlv = -25.
maxlv = 25.
intlv = 5.
; scale = 86400./1000.

seas = "SHSummer"

; fname    = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"+"mvimd.daily.regrid.1980-2019.nc"
; fname    = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"+"VIMFC_ERA5_1980-2018.nc"
fname    = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"+"VIMFC_ERA5_1980-2018.daysub.nc"
h = addfile(fname,"r")
; xraw = h->mvimd
xraw = h->vimfc

type = "raw"
data = "makeown"

replace_ieeenan(xraw, default_fillvalue("float"), 0)
t = xraw&time
yyyymmdd = cd_calendar(t,-2)
ystrt = 19810101
ylast = 20181231
istrt    = ind(yyyymmdd.eq.ystrt)
ilast    = ind(yyyymmdd.eq.ylast)

T = xraw&time(istrt:ilast)
ymdhms      = cd_calendar(T, 0)

; prilast)-1
; print(nlast)
iseason     = choose_season(seas, ymdhms)
xavg        = dim_avg_n_Wrap(xraw(iseason,:,:),0)

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

if data.eq."fromera" then
fname = wave+"_wave_composite_"+seas+"_vimfc_sig95.ref"+ref+"."+data+".nc"
scale = 86400.
else
fname = wave+"_wave_composite_"+seas+"_vimfc_sig95.ref"+ref+"."+data+"."+type+".nc"
scale = -86400./1000.
end if
; fname = "olr_er_wave_composite.nc"

f     = addfile(diri+fname, "r")
x_in  = short2flt(f->composite)
a     = short2flt(f->alpha)

x_in = -x_in
x_in@_FillValue = default_fillvalue("float")
replace_ieeenan(x_in, default_fillvalue("float"), 0)
a@_FillValue = default_fillvalue("float")
replace_ieeenan(a, default_fillvalue("float"), 0)

ndim = dimsizes(x_in)
; xseas = conform_dims(ndim, xavg, (/1,2/))

x     = where(a.eq.1., x_in*scale, x_in@_FillValue)
copy_VarMeta(x_in, x)
printVarSummary(x)

printMinMax(x,0)

n      = 8
;************************************************
; create plots
;************************************************
  ; wks = gsn_open_wks("png",diro+"dyn_anom_comp_fromera_"+wave+"_"+seas+"ref"+ref)              ; send graphics to PNG file
    wks = gsn_open_wks("png",diro+"dyn_comp_"+wave+"_"+seas+"ref"+ref+"."+type+data)              ; send graphics to PNG file

  cmap  = read_colormap_file("NCV_blu_red")
  cmap = cmap(::-1,:)
  cmap(9:10,:) = 0


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

  res@mpMaxLonF           = 170
  res@mpMinLonF           = 90


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
  res2@cnFillOn            = True             ; turn on color
  res2@lbLabelBarOn        = False            ; turn off individual cb's
  res2@cnLinesOn           = False
  ; res2@cnFillIndex         = 6
  res2@cnFillPattern       = 6
  res2@cnLevelSelectionMode =  "ManualLevels"
  res2@cnMinLevelValF       =  res@cnMinLevelValF
  res2@cnMaxLevelValF       =  res@cnMaxLevelValF
  res2@cnLevelSpacingF      =  res@cnLevelSpacingF
  res2@gsnAddCyclic         = False
  res@cnFillPalette         = cmap
  res2@cnInfoLabelOn        = False
  res2@cnLineLabelsOn        = False
  ; res2@cnFillColor          = "gray60"
  res2@gsnLeftString        = ""
  res2@gsnRightString        = ""

  res2@gsnContourNegLineDashPattern = 2
  res2@gsnContourZeroLineThicknessF = 2.5

  if data.ne."fromera" then
    x_in@units = "g/kg s^-1"
  end if

  x_con = x_in*scale
  copy_VarCoords(x_in,x_con)

  do g = 0, 7

    res@gsnFrame                    = False
    res@gsnLeftString = x@ndays(g+1) + " days"
    res@mpLandFillColor             = "transparent"
    res@mpOceanFillColor            = "white"
    res@cnFillOpacityF              = 1.0
    res@mpFillDrawOrder             = "PostDraw"
    ; res@gsnFrame                    = True
    ; res@mpFillAreaSpecifiers        = "Oceans"
    ; res@m
    ; res@mpMaskAreaSpecifiers        = "Australia"

    res@mpAreaMaskingOn       = False            ; Indicate we want to
    res@mpMaskAreaSpecifiers  = "Australia"  ; mask land.
    ; res@cnFillDrawOrder             = "PreDraw"

    ; res@gsnFrame = True
    ; res@gsnDraw  = False
    plot(plotsort(g)) = gsn_csm_contour_map(wks,x_con({g+1},:,:),res)
    plotc(plotsort(g)) = gsn_csm_contour(wks, x({g+1},:,:),res2)

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
  resP@lbLabelStride        = 2
  ; resP@lbTitleString  = x_in@units + "x"+sprintf("%10.5g",scale)
  resP@lbTitleString = "[ mm/day ]"
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
