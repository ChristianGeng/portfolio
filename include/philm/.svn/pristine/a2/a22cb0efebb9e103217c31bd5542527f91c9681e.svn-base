function [data,sf]=adlink_stop(ai);
% ADLINK_STOP Retrieve analog input data
% function [data,sf]=adlink_stop(ai);
% ADLINK_STOP: Version20.09.2013
%
%   Description
%       Retrieves analog data from acquistion started by ADLINK_START
%       Mainly designed for user extensions to prompt programs for simple
%       analog acqusition, e.g. to run ADLINK hardware in ultrasound
%       experiments
%       sf: actual samplerate used (maybe different from sample rate
%           requested in ADLINK_START if rate is not available on the hardware
%       ai: The analog input object returned by adlink_start (see
%           prompter_ini_base for predefined fields making it available when
%           prompt program is running)
%
%   See Also
%       ADLINK_START, PROMPTER_INI_BASE

data=[];
sf=[];

%wait for running 'Off'
%check 'SampleAcquired' as expected ??
%timeout???
istop=0;
while ~istop
rr=get(ai,'Running');
%disp(rr);
istop=strcmp(rr,'Off');
if ~istop disp('Waiting for ai to stop'); end;
end;

sa=get(ai,'SamplesAvailable');
if sa>0
spt=get(ai,'SamplesPerTrigger');
if sa~=spt
    disp(['Expected ' int2str(spt) ' samples, but ' int2str(sa) ' are available']);
end;

data = getdata(ai);
%get actual samplerate used
sf=get(ai,'SampleRate');
%plot(data);
else
    disp('No data available');
end;

%keyboard;

delete(ai);

