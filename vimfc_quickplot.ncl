
diri ="/Users/fadhlilrizki/Documents/PhD/thesis/dataout/dynamics/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/dynamics/"
fname ="er_er_wetwet_TE_mam"
f = addfile(diri+"vimfc_"+fname+".nc", "r")

x = f->comp

coords = x
x = x*1000.
copy_VarMeta(coords,x)
printVarSummary(x)
printMinMax(x,0)

wks = gsn_open_wks("png",diro+"vimfc_"+fname)              ; send graphics to PNG file
cmap  = read_colormap_file("CBR_drywet")


minlv = -40.
maxlv = 40.
intlv = 2.

  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
  res@cnFillPalette       = cmap
  res@lbLabelBarOn        = True            ; turn off individual cb's
  res@cnLinesOn           = False

  res@tiMainString    = fname

  res@mpFillOn            = False
  res@mpMaxLatF           = -5
  res@mpMinLatF           = -25

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


plot = gsn_csm_contour_map(wks,x, res)
draw(wks)
frame(wks)
