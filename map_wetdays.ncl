;----------------------------------------------------------------------
;  maponly_2.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Turning on map country boundaries
;   - Changing the color of map outlines
;   - Changing the thickness of map outlines
;   - Zooming in on a particular area on the map
;   - Turning off map fill
;   - Enabling the most up-to-date country boundaries
;----------------------------------------------------------------------
;
; Note: in NCL V6.4.0, mpDataBaseVersion will default to "MediumRes"
; if mpOutlineBoundarySets and/or mpFillBoundarySets is set to
; something other than "Geophyiscal".
;
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "diag_local_wave_phase.ncl"
;----------------------------------------------------------------------
begin

  diri = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
  dirishp = diri+"shpAUS/"
  foutname = "agcd_v1_precip_calib_r025_daily_1981-2020.nc"

  f95_mam = "agcd_mam_95.nc"
  f95_djf = "agcd_djf_95.nc"
  diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/misc/"

  f = addfile(diri+foutname, "r")
  fmam = addfile(diri+f95_mam, "r")
  fdjf = addfile(diri+f95_djf, "r")

  time = f->time
  dates = cd_calendar(time, -2)
  istrt = ind(dates.eq.19810101)
  ilast = ind(dates.eq.20181231)
  delete(time)

  x = f->precip(istrt:ilast,:,:)

  time = x&time
  TIME    = cd_calendar(time, 0)          ; type float
  year    = toint( TIME(:,0) )
  month   = toint( TIME(:,1) )
  day     = toint( TIME(:,2) )
  ddd     = day_of_year(year, month, day)
  yyyyddd = year*1000 + ddd

  iSummer     = choose_season("SHSummer", TIME)
  iAutumn     = choose_season("SHAutumn", TIME)

  xSummer = x(iSummer,:,:)
  xAutumn = x(iAutumn,:,:)

  mean_Summer  = dim_avg_n_Wrap(xSummer, 0)
  mean_Autumn  = dim_avg_n_Wrap(xAutumn, 0)

  mean_Summer  = dim_avg_n_Wrap(xSummer, 0)
  mean_Autumn  = dim_avg_n_Wrap(xAutumn, 0)

  th_Summer    = fdjf->precip
  th_Autumn    = fmam->precip

  coords = th_Summer

  x_wet = where(x.gt.1., 1., 0)
  copy_VarMeta(x, x_wet)
  wet_Summer   = dim_sum_n_Wrap(x_wet(iSummer,:,:),0)/dimsizes(iSummer)
  wet_Autumn   = dim_sum_n_Wrap(x_wet(iAutumn,:,:),0)/dimsizes(iAutumn)

  printMinMax(wet_Summer, 0)
  ; th_Summer = where(th_Summer.eq.0., th_Summer@_FillValue, th_Summer)
  ; th_Autumn = where(th_Autumn.eq.0., th_Autumn@_FillValue, th_Autumn)
  ; copy_VarMeta(coords,th_Summer)
  ; copy_VarMeta(coords,th_Autumn)

  ndim = dimsizes(mean_Summer)
  xvar = new((/6, ndim(0), ndim(1)/), "float")
  xname = (/"[A] DJF mean", "[D] MAM mean", "[B] DJF 95th", "[E] MAM 95th", "[C] DJF Prob raindays", "[F] MAM Prob raindays"/)

  xvar(0,:,:) = mean_Summer
  xvar(1,:,:) = mean_Autumn
  xvar(2,:,:) = (/th_Summer/)
  xvar(3,:,:) = (/th_Autumn/)
  xvar(4,:,:) = (/wet_Summer/)
  xvar(5,:,:) = (/wet_Autumn/)

  wks  = gsn_open_wks("png",diro+"mapstat_presentation_wet")           ; send graphics to PNG file
  plots = new(6, graphic)

  cmap  = read_colormap_file("wind_17lev")
  cmap2 = read_colormap_file("spread_15lev")
  cmap3 = read_colormap_file("precip_11lev")
  ; cmap2(0:,:) = 0


  res                             = True
  res@mpFillOn                    = True

  res@gsnDraw = False
  res@gsnFrame = False

  res@mpMaxLatF                   = -9           ; choose subregion
  res@mpMinLatF                   = -25
  res@mpMaxLonF                   = 155
  res@mpMinLonF                   = 112

  ;---Set resources for better map outlines
  res@mpOutlineOn                 = True


  res@mpOutlineBoundarySets       = "AllBoundaries"
  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..4"       ; gives us some provincial boundaries

  res@cnFillOn  = True
  res@cnLinesOn = False
  res@cnInfoLabelOn        = False
  res@cnLineLabelsOn        = False

  res@cnLevelSelectionMode =  "ManualLevels"

  res@cnFillPalette       = cmap
  res@gsnAddCyclic         = False
  res@gsnLeftString        = ""
  res@cnFillMode = "CellFill"
  res@gsnRightString        = ""

