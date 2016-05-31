%set up sensor orientation display
% cartesian version

mysiglist=cellstr(str2mat('tb','tm','tt','ul','ll','jaw'));
mt_sxyadv('sagittal','x_mode','signal_data','x_spec',char(strcat(mysiglist,'_ox')))
mt_sxyadv('sagittal','y_mode','signal_data','y_spec',char(strcat(mysiglist,'_oy')))
mt_sxyadv('sagittal','z_mode','signal_data','z_spec',char(strcat(mysiglist,'_oz')))
%mt_sxyadv('sagittal','z_mode','constant','z_spec','1')
%use this to scale vector length
mt_sxyadv('sagittal','xform','5');
mt_sxyad('sagittal','v_mode','cartesian')

return;
%same for coronal


mt_sxyadv('axial','x_mode','signal_data','x_spec',str2mat('ul_ox','ll_ox','jaw_ox'))
mt_sxyadv('axial','y_mode','signal_data','y_spec',str2mat('ul_oy','ll_oy','jaw_oy'))
mt_sxyadv('axial','z_mode','signal_data','z_spec',str2mat('ul_oz','ll_oz','jaw_oz'))
%mt_sxyadv('sagittal','z_mode','constant','z_spec','1')
%use this to scale vector length
mt_sxyadv('axial','xform','0.5');
mt_sxyad('axial','v_mode','cartesian')
