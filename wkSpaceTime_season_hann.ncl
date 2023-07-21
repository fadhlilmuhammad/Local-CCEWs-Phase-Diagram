;---------------------------------------------
; wkSpaceTime_3.ncl
;---------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually

;try seeing it with more equtor lat
;apply project dx2

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "wkSpaceTime_mod.ncl"
load "diag_local_wave_phase.ncl"

  seas = "SHSummer"
  pwdir   = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
  diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/STSA/"        ; output dir: location of plots

  latN     = 15
  latS     = -latN       ; symmetric about the equator

  nDayWin  = 96      ; Wheeler-Kiladis [WK] temporal window length (days)
  nDaySkip = -65     ; time (days) between temporal windows [segments]
                     ; negative means there will be overlapping
                     ; temporal segments

  opt      = True
  opt@debug= True
  opt@pltType     = "png"   ; send graphics to PNG file
  opt@cnLinesOn   = False   ; turn off contour lines
                     ; specify the plot intervals
  ; opt@Fig_2 =
  ; opt@Fig_3a      = fspan( 1,2,15)
  ; opt@Fig_3b      = (/1.0,1.5,2,3,4,5,6,7,8,9,10,11,13,15,17/)  ; unequal

  spd      = 1       ; samples per day (6 hour sampling rate)
  var      = "olr_anom_sm"  ; user specified
  ; var      = "kelvin"

; diri     = "/project/cas/shea/WHEELER/"
  diri     = pwdir    ; new input directory
  fili     = diri+"olr.day.anomalies.1980-2019.nc"
  ; fili     =  "dataout/olr.kelvin.nc"
  case     = "OLR-"+seas+" "+latN+"N-"+latN+"S"+"_"+var



  ; f        = addfile (diri+fili, "r")
  f = addfile(fili,"r")

  date = cd_calendar(f->time, -2)


  ; date_start = ind(date.eq.19790101)
  ; date_end = ind(date.eq.20211231)
  date_start = ind(date.eq.19810101)
  date_end = ind(date.eq.20181231)
  ymdhms= cd_calendar(f->time(date_start:date_end), 0)

  mm      = floattoint( ymdhms(:,1) )        ; just months

  if seas.eq."SHWinter" then
    iseason = ind( mm.ge.6 .and. mm.le.8)
  else if seas.eq."SHSpring" then
    iseason = ind( mm.ge.9 .and. mm.le.11)
  else if seas.eq."SHSummer" then
    iseason = ind( mm.eq.12 .or.mm.le.2)
  else if seas.eq."SHAutumn" then
    iseason = ind( mm.ge.3 .and. mm.le.5)
  else if seas.eq."NDJFMA" then
    iseason = ind(mm.ge.11 .or. mm.le.4)
  else if seas.eq."MJJASO" then
    iseason = ind(mm.ge.5 .and. mm.le.10)
  else if seas.eq."All Dates" then
    iseason = ind(mm.ge.1)
  end if
  end if
  end if
  end if
  end if
  end if
  end if


  olr_inn    = short2flt(f->$var$(date_start:date_end,{latS:latN},:) )    ; (time,lat,lon)

  lon = olr_inn&lon
  w         = hann_lon(lon, 133, 180)
  olr_in    = olr_inn*conform_dims(dimsizes(olr_inn), w, 2)

  copy_VarMeta(olr_inn, olr_in)
  printVarSummary(olr_in)
  olr_in@missing_value = default_fillvalue("float")
  ; print(iseason)
  olr_seas  = olr_in(iseason,:,:)
  ; olr_ANOM  = olr_seas - conform_dims(dimsizes(olr_seas),dim_avg_n(olr_seas, 0), (/1,2/)) ;get seasonal anomalies
  ;
  olr       = olr_seas
  ; copy_VarMeta(olr_seas,olr)

  ; system("rm "+"olr_filtered_hann.nc")
  ; fout = addfile("olr_filtered_hann.nc","c")
  ; fout->olr = olr

  ; printVarSummary(olr_ANOM)

  if (any(olr.eq.olr@missing_value)) then
    print("ada missing")
    exit
  else

  delete(olr@missing_value)
  delete(olr@_FillValue)
                     ; calculation and create plots
  spec = SpaceTime_Background(olr,   diro, case, var             \
              ,latN, spd, nDayWin, nDaySkip, opt  )

  printVarSummary(spec)

  opt@Fig_3a = (/1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8 /)
  opt@Fig_3b = (/1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8/)
  opt@Fig_3c = (/2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8,2.9,3.0/)

  opt@pltColorMap = "WhBlGrYeRe"
  opt@pltTitle   = "OLR: "+seas+" "+latN+"N-"+latN+"S"
  opt@netCDF = True
  opt@dirNetCDF = "/Users/fadhlilrizki/Documents/PhD/thesis/dataout/STSA/"
  opt@filNetCDF = "SpaceTime."+seas+"."+latN+"_hann.nc"

  ; wkSpaceTime_Seas (olr, spec,  diro, case, var             \
  ;             ,latN, spd, nDayWin, nDaySkip, opt  )
  wkSpaceTime_hann (olr,  diro, case, var             \
              ,latN, spd, nDayWin, nDaySkip, opt  )

  end if
