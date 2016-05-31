function [axnames,xyindex,sf,timestamp,contourh]=mt_gvideocd(iarg)
% mt_gvideocd Get data to prepare for video
% function [axnames,xyindex,sf,timestamp,contourh]=mt_gvideocd(iarg)
% mt_gvideocd: Version 02.04.2012
%
%   Syntax
%     iarg: (optional) If present and true, timestamps and samplerates must
%     be same for all signals, and only this common timestamp and
%     samplerate is returned.
%       Otherwise separate samplerates etc. are returned for each signal
%		xyindex: Signal number
%		timestamp: start and end of available video data
%		contourh:	handle of image object
%
%   Description
%       Retrieves information on video axes required by mt_??? (and
%       mt_video) to do video displays.
%       Information will not be returned on video axes whose display flag is disabled
%
%   Updates
%       03.2012 compatible with true color data
%       04.2012 Note on usage: mt_video now called without input argument,
%       i.e. no constraints on samplerates and timestamps
%       old programs like mt_video2tif are still restricted, like the older
%       version of mt_video

imovie=0;
if nargin>0 imovie=iarg; end;

axnames='';xyindex=[];sf=[];timestamp=[];contourh=[];


figh=mt_gfigh('mt_video');
if isempty(figh) return; end;

fS=get(figh,'userdata');



%myS=mt_gxyad;
%if isempty(myS) return; end;

axislist=fS.axis_names;
displayflag=fS.display_flag;

axislist=axislist((displayflag==1),:);
if isempty(axislist) return; end;

nax=size(axislist,1);



xyindex=zeros(nax,1);sf=zeros(nax,1);timestamp=zeros(nax,2);contourh=zeros(nax,1);

for iax=1:nax
   myname=deblank(axislist(iax,:));
   xyindex(iax)=mt_gvideoad(myname,'signal_number');
	signame=mt_gvideoad(myname,'signal_name');   
   tt=mt_gvideoad(myname,'samplerate');
   
   
   if ~isempty(tt) sf(iax)=tt;end;
   t0=mt_gsigv(signame,'t0');
   dsize=mt_gsigv(signame,'data_size');
   
%03.2012. make sure truecolor data is handled correctly
   %if length not 3 or 4, means trial not available, cf. mt_loadt
   timestamp(iax,1)=t0;
   if length(dsize)>=3
   timestamp(iax,2)=t0+(dsize(end)-1)/sf(iax);
else
   
   disp('mt_gvideocd: Trial not available'); 
   %should block any attempt to display this signal
   timestamp(iax,:)=[-1 -1];
end;

   contourh(iax)=findobj(figh,'tag',myname,'type','image');
end;

if imovie
   if ~isempty(xyindex)
      ilim=0;
      if any(sf~=sf(1)) ilim=1;end;
      if any(timestamp(:,1)~=timestamp(1,1)) ilim=1;end;
      if any(timestamp(:,2)~=timestamp(1,2)) ilim=1;end;
      if ilim
         disp('mt_gvideocd: Inconsistent data preparing for mt_video. Only using first available axes');
         xyindex=xyindex(1);
         contourh=contourh(1);
         axislist=axislist(1,:);
      end;
      sf=sf(1);
      timestamp=timestamp(1,:);
   end;
end;
axnames=axislist;
