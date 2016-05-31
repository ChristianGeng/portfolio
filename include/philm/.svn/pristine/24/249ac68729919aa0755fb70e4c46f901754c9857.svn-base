function ai_device=adlink_start(sf,mydur)
% ADLINK_START Start analog acquistion
% function ai_device=adlink_start(sf,mydur)
% ADLINK_START: Version 20.09.2013
%
%   Description
%       Start analog acquisition. Currently fixed to Adlink hardware
%       Mainly designed for user extensions to prompt programs for simple
%       analog acqusition, e.g. to run ADLINK hardware in ultrasound
%       experiments
%       Default settings are appropriate for audio and synch acquistion
%       in ultrasound experiments. Will be extended with third input
%       argument to allow more flexible setting.
%       sf: samplerate. Note: A warning will be given if the desired
%           samplerate is not avaiable. ADLINK_STOP returns the actual
%           samplerate used
%       mydur: Duration in seconds
%       ai_device: The analog input object created by the data acquistion
%           toolbox. This must be stored by the calling program and passed on
%           to functions such as ADLINK_STOP, e.g. using the predifined fields
%           in the main data structure of the prompt program (see
%           prompter_ini_base. Use e.g prompter_smaind('ai_object',ai_device))
%
%   See Also
%       ADLINK_STOP, PROMPTER_INI_BASE


% should have additional input argument to override default settings

%c:\phil\matlab\adlink
aa=daqhwinfo('mwadlink');
  ai_device = analoginput('mwadlink', 0);
set(ai_device,'InputType','DIFF');
  ai0 = addchannel(ai_device, [0 1]);
  
  %set channel input range
  set(ai0(1),'InputRange',[-5 5]);
  set(ai0(2),'InputRange',[-5 5]);

  %   getsample(ai_device)
set(ai_device, 'SampleRate', sf);
sfuse=get(ai_device,'SampleRate');

if sf~=sfuse
disp(['Sample rate requested, used : ' num2str([sf sfuse])]);
end;

samppertrig=mydur*sfuse;
   set(ai_device, 'SamplesPerTrigger', samppertrig);
    

%disp('hit a key to run');
%pause;
start(ai_device);
irun=0;

%timeout???
while ~irun
rr=get(ai_device,'Running');
%disp(rr);
irun=strcmp(rr,'On');
if ~irun disp('Waiting to run'); end;
end;

%if timeout set ai_device to empty (stop and delete)


