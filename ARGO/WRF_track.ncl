;plot hurricane track (WRF ONLY simulated one and Obs one) with SSS on it. 
;SSS from SODA 
;model inout/output don't have SSS, only has SST 
;see the model input change on sst 
;Max Wind speed from the model output 

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
Dir="./cfsr/"
Dir2="/tiered/user/xiaoxiaoyu/SODA_HU/"

hurricane_name = "200704"
fiTY = hurricane_name+".txt"
month=7
hurricane_month = "Aug"
f = addfile(Dir2+"soda3.3.1_mn_ocean_reg_2007.nc","r")


sst = f->temp(month,0,{-11.7:24.1},{273.5:354}) 
sss = f->salt(month,0,{-11.7:24.1},{273.5:354})  
mlp=f->mlp(month,{-11.7:24.1},{273.5:354})  
mlt=f->mlt(month,{-11.7:24.1},{273.5:354})  
blt=mlt-mlp
copy_VarMeta(mlp, blt)

  lat= f->latitude({-11.7:24.1})
  lon= f->longitude({273.5:354}) 
 
  sst@long_name = " "       ; assign long_name
  sss@long_name = " " 
  blt@long_name = " "
  sss@units=" "
  sst@units=" "
  blt@units=" "
;==================================================================== 
; ndate=dimsizes(date)

fs = systemfunc("ls "+Dir+"wrfout_d01_*")
nfs= dimsizes(fs)
ndate=nfs

a = addfile(fs(2)+".nc","r")
  latT=a->XLAT(0,:,0)                     
  latT@units="degree_north"
  lonT= a->XLONG(0,0,:)
  lonT@units="degree_east"  
  nlat=dimsizes(latT) 
  nlon=dimsizes(lonT)
  
  lat2d = a->XLAT(0,:,:)
  lon2d = a->XLONG(0,:,:)
  lon1d = ndtooned(lon2d)
  lat1d = ndtooned(lat2d)
;********************************************************  
; Sea Level Pressure
  slp = wrf_user_getvar(a,"slp",0)
  slp@lat2d = wrf_user_getvar(a,"XLAT",0)   ; latitude/longitude
  slp@lon2d = wrf_user_getvar(a,"XLONG",0)  ; required for plotting
  dims = dimsizes(slp)
  imin = new(ndate,integer)
  jmin = new(ndate,integer)
  smin = new(ndate,integer)
  timen =new((/ndate/),"string")

  slpm=new((/nfs/),"float")
  slpm0=new((/nfs/),"float")

  imax = new(ndate,integer)
  jmax = new(ndate,integer)
  smax = new(ndate,integer)
  mwind0 = new((/nfs/),"float")
  mwind = new((/nfs/),"float")


  do ifs=0,nfs-1
    f2 = addfile(fs(ifs)+".nc","r")
    timen(ifs)=tostring(f2->Times)

    slp2d = wrf_user_getvar(f2,"slp",0)
    slpm(ifs)=min(slp2d)
    slpm0(ifs)=floattointeger(slpm(ifs))
    slp1d     = ndtooned(slp2d)
    smin(ifs) = minind(slp1d)
    minij     = ind_resolve(ind(slp1d.eq.min(slp2d)),dims)   
    imin(ifs) = minij(0,0)
    jmin(ifs) = minij(0,1)    

    u10 = wrf_user_getvar(f2,"U10",0)
    v10 = wrf_user_getvar(f2,"V10",0)
    wind2d=sqrt(u10^2+v10^2)
    mwind0(ifs)=max(wind2d)
    mwind(ifs)=floattointeger(mwind0(ifs))
    wind1d     = ndtooned(wind2d)
    smax(ifs) = minind(wind1d)
    maxij     = ind_resolve(ind(wind1d.eq.min(wind2d)),dims)   
    imax(ifs) = maxij(0,0)
    jmax(ifs) = maxij(0,1)     
  end do

imin1d=ndtooned(imin)
jmin1d=ndtooned(jmin)
; smin1d=ndtooned(smin)
slpm1d=slpm0
windm1d=mwind

;********************************************************************    store data as a csv file 
; store data as a csv file 
dims3=num(.not.ismissing(slpm1d))
imin1d2=imin1d(ind(.not.ismissing(imin1d)))                            ;;**** how to delete missing values in the array
jmin1d2=jmin1d(ind(.not.ismissing(jmin1d)))
slpm1d2=slpm1d(ind(.not.ismissing(slpm1d)))

windm1d2=windm1d(ind(.not.ismissing(windm1d)))