;---Increase thickness of map outlines
  res@mpPerimOn                   = True
  res@mpPerimLineThicknessF       = 2.0
  res@mpNationalLineThicknessF    = 3
  res@mpProvincialLineThicknessF  = 1.1
  res@mpGeophysicalLineThicknessF = 1.5
  res@mpPerimLineColor = "DarkGreen"

  res@cnMissingValFillColor = "gray"

  res@gsnAddCyclic = False

  res@mpAreaMaskingOn       = True            ; Indicate we want to
  res@mpMaskAreaSpecifiers  = "Australia"  ; mask land.
  res@cnFillDrawOrder             = "PreDraw"
  res@mpAreaMaskingOn       = True            ; Indicate we want to

  res@mpLandFillColor             = "transparent"
  res@mpOceanFillColor            = "white"
  res@cnFillOpacityF              = 1.0
  res@mpFillDrawOrder             = "Draw"

  res@lbTitleFontHeightF = 0.013
  res@lbLabelFontHeightF = 0.013


  res@pmLabelBarHeightF    = 0.07
  res@lbTopMarginF = 0.3
  ; res@lbLabelAlignment = "horizon"


  minlv = (/0,0,0,0,0,0/)
  maxlv = (/20,20,50,50,1,1/)
  intlv = (/2,2,2,2,0.1,0.1/)

  ; dum   = new(5, graphic)

  latSs = (/-17, -16, -20, -25, -23.5/)
  latNs = (/-11, -10, -13.5, -20, -16./)
  lonLs = (/129, 141, 120, 138, 146./)
  lonRs = (/137, 146, 128, 145, 151./)

  gres = True
  gres@gsLineColor = "black"   ;-- grid line color
  gres@gsLineThicknessF = 1.7   ;-- grid line thickness

  regions = (/"Top End", "Cape York", "Kimberley", "Inland Queensland", "East Coast"/)
  ;**********
  ;************************************************
  ; add the box
  ;************************************************
    resg                  = True                      ; polyline mods desired
    resg@gsLineColor      = "black"                     ; color of lines
    resg@gsLineThicknessF = 2.0                       ; thickness of lines

  ; create array of dummy graphic variables. This is required, b/c each line
  ; must be associated with a unique dummy variable.

  dum   = new(30,graphic)
  dumtx = new(30,graphic)
  dumtx2 = new(6,graphic)
  dum1  = new(6,graphic)

  n = 0
  do i = 0, 5

    if i.lt.4 then
    res@lbTitleString  = "[mm/day]"
    else
    res@lbTitleString  = "[rainfall probability]"
    end if
    res@lbTitlePosition = "bottom"

    res@cnMinLevelValF       =  minlv(i)
    res@cnMaxLevelValF       =  maxlv(i)
    res@cnLevelSpacingF      =  intlv(i)

    copy_VarCoords(mean_Summer,xvar(i,:,:))
    copy_VarAtts(mean_Summer,xvar(i,:,:))

    if i.lt.2 then
      delete(res@cnFillPalette)
      res@cnFillPalette = cmap
    else if i.lt.4 then
      delete(res@cnFillPalette)
      res@cnFillPalette = cmap2
    else
      delete(res@cnFillPalette)
      res@cnFillPalette = cmap3
    end if
  end if

    plots(i) = gsn_csm_contour_map(wks,xvar(i,:,:),res)                 ; draw map
    dum1(i) = gsn_add_shapefile_polylines(wks,plots(i),dirishp+"eastcoast_upper.shp",True)

    lontx  = (/135.,148.,123., 141.5, 150./)
    lattx   = (/-10., -14., -13., -19., -17./)
  ; draw each line separately. Each line must contain two points.
    do j = 0 , 3
      ; resg@gsLineLabelString= regions(j)                    ; adds a line label string
      ; resg@gsLineLabelFontHeightF = 0.008

      ;************************************************
      ; label the box with additional text
      ;************************************************
      tres       =  True
      tres@txFontHeightF = 0.01

      resg@tfPolyDrawOrder = "PostDraw"  ; this can be used for polylines, polymarkers, or polygons
      lat = (/latSs(j),  latNs(j), latNs(j), latSs(j), latSs(j)/)
      lon = (/lonLs(j), lonLs(j),  lonRs(j), lonRs(j), lonLs(j)/)
      dumtx(n) = gsn_add_text(wks,plots(i),regions(j),lontx(j),lattx(j),tres)
      dum(n)=gsn_add_polyline(wks,plots(i),lon,lat,resg)
      n = n+1
    end do

    dumtx2  = gsn_add_text(wks,plots(i),regions(4),lontx(4),lattx(4),tres)
    ; dum(i)=gsn_add_polyline(wks,plots(i),(/lonLs(0), lonRs(0)/), (/latSs(0),latNs(0)/),gres)
  end do


;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = False                   ; add common colorbar
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPanelFigureStrings= xname ; add strings to panel
  resP@amJust   = "TopLeft"
  resP@lbLabelStride        = 2
  resP@lbTitleString  = "[mm/day]"
  resP@lbTitlePosition = "bottom"
  resP@lbTopMarginF    = 0.4
  resP@lbBottomMarginF = 0.005
  resP@lbTitleFontHeightF = 0.01


  ; resP@gsnPanelMainPosXF  = 0.2

  gsn_panel(wks,plots,(/3,2/),resP)               ; now draw as one plot


  txres               = True
  txres@txFontHeightF = 0.015
  ; gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)

  end