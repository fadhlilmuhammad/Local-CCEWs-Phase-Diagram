
load "utils.ncl"

diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/olr_filtered/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/olr_filtered/"
seas = "SHAutumn"

waves = (/"er","kelvin","mrg","td"/)

x    = new((/4,12,21/), "float")
ndim = dimsizes(x)

do i = 0, ndim(0)-1
  wave = waves(i)
  print("wave "+wave)
  f    = addfile(diri + "lonclm.var.olr."+wave+".25.nc", "r")

  coords = f->clm_lonvariance
  printVarSummary(coords)
  mean = dim_avg_n_Wrap(f->clm_lonvariance(:,:),0)

  printVarSummary(mean)

  mean_avg = new((/12,21/),"float")
  do t = 0, 11
    ; print("nononon")
    do lat=0,20
        mean_avg(t,lat) = mean(lat)
    end do
  end do

  ; mean_avg = avg(f->clm_latvariance(:,{90:180}))
  x(i,:,:) = f->clm_lonvariance/mean_avg
  copy_VarCoords(coords,x(i,:,:))
  delete(f)
end do

x!0 = "wave"
x&wave = waves
; x&month = (/1,2,3,4,5,6,7,8,10,11,12/)
printVarSummary(x)
printMinMax(x,0)

;==============================================
; create color plot
;=============================================
  wks  = gsn_open_wks ("png", diro+"wave_lonactivity_panel" )           ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@cnFillOn             = True               ; turn on color fill
  res@gsnDraw = False
  res@gsnFrame = False
  res@cnFillPalette        = "CBR_wet"           ; set color map
  res@cnLinesOn            = True
  ; res@gsnContourZeroLineThicknessF = 3.5        ; sets thickness of zero contour to 3.5 (default=1)
  res@gsnMajorLonSpacing   = 2.
  ; res@gsnMajorLatSpacing   = 2.
  res@cnInfoLabelOn      = False

  ; res@tiMainString         = "Pacific Region"   ; title

  ; if wave.ne."td" then
  ; res@gsnLeftString        = str_upper(wave) + " waves"
  ; else
  ; res@gsnLeftString        = str_upper(wave) + "-type waves"
  ; end if

  res@gsnLeftString        = ""

  res@gsnRightString       = "[OLR variance]"


  res@tmYLMode           = "Explicit"         ; Define own tick mark labels.
  ; res@tmYLMinorValues    = major_ticks(0:ndays-1:6)
  res@tmYLValues         = x&month
  res@lbLabelBarOn       = False
  ; res@tmYLLabels         = new(ndays,string)
  res@tmYLLabels         = (/"Jan", "Feb","Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"/)

  plots = new(ndim(0), graphic)

  do i = 0, ndim(0)-1

    wave = waves(i)
    if (wave.eq."er").or.(wave.eq."td") then
    res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels
    res@cnMinLevelValF       = 0.	        ; min level
    res@cnMaxLevelValF       =  3.               ; max level
    res@cnLevelSpacingF      = 0.2                 ; contour level spacing
    else
    res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels
    res@cnMinLevelValF       = 0.	        ; min level
    res@cnMaxLevelValF       =  3.               ; max level
    res@cnLevelSpacingF      = 0.2                 ; contour level spacing
    end if


    if x&wave(i).ne."kelvin" then
    plots(i) = gsn_csm_hov(wks, x(i,:,{-20:-10}), res)
    else
    plots(i) = gsn_csm_hov(wks, x(i,:,{-15:-10}), res)
    end if

    opt = True
    opt@gsnShadeFillType = "color"
    opt@gsnShadeLow      = 3
    opt@gsnShadeHigh     = 17

    ; plots(i) = gsn_contour_shade(plots(i), 0, 1, opt)   ; add shading from <-5 and
    ; set_contour_line_thicknesses(plots(i),1,3.5)

  end do

;;  PANEL

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelLabelBar = True                  ; add common colorbar
  resP@gsnPanelBottom   = 0.05                   ; add space at bottom
  resP@gsnPanelFigureStrings= (/"A) ER waves","B) Kelvin waves","C) MRG waves","D) TD-type waves"/) ; add strings to panel
  resP@amJust   = "TopLeft"
  resP@lbLabelStride        = 2
  ; resP@lbTitleString  = "[mm/day]"
  ; resP@lbTitlePosition = "bottom"
  resP@lbTopMarginF    = 0.4
  resP@lbBottomMarginF = 0.005
  resP@lbTitleFontHeightF = 0.01

  ; resP@gsnPanelMainPosXF  = 0.2

  gsn_panel(wks,plots,(/2,2/),resP)               ; now draw as one plot



  txres               = True
  txres@txFontHeightF = 0.005
  ; gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
