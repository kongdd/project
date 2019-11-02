;*********************************************************************
;Draw monthly preci in every month(3*4) of one case, just simply view 
;the distribution of a variable.
;                                                     by Ql Ren
;                                                    2019/07/12
;*********************************************************************************
begin
var_option   = 2
month_option =  True;False
case_option = 0 ;0 means NUDG experiment; 1 means noTP experiment
nl = 3 ;(/850,700,500,200/)
fnc  = 0    ;chose which case to draw
diff = True ;whether draw the difference

if(var_option.eq.0) then 
    draw_var = (/"Qd"   ,"Qeddy","total"/)  ;this is the variable used to draw, can used as center string
    var_name = (/"Qd"   ,"Qeddy"/)  ;use to read variables
    unit     = (/"K/Day","K/Day","K/day"/)  ;this can be used as right string 
end if
if(var_option.eq.1) then 
    draw_var = (/"fQd" ,"fQeddy","A","total"/)  ;this is the variable used to draw, can used as center string
    var_name = (/"f_Qd","f_Qeddy","A","total"/)  ;use to read variables
    unit     = "10~S~-10~N~" + (/"s~S~-2~N~","s~S~-2~N~","s~S~-2~N~","s~S~-2~N~"/)  ;this can be used as right string 
end if
if(var_option.eq.2) then 
    draw_var = (/"fQd" ,"fQeddy","A","total"/)  ;this is the variable used to draw, can used as center string
    var_name = (/"dzdt","dudt","dTdt"/)  ;
    unit     = "10~S~-3~N~" + (/"m~S~2~N~/s~S~3~N~","m/s~S~2~N~","K/s"/)  ;this can be used as right string 
    nnv = 0 ;used to read dzdt induced by different forcing
    select = (/0,1,2/) ;(/1,2,3/) ;0 is Qd, 1 is Qd_t
end if
months   = (/"MJ","JA"/)
lev = (/850,700,500,200/)

;the path of the file
path    = "/home/ys17-19/renql/project/TP_NUDG"
if(case_option.eq.0) then
    case1   = (/"CTRL","NUDG6h"/);,"NUDG24h"/)
    case2   = (/"CTRL","NG6h-CTRL"/);, "NG24h-CTRL"/)
    gtopfile = path + "/analysis/mdata/" + "gtopo30_0.9x1.25.nc"
    nsample = 27
else
    case1   = (/"TP_CTRL","TP_CR"/)
    case2   = (/"CTRL"   ,"noTP"/)
    ;gtopfile = "/home/ys17-19/renql/model/TP_CR/USGS-gtopo30_1.9x2.5_noTP_c050602C.nc" 
    gtopfile = "/home/ys17-19/renql/model/TP_CTRL/USGS-gtopo30_1.9x2.5_remap_c050602.nc" 
    nsample = 10
end if

if(var_option.lt.2)
    filename = path + "/z_tendency-20191022/mdata/" + case1 + "-Clim_daily_Qd_Qeddy_A.nc"
    fig_name = path + "/z_tendency-20191022/fig/1p2x3_clim_MJ-JA_" + var_name(0) + "-" + lev(nl)  
else
    if(month_option) then
    filename = path + "/z_tendency-20191022/mdata/" + case1 + "-Clim_dzdt_monthly-global.nc"
    else
    filename = path + "/z_tendency-20191022/mdata/" + case1 + "-Clim_daily_dzdt.nc"
    end if
    fig_name = path + "/z_tendency-20191022/fig/1p2x3_clim_MJ-JA_" + var_name(nnv) + "-" + lev(nl)  
end if
;fig_title  = "Seasonal " + draw_var(nv) + " variance in " ;+season
pre_case   = (/"(a","(b","(c","(d","(e","(f","(g","(h","(i","(j","(k","(l"/)
fig_out    ="pdf";"x11"

;area: east Asia
lats = 0   ;20 
latn = 89  ;55 
lonl = 10   ;30 
lonr = 350 ;150
month_s = 5
month_e = 8

f = addfile(gtopfile,"r")
phis   = f->PHIS({lats:latn},{lonl:lonr})
phis   = phis/9.8   ;convert unit from m2/s2 to gpm
nmonth = dimsizes(months)
nlat   = dimsizes(phis&lat)
nlon   = dimsizes(phis&lon)
nlev   = dimsizes(lev)
nvar   = dimsizes(draw_var)
ncase  = dimsizes(case1)

