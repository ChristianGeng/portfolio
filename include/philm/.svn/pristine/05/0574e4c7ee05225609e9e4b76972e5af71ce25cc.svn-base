function mytime=mt_findz(ichan,xdir,sdir,ithr,idif,sf,curh);
% MT_FINDZ Find zero crossing (and related thresholds) relative to active cursor
% function mytime=mt_findz(ichan,xdir,sdir,ithr,idif,sf,curh);
% mt_findz: Version 1.12.2004
%
%	Syntax
%		Not ready
%		All arguments compulsory! To try and speed things up a bit
%		xdir: Zero crossing direction. Data is multiplied by dir, so use 1 (default) for positive, and -1 for negative zero crossing
%		sdir: Search direction from active cursor ('>' or '<'). Default is '>'.
%				search region is bounded by the other cursor or screen start/end
%		ithr: threshold
%		idif: differentiation order
%		sf: sample rate of data
%		curh:	cursor handles
%
%   mytime: empty if no zerocrossings found
%
%	See also
%		FINDTH: general purpose threshold search
%
%	Remarks
%		Mainly intended to give quick zero crossing position for use with cursor
%		movement.
%		Differentiation not yet implemented
%		No checks on correct arguments

mytime=[];

%if nargin 
   mychan=ichan;
%else
%   mychan=mt_gcsid('audio_channel');
%end;

%mydir=1;
%if nargin>1 
   mydir=xdir; 
%end;

%mypos='>';
%check allowable operation....
%if nargin>2 
   mypos=sdir;
%end;

%mythr=0;
%if nargin>3 
   mythr=ithr; 
%end;


%sf=mt_gsigv(ichan,'samplerate');



%curh=mt_gcurh;
curp=mt_gcurp(curh);
curfree=mt_tcurs(curh,1);
ip=getfirst(find(curfree==1));

distim=mt_gdtim;
guktim=curp;

if ((ip==1)& strcmp(mypos,'<')) guktim=[distim(1) curp(1)];end;
if ((ip==2)& strcmp(mypos,'>')) guktim=[curp(2) distim(2)];end;



[y,actualtime]=mt_gdata(ichan,guktim);

y=y*mydir;


if idif>=1 
%    disp('differentiating')
    y=diff(y,idif); 
    
%    keyboard;
end;

mythr=mythr*mydir;

l=length(y);
if l<2 return;end;
ysh=y([2:l l]);
v=((ysh>=mythr)&(y<mythr));
v(1)=0;
v=find(v);
if ~isempty(v)
   if strcmp(mypos,'>')
      vi=v(1);
   else
      vi=v(end);
   end;
   %interpolate etc.
%   xvi=interp1q([y(vi);y(vi+1)],[vi;vi+1],mythr);
   mytime=actualtime(1)+((vi-1)./sf);
end;


