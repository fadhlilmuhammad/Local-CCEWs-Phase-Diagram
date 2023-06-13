;*************************************************
; mfc_conv_2.ncl
;
; Similar to mfc_conv_1.ncl except a different approach is used.
;
; Rather tha using DIV(U*Q) directly, this script expands this into two separate components.
;
; divcepts illustrated:
;   MFC = Moisture Flux divergence
;
;   MFC_advect = -(u*(dq/dx)+v*(dq/dy) )    ; advection term
;   MFC_conv   = -q*((du/dx)+(dv/dy) )      ; div(div)-vergence
;
;   MFC = MFC_advect + MFC_convection
;
;   - Plot a number of quantities
;*************************************************
;---Calculate the Horizontal Moisture Flux divergence [MFC]
;*************************************************
;---High frequency source data: hourly/3hr/6hr/12hr/daily .... NOT monthly values
;---References:
;---http://www.cgd.ucar.edu/cas/catalog/newbudgets/
;---http://tornado.sfsu.edu/geosciences/classes/e260/AtmosphericRivers/Moisture%20Flux.pdf
;---https://www.spc.noaa.gov/publications/banacos/mfc-sls.pdf
;===================================================================
;   Data Source: ESRL Physical Sciences Division
;        https://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
;   NCEP Reanalysis data provided by the NOAA/OAR/ESRL PSD, Boulder, Colorado, USA,
;   from their Web site at https://www.esrl.noaa.gov/psd/
;===================================================================
print("Reading the input file...")

diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"
diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"

; i = addfile(diri + "u_era5_daily.nc", "r")
; j = addfile(diri + "v_era5_daily.nc", "r")
; f = addfile(diri + "q_era5_daily.nc", "r")


i = addfile(diri + "u_era5_oper_pl_20000101.daily.nc", "r")
j = addfile(diri + "v_era5_oper_pl_20000101.daily.nc", "r")
f = addfile(diri + "q_era5_oper_pl_20000101.daily.nc", "r")

TIME2 = f->time
date = cd_calendar(TIME2, -2)
; istrt= ind(date.eq.19800101)
; ilast= ind(date.eq.20191231)

time = (f->time)
level = int2flt(f->level)
latitude = dble2flt(f->latitude({-30:30}))
longitude = dble2flt(f->longitude)



; nt   = time(100)          ; date for plotting and testing

q = short2flt(f->q(time|:, level|:, {latitude|-30:30}, longitude|:))
u = short2flt(i->u(time|:, level|:, {latitude|-30:30}, longitude|:))
v = short2flt(j->v(time|:, level|:, {latitude|-30:30}, longitude|:))

replace_ieeenan(q,default_fillvalue("float"),0)
replace_ieeenan(u,default_fillvalue("float"),0)
replace_ieeenan(v,default_fillvalue("float"),0)

printVarSummary(q)
printMinMax(q,0)

  ptop = 100              ; 'shum' upper level
  ptop@units = "hPa"
  g    = 9.80665          ; m/s2

  date  = 20080715        ; NH summer

;---Vertical levels

  ptop = ptop*100
  ptop@units = "Pa"
  psfc = 1000.0 * 100.0

  plev = q&level                      ; hPa
  plev = plev*100                     ; [100000,...,30000] Pa [kg/(m-s2)]
  plev@units = "Pa"


  dp 		= dpres_plevel_Wrap(plev, psfc, ptop, 0)
  DP    = conform(u,dp,1)

  printVarSummary(DP)
;---Change [kg/kg] to [g/kg]; not necessary: but common units for q

  q    = q*1000
  q@units = "g/kg"

;---Divergence function [used later] requires S->N grid order

printVarSummary(level)
  u    = u(:,:,:,:)
  v    = v(:,:,:,:)
  q    = q(:,:,:,:)
  ps   = DP

