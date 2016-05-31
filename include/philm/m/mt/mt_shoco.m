function newindex=mt_shoco(xyindex,sf,timestamp,contourhb,contourhbv,timelist,oldindexb)
% mt_shoco Show contours in x/y display
% function newindex=mt_shoco(xyindex,sf,timestamp,contourhb,contourhbv,timelist,oldindexb)
% mt_shoco: Version 31.7.2003
%
% Syntax
%   xyindex: Number of each xy axis, for indexing into MT_XYDATA
%				vector, same length as sf, same number of rows as contourhb
%   sf: vector of sample rates; needed for indexing into the data arrays at arbitrary times
%   timestamp: Matrix of start and end times (of xy data) relative to start of trial
%   contourhb:  Handles of line objects to show contours; 1 row per axis. Usually 2 columns(left and right contours)
%   contourhbv:  Handles of line objects to show sensor vectors (velocity, orientation); 1 row per axis. Usually 2 columns(left and right contours)
%   timelist: List of times relative to start of trial at which to show contours
%             Row vector, must have same number of columns as contourhb.
%   next 2 args. are intended to help avoid superfluous graphics activity
%   oldindexb: indices into data buffers of last contours   (optional)
%              should be reset to a negative number of data buffers have changed since last call
%              This is also done if the argument is missing
%              Must have same number of columns as timelist and contourhb
%					and same number of rows as contourhb
%   newindex: indices into data buffers of current contours
%             0 means requested time not in data buffer
%
% Description
%   Show contours in xy display at specified times.
%		This routine should be used in conjunction with mt_gxycd.
%		mt_shoco doesn't do many checks.
%
% See also
% mt_xydis for xy display, mt_sxyad etc. setup; mt_gxycd. mt_movie

global MT_XYDATA
global MT_XYVDATA


lf=length(timelist);
nax=length(xyindex);

if size(timestamp,1)~=nax
    timestamp=repmat(timestamp(1,:),[nax 1]);
end;
if length(sf)~=nax
    sf=repmat(sf(1),[nax 1]);
end;

if nargin<7
   oldindexb=ones(nax,lf)*(-1);
end;
newindex=zeros(nax,lf);

for iax=1:nax
	axnum=xyindex(iax);   
   [ndat,ntraj]=size(MT_XYDATA{axnum,1});
   oldindex=oldindexb(iax,:);
   contourh=contourhb(iax,:);
   contourhv=contourhbv(iax,:);
   
   %determine buffer index from timelist
%disp(['mt_shoco ' int2str(iax)])
%   keyboard;
   framen=timelist-timestamp(iax,1);
   framen=round(framen*sf(iax));
   framen=framen+1;
   %        disp(ndat);
   %        disp(framen);
   
   voff=find((framen<=0) | (framen>ndat));
   if ~isempty(voff)
      ll=length(voff);
      framen(voff)=zeros(1,ll);
   end;
   
   %try and avoid superfluous graphics actions
   
   for ii=1:lf
      if oldindex(ii)~=framen(ii)
         dovec=~isnan(contourhv(ii));
         if framen(ii)==0
            set(contourh(ii),'visible','off');
            if dovec set(contourhv(ii),'visible','off');end;
         else
            ipp=framen(ii);
            set(contourh(ii),'xdata',MT_XYDATA{axnum,1}(ipp,:),'ydata',MT_XYDATA{axnum,2}(ipp,:),'zdata',MT_XYDATA{axnum,3}(ipp,:));
            if oldindex(ii)<=0 set(contourh(ii),'visible','on');end;
            if dovec
            set(contourhv(ii),'xdata',MT_XYVDATA{axnum,1}(ipp,:),'ydata',MT_XYVDATA{axnum,2}(ipp,:),'zdata',MT_XYVDATA{axnum,3}(ipp,:));
            if oldindex(ii)<=0 set(contourhv(ii),'visible','on');end;
            end;
         end;
      end;
   end;
   newindex(iax,:)=framen;
end;		%axes
drawnow;