f = addfile(filename(0),"r")
if(.not.(month_option)) then 
time = cd_calendar(f->time,0)
select_time = ind(time(:,1).ge.month_s.and.time(:,1).le.month_e)
ntime = dimsizes(select_time)
var   = new((/ncase,nvar,ntime ,nlat,nlon/),double)
end if
var_m = new((/ncase,nvar,nmonth,nlat,nlon/),double)

;the number of the panel plot
    plot     = new((/nvar*nmonth/),graphic)
    gtop     = new((/nvar*nmonth/),graphic)
    line     = new((/nvar*nmonth/),graphic)

;set the area of the box
maxlon = 105
minlon = 70
maxlat = 40
minlat = 25
lonx = (/ minlon, maxlon, maxlon, minlon, minlon /)
latx = (/ minlat, minlat, maxlat, maxlat, minlat /)

;define the thickness and height of the title,tick and label
   tick_font      = 0.03
   subtitle_font  = 0.03
   title_font     = 0.03
   tick_thick     = 8.0
   subtitle_thick = 8.0  ;not have this attribute
   title_thick    = 5.0
   mp_thick       = 3.0
   font_index     = 22

;================================================================
;read data
;====================================================================
if(month_option) then
do nc = 0, ncase-1, 1
    print(filename(nc))
    f = addfile(filename(nc),"r")
    if(var_option.le.1)
        do nv = 0, nvar-2,1
        var_m(nc,nv,:,:,:)  = f->$var_name(nv)$(:,{lev(nl)},{lats:latn},{lonl:lonr}) ;get an array (ncase,nmonth,nlat,nlon)
        end do
    else
        var_m(nc,0:2,:,:,:)  = f->$var_name(nnv)$(select,:,{lev(nl)},{lats:latn},{lonl:lonr}) ;get an array (ncase,nmonth,nlat,nlon)
    end if
end do 
else
do nc = 0, ncase-1, 1
    f = addfile(filename(nc),"r")
    if(var_option.le.1)
        do nv = 0, nvar-2,1
        var(nc,nv,:,:,:)  = f->$var_name(nv)$(select_time,{lev(nl)},{lats:latn},{lonl:lonr}) ;get an array (ncase,nmonth,nlat,nlon)
        end do
    else
        var(nc,0:2,:,:,:)  = f->$var_name(nnv)$(select,select_time,{lev(nl)},{lats:latn},{lonl:lonr}) ;get an array (ncase,nmonth,nlat,nlon)
    end if
end do 
;calc ealy(56) and late(78) stage of the summer 
select_time := ind(time(:,1).ge.5.and.time(:,1).le.6)
var_m(:,:,0,:,:) = dim_avg_n_Wrap(var(:,:,select_time,:,:),2)
select_time := ind(time(:,1).ge.7.and.time(:,1).le.8)
var_m(:,:,1,:,:) = dim_avg_n_Wrap(var(:,:,select_time,:,:),2)
printVarSummary(var_m)
end if

var_m(:,nvar-1,:,:,:) = dim_sum_n(var_m(:,0:(nvar-2),:,:,:),1)

if(var_option.eq.0) then 
    var_m = var_m*24*3600 ;convert units of Q from K/s to K/Day 
end if
if(var_option.eq.1) then 
    var_m = var_m*10^10
end if
if(var_option.eq.2) then 
    var_m = var_m*10^3
end if
printVarSummary(var_m)

if(diff) then 
do nc = 1, ncase-1, 1
    var_m(nc,:,:,:,:) = var_m(nc,:,:,:,:) - var_m(0,:,:,:,:)
end do 
end if

;==============================================================
;draw figure in twelve months (one month is a fgure)
;==================================================================
    wks = gsn_open_wks(fig_out,fig_name)
    ;gsn_define_colormap(wks,"BlueDarkRed18")
    ;blue and red, has 18 colors,2-10 is blue
    ;gsn_define_colormap(wks,"GMT_polar") 
    ;blue and red, has 20 colors, 2-11 is bule, 12-21 is red
    ;gsn_define_colormap(wks,"matlab_jet") 
    ;has 64 colors blue green yellow,red

    res                  = True
    res@gsnFrame         = False
    res@gsnDraw          = False
    res@gsnMaximize      = True
    res@gsnAddCyclic     = False
    res@gsnPaperOrientation = "portrait"
    ;res@vpHeightF        = 0.25
    ;res@vpWidthF         = 0.8

