;*************************************************
; panel_3.ncl
;
; Concepts illustrated:
;   - Paneling three plots vertically on a page
;   - Adding a common title to paneled plots
;   - Adding a common labelbar to paneled plots
;   - Subsetting a color map
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

;************************************************
; read in netCDF file
;************************************************
  diri  = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"
  diro  = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/misc/"

  fname = "trybudget.regrid2.nc"
  gname = "mvimd_era5_trybudget.nc"
  hname = "trybudget_vimfc_makeown2.5.nc"
  iname = "trybudget_spectral.regrid.nc"

  f = addfile(diri+fname,"r")
  g = addfile(diri+gname, "r")
  h = addfile(diri+hname, "r")
  i = addfile(diri+iname, "r")

  u_in = f->vimfc(0,:,:)                                ; read July zonal winds
  v_in = g->mvimd(0,:,:)
  x_in = h->vimfc(0,:,:)
  y_in = short2flt(i->vimfc(0,:,:))

  u    = u_in*86400/1000.
  v    = v_in*-86400.
  x    = x_in*86400/1000.
  y    = y_in*86400./1000.

  copy_VarMeta(x_in,x)
  copy_VarMeta(u_in,u)
  copy_VarMeta(v_in,v)
  copy_VarMeta(y_in,y)

  u@long_name = "Homemade VIMFC regridded AFTER calculating"
  v@long_name = "VIMFC from era5 (Off the shelf)"
  x@long_name = "Homemade VIMFC regridded BEFORE calculating"
  y@long_name = "Homemade VIMFC w/ spectral differencing regridded AFTER calculating"

  u@units     = "mm/day"
  v@units     = "mm/day"
  x@units     = "mm/day"
  y@units     = "mm/day"


;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png",diro+"panel")              ; send graphics to PNG file

  cmap = read_colormap_file("NCV_blu_red")

  plot = new(4,graphic)                          ; create a plot array

  res                     = True
  res@gsnDraw             = False           ; don't draw

  res@mpFillOn            = False
  res@mpMaxLatF           = -5
  res@mpMinLatF           = -25

  res@mpMaxLonF           = 170
  res@mpMinLonF           = 90

  res@cnLinesOn           = False

  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn       = False           ; turn off cn info label
  res@cnFillOn            = True            ; turn on color
  res@cnFillPalette       = cmap
  res@lbLabelBarOn        = False           ; turn off individual cb's

; to have a common label bar, both plots should be set to the same interval
; b/c the label bar is drawn by default from the interval of the first plot.
  res@cnLevelSelectionMode =  "ManualLevels"
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  10.
  res@cnLevelSpacingF      =   1.


  plot(0) = gsn_csm_contour_map(wks,u,res)
  plot(1) = gsn_csm_contour_map(wks,v,res)
  plot(2) = gsn_csm_contour_map(wks,x,res)
  plot(3) = gsn_csm_contour_map(wks,y,res)
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
  resP@gsnPanelMainString = "VIMFC comparison"

  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.007               ; make labels smaller

  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