timen1d2=timen(ind(.not.ismissing(timen)))
; print(imin1d2)
lonmin=new(dims3,float)
latmin=new(dims3,float)
do i=0,dims3-1 
lonmin(i)=lon2d(imin1d2(i),jmin1d2(i))
latmin(i)=lat2d(imin1d2(i),jmin1d2(i))
end do

; print(timen)
; ; imtime0 = conform_dims((/8,8/), time, 0)
; imtime1  = ndtooned(timen)
; imtime = timen(0:dims3-1)

alist = [/timen1d2,lonmin,latmin,slpm1d2,windm1d2/]

  filename = hurricane_name+".csv"
  system("rm -rf " + filename)
  write_table(filename,"w",alist,"%s,%10f,%10f,%13.2f,%13.2f")
;====================================================================  
 wks   = gsn_open_wks ("ps",hurricane_name+"track_WRF_only_cfsr")  
gsn_define_colormap(wks,"MPL_GnBu")

  resC                  = True                      ; plot mods desired
  resC@vpWidthF         = 0.9           ; change aspect ratio of plot
  resC@vpHeightF        = 0.9
  resC@gsnDraw	        = False	  ; do not draw frame since we will be adding a polyline and paneling
  resC@gsnFrame         = False   ; do not advance frame
  resC@cnFillOn         = True                      ; turn on color
  resC@cnLinesOn        = False	; but no contour lines
  resC@cnLineLabelsOn      = False
  resC@gsnAddCyclic   =False 
  resC@gsnSpreadColors   = True                      ; use full range of colors
  resC@mpMinLonF         =273.5
  resC@mpMaxLonF         =354
  resC@mpMinLatF         =-12
  resC@mpMaxLatF         =24
  resC@gsnMaximize	= True	  ; maximize the plot space on page - this will apply to each individual plot
  resC@gsnPaperOrientation = "landscape"
  resC@cnFillDrawOrder  = "Predraw"
  resC@gsnStringFontHeightF =0.02
  

; Set the size of the individual title and axis fonts
     resC@tiXAxisFontHeightF = 0.03
     resC@tiYAxisFontHeightF = 0.03   
     resC@tiXAxisOn = False
     resC@tiYAxisOn = False 
	   resC@tiMainString  = " "
     resC@tiMainFontHeightF = 0.02
     resC@tiMainFontThicknessF = 1.0
        resC@tmXBLabelFontHeightF = 0.02    ; boost the axis value labels even more
        resC@tmYLLabelFontHeightF = 0.02
        resC@tmYRLabelFontHeightF = 0.02
;        resC@tmXBLabelStride=2
;        resC@tmYBLabelStride=2
     resC@lbLabelBarOn = False	; turn off label bars for the individual plots


     resC@tmXBMode = "Explicit"
     resC@tmXBValues=(/270,280,290,300,310,320, 330,340,350/)
     resC@tmXBLabels=(/"90W","80W","70W","60W","50W","40W","30W","20W","10W"/)
     resC@tmXBLabelFontHeightF = 0.02
     resC@tmYLLabelFontHeightF = 0.02
     resC@tmXTOn            = False
     resC@tmYROn            = False
     resC@tmLabelAutoStride = True

     ;resC@cnFillPalette = "BlGrYeOrReVi200"
     ;resC@cnLevelSelectionMode = "ExplicitLevels" 
     resC@cnInfoLabelOn= False
     resC@cnLabelMasking= False
     ;resC@lbTopMarginF = 0.13

  resC@gsnLeftString        = "Salinity: psu"
  resC@tiMainString         = "WRF reso = 10 km from cfsr"
  resC@tiMainPosition       = "Center"

  ;resC@cnLevels = (/33.8, 34.2, 34.6, 35.0, 35.4, 35.8, 36.2/)
  ;resC@cnFillColors = (/ 101, 80, 64, 48, 35, 27, 19, 129/) 
     resC@cnLevelSelectionMode = "ManualLevels"
   resC@cnLevelSpacingF = 0.4
   resC@cnMinLevelValF =33.8
   resC@cnMaxLevelValF =36.2   
  plot2 = gsn_csm_contour_map(wks,sss, resC)


  resC11                  = True 
  resC11@gsnDraw      = False   ; do not draw frame since we will be adding a polyline and paneling
  resC11@gsnFrame     = False 
  resC11@cnFillOn         = False                      ; turn on color
  resC11@cnLinesOn        = True
  resC11@cnLineThicknessF =3.5
  resC11@cnLineColor="black"
  resC11@cnInfoLabelOn= False
  resC11@cnLevelSelectionMode = "ExplicitLevels" 

  resC11@cnLineLabelsOn       = True
  resC11@cnLabelMasking       = True

  resC11@cnLevels = (/35.8/)



  plot21 = gsn_csm_contour(wks,sss,resC11)
  overlay(plot2,plot21)
 
 