;---Layer thickness: ; Pa=>[kg/(m-s2)], (time,level,lat,lon)
;---Mass weighting:  (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
;---Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

  ; dp   = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness

  dpg  = DP/g
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"      ; dp/g, Pa/(m s-2), reduce to kg m-2

;************************************************
; Calculate the MFC_advection term
;   MFC_advect = -(u*(dq/dx)+v*(dq/dy) )
; Internally, gradients are calculated via spherical harmonics
;*************************************************


  long_name = "MFC_advection"
  units     = "g/(kg-s)"       ; (m/s)*(g/kg)*(1/m) => (m/s)*(g/kg-m) => g/(kg-s)

  cyclic    = True   ; Grid is global
  opt_adv   = 1

  mfc_adv   = advect_variable_cfd(u,v,-q, latitude, longitude, cyclic, long_name, units, opt_adv)
  ; mfc_adv   = mfc_adv
  ;
  ; do i = 0, 2
  ;   mfc_adv[i]   = -mfc_adv[i]
  ; end do


  printVarSummary(mfc_adv)
  printMinMax(mfc_adv, 0)
  print("--------")

;************************************************
; Calculate the MFC_convergence term
;   MFC_conv   = -q*((du/dx)+(dv/dy) )      ; div(div)-vergence
;*************************************************

  duv  =uv2dv_cfd(u, v, latitude, longitude, 2)        ; (1/m)(m/s) => (1/s) ; (time,level,lat,lon)

  printVarSummary(duv)
  mfc_conv   = -q*duv
  mfc_conv@long_name = "MFC_convergence"
  mfc_conv@units     = "g/(kg-s)"  ; (g/kg)(1/s) => g/(kg-s)
  copy_VarCoords(duv,mfc_conv)
  delete(duv)

;************************************************
; Calculate the total MFC
;*************************************************

  mfc = mfc_adv[0] + mfc_conv
  mfc@long_name = "Moisture Flux convergence"
  mfc@units     = "g/(kg-s)"  ; (g/kg)(1/s) => g/(kg-s)


PRINT_RAW = True
if (PRINT_RAW) then
  printVarSummary(mfc_adv)                          ; (time,level,lat,lon)
  printMinMax(mfc_adv,0)
  printVarSummary(mfc_conv)
  printMinMax(mfc_conv,0)
  print("-----")
  printVarSummary(mfc)
  printMinMax(mfc,0)
  print("-----")

  printVarSummary(ps)                         ; (time,lat,lon); Pa => kg/(m-s2)
  printMinMax(ps,0)
  print("-----")
  printVarSummary(dp)                         ; (time,level,lat,lon); Pa => kg/(m-s2)
  printMinMax(dp,0)
  print("-----")
                                ; examine layer thickness at selected locations
  print(dp(nt,:,{40},{180}))    ; mid-Pacific
  print(dp(nt,:,{40},{255}))    ; Boulder, CO
  print("-----")
end if

;---Integrated mass weighted moisture flux components

printVarSummary(mfc_adv[0])
printVarSummary(mfc_adv[1])
printVarSummary(mfc_adv[2])

  mfc_adv_dpg = mfc_adv[0]*dpg                ; mass weighted 'uq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
  imfc_adv    =  dim_sum_n(mfc_adv_dpg, 1)
  imfc_adv@long_name = "Integrated Mass Flux Advection"
  imfc_adv@LONG_NAME = "Sum: Mass Weighted Integrated Mass Flux Advection: mfc_adv*dpg"
  imfc_adv@units     = "[m/s][g/kg]"
  copy_VarCoords(u(:,0,:,:), imfc_adv); (time,lat,lon)
  delete(mfc_adv_dpg)

  mfc_advx_dpg = mfc_adv[1]*dpg                ; mass weighted 'uq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
  imfc_advx    =  dim_sum_n(mfc_advx_dpg, 1)
  imfc_advx@long_name = "Integrated Mass Flux Advection X"
  imfc_advx@LONG_NAME = "Sum: Mass Weighted Integrated Mass Flux Advection: mfc_adv*dpg"
  imfc_advx@units     = "[m/s][g/kg]"
  copy_VarCoords(u(:,0,:,:), imfc_advx); (time,lat,lon)
  delete(mfc_advx_dpg)

  mfc_advy_dpg = mfc_adv[2]*dpg                ; mass weighted 'uq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
  imfc_advy    =  dim_sum_n(mfc_advy_dpg, 1)
  imfc_advy@long_name = "Integrated Mass Flux Advection"
  imfc_advy@LONG_NAME = "Sum: Mass Weighted Integrated Mass Flux Advection: mfc_adv*dpg"
  imfc_advy@units     = "[m/s][g/kg]"
  copy_VarCoords(u(:,0,:,:), imfc_advy); (time,lat,lon)
  delete(mfc_advy_dpg)


  mfc_conv_dpg = mfc_conv*dpg                ; mass weighted 'mfc_conv'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
  imfc_conv    = dim_sum_n(mfc_conv_dpg, 1)
  imfc_conv@long_name = "Integrated  Mass Flux divergence"
  imfc_conv@LONG_NAME = "Sum: Mass Weighted Integrated Mass Flux divergence [mfc_conv*dpg]"
  imfc_conv@units     = "[m/s][g/kg]"
  copy_VarCoords(v(:,0,:,:), imfc_conv); (time,lat,lon)
  delete(mfc_conv_dpg)

  VIMFC =  imfc_adv +  imfc_conv
  VIMFC@long_name = "VIMFC"
  VIMFC@LONG_NAME = "VIMFC: [imfc_adv+imfc_conv]"
  VIMFC@units = "[m/s][g/kg]"
  copy_VarCoords(q(:,0,:,:),VIMFC)            ; (time,lat,lon)


outname_vimfc = "trybudget.nc"
system("rm "+diro+outname_vimfc)

fout = addfile(diro+outname_vimfc, "c")
fout->vimfc = VIMFC
fout->imfc_adv = imfc_adv
fout->imfc_advy = imfc_advy
fout->imfc_advx = imfc_advx
fout->imfc_conv = imfc_conv

; print("Calculating climatology and anomaly...")

; TIME = cd_calendar(time, -5)
; year = TIME(:, 0)
; month = TIME(:, 1)
; day = TIME(:, 2)
; ddd = day_of_year(year, month, day)
; yyyyddd = year * 1000 + ddd
;
; vimfc_climatology = clmDayTLL(VIMFC, yyyyddd)
; vimfc_smooth = smthClmDayTLL(vimfc_climatology, 3)
; vimfc_anomaly = calcDayAnomTLL(VIMFC, yyyyddd, vimfc_climatology)
;
; imfc_adv_climatology = clmDayTLL(imfc_adv, yyyyddd)
; imfc_adv_smooth = smthClmDayTLL(imfc_adv_climatology, 3)
; imfc_adv_anomaly = calcDayAnomTLL(imfc_adv, yyyyddd, imfc_adv_climatology)
;
; imfc_advx_climatology = clmDayTLL(imfc_advx, yyyyddd)
; imfc_advx_smooth = smthClmDayTLL(imfc_advx_climatology, 3)
; imfc_advx_anomaly = calcDayAnomTLL(imfc_advx, yyyyddd, imfc_advx_climatology)
;
; imfc_advy_climatology = clmDayTLL(imfc_advy, yyyyddd)
; imfc_advy_smooth = smthClmDayTLL(imfc_advy_climatology, 3)
; imfc_advy_anomaly = calcDayAnomTLL(imfc_advy, yyyyddd, imfc_advy_climatology)
;
; imfc_conv_climatology = clmDayTLL(imfc_conv, yyyyddd)
; imfc_conv_smooth = smthClmDayTLL(imfc_conv_climatology, 3)
; imfc_conv_anomaly = calcDayAnomTLL(imfc_conv, yyyyddd,  imfc_conv_climatology)
;
;
; outname_vimfc = "VIMFC_ANOM_1980-2019.nc"
; system("rm "+diro+outname_vimfc)
;
; fout = addfile(diro+outname_vimfc, "c")
; fout->vimfc_anom = vimfc_anomaly
; fout->imfc_adv_anom = imfc_adv_anomaly
; fout->imfc_advy_anom = imfc_advy_anomaly
; fout->imfc_advx_anom = imfc_advx_anomaly
; fout->imfc_conv_anom = imfc_conv_anomaly
;
;
; PRINT_RESULT = True
; if (PRINT_RESULT) then
;     printVarSummary(imfc_adv)                 ; (time,lat,lon)
;     printMinMax(imfc_adv,0)
;     print("-----")
;     printVarSummary(imfc_conv)                 ; (time,lat,lon)
;     printMinMax(imfc_conv,0)
;     print("-----")
;     printVarSummary(VIMFC)               ; (time,lat,lon)
;     printMinMax(VIMFC,0)
;     print("-----")
; end if

; ;*************************************************
; ; plot results
; ;*************************************************
;
;   scl5  = 1e5                                  ; arbitrary: used for nicer plot values
;   sclab5= "(10~S~-5~N~)"                       ; used later
;   SCLAB5= "(10~S~5~N~)"
;
;   scl6  = 1e6
;   sclab6= "(10~S~-6~N~)"
;   SCLAB6= "(10~S~6~N~)"
;
;   plot := new(2,graphic)
;
;   wks   = gsn_open_wks("png","mfc_conv_2")        ; send graphics to PNG file
;
; ;--- mfc_adv and mfc_conv at a specified pressure level
;
;   res                   = True             ; plot mods desired
;   res@gsnDraw           = False            ; don't draw yet
;   res@gsnFrame          = False            ; don't advance frame yet
;
;   res@cnFillOn          = True             ; turn on color
;   res@cnLinesOn         = False            ; turn off divtour lines
;   res@cnLineLabelsOn    = False            ; turn off divtour lines
;   res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
;   res@mpFillOn          = False            ; turn off map fill
;   res@lbLabelBarOn      = False            ; turn off individual cb's
;                                            ; Use a common scale
;   res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb divsistent
;   res@cnMaxLevelValF       =   12.0        ; max level
;   res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
;   res@cnLevelSpacingF      =    0.5        ; divtour interval
;
;   LEVP    = 850
;   res@gsnCenterString      = LEVP+"hPa"
;
;   MFC_ADV = mfc_adv(100,{850},:,:)         ; keep meta data
;   MFC_ADV = MFC_ADV*scl5
;   res@gsnRightString  = sclab5+" "+mfc_adv@units
;   plot(0) = gsn_csm_convtour_map(wks,MFC_ADV,res)
;
;   MFC_conv = mfc_conv(100,{LEVP},:,:)
;   MFC_conv = MFC_conv*scl5
;   res@gsnRightString  = sclab5+" "+mfc_conv@units
;   plot(1) = gsn_csm_convtour_map(wks,MFC_conv,res)
;
;   resP                     = True                ; modify the panel plot
;   resP@gsnPanelMainString  = date+": Unweighted MFC_ADV, MFC_conv"
;   resP@gsnPanelLabelBar    = True                ; add common colorbar
;   gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
;
; ;--- Integrated Moisture Transport [iuq, ivq]
;
;   delete([/res@gsnRightString, res@gsnCenterString/]) ; not used for this plot
;
;   res@cnMaxLevelValF       =  0.50                   ; min level
;   res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
;   res@cnLevelSpacingF      =  0.05                   ; divtour interval
;
;   IMFC_ADV = imfc_adv(nt,:,:)                    ; local array: keep meta data
;   plot(0)  = gsn_csm_convtour_map(wks,IMFC_ADV,res)
;
;   IMFC_conv = imfc_conv(nt,:,:)                    ; local array: keep meta data
;   plot(1) = gsn_csm_convtour_map(wks,IMFC_conv,res)
;
;   resP@gsnPanelMainString  = date+": Integrated Moisture Flux: Advect, divergence"
;   gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
;
;   delete( [/IMFC_ADV, IMFC_conv/] )                   ; no longer needed
;
;   res@lbLabelBarOn      = True
;   res@gsnDraw = True
;   res@gsnFrame= True
;
; ;---Integrated Divergence of Moisture Flux divergence [no scaling]
;
;  ;res@cnFillPalette        = "cmp_flux"
;   res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb divsistent
;   res@cnMaxLevelValF       =  0.50                ; min level
;   res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
;   res@cnLevelSpacingF      =  0.050               ; divtour interval
;   res@tiMainString         = date+": VIMFC: [IMFC_ADV+IMFC_conv]"
;
;   plt = gsn_csm_convtour_map(wks,VIMFC(nt,:,:) ,res)
