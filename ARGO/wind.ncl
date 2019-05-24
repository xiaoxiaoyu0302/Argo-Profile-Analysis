load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
Dir="./cfsr/"

f2 = addfile(Dir+"wrfout_d01_2007-08-16_18:00:00","r")



    u10 = wrf_user_getvar(f2,"U10",0)
    v10 = wrf_user_getvar(f2,"V10",0)
    wind2d=sqrt(u10^2+v10^2)
    mwind0=min(wind2d)
    mwind=floattointeger(mwind0)
    ; wind1d     = ndtooned(wind2d)
    ; smax = minind(wind1d)
    ; maxij     = ind_resolve(ind(wind1d.eq.min(wind2d)),dims)   
    ; imax = maxij(0,0)
    ; jmax= maxij(0,1)    


printVarSummary(u10)
print(wind2d(0:9,0:9))

end