load "utils.ncl"
; waves = "kelvin"
folder = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
type = "anom"
; fname = "olr."+waves+"."+type+".nc"
; fname = "olr."+waves+".1979-2021.nc"
fname = "olr.day.anomalies.1980-2019.nc"

seas  = "SHSummer"


;TRY EOFS with raw data
;OLR variance plot for waves
;OLR seasonal plot
;OLR kelvin 15NS, regress to OLR again. to clean the MRW

ystrt = 19810101
ylast = 20181231

neof = 20
f = addfile(folder+fname,"r")

time = f->time
date = cd_calendar(time, -2)

iStrt = ind(date.eq.ystrt)
iLast = ind(date.eq.ylast)

x_in = f->olr_anom_sm(iStrt:iLast,{-20:20},:)

ymdhms = cd_calendar(x_in&time, 0)
iseason = choose_season(seas, ymdhms)

x     = x_in(iseason, :, :)
printVarSummary(x)




eof    = eofunc_n_Wrap(x, neof, False,0)
eof_ts = eofunc_ts_n_Wrap(x,eof,False,0)

printVarSummary(eof)
printVarSummary(eof_ts)


; fout = "eof.olr."+waves+".nc"
; fout2 = "eof_ts.olr."+waves+".nc"

do i = 0, neof-1
  print("eof-"+(i+1)+": "+sum(eof@pcvar(0:i))+"%"); write loop content
end do

fout = "eof.olr."+type+"."+seas+".nc"
fout2 = "eof_ts.olr."+type+"."+seas+".nc"


system("rm "+folder+fout)
system("rm "+folder+fout2)

fnc = addfile(folder+fout, "c")
fnc->eof = eof

fnc2 = addfile(folder+fout2, "c")
fnc2->eof_ts = eof_ts
