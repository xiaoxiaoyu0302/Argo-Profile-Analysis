; plot the initial hurricane wind condition from wrfinput_d01

;   - Overlaying vectors and filled contours on a map
;   - Manually attaching lat/lon coordinate arrays to a variable
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Moving the vector reference annotation to the top right of the plot
;   - Drawing curly vectors
;   - Setting the color for vectors
;   - Making the labelbar be vertical
;   - Increasing the thickness of vectors
;----------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin


  a = addfile("wrfinput_d01","r")

  lat=a->XLAT(0,:,0)
  lon=a->XLONG(0,0,:)

  P0=a->P(0,0,:,:)
  Pb = a->PB(0,0,:,:)                    ; base state pressure

  P  = P0
  u=a->U10(0,:,:)
  v=a->V10(0,:,:)

printVarSummary(P)
  P!0="lat"
  P!1="lon"
  P&lat=lat
  P&lon=lon

  copy_VarCoords(P, u)
  copy_VarCoords(P, v)


;---Create plot
  wks = gsn_open_wks("ps","vector")            ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200")

  res                      = True               ; plot mods desired
  res@gsnAddCyclic        = False 
  res@gsnScalarContour     = True               ; contours desired
  res@mpLandFillColor      = "gray"            ; set land to be gray
  res@mpMinLonF            =  min(lon)              ; select a subregion
  res@mpMaxLonF            =  max(lon)
  res@mpMinLatF            =   min(lat)
  res@mpMaxLatF            =  max(lat)

  res@lbOrientation            = "Vertical"     ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
  
  ; res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  ; res@cnMinLevelValF       = 24.0               ; set min contour level
  ; res@cnMaxLevelValF       = 29                 ; set max contour level
  ; res@cnLevelSpacingF      = 0.10               ; set contour spacing

  res@vcRefMagnitudeF           = 15.0             ; define vector ref mag
  res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
  res@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color
  res@vcRefAnnoArrowUseVecColor = True          ; don't use vec color for ref

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curly vectors
  res@vcLineArrowColor        = "black"          ; change vector color
  res@vcLineArrowThicknessF   = 2.0               ; change vector thickness
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last
  res@gsnDraw          = False                    ; turn off draw and frame
  res@gsnFrame         = False                    ; b/c this is an overlay plot
    ; res@gsnLeftString   = "hydrostatic pressure"
  ; res@gsnRightString  = "hPa"
 res@gsnCenterString = "WRF input file"
  plot=gsn_csm_vector_map(wks,u(::5,::5),v(::5,::5),res)

  delete(res)
  res                 = True
  res@gsnDraw         = False
  res@gsnFrame        = False
  res@cnFillOn             = True 
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False  

  res@cnFillPalette        = cmap(17:,:)        ; subset the color map

 

  res@pmLabelBarOrthogonalPosF = .10 
  res@lbLabelFontHeightF         = 0.008
  ; res@vpHeightF                 = 0.03
  res@pmLabelBarHeightF    = 0.13 
  cplot = gsn_csm_contour(wks,P,res)
  overlay(plot,cplot)
  draw(plot)
  frame(wks)

end




