function [filename,declevel,S]=findtdms_chinfo(id)
% FINDTDMS_CHINFO Get info on channel in tdms file
% function [filename,declevel,S]=findtdms_chinfo(id)
% findtdms_chinfo Version 04.03.2013
%
%   Description
%       Mainly for use within converttdms_ph
%       Processes the struct with TDMS properties of the current channel to
%       get essential data for the output file (including filename and
%       descriptor to use in final mat file
%
%   Syntax
%       filename: Converts the TDMS longname propery into a form suitable
%           for use as an output filename
%           e.g (depending on system date format) longname may look like this:
%           '13/02/2013 11:09:19 - Voltage - All Data/Sennheiser_Mike'
%           The filename generated will be:
%           '13022013_110919_Voltage_Sennheiser_Mike'
%           Special case for TTL signals:
%           '13/02/2013 11:09:19 - TTL - All Data/SYNC - line 0'
%           Since this does not correspond to how the signal is listed in
%           the TTL_meta.txt file the ' - line 0' suffix is removed.
%           (I am not even sure that what looks like the line number is
%           always correct.
%           The definitive hardware connection information can be found in 
%           S.NI_ChannelName)
%
%       declevel: Decimation level. The actual sampled data has decimation
%           level 0. Other decimation levels > 0 seem to be just for
%           display purposes of existing TDMS files in SignalExpress
%           (declevel < 0 may occur for non-sampled data (e.g. events)
%
%       S: Struct with following fields
%            'descriptor', 'NI_ChannelName', 'unit', 'samplerate'
%           S.descriptor is the user-defined channel name (i.e.
%           'Sennheiser_Mike' in the above example.

%assume longname looks like this
%'13/02/2013 11:09:19 - Voltage - All Data/Sennheiser_Mike'
%or this (depending on date format)
%'13.02.2013 11:09:19 - Voltage - All Data/Sennheiser_Mike'
%If signalexpress uses the windows short date setting then other
%possibilities could occur, e.g.??
%'13-Feb-13 11:09:19 - Voltage - All Data/Sennheiser_Mike'

%25.02.2013: handle case where date format contains slashes
%01.03.2012: correct handling of descriptor after previous changes

longname=id.long_name;
filename=longname;
ipi=findstr(' - line ',filename);
if ~isempty(ipi) filename(ipi:end)=[]; end;

filename=strrep(filename,' - ','_');
filename=strrep(filename,'-','');       %possible in date?
filename=strrep(filename,'.','');       %assume only occurs in date
filename=strrep(filename,':','');       %assume only occurs in time
ipi=findstr('/',filename);
descriptor=filename((ipi(end)+1):end);
filename=strrep(filename,'All Data/','');
filename=strrep(filename,'/','');       %should just be any slashes in date
filename=strrep(filename,' ','_');
filename=strrep(filename,'__','_');
%must be a better way of doing this
descriptor=strrep(descriptor,' ','_');
descriptor=strrep(descriptor,'__','_');

%the result should be a filename like
%'13022013_110919_Voltage_Sennheiser_Mike'


S.descriptor=descriptor;

%also need info to use as unit, samplerate

unit='';
samplerate=NaN;

declevel=-1;
mychan='';
f1=fieldnames(id);

nf1=length(f1);

for if1=1:nf1
    tf1=id.(f1{if1});
    if isstruct(tf1)
        if isfield(tf1,'name')
            myname=tf1.name;
            if strcmp(myname,'DecimationLevel')
                declevel=tf1.value;
            end;
            if strcmp(myname,'NI_ChannelName')
                ccc=tf1.value;
                mychan=char(ccc);
            end;
            if strcmp(myname,'wf_increment')
                samplerate=1./tf1.value;
            end;
            if strcmp(myname,'unit_string')     %alternative: NI_UnitDescription
                ccc=tf1.value;
                unit=char(ccc);
            end;
        end;
    end;
end;
S.NI_ChannelName=mychan;
S.unit=unit;
S.samplerate=samplerate;