; add hurricane track
  fiTY2=Dir2+fiTY
  nrowtc = numAsciiRow(fiTY2)
  latc=new(nrowtc,"float")
  lonc=new(nrowtc,"float")
  vmax=new(nrowtc,"float")
   
  data=asciiread(fiTY2, -1, "string") 
  latc=stringtofloat(str_get_cols(str_get_field(data, 5,","),1,4))
  lonc2=stringtofloat(str_get_cols(str_get_field(data, 6,","),1,6))
  lonc=360.0-lonc2
  vmax=stringtofloat(str_get_field(data, 7,","))


  resLineC = True
  resLineC@gsLineThicknessF = 6
  resLineC@gsLineColor = "black"

  dumLineC = new(nrowtc, graphic)
  dumLineC2 = new(nrowtc, graphic)
  dumLineC3 = new(nrowtc, graphic)


  line= new(ndate, graphic)
  line2= new(ndate, graphic)
  line3= new(ndate, graphic) 
  Dot= new(ndate, graphic)
  Dot2= new(ndate, graphic)
  Dot3= new(ndate, graphic)
  DotC= new(ndate, graphic)
  Dot2C= new(ndate, graphic)
  Dot3C= new(ndate, graphic)


  resDotC = True
  resDotC@gsMarkerIndex  = 16                  ; filled dot  
  resDotC@gsMarkerThicknessF = 4.0
  resDotC@gsMarkerOpacityF = 1.0
  resDotC@gsMarkerSizeF = 0.01
  
  colours = (/"gray","green","yellow","red","maroon","purple"/)

  do i = 0, nrowtc-2
    xxC = (/ lonc(i), lonc(i+1)/)
    yyC = (/ latc(i), latc(i+1)/)
    dumLineC2(i) = gsn_add_polyline(wks, plot2, xxC, yyC, resLineC)
  end do


  do i = 0,ndate-2
     xxT=(/lon2d(imin(i),jmin(i)),lon2d(imin(i+1),jmin(i+1))/)
     yyT=(/lat2d(imin(i),jmin(i)),lat2d(imin(i+1),jmin(i+1))/)
     line2(i) = gsn_add_polyline(wks,plot2,xxT,yyT,resLineC)
  end do


  dumDotC = new(nrowtc, graphic)
  dumDotC2= new(nrowtc, graphic)
  dumDotC3= new(nrowtc, graphic)

  do i = 0, nrowtc-1
    if (vmax(i).le.64) then
      resDotC@gsMarkerColor = colours(0)
    end if
    if (vmax(i) .ge. 64 .and. vmax(i).le.82) then
      resDotC@gsMarkerColor = colours(1)
    end if
    if (vmax(i).ge.82 .and. vmax(i) .le. 95) then
      resDotC@gsMarkerColor = colours(2)
    end if
    if (vmax(i).ge.96 .and. vmax(i) .lt. 112) then
      resDotC@gsMarkerColor = colours(3)
    end if
    if (vmax(i).ge.113 .and. vmax(i) .lt. 136) then
      resDotC@gsMarkerColor = colours(4)
    end if
    if (vmax(i).ge.136) then
      resDotC@gsMarkerColor = colours(5)
    end if
    dumDotC2(i) = gsn_add_polymarker(wks, plot2, lonc(i), latc(i), resDotC)
   end do

dot2 = new(ndate, graphic)
  do i = 0,ndate-2
    resDotC@gsMarkerColor = "black"
    dot2(i)=gsn_add_polymarker(wks,plot2,lon1d(smin(i)),lat1d(smin(i)),resDotC)
  end do

  dumDot2C2= new(nrowtc, graphic)

  delete(resDotC@gsMarkerColor)
  
  resDotC@gsMarkerIndex    = 4          ; Hollow dots
  resDotC@gsMarkerColor    = "black"
  resDotC@gsMarkerThicknessF =4
  do i = 0, nrowtc-1
    dumDot2C2(i) = gsn_add_polymarker(wks, plot2, lonc(i), latc(i), resDotC)
  end do

  dotC = new(ndate, graphic)
  dot2C= new(ndate, graphic)
  dot3C= new(ndate, graphic)
    do i = 0,ndate-2
      dot2C(i)=gsn_add_polymarker(wks,plot2,lon1d(smin(i)),lat1d(smin(i)),resDotC)
  end do

  resTiC = True
  resTiC@txFontHeightF = 0.025
  resTiC@txJust = "BottomLeft"
  resTiC@txFontColor = "black"
  resTiC@txFontThicknessF = 5
  dumtC = gsn_add_text(wks,plot2, hurricane_name, 285, 0, resTiC)





draw(plot2)
frame(wks)
  
end 








