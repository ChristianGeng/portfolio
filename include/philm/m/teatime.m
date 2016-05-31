function teatime(mytime,soundlist)
% TEATIME Matlab timer for alarm after fixed interval
% function teatime(mytime,soundlist)
% teatime: Version 03.06.2013
%
%   Syntax
%       mytime: timer period in seconds. optional. default to 120
%           Can also be a vector. Callback then restarts timer with next
%           element in vector
%       soundlist: Optional (default to tealist.txt). Text file with list
%       of sound files that can be used
%
%   Description
%       First tries to find a list of wav files in tealist.txt
%       If successful choses one at random as sound to play
%       Otherwise, tries to find and play a wav file called teasound.wav
%       If unsuccessful, just beeps
%
%   Updates
%       2.08
%           mytime can be vector
%           list file as optional second argument
%       04.2012 primitive way of avoiding same random sequence occuring
%       06.2013 replace ascii bell with beep. correct handling of missing
%           tealist or missing wav file

startdelay=120;
if nargin startdelay=mytime; end;
%default execution mode is single shot
ht=timer('timerfcn',@teatimecbx,'startdelay',startdelay(1),'tag','tea');
startdelay(1)=[];
userdata.startdelay=startdelay;
userdata.teasound='teasound';
userdata.tealist='tealist.txt';
if nargin>1 userdata.tealist=soundlist; end;

set(ht,'userdata',userdata);
start(ht);
function teatimecbx(cbobj,cbdata)

userdata=get(cbobj,'userdata');
mysound=userdata.teasound;
listfile=userdata.tealist;
ns=NaN;
nr=NaN;

if exist(listfile,'file')
    ss=file2str(listfile);
    ns=size(ss,1);
%should really set random seed at matlab startup
    cc=clock;
cc=round(cc(6));
    for ii=1:cc nr=randperm(ns);end;
    mysound=deblank(ss(nr(1),:));
%    disp(mysound);
end;

try
%disp(mysound);
    [y,sf]=wavread(mysound);
    soundsc(y,sf);
catch
    disp([ns nr(1)]);
    disp(mysound);
    disp(lasterr);
    for ii=1:10 beep;pause(0.5); end;

end;

startdelay=userdata.startdelay;

%in single-shot mode timer seems to stop after return from callback, so
%delete and create a new timer if necessary
%Other possibility would be to repeat with a fixed period

stop(cbobj);
delete(cbobj);

if ~isempty(startdelay)
    ht=timer('timerfcn',@teatimecbx,'startdelay',startdelay(1),'tag','tea');
    startdelay(1)=[];
    userdata.startdelay=startdelay;
    set(ht,'userdata',userdata);
    start(ht);
end;
