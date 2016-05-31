function [descriptor,unit,cut_type_value,cut_type_label]=cutstruc
% cutstruc Initialize some basic cutfile variables
% function [descriptor,unit,cut_type_value,cut_type_label]=cutstruc
% cutstruc: Version 2.2.98

  descriptor=str2mat('cut_start','cut_end','cut_type','trial_number');
  unit=str2mat('s','s',' ',' ');
  cut_type_value=0;
  cut_type_label='trial';

