function [brightlist,samplerate]=getsyncbu_v(aviname,Sin)
% GETSYNCBU_V Get frame numbers of video marked by sync bright up
% function [brightlist,samplerate]=getsyncbu_v(aviname,Sin)
% getsyncbu_v: Version 11.3.2013
%
%   Description
%       Sin not yet used. Will be needed to override default settings
%
%   Syntax
%       List of fields (numbered from 1) marked by brightup unit
%       samplerate: Simply copied from avi header and multiplied by 2 for
%       frame to field conversion. For information only. Precise samplerate
%       should be taken from analysis of audio track (see getsyncbu_a)
%
%   See Also GETSYCNBU_A

S=[];
if nargin>1 S=Sin; end;

brightlist=[];
samplerate=[];
if ~exist([aviname '.avi'],'file')
    disp('avi file not found?');
    disp(aviname);
    return;
end;

vo=videoreader([aviname '.avi']);
data=read(vo);
V=get(vo);

firstfield=1;
iplane=1;
colrange=100:180;
rowrange=50:100;
bu_thresh=220;

nbfield=4;      %number of fields that should be marked
data=squeeze(data(rowrange,colrange,iplane,:));

data=deinterlace(data,firstfield);
nfield=size(data,3);
blist=zeros(nfield,1);
for ii=1:nfield
    x=data(:,:,ii);
    if mean(x(:))>bu_thresh
        blist(ii)=1;
    end;
end;
brightlist=find(blist);
if length(brightlist)~=nbfield
    disp('Unexpected number of marked fields');
end;
%probably means field order should be flipped
if any(diff(brightlist)) ~=1
    disp('Marked fields not adjacent?');
    keyboard;
end;

samplerate=V.FrameRate*2;       %after conversion to fields
mytimes=(brightlist-1)/samplerate;
%disp(mytimes');

