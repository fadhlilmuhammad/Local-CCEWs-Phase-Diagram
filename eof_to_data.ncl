
seas = "SHAutumn"
waves = "kelvin"
folder = "dataout/"

; fname  = "eof.olr."+waves+".nc"
; fname2 = "eof_ts.olr."+waves+".nc"


fname  = "eof.olr."+waves+"."+seas+".nc"
fname2 = "eof_ts.olr."+waves+"."+seas+".nc"

; fname  = "eof.olr."+waves+".20NS.nc"
; fname2 = "eof_ts.olr."+waves+".20NS.nc"


f  = addfile(folder+fname, "r")
f2 = addfile(folder+fname2, "r")

eof    = f->eof
eof_ts = f2->eof_ts

neval = 2                      ; number of EOFs

do n=0,neval-1
   eof_ts(n,:) = eof_ts(n,:) + eof_ts@ts_mean(n)  ; add time series mean
end do
              ;
x2    = eof2data_n(eof(0:neval-1,:,:),eof_ts(0:neval-1,:),0)

x2!0 = "time"
x2!1 = "lat"
x2!2 = "lon"

x2&time = eof_ts&time
x2&lat  = eof&lat
x2&lon  = eof&lon

x2@eof = "reconstructed until EOF-"+neval
; fout = "recon_olr."+waves+".nc"
; system("rm "+folder+fout)


fout = "recon_olr."+waves+"."+seas+".nc"
system("rm "+folder+fout)

fnc = addfile(folder+fout, "c")
fnc->$waves$ = x2
