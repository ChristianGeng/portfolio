function S=findsonixpulse(myfile,mythresh)
% FINDSONIXPULSE Find sync pulses in ultrasonix frame sync signal
% function S=findsonixpulse(myfile,mythresh)
% findsonixpulse: Version 12.03.2013
%
%   Syntax
%       myfile: specifiy without extension
%           first tries to load mat file.
%           if not present tries wav file (e.g. from AAA export)
%           Currently assumes only one channel in input file
%       mythresh: will depend on file and data type
%           in wav files 1 corresponds to fsd
%       S: struct with fields framerate, starttime, endtime, npulse,
%           jitterinsamples (should probably not normally be > 1)
%   Notes
%       It is assumed that the sonix synch pulses are output at the end of
%       each frame scan. Accordingly, the times returned in S.starttime and
%       S.endtime are the pulse time minus framelength/2. This means that
%       notional time of occurrence of an ultrasound frame then corresponds
%       to the time at which the central scanlines are being sampled
%       (strictly speaking this also assumes that the ultrasound is being
%       run at the maximum framerate possible for the chosen settings).

S=[];

fileok=0;
if exist([myfile '.mat'],'file')
    sf=mymatin(myfile,'samplerate');
    y=double(mymatin(myfile,'data'));
    fileok=1;
end;

if exist([myfile '.wav'],'file')
    [y,sf]=wavread([myfile '.wav']);
    fileok=1;
end;

if ~fileok
    disp(['findsonixpulse: Pulse file not found : ' myfile]);
    return;
end;

y1=y(2:end);
y2=y(1:(end-1));
vv=find(y1>mythresh & y2<=mythresh);
npulse=length(vv);
if npulse <2
    disp('findsonixpulse: not enough pulses');
    return;
end;

vv=vv/sf;
starttime=vv(1);
endtime=vv(end);
timediff=diff(vv);
plot(timediff);
maxd=max(timediff);
mind=min(timediff);
jitterinsamples=(maxd-mind)/(1/sf);
frameraterange=(1/mind)-(1/maxd);

frameinc=(endtime-starttime)/(npulse-1);
framerate=1/frameinc;

%probably should hardly ever be > 1
if jitterinsamples>3
    disp(['findsonixpulse: unstable pulse sequence? (framerate (Hz) and jitter (in samples)) ' num2str([framerate jitterinsamples])]);
    keyboard;
end;
S.framerate=framerate;
S.starttime=starttime-(frameinc/2);
S.endtime=endtime-(frameinc/2);
S.npulse=npulse;
%S.frameraterange=frameraterange;
S.jitterinsamples=jitterinsamples;
