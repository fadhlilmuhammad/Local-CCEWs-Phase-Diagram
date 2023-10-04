
folderin  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/theory/"

fk = addfile(folderin+"KELVIN_structure_tstep.nc", "r")
fm = addfile(folderin+"MRG_structure_tstep.nc", "r")
fe = addfile(folderin+"ER_structure_tstep.nc", "r")
fi = addfile(folderin+"EIG_structure_tstep.nc", "r")
fw = addfile(folderin+"WIG_structure_tstep.nc", "r")

klv  = fk->KELVIN
mrg  = fm->MRG
erw  = fe->ER
eig  = fi->EIG
wig  = fw->WIG

folderout = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/theory/"

; ===========================
; create plot
; ===========================

dtim = 16
do t = 0, dtim-1
 wks   = gsn_open_wks ("eps", folderout+"wave_structure_panel_"+t)        ; send graphics to PNG file
 plot  = new(5,graphic)

 res                 = True                    ; plot mods desired

 cmap = read_colormap_file("cmocean_curl")
 ; cmap(99:149,:) = 0.
 ; res@tiMainString    = wave+" waves"        ; title
 res@cnLevelSpacingF = 2.                      ; contour interval
 res@gsnDraw  = False
 res@gsnFrame = False
 res@cnFillOn        = True                    ; turn on color
 res@cnFillPalette   = cmap           ; choose color map

 res@gsnContourZeroLineThicknessF = 2.	       ; doubles thickness of zero contour
 res@cnLevelSelectionMode = "ManualLevels" ; manual levels
 res@cnMinLevelValF       = -1.
 res@cnMaxLevelValF       =  1.
 res@cnLevelSpacingF      =  0.2

 res@tmXBMode        = "Explicit"
  res@tmXBValues      = (/-3.14,-3.14/2,0,3.14/2,3.14/)
  res@tmXBLabels      = (/"-~F8~p","-~F8~p/2","0","~F8~p/2","~F8~p"/)
  ; res@tmXBMinorValues = ispan(1949,2006,1)
  ; res@gsnLeftString   = "tmXBMode = Explicit"
  res@lbLabelBarOn = False
  ; res@cnLineLabelOn = False
 res@cnLinesOn = False
 res@cnInfoLabelOn = False
 res@cnLineLabelsOn = False

 klv_plot = klv/max(klv)
 copy_VarCoords(klv, klv_plot)
 res@gsnLeftString = "k*= 1, n= -1"
 plot(0) = gsn_csm_contour(wks, klv_plot(tstep|t,y|:,x|:), res)

 res@cnMinLevelValF       = -1.0
 res@cnMaxLevelValF       =  1.0
 res@cnLevelSpacingF      =  0.2

 ; res@tmYLLabelsOn   = False

 mrg_plot = mrg/max(mrg)
 copy_VarCoords(mrg, mrg_plot)
 res@gsnLeftString = "k*=-1, n= 0"
 plot(1) = gsn_csm_contour(wks,mrg_plot(tstep|t,y|:,x|:) , res)

 res@cnMinLevelValF       = -1.
 res@cnMaxLevelValF       =  1.
 res@cnLevelSpacingF      =  0.2

 erw_plot = erw/max(erw)
 copy_VarCoords(erw, erw_plot)
 res@gsnLeftString = "k*= -1, n= 1"
 plot(2) = gsn_csm_contour(wks, erw_plot(tstep|t,y|:,x|:), res)


 eig_plot = eig/max(eig)
 copy_VarCoords(eig, eig_plot)
 res@gsnLeftString = "k*= 1, n= 0"
 plot(3) = gsn_csm_contour(wks, eig_plot(tstep|t,y|:,x|:), res)

 wig_plot = wig/max(wig)
 copy_VarCoords(wig, wig_plot)
 res@gsnLeftString = "k*= -1, n= 2"
 plot(4) = gsn_csm_contour(wks, wig_plot(tstep|t,y|:,x|:), res)
 ;************************************************
 ; create panel
 ;************************************************
 resP = True
 resP@gsnPanelFigureStrings = (/"A) KELVIN", "B) MRG", "C) ER", "D) EIG", "E) WIG"/)
 ; resP@gamOrthogonalPosF = -0.9
 ; resP@gamParallelPosF = -0.9
 resP@amJust  = "TopLeft"
   gsn_panel(wks,plot,(/2,3/),resP)             ; now draw as one plot

end do
