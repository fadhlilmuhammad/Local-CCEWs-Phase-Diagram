
diri = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"
diro = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/precip/combined/"


lsname = systemfunc("ls "+diri+"combined_er_*.nc")

flsname = lsname
do i = 0, dimsizes(lsname)-1
  flsname(i) = systemfunc("echo "+lsname(i) +" | awk -F'/' ' { print $NF } ' "  )
  ; print(check)
end do

print(flsname)


f = addfiles(lsname, "r")
ListSetType (f, "join")

x_in = f[:]->composite

ndim = dimsizes(x_in)
printVarSummary(x_in)

a     = short2flt(f[0]->alpha)
printVarSummary(a)

x     = where(a.eq.1., x_in, x_in@_FillValue)
copy_VarMeta(x_in, x)
printVarSummary(x)

minlv = -10.
maxlv = 10.
intlv = 1.

do i = 0, ndim(0)-1

  ; systemfunc()

  wks = gsn_open_wks("png",diro+"_combinerain_er_"+flsname(i))              ; send graphics to PNG file

  cmap  = read_colormap_file("precip_diff_12lev")
  ; cmap  = cmap(::-1,:)

  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
  res@cnFillPalette       = cmap
  res@lbLabelBarOn        = True            ; turn off individual cb's
  res@cnLinesOn           = False

  res@mpFillOn            = True
  res@mpMaxLatF           = -10
  res@mpMinLatF           = -20

  res@mpMaxLonF           = 150
  res@mpMinLonF           = 120


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
  res@gsnLeftString        = flsname(i)
  res@gsnRightString        = ""

  ; res@gsnFrame                    = False
  ; res@gsnLeftString = x@ndays(i+1) + " days"
  res@mpLandFillColor             = "transparent"
  res@mpOceanFillColor            = "white"
  res@cnFillOpacityF              = 1.0
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
  plot = gsn_csm_contour_map(wks,x_in(i,:,:),res)

  draw(plot)
  frame(wks)
  ; plotc(plotsort(g)) = gsn_csm_contour(wks, x_in({g+1},:,:),res2)

  ; overlay(plot(plotsort(g)), plotc(plotsort(g)))

end do