;-------set the attribute of the map-------------------
    res@mpCenterLonF     = 180.
    res@mpMaxLatF        = latn
    res@mpMinLatF        = lats
    res@mpMaxLonF        = lonr
    res@mpMinLonF        = lonl
    res@gsnMajorLatSpacing = 15
    res@gsnMajorLonSpacing = 30
    res@mpFillOn         = False
    ;res@mpLandFillColor = "gray"
    ;res@mpFillDrawOrder = "PreDraw"
    res@mpGeophysicalLineThicknessF = mp_thick
    res@mpGeophysicalLineColor      = "black";"white"

;--------set the form of the coordinate-----------------
    res@tmBorderThicknessF  = mp_thick
    res@tmXBLabelFont   = font_index
    res@tmYLLabelFont   = font_index
    res@tmXBLabelFontHeightF     = tick_font
    ; res@tmXBLabelFontAspectF   = 1.6
    res@tmXBLabelFontThicknessF  = tick_thick
    res@tmYLLabelFontHeightF     = tick_font
    ; res@tmYLLabelFontAspectF   = 1.3
    res@tmYLLabelFontThicknessF  = tick_thick
    
    res@tmXBMajorThicknessF     = mp_thick
    res@tmYLMajorThicknessF     = mp_thick
    ;  res@tmXBMajorOutwardLengthF = -0.
    ;  res@tmYLMajorOutwardLengthF = -0.
    ;  res@tmYRMajorOutwardLengthF = -0.
      
    res@tmXBMinorThicknessF     = mp_thick
    res@tmYLMinorThicknessF     = mp_thick
    ;  res@tmXBMinorOutwardLengthF = -0.
    ;  res@tmYLMinorOutwardLengthF = -0.
    ;  res@tmYRMinorOutwardLengthF = -0.

;---------set the attribute of the contour-----------------
    res@cnFillOn         = True
    res@cnLinesOn        = False ;True
    res@cnLineLabelsOn   = False
    res@cnInfoLabelOn    = False
    ;res@cnLineThicknessF = 0
    ;res@gsnContourZeroLineThicknessF = 4.0
    ;res@cnLineColor      = "blue"
   
    ;res@cnLevelSelectionMode = "AutomaticLevels"   ; set manual contour levels
    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;res@cnLevels             = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;res@cnLevels             = ispan(0,60,10)
    ;res@cnFillColors         = (/-1,20,47,57,94,127,152/)
    ;res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    ;res@cnMinLevelValF        = 1          ; set min contour level
    ;res@cnMaxLevelValF        = 13 ;32        ; set max contour level
    ;res@cnLevelSpacingF       = 1        ; set contour interval

    res@gsnSpreadColors      = False  ;True              ; turn of the full color map
    res@gsnSpreadColorStart  = 11                ; start at color 17
    res@gsnSpreadColorEnd    = 2                ; end at color 200
    
    res@lbLabelBarOn         = True   ; the label bar
    res@lbOrientation        = "Horizontal"
    res@lbLabelFontHeightF   = tick_font              ; make labels smaller
    res@lbLabelFont          = font_index              ; make labels smaller
    res@lbLabelStride        = 1
    res@lbBoxLineThicknessF  = mp_thick-1

    res@pmLabelBarZone               = 0
    res@pmLabelBarOrthogonalPosF     = 0.15
    res@pmLabelBarParallelPosF       = 0.5

;----------Set res sig-----------
    res_sig                  = True
    res_sig@gsnDraw          = False
    res_sig@gsnFrame         = False
    res_sig@cnFillOn         = True       ; Fill contours
    res_sig@cnLinesOn        = False;True      ; turn off contour lines
    res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
    res_sig@cnInfoLabelOn    = False
    ;res_sig@cnLineThicknessF = 2
    ;res_sig@cnLineColor     = "black"
    res_sig@cnMonoFillPattern= True;False
    res_sig@cnFillPattern    = 11
    res_sig@cnMonoFillScale  = True
    res_sig@cnFillScaleF     = 0.5
    res_sig@cnMonoFillColor  = True
    res_sig@cnFillColor      = "grey0"
    res_sig@lbLabelBarOn     = False;True   ; turn off the label bar
    
    res_sig@gsnCenterString      = ""
    res_sig@gsnLeftString    = " "
    res_sig@gsnRightString   = " "

;--------set the attribute of polygon--------------
    lnres                      = True
    lnres@gsLineColor          = "black"
    lnres@gsLineDashPattern    = 0
    lnres@gsLineThicknessF     = 4.0
    ;lnres@gsLineLabelString    = "TP"

