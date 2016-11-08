pro mms_summary_brst_plot_main_auto
; load data from remote data dir if local data does not match. --> so make sure your IDL can connect to MMS LASP data base
; see mms_load_data.pro for stricter use
;
; time interval of every summary plot is no longer than ~2 min. By Binbin Tang 2016/10/27
;
; some minor changes. By Binbin Tang, 2016-10-28
; a)add a log file in case IDL sometimes exit unexpectly.
; b)loop for all 4 mms probes.(But I suggest only plot MMS1 data at the beginning). Binbin Tang, 2016-11-01

del_data,'*'
;setup
setenv,'root_data_dir=N:\observation\'
;fig_save_dir = 'E:\ob_temp\MMS\summary\'
fig_save_dir = 'L:\Our_study\MMS_summary_plot\'
mms_init
if undefined(local_data_dir) then local_data_dir = !mms.local_data_dir

;probe='4'
probe_arr = ['1','2','3','4']
for iprobe = 3 , 3 do begin
probe = probe_arr[iprobe]

fgm_data_rate='srvy'
fpi_data_rate='brst'
edp_data_rate='fast'
data_rate = fpi_data_rate
level='l2'
coord = 'gse'
day = '2016-09-27'
fig_tlong = 120.   ; time interval for plot. The maximum time interval could be 1.5*flg_tlong

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
day_db = time_double(day)
trange_init = [time_string(day_db),time_string(day_db + 86400 - 1)]

; in this rutinue, we use FPI data to determine the time interval to plot, for it is the selected 'brst' mode data
day_string = time_string(trange_init[0], tformat='YYYY-MM-DD')
end_string = time_string(trange_init[1], tformat='YYYY-MM-DD-hh-mm-ss')

datatype = 'dis-moms'
probe_str = 'mms' + strcompress(string(probe), /rem)
public = 1

;check remote data
qt0 = systime(/sec) ;temporary
data_file = mms_get_science_file_info(sc_id= probe_str, instrument_id='fpi', $
data_rate_mode=fpi_data_rate, data_level=level, start_date=day_string, $
end_date=end_string, descriptor=datatype, public=public, cdf_version=cdf_version)
dt_query = systime(/sec) - qt0 ;temporary

remote_file_info = mms_parse_json(data_file)

filename = remote_file_info.filename
num_filenames = n_elements(filename)
;num_filenames = 2;
; now, we know how many files at the selected day

dir_path = fpi_data_rate eq 'brst' ? '/YYYY/MM/DD' : '/YYYY/MM'   ; ...
instrument = 'fpi'

cyear1 = strmid(trange_init[0],0,4)
cmonth1 = strmid(trange_init[0],5,2)
cday1 = strmid(trange_init[0],8,2)
for i = 0, num_filenames-1 do begin
;1) check if local dir is the latest version of cdf file
timetag = time_string(time_double(remote_file_info[i].timetag), tformat ='YYYY-MM-DD')

daily_names = file_dailynames(file_format=dir_path, /unique, trange=timetag)

; updated to match the path at SDC; this path includes data type for
; the following instruments: EDP, DSP, EPD-EIS, FEEPS, FIELDS, HPCA, SCM (as of 7/23/2015)
sdc_path = instrument + '/' + data_rate + '/' + level
sdc_path = datatype ne '' ? sdc_path + '/' + datatype + daily_names : sdc_path + daily_names
file_dir = local_data_dir + strlowcase(probe_str + '/' + sdc_path)
;  print,file_dir
file_dir = strjoin(strsplit(file_dir, '/', /extract), path_sep())

same_file = mms_check_file_exists(remote_file_info[i], file_dir = file_dir)
if same_file eq 0 then begin
dprint, dlevel = 0, 'Downloading ' + filename[i] + ' to ' + file_dir
status = get_mms_science_file(filename=filename[i], local_dir=file_dir, public=public)
endif

; get the length of a file
file_path_name = file_dir+'\'+filename[i]
mms_cdf2tplot, file_path_name, varformat = 'mms'+probe+'_dis_numberdensity_'+fpi_data_rate
get_data, 'mms'+probe+'_dis_numberdensity_'+fpi_data_rate, data = temp
file_tlong = temp.x[n_elements(temp.x)-1] - temp.x[0]  ; sec

fig_numf = file_tlong/fig_tlong
fig_num = round(file_tlong/fig_tlong)
if (fig_num eq 0) then begin
fig_num = 1   ; in case the length of a file is shorter than 1/2 fig_tlong
endif

for j = 1,fig_num do begin
if(j eq fig_num) then begin
if(fig_numf gt fig_num) then t0 = temp.x[0]+(j-1)*fig_tlong ; which could be longer than fig_long
if(fig_numf le fig_num) then t0 = temp.x[n_elements(temp.x)-1] - fig_tlong
t0 = t0 > temp.x[0]
trange=[time_string(t0,TFORMAT='YYYY-MM-DD/hh:mm:ss.ff'),time_string(temp.x[n_elements(temp.x)-1],TFORMAT='YYYY-MM-DD/hh:mm:ss.ff')]
endif else begin
trange=[time_string(temp.x[0]+(j-1)*fig_tlong,TFORMAT='YYYY-MM-DD/hh:mm:ss.ff'),time_string(temp.x[0]+ j*fig_tlong,TFORMAT='YYYY-MM-DD/hh:mm:ss.ff')]
endelse
mms_summary_fpi3x_plot,probe = probe, trange = trange, coord = coord,$
level = level, fgm_data_rate = fgm_data_rate,$
fpi_data_rate= fpi_data_rate, edp_data_rate= edp_data_rate,$
fig_save_dir = fig_save_dir
endfor
openw,lun,fig_save_dir+'mms'+probe+'\'+cyear1+'\'+cmonth1+'\'+cday1+'\log.dat',/get_lun,/append
printf,lun,i,fig_num,trange[0], format='(2i4,3x,a22)'
free_lun,lun
endfor

endfor
end