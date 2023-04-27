;Detecting midlatitude rossby waves

folder = "data/"
fname  = "olr.day.anomalies.1979-2021.nc"

f      = addfile(folder+fname, "r")

ystrt = 19790101
ylast = 20211231

neof = 200


time = f->time
date = cd_calendar(time, -2)

iStrt = ind(date.eq.ystrt)
iLast = ind(date.eq.ylast)

x = f->OLR_anom_sm(iStrt:iLast,{-50:-15},:)

printVarSummary(x)

eof    = eofunc_n_Wrap(x, neof, False,0)
eof_ts = eofunc_ts_n_Wrap(x,eof,False,0)

printVarSummary(eof)
printVarSummary(eof_ts)


; fout = "eof.olr."+waves+".nc"
; fout2 = "eof_ts.olr."+waves+".nc"


fout = "eof.olr.midlatitude.rossby.nc"
fout2 = "eof_ts.olr.midlatitude.rossby.nc"

folderout = "dataout/"

system("rm "+folderout+fout)
system("rm "+folderout+fout2)

fnc = addfile(folderout+fout, "c")
fnc->eof = eof

fnc2 = addfile(folderout+fout2, "c")
fnc2->eof_ts = eof_ts
