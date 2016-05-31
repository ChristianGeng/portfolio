function [xyindex,sf,timestamp,contourh,contourhv]=mt_gxycd(iarg)
% mt_gxycd Get data to prepare for xy contour display
% function [xyindex,sf,timestamp,contourh,contourhv]=mt_gxycd
% mt_gxycd: Version 6.12.2000
%
% Syntax
%     iarg: (optional) If present and true, prepare for mt_movie, otherwise for mt_shoco
%			mt_movie has the additional constraint that samplerates and timespecs must be same for all axes
%
% Description
%    Retrieves information on xy axes required by mt_shoco (and mt_movie) to do contour displays
%	  Information will not be returned on xy axes whose xy data is not from the current trial
%		or whose contour handles have been set to invalid (see mt_sfigd)

global MT_XYDATA
global MT_XYVDATA

imovie=0;
if nargin>0 imovie=iarg; end;

xyindex=[];sf=[];timestamp=[];contourh=[];contourhv=[];

myS=mt_gxyad;
if isempty(myS) return; end;

axislist=myS;
nax=size(axislist,1);
curh=mt_gfigd('xy_contour_handles');
curhv=mt_gfigd('xy_vector_handles');

if imovie
   curh=curh(:,3);
   curhv=curhv(:,3);
	ncon=1;   
else
   curh=curh(:,1:2);	%eliminate movie contour
   curhv=curhv(:,1:2);	%eliminate movie contour
	ncon=2;   
end;

itrial=mt_gtrid('number');


xyindex=zeros(nax,1);sf=zeros(nax,1);timestamp=zeros(nax,2);
contourh=ones(nax,ncon)*NaN;
contourhv=contourh;
trialn=zeros(nax,1);

for iax=1:nax
   myname=deblank(axislist(iax,:));
   xyindex(iax)=mt_gxyad(myname,'axis_number');
   tt=mt_gxyad(myname,'trial_number');
   if ~isempty(tt) trialn(iax)=tt; end;
   
   tt=mt_gxyad(myname,'samplerate');
   if ~isempty(tt) sf(iax)=tt;end;
   tt=mt_gxyad(myname,'time_spec');
   if ~isempty(tt) timestamp(iax,:)=tt;end;
   contourh(iax,:)=curh(xyindex(iax),:);
   vmode=mt_gxyad(myname,'v_mode');
   if ~(isempty(vmode) | strcmp(vmode,'none'))
      if size(MT_XYDATA{xyindex(iax),1},1)==size(MT_XYVDATA{xyindex(iax),1},1)
         contourhv(iax,:)=curhv(xyindex(iax),:);
      else
         disp('mt_gxycd: Unable to display vectors; xy data may need updating');
      end;
      
   end;
   
end;

vv=find((isnan(contourh(:,1)))| (trialn~=itrial));
if ~isempty(vv)
   xyindex(vv)=[];
   sf(vv)=[];
   timestamp(vv,:)=[];
   contourh(vv,:)=[];
   contourhv(vv,:)=[];
end;

if imovie
   if ~isempty(xyindex)
      ilim=0;
      if any(sf~=sf(1)) ilim=1;end;
      if any(timestamp(:,1)~=timestamp(1,1)) ilim=1;end;
      if any(timestamp(:,2)~=timestamp(1,2)) ilim=1;end;
      if ilim
         disp('mt_gxycd: Inconsistent data preparing for mt_movie. Only using first available axes');
         xyindex=xyindex(1);
      end;
      sf=sf(1);
      timestamp=timestamp(1,:);
   end;
end;
