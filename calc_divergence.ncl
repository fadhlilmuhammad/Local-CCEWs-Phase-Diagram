

diri = "/Users/fadhlilrizki/Documents/PhD/thesis/data/"
f = addfile(diri + "u_era5_daily.nc", "r")
g = addfile(diri + "v_era5_daily.nc", "r")
h = addfile(diri + "q_era5_daily.nc", "r")

u = short2flt(f->u)
v = short2flt(g->v)
q = short2flt(h->q)

dv = uv2dv_cfd(u,v,u&lat,u&lon, 3)
qdv = -q*10^8.*dv
copy_VarCoords(u, dv)
copy_VarCoords(dv, qdv)


dv@long_name = "divergence from daily data"
dv@units     = "s^-1"

qdv@long_name = "-q x divergence"
qdv@units    = "g/kg s^-1 x 10^5"


printVarSummary(dv)

setfileoption("nc","Format","NetCDF4")

system("rm "+diri+ "dv_era5_daily.nc")
fout = addfile(diri+"dv_era5_daily.nc", "c")
fout->dv = dv
fout->qconv = qdv