;--------set the attribute of gtop--------------
    res_gtop                  = True
    res_gtop@gsnDraw          = False
    res_gtop@gsnFrame         = False
    res_gtop@cnFillOn         = False
    res_gtop@cnLinesOn        = True      ; turn off contour lines
    res_gtop@cnLineLabelsOn   = False      ; turn off contour line labels
    res_gtop@cnInfoLabelOn    = False
    res_gtop@cnLineThicknessF = 4.0
    res_gtop@cnLineColor      = "black"
    res_gtop@cnLevelSelectionMode  = "ExplicitLevels" ; set manual contour levels
    res_gtop@cnLevels         = (/1500/)
    res_gtop@gsnCenterString      = ""
    res_gtop@gsnLeftString    = " "
    res_gtop@gsnRightString   = " "

;------------------------------------------------------------------
;draw the subgraph and change the left and right titles
;-----------------------------------------------------------------------
   ; res@tiMainString         = fig_title + "in" + months(m)
    ;res@tiMainFontHeightF    = 0.04
   ; res@tiMainFontColor      = "black"
    res@gsnCenterString      = ""
    res@gsnStringFont         = font_index
    res@gsnStringFontHeightF = subtitle_font

    resp  = True    
    resp@gsnMaximize   = True
    resp@gsnPaperOrientation = "portrait"
    ;resp@gsnPanelLabelBar = True
    ;resp@pmLabelBarWidthF  = 0.5
    ;resp@pmLabelBarHeightF = 0.05
    ;resp@lbLabelFontHeightF = tick_font
    ;resp@lbLabelFontThicknessF = tick_thick
    resp@txFontHeightF = title_font 
    resp@txFontThicknessF = title_thick

if(var_option.eq.0) then ;Q
    minlvl = (/-2.4,-2.4,-2.4/);
    maxlvl = (/ 2.4, 2.4, 2.4/);
    spacig = (/0.3 ,0.3 ,0.3 /);
end if

if(var_option.eq.1) then ;forc
    minlvl = (/-2.4,-2.4,-2.4,-2.4/);
    maxlvl = (/ 2.4, 2.4, 2.4, 2.4/);
    spacig = (/0.3 ,0.3 ,0.3 ,0.3 /);
end if
    
if(var_option.eq.2) then ;dzdt
    minlvl = (/-8,-8,-8,-8/);,-1.6,-1.6,-1.6,-1.6
    maxlvl = (/ 8, 8, 8, 8/);,1.6 ,1.6 ,1.6 ,1.6 
    spacig = (/ 1, 1, 1, 1/);,0.2 ,0.2 ,0.2 ,0.2 
end if

    res@cnFillPalette = "BlueDarkRed18"
   ;blue and red, has 18 colors,2-10 is blue
    ;res@cnFillPalette = "precip3_16lev"
    ;blue and yellow and red, has 17 colors,2-18,2 is white
do nv = 0,nvar-1,1
do nm = 0,nmonth-1,1
    ;np = nm*nvar + nv
    np = nv*nmonth + nm
    res@gsnLeftString   = pre_case(np) + ") " + case2(fnc) + " " + months(nm)
    if(var_option.eq.2) then 
    res@gsnRightString  = lev(nl) + "hPa " + draw_var(nv) + " (" + unit(nnv) + ")"
    else
    res@gsnRightString  = lev(nl) + "hPa " + draw_var(nv) + " (" + unit(nv) + ")"
    end if
    res@gsnSpreadColors       = False              ; turn of the full color map
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnLevelSpacingF       := spacig(nv)        ; set contour interval
    res@cnMaxLevelValF        := maxlvl(nv) ;32    ; set max contour level
    res@cnMinLevelValF        := minlvl(nv)       ; set min contour level
    plot(np)     = gsn_csm_contour_map_ce(wks,var_m(fnc,nv,nm,:,:),res)
    gtop(np) = gsn_csm_contour(wks,phis,res_gtop)
    overlay(plot(np),gtop(np))
    if(case_option.eq.0) then 
    line(np) = gsn_add_polyline( wks, plot(np), lonx, latx, lnres )
    end if 
    print(max(var_m(fnc,nv,nm,{lats:latn},{lonl:lonr})))
    print(min(var_m(fnc,nv,nm,{lats:latn},{lonl:lonr})))
end do 
end do 

;    resp@txString      = fig_title
    ;gsn_panel(wks,plot,(/nmonth,nvar/),resp)
    gsn_panel(wks,plot,(/nvar,nmonth/),resp)
end
