function G=getxsu(fid);
% GETXSU Get setup file of Sony Ex system
% function G=getxsu(fid);
% getxsu: Version 6.1.08
%
%   Notes
%       Not yet complete

tmp=fread(fid,15,'*uchar');
G.fileid=char(tmp');

tmp=fread(fid,1,'single');

G.fileversion=tmp;

%global settings

tmp=fread(fid,4,'int16');

G.frequencytype=tmp(1);
G.databits=tmp(2);
G.triggerstartcondition=tmp(3);
G.triggercount=tmp(4);

tmp=fread(fid,1,'double');

G.triggerstarttime=tmp;

tmp=fread(fid,1,'int32');
G.triggerintervaltime=tmp;

tmp=fread(fid,1,'int16');
G.triggerdurationtype=tmp;

tmp=fread(fid,1,'int32');
G.triggerdurationlength=tmp;

tmp=fread(fid,1,'int16');
G.interval2trigger=tmp;

%apparently logical (boolean)
tmp=fread(fid,1,'int32');
G.panellock=tmp;

tmp=fread(fid,3,'int16');
G.fanmode=tmp(1);
G.ILinkspeed=tmp(2);

%maybe not really needed in the struct
tmpl=tmp(3);
G.homedirlength=tmpl;

tmp=fread(fid,tmpl,'*uchar');
G.homedir=char(tmp');

tmp=fread(fid,1,'int16');
G.dateformat=tmp;

tmp=fread(fid,1,'single');
G.noisefloor=tmp;

tmp=fread(fid,5,'int16');
G.fftpower=tmp(1);
G.fftwindow=tmp(2);
G.fftoverlap=tmp(3);
G.octavefraction=tmp(4);
G.cumavemeth=tmp(5);

tmp=fread(fid,2,'single');
G.cumexpn=tmp(1);
G.cumdecaytime=tmp(2);

tmp=fread(fid,1,'int16');
G.maxcumproc=tmp;

%logical
tmp=fread(fid,2,'int32');
G.recordtimedata=tmp(1);
G.recordfreqdata=tmp(1);

