pro MMS_summary_FPI3x_plot,probe = probe, trange = trange, coord = coord,$
level = level, fgm_data_rate = fgm_data_rate,$
fpi_data_rate= fpi_data_rate, edp_data_rate= edp_data_rate, $
fig_save_dir = fig_save_dir
; plot data from a single satellite
; showing FPI, EDP and FGM in GSE. revised from MMS crib pros.
;  By Binbin Tang 20160314
; Update to load FPI version3.x files. Binbin Tang 2016/10/21
; make it to be a subrutinue. Binbin Tang 2016/10/27

!P.thick= 3
del_data,'*'
;  ;setup
;  probe='1'
;  ;probe = ['1','2','3','4']
;  data_rate='brst'
;  fgm_data_rate='srvy'
;  fpi_data_rate='brst'
;  edp_data_rate='fast'
;  level='l2'
;  coord = 'gse'
;trange=['2016-08-22/06:01:00','2016-08-22/06:01:30']
trange= trange
time_db = time_double(trange)
trange1 = time_string([time_db[0]-120, time_db[1]+120]) ; a longer time interval
timespan,trange

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;data loading
;load fgm data
mms_load_fgm, probes= probe, level=level,data_rate=fgm_data_rate, varformat='*fgm_b_'+coord+'*' ;, /latest_version, cdf_filenames = files, data_rate=data_rate
; load support data for transformations
mms_load_mec, probe=probe, trange=trange1

datatype = ['des-moms', 'dis-moms']
mms_load_fpi, probes=probe, trange=trange, datatype=datatype, level=level, data_rate= fpi_data_rate;,varformat='*_gse*'

datatype = ['dce','scpot']
mms_load_edp, probe= probe, datatype=datatype, level= level,data_rate= edp_data_rate,varformat='*_'+coord+'*'

store_data,'mms'+probe+'_numberdensity_'+fpi_data_rate,data=['mms'+probe+'_dis_numberdensity_'+fpi_data_rate,'mms'+probe+'_des_numberdensity_'+fpi_data_rate]
store_data,'mms'+probe+'_des_tempfac_'+fpi_data_rate,data=['mms'+probe+'_des_temppara_'+fpi_data_rate,'mms'+probe+'_des_tempperp_'+fpi_data_rate]
store_data,'mms'+probe+'_dis_tempfac_'+fpi_data_rate,data=['mms'+probe+'_dis_temppara_'+fpi_data_rate,'mms'+probe+'_dis_tempperp_'+fpi_data_rate]

;  vi_name = 'mms'+probe+'_dis_bulk_'+ fpi_data_rate
;  join_vec,  'mms'+probe+'_dis_bulk'+ ['x','y','z']+'_dbcs_'+ fpi_data_rate, vi_name
;
;  mms_cotrans, [vi_name], out_coord='gse', out_suffix='_gse', $
;    in_coord='dmpa', /ignore_dlimits
;
;  ve_name = 'mms'+probe+'_des_bulk_'+fpi_data_rate
;  join_vec,  'mms'+probe+'_des_bulk'+ ['x','y','z']+'_dbcs_'+fpi_data_rate, ve_name
;
;  mms_cotrans, [ve_name], out_coord='gse', out_suffix='_gse', $
;    in_coord='dmpa', /ignore_dlimits

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plotting
tkm2re, 'mms'+probe+'_mec_r_'+coord, /replace
split_vec,'mms'+probe+'_mec_r_'+coord
;used to set label for var_label option
options,'mms'+probe+'_mec_r_'+coord+'_x',ytitle=textoidl('X(R_{E})'),format='(f6.2)'
options,'mms'+probe+'_mec_r_'+coord+'_y',ytitle=textoidl('Y(R_{E})'),format='(f6.2)'
options,'mms'+probe+'_mec_r_'+coord+'_z',ytitle=textoidl('Z(R_{E})'),format='(f6.2)'

options,'mms'+probe+'_numberdensity_'+fpi_data_rate,labflag=-1,ytitle = TextoIDL('den'),colors = ['r','x']
;ylim,'mms'+probe+'_numberdensity_'+fpi_data_rate,0.1,40,1
options,'mms'+probe+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2',colors = ['b','g','r'],labflag=-1
options,'mms'+probe+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2',ytitle = TextoIDL('Edce')
options,'mms'+probe+'_dis_bulkv_'+coord+'_'+fpi_data_rate,labels=['Vi,x','Vi,y','Vi,z'],ytitle = TextoIDL('V');,yticks=3
;ylim,['mms'+probe+'_dis_bulkv_'+coord+'_'+fpi_data_rate],-300,220,0
options,'mms'+probe+'_des_bulkv_'+coord+'_'+fpi_data_rate,labels=['Ve,x','Ve,y','Ve,z'],ytitle = TextoIDL('V')
;ylim,[ve_name+'_gse'],-550,500,0
options,'mms'+probe+'_des_tempfac_'+fpi_data_rate,labflag=-1,ytitle = TextoIDL('Te'),colors = ['r','x']
options,'mms'+probe+'_dis_tempfac_'+fpi_data_rate,labflag=-1,ytitle = TextoIDL('Ti'),colors = ['r','x']
;ylim,'mms'+probe+'_dis_tempfac_'+fpi_data_rate,0,1000,0
options,'mms'+probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2',ytitle = TextoIDL('B');,yticks=2
;ylim,'mms'+probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec',-35,50,0
options, 'mms'+probe+'_des_energyspectr_omni_'+fpi_data_rate,ytitle = 'Ele', ysubtitle= '[eV]';,charsize = 0.8
options, 'mms'+probe+'_dis_energyspectr_omni_'+fpi_data_rate,ytitle = 'Ion',ysubtitle ='[eV]'
options,'mms'+probe+'_des_pitchangdist_avg',ytitle = 'P.A.'

