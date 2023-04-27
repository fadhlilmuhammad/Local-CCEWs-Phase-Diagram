
load "utils.ncl"
waves = "kelvin"
folder = "dataout/"
; fname = "olr."+waves+"."+type+".nc"
fname = "olr."+waves+".nc"

;TRY EOFS with raw data
;OLR variance plot for waves
;OLR seasonal plot
;OLR kelvin 15NS, regress to OLR again. to clean the MRW

ystrt = 19810101
ylast = 20181231

seas  = "SHAutumn"
type = seas;""

neof = 200
f = addfile(folder+fname,"r")

time = f->time
date = cd_calendar(time, -2)

iStrt = ind(date.eq.ystrt)
iLast = ind(date.eq.ylast)

x_in = f->$waves$(iStrt:iLast,{-25:25},:)


ymdhms = cd_calendar(x_in&time, 0)
iseason = choose_season(seas, ymdhms)

x = x_in(iseason,:,:)

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

fout = "eof.olr."+waves+"."+type+".nc"
fout2 = "eof_ts.olr."+waves+"."+type+".nc"


system("rm "+folder+fout)
system("rm "+folder+fout2)

fnc = addfile(folder+fout, "c")
fnc->eof = eof

fnc2 = addfile(folder+fout2, "c")
fnc2->eof_ts = eof_ts
