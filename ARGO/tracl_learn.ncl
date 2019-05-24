;************************************
; unique_8.ncl
;
; Concepts illustrated:
;   - Drawing polymarkers and polylines on a map plot
;   - Plotting locations of Hurricane Katrina
;   - Reading data from an ASCII file
;   - Masking the land in a map plot
;************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin  
;
; Open up wrfinput_d01, which is a netCDF file.  Be sure to include
; ".nc" so it knows it's a netCDF file.
;
  a = addfile("wrfinput_d01.nc","r")

;
; Read in track values.
;
  data = asciiread("ACTUAL_data.dat",(/13,3/),"float")
  track_lat = data(:,0)
  track_lon = data(:,1)
  cat_vals  = data(:,2)

;
; Read variable SST on the file to a local variable "sst".
;
  sst = a->SST

;
; Mask values over land.
;
  sst = mask(sst,sst.eq.0,False)
  sst = sst - 273.15     ; Convert to celsius
  sst@units = "C"

;
; Read in the 2D lat/lon arrays associated with sst, and attach
; them to sst. When you pass this data structure to the plotting
; routine, then, the lat2d/lon2d coordinates will be used to help
; plot the data in the correct location on the map.
;
  lat2d = a->XLAT(0,:,:)
  lon2d = a->XLONG(0,:,:)
  sst@lat2d = lat2d
  sst@lon2d = lon2d  

  nlat = dimsizes(lat2d(:,0))
  nlon = dimsizes(lat2d(0,:))

;
; Start the graphics part of the code.
;
  wks = gsn_open_wks("png","unique")      ; send graphics to PNG file
  cmap = read_colormap_file("rainbow")    ; choose colormap

  res                       = True
  res@pmTickMarkDisplayMode = "Always"    ; use NCL default lat/lon labels

  res@gsnMaximize           = True        ; Maximize plot in frame
  res@gsnAddCyclic          = False       ; data already has cyclic point

  res@cnFillOn              = True
  res@cnFillPalette         = cmap(30:,:) ; set color map
;
; Select our own contour levels.
;
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 24
  res@cnMaxLevelValF       = 32
  res@cnLevelSpacingF      = 0.125

  res@cnLinesOn            = False     ; Turn off contour lines
  res@lbBoxLinesOn         = False     ; Turn off labelbar box lines 

  res@lbOrientation        = "Vertical"
  res@lbTitleString        = "Sea Surface Temperature (deg C)" ; bar title
  res@lbTitlePosition      = "Right"                           ; title location
  res@lbTitleDirection     = "Across"                          ; letter angle
  res@lbTitleAngleF        = 90.                               ; title angle
  res@lbTitleFontHeightF   = 0.02                              ; font height

;
; Zoom in on map area that we are interested in.
;
  res@mpLimitMode           = "Corners"
  res@mpLeftCornerLatF      = 17                 ; lat2d(0,0)
  res@mpLeftCornerLonF      = -98                ; lon2d(0,0)
  res@mpRightCornerLatF     =  32                ; lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF     = -75                ; lon2d(nlat-1,nlon-1)

;
; Select a map outline resolution, which can be "LowRes", "MediumRes", or
; "HighRes". To use "HighRes", you must download a separate map
; database. For more information, see:
;
;  http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;
  res@mpDataBaseVersion =  "LowRes"

  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"

  res@gsnFrame       = False
  res@tiMainString   = "Actual Track of Hurricane Katrina (2005)" ; title
  res@tiMainOffsetYF = -0.03
  res@gsnLeftString  = ""                      ; left title, remove default
  res@gsnRightString  = "NHC track data"       ; right title, remove default: C

  plot = gsn_csm_contour_map(wks,sst(0,:,:),res)

;
; Set up labels and colors for each storm category.
;
  categories = (/    0,       1,     2,        3,        4,     5 /)
  labels     = (/ "TS", "Cat. 1", "Cat. 2", "Cat. 3", "Cat. 4", "Cat. 5"/)
  colors     = (/"purple", "blue", "green", "yellow", "orange", "red"/)
    x        = (/  -98,     -98,   -95,      -95,      -98 /)
    y        = (/   24,      18,    18,       24,       24 /)
  sizes      = fspan(0.007,0.012,6)     

;
; Draw a white filled box. This will be for the legend.
;
  mkres                  = True
  mkres@gsFillColor      = "Background"
  mkres@gsLineThicknessF = 2.0                       ; thickness of line
  gsn_polygon(wks,plot,x,y,mkres)
  gsn_polyline(wks,plot,track_lon,track_lat,mkres)

  filled_circle = NhlNewMarker(wks,"Z",37,0.,0.,1.,1.,0.)
  hollow_circle = NhlNewMarker(wks,"R",37,0.,0.,1.,1.,0.)

;
; Set up resources for labels and markers for each storm track.
;
  txres = True
  txres@txFontHeightF = 0.015
  mkres@gsEdgesOn     = True
  mkres@gsEdgeColor   = "black"
  
;
; Loop through the categories, and then grab all the track data that
; falls into that category and draw the appropriate size and color marker
; for that storm track location.
;
  start_lat = 23.5
  start_lon = -97.5
  do i=0,dimsizes(categories)-1
    indices = ind(cat_vals.eq.categories(i))
    if(.not.any(ismissing(indices))) then

       mkres@gsMarkerSizeF = sizes(i)
       mkres@gsMarkerColor = colors(i)
       mkres@gsMarkerIndex = filled_circle
       gsn_polymarker(wks,plot,track_lon(indices),track_lat(indices),mkres)
       gsn_polymarker(wks,plot,start_lon,start_lat,mkres)

       mkres@gsMarkerColor = "black"
       mkres@gsMarkerIndex = hollow_circle
       gsn_polymarker(wks,plot,track_lon(indices),track_lat(indices),mkres)
       gsn_polymarker(wks,plot,start_lon,start_lat,mkres)
       gsn_text      (wks,plot,labels(i),-96,start_lat,txres)
       
       start_lat = start_lat - 1

    end if
    delete(indices)
  end do

  frame(wks)
end
