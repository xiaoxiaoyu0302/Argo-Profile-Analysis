; read the lowest mslp, and time  from WRF 10 km and 30 km
; read the same from the observation
; plot the three lines 

; how to draw a simple_legend  ***************
; getvalues plot1: get the value of the exact location of the plot 

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;read the slp from the CRESM results
dir="./"
hurricane_name="200704"
fiTY = dir+hurricane_name+".txt"
dir1="./"

; add hurricane mslp from observation
nrowtc = numAsciiRow(fiTY)
mslp=new(nrowtc,"float")
data=asciiread(fiTY, -1, "string") 
mslp=stringtofloat(str_get_field(data, 8,","))
dims=dimsizes(mslp)

filename = dir1+hurricane_name+".csv"
alist=asciiread(filename,-1,"string")
strs = str_split_csv(alist,",",0)

nums=tofloat(strs)
dims1=dimsizes(nums(:,0))
slp1=nums(:,3)

; ;read the slp from the WRF results
; dir2="./"
; filename2=dir2+hurricane_name+".csv"
; alist2=asciiread(filename2,-1,"string")
; strs2 = str_split_csv(alist2,",",0)
; nums2=tofloat(strs2)
; slp2=nums2(:,3)
; dims2=dimsizes(nums2(:,3))


; print(dims)
; print(dims1)
; print(dims2)

;************** solve if the start date is different *************
;************** make sure the end date is the same !! ************
dimmin=min((/dims,dims1/))

timec=ispan(0,nrowtc-1,1)
 data2      = new((/2,dimmin/),"float") 
 data2(0,:)=mslp(dims-dimmin:dims-1)  ; obs
 data2(1,:)=slp1(dims1-dimmin:dims1-1)  ;10 km  ; cfsr
 ; data2(2,:)=slp2(dims2-dimmin:dims2-1)  ;30 km  ; ecmwf
print(data2)
print(timec)
;******************************************************************

; plot two time series from model output and from observation
 wks   = gsn_open_wks ("ps","mslp_cfsr")  
 res                    = True  
 res@gsnDraw            = False
 res@gsnFrame           = False 
 res@vpHeightF         = 0.6
 res@vpWidthF            = 0.8
 res@xyMonoLineColor    = False 
 res@xyLineColors       = (/"black","Blue","red"/)
 res@xyLineThicknesses   = (/3.0,3.0,3.0/)
 res@xyDashPatterns  = (/0.,0.,0/) 
 res@tmXBTickSpacingF =-0.01
 res@tmXBLabelFontHeightF = 0.015
 res@tmXBLabelFontThicknessF =0.2

 res@tmXTOn            = False
 res@tmXTLabelsOn      = False
  res@tmYROn            = False
 res@tmYRLabelsOn      = False

;  res@trYMaxF            = 1010.
; res@trYMinF            = 910. 
; res@trXMinF              = 0    
; res@trXMaxF              = 85 
; 
; res@tiXAxisOn          = True
res@tiYAxisString        = "MSLP" 
res@tiYAxisFontHeightF   = 0.02 

res@tiXAxisString        = "Date" 
res@tiXAxisFontHeightF    = 0.02


res@tmXBMode = "Explicit"
res@tmXBValues=(/0,7,15,23/)
res@tmXBLabels=(/"08/16 00Z","08/17 00Z","08/18 00Z","08/19 00Z"/)

res@tmXBOn            = True
res@tmXBLabelsOn      = True
res@tiMainFontHeightF =0.025
res@tiMainFontThicknessF=2.0
res@tiMainString  = "Hurricane No."+hurricane_name+" WRF only CFSR"
plot1  = gsn_csm_xy (wks,timec,data2,res) ; create plot
; ---- legend 
  lgres                    = True
  lgres@lgLineColors       = res@xyLineColors
  lgres@lgLineThicknessF   = res@xyLineThicknesses  ; legend line thickness = contour line thickness
  lgres@lgDashIndexes     = res@xyDashPatterns 
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .08            ; set the legend label font thickness
  lgres@vpWidthF           = 0.15           ; width of legend (NDC)
  lgres@vpHeightF          = 0.1            ; height of legend (NDC)
  lgres@lgPerimColor       = "orange"       ; draw the box perimeter in orange
  lgres@lgPerimThicknessF  = 3.0            ; thicken the box perimeter
  lbid = gsn_create_legend(wks,3,(/"OBS","CFSR"/),lgres)         ; create legend

  amres = True
  amres@amParallelPosF   = -0.35         ; move legend to the right
  amres@amOrthogonalPosF = 0.32             ; move the legend down
  annoid1 = gsn_add_annotation(plot1,lbid,amres)   ; add legend to plot

draw(plot1)
   frame(wks)

end


