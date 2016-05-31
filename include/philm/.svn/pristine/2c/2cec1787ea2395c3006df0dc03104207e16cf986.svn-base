function mt_scsid(myfield,mydata)
% MT_SCSID Set common signal data
% function mt_scsid(myfield,mydata)
% mt_scsid: Version 28.4.98
%
%	Description
%		Stored in userdata of axes "signal_axis" of organization figure
%		Fields are:
%
%			signal_list
%				A string matrix of the signal names
%
%			signalpath
%				The common prefix to the mat files where the signals are stored
%				(see mt_org)
%
%			ref_trial
%				(see mt_org)
%
%			unique_matname
%				A string matrix of the non-common part of the mat file names
%
%			mat2signal
%				A cell array listing the signals for each entry in "unique_matname"
%
%			max_sample_inc
%				Sample increment (in seconds) of the signal with the lowest sample rate
%				(used internally to control the resolution of some time settings)
%
%			audio_channel
%				Name of current signal used for audio output
%
%	See Also
%		MT_ORG MT_GCSID, MT_SSIG, MT_GSIGV MT_LOADT

myS=[];
figorgh=mt_gfigh('mt_organization');
saxh=findobj(figorgh,'tag','signal_axis');

myS=get(saxh,'userdata');

fieldlist=fieldnames(myS);
vi=strmatch(myfield,fieldlist);
if isempty(vi)
   disp(['mt_scsid: Bad field name; ' myfield]);
   return;
end;


myS=setfield(myS,myfield,mydata);

set(saxh,'userdata',myS);


