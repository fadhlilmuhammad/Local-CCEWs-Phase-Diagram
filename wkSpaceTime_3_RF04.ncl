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
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"

  ; pwdir = "/Users/fadhlilrizki/Documents/GitHub/Local-CCEWs-Phase-Diagram/data/"
  pwdir   = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
  diro     = "/Users/fadhlilrizki/Documents/PhD/thesis/figures/STSA/"        ; output dir: location of plots

  latN     = 25
  latS     = -latN       ; symmetric about the equator
  case     = "cek"+latN

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
  var      = "olr"  ; user specified

; diri     = "/project/cas/shea/WHEELER/"
  diri     = pwdir    ; new input directory
  fili     = "olr.day.anomalies.1980-2019.nc"



  f        = addfile (diri+fili, "r")

  date = cd_calendar(f->time, -2)
  date_start = ind(date.eq.19810101)
  date_end = ind(date.eq.20181231)

  olr    = short2flt(f->$var$(date_start:date_end,{latS:latN},:) )    ; (time,lat,lon)


  printVarSummary(olr)

  if (any(olr.eq.olr@missing_value)) then
    print("ada missing")
    exit
  else

  delete(olr@missing_value)
  delete(olr@_FillValue)
                     ; calculation and create plots
  wkSpaceTime (olr, diro, case, var             \
              ,latN, spd, nDayWin, nDaySkip, opt  )

  end if
