print("Reading the input file...")

diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/"
diri     = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"

; i = addfile(diri + "u_era5_daily.nc", "r")
; j = addfile(diri + "v_era5_daily.nc", "r")
; f = addfile(diri + "q_era5_daily.nc", "r")


i = addfile(diri + "w_era5_daily.nc", "r")
f = addfile(diri + "q_era5_daily.nc", "r")

TIME2 = f->time
date = cd_calendar(TIME2, -2)
istrt= ind(date.eq.19800101)
ilast= ind(date.eq.20191231)

time = (f->time(istrt:ilast))
level = int2flt(f->level)
latitude = dble2flt(f->lat({-30:30}))
longitude = dble2flt(f->lon)

nt   = time(100)          ; date for plotting and testing

q = short2flt(f->q(time|istrt:ilast, level|:, {lat|-30:30}, lon|:))
w = short2flt(i->w(time|istrt:ilast, level|:, {lat|-30:30}, lon|:))

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
  DP    = conform(w,dp,1)

  printVarSummary(DP)
;---Change [kg/kg] to [g/kg]; not necessary: but common units for q

  q    = q*1000
  q@units = "g/kg"

;---Divergence function [used later] requires S->N grid order

printVarSummary(level)
  w    = w(:,:,:,:)
  ps   = DP

;---Layer thickness: ; Pa=>[kg/(m-s2)], (time,level,lat,lon)
;---Mass weighting:  (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
;---Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

  ; dp   = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness

  dpg  = DP/g
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"      ; dp/g, Pa/(m s-2), reduce to kg m-2

  vadv = w * DP
  vadv_dpg = w * dpg

  long_name = "vertical advection"
  units     = "g/(kg-s)"       ; (m/s)*(g/kg)*(1/m) => (m/s)*(g/kg-m) => g/(kg-s)


  copy_VarCoords(w,vadv)

  ivadv    =  dim_sum_n(vadv_dpg, 1)
  ivadv@long_name = "Integrated Mass Flux Advection"
  ivadv@LONG_NAME = "Sum: Mass Weighted Integrated Mass Flux Advection: mfc_adv*dpg"
  ivadvv@units     = "[m/s][g/kg]"
  copy_VarCoords(w(:,0,:,:), ivadv); (time,lat,lon)
  delete(ivadv_dpg)


  outname = "integrated_wdqdp.nc"
  system("rm "+diro+outname)

  fout = addfile(diro+outname2, "c")
  fout->wdqdp = ivadv

  outname2 = "wdqdp.nc"
  system("rm "+diro+outname2)

  fout2 = addfile(diro+outname2, "c")
  fout2->wdqdp =vadv