cyear1 = strmid(trange[0],0,4)
cmonth1 = strmid(trange[0],5,2)
cday1 = strmid(trange[0],8,2)
chh1 = strmid(trange[0],11,2)
cmm1 = strmid(trange[0],14,2)
css1 = strmid(trange[0],17,2)

file_dr = fig_save_dir+'mms'+probe+'\'+cyear1+'\'+cmonth1+'\'+cday1
IF (FILE_TEST(file_dr, /DIRECTORY) EQ 0) THEN BEGIN
FILE_MKDIR,file_dr
ENDIF
file_fn =  file_dr+'\'+cyear1+cmonth1+cday1+strtrim(time_string(time_double(trange[0]),tformat='hhmmss'))+'_'+strtrim(time_string(time_double(trange[1]),tformat='hhmmss'))+'_summary_brst_V1.0'

ps = 0
if(ps eq 1) then begin
POpen,file_fn+'.ps', color=1, $
units='inches', xsize=7, ysize=7.5, FONT = 0, encapsulated = 0
Tplot,[$
'mms'+probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2',$
'mms'+probe+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2',$
'mms'+probe+'_numberdensity_'+fpi_data_rate,$
'mms'+probe+'_dis_tempfac_'+fpi_data_rate,$
'mms'+probe+'_dis_bulkv_'+coord+'_'+fpi_data_rate,$
'mms'+probe+'_des_tempfac_'+fpi_data_rate,$
'mms'+probe+'_des_bulkv_'+coord+'_'+fpi_data_rate,$
'mms'+probe+'_dis_energyspectr_omni_'+fpi_data_rate,$
'mms'+probe+'_des_energyspectr_omni_'+fpi_data_rate,$
'mms'+probe+'_des_pitchangdist_avg'  $
],$
var_label=['mms'+probe+'_mec_r_'+coord+'_x','mms'+probe+'_mec_r_'+coord+'_y','mms'+probe+'_mec_r_'+coord+'_z']
TimeBar, 0., color=0, linestyle=2, thick=2, varname= 'mms'+probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2', /databar
TimeBar, 0., color=0, linestyle=2, thick=2, varname= 'mms'+probe+'_des_bulkv_'+coord+'_'+fpi_data_rate, /databar
TimeBar, 0., color=0, linestyle=2, thick=2, varname= 'mms'+probe+'_dis_bulkv_'+coord+'_'+fpi_data_rate, /databar
;    TimeBar, time_double('2015-10-16/13:05:43.6'), color=0, thick=2.3,linestyle = 1
;    TimeBar, time_double('2015-10-16/13:06:02'), color=0, thick=2.3,linestyle = 1
Pclose

endif else begin
!p.charthick=1.5   &   !p.charsize=1.5
window,0,xsize=1000,ysize=1000
Tplot,[$
'mms'+probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2',$
'mms'+probe+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2',$
'mms'+probe+'_numberdensity_'+fpi_data_rate,$
'mms'+probe+'_dis_tempfac_'+fpi_data_rate,$
'mms'+probe+'_dis_bulkv_'+coord+'_'+fpi_data_rate,$
'mms'+probe+'_des_tempfac_'+fpi_data_rate,$
'mms'+probe+'_des_bulkv_'+coord+'_'+fpi_data_rate,$
'mms'+probe+'_dis_energyspectr_omni_'+fpi_data_rate,$
'mms'+probe+'_des_energyspectr_omni_'+fpi_data_rate,$
'mms'+probe+'_des_pitchangdist_avg'  $
],$
var_label=['mms'+probe+'_mec_r_'+coord+'_x','mms'+probe+'_mec_r_'+coord+'_y','mms'+probe+'_mec_r_'+coord+'_z']
TimeBar, 0., color=0, linestyle=2, thick=2, varname= 'mms'+probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2', /databar
TimeBar, 0., color=0, linestyle=2, thick=2, varname= 'mms'+probe+'_des_bulkv_'+coord+'_'+fpi_data_rate, /databar
TimeBar, 0., color=0, linestyle=2, thick=2, varname= 'mms'+probe+'_dis_bulkv_'+coord+'_'+fpi_data_rate, /databar
;   makepng,files+'\MDD_STD_IDL_'+strmid(trange[0],0,10)+strtrim(time_string(time_double(trange[0]),tformat=' hhmmss'))+strtrim(time_string(time_double(trange[1]),tformat=' hh-mm-ss'))+'_'+strtrim(points,2)+'_points_V'
makepng, file_fn
endelse
end