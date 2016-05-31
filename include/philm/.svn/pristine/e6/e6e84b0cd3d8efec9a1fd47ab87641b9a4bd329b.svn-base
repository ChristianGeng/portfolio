function mt_setft(siglist,suffmode,sufflen,spacefac,minstem);
% MT_SETFT Set up time display
% function mt_setft(siglist,suffmode,sufflen,spacefac,minstem);
% mt_setft: Version 21.3.02
%
%	Syntax
%		siglist: The list of signals to display (string matrix)
%		The remaining arguments are optional and are used to determine the colour scheme
%		If absent or empty, default values are used.
%		suffmode: Set to 'suffix' (default) or 'stem'.
%			Determines whether signals are grouped by suffix or stem
%			When grouped by suffix all signals with the same suffix have a similar colour
%			while signals with the same stem have a contrasting colour
%			When grouped by stem the procedure is reversed
%			Grouping by suffix is default, and gives best results when signals with the same
%			stem are adjacent on the screen. This is also the appropriate setting when
%			axes are paired: See MT_SFTLR
%		sufflen: Determines where to split the signal name into stem and suffix
%			Positive values make the split after the nth character from the beginnig;
%			Negative values make the split before the nth character from the end.
%			default=-1
%			The appropriate choice will depend on whether the signal names are more conveniently
%			regarded as having a fixed length stem or a fixed length suffix
%		spacefac: Adjusts the amount of similarity in colour within the grouped signals.
%			0 means that grouping has no effect. The higher the value, the more similar the colour
%			of the grouped signals will be. Default = 2.
%		minstem: Minimum length of stem. Gives some additional control in unusual cases,
%			where a signal name terminates in a string that looks like a suffix, but actually isn't.
%			Default=1
%
%	Description
%		Set up time display for list of signals. One axis (and panel) per signal
%		Initially axis tag and line tag are same = signal name
%		Use separate function to juggle axis positions and assignment of signals to axes
%		Should be extended to allow replace, add and delete modes
%		If no input argument, uses all signals
%		Tries to retain signal pairs
%
%	See also
%		MT_SHOFT MT_GETFT MT_NEWFT MT_SFTLR MT_GSIGV MT_GCSID


%if same signal occurs multiple times we need a suffix for the axis tag
% (display in axis title??)
% and then need to decide whether activation is based on axes or signals

%assume figure initialized by mt_org

oldfigh=gcf;
figh=mt_gfigh('mt_f(t)');
figure(figh);

myS=mt_getft;
oldaxes=myS.axis_name;

doini=0;
docolours=0;
if isempty(oldaxes)
   doini=1;
   docolours=1;   
end;

%handle colour scheme defaults
suffm='suffix';
suffl=-1;
spacef=2;
minst=1;

colouronly=0;
if nargin>1 
   docolours=1;
   if isempty(siglist) colouronly=1;end;
   suffm=suffmode;
   if nargin>2
      suffl=sufflen;
   if nargin>3
      spacef=spacefac;
      if nargin>4
         minst=minstem;
      end;
      
      end;
   end;
end;





activelist='';
if nargin activelist=siglist; end;



if doini
   %initialize using all signals
   
   siglist=mt_gcsid('signal_list');
   
%keyboard;   
   %eliminate non-scalar signals
   mycols=mt_gsigv(siglist,'mat_column');
   vscalar=find(mycols~=0);
   if length(mycols)>length(vscalar)
      disp('mt_setft: Skipping non-scalar signals');
   end;
   
   if isempty(vscalar)
      disp('mt_setft: No scalar signals???');
      %any more tidying up ????
      return
   end;
   
   siglist=siglist(vscalar,:);
   nchan=size(siglist,1);
   
   axpos=subp_pos(nchan);
   
   
   %axes names will be same as osci names unless same signal plotted twice
   axislist=siglist;
   panellist=(1:nchan)';
   activeflag=zeros(nchan,1);
   
   
   %===========================
   %graphics initialization
   %===========================
   
   for ichan=1:nchan
      
      chanstring=deblank(siglist(ichan,:));
      axish(ichan)=axes;
      set (axish(ichan),'tag',deblank(axislist(ichan,:)),'position',axpos(ichan,:));
      %create line object for oscillogram, ev. other props. like colour, linetype
      %erase mode xor doesn't work if line segments overlap
      %      osch(ichan)=line('EraseMode','background','Color',chancol(mycol,:));
      %colour is done below
      osch(ichan)=line('EraseMode','background');
      set (osch(ichan),'tag',chanstring);
      myunit=deblank(mt_gsigv(chanstring,'unit'));
      lab=[chanstring ' (' myunit ')'];
      %      ylabel(lab,'color',chancol(mycol,:),'interpreter','none');
      %	colour is done below
%      ylabel(lab,'interpreter','none');
      ylabel(myunit,'interpreter','none');
%   title with blanks to keep separate if axes are paired
      title([' ' chanstring ' '],'interpreter','none','fontweight','bold','horizontal','right','vertical','top');
%      htmp=get(gca,'title');
%      set(htmp,'visible','off');        %may be useful eventually
      %   if (ichan~=nchan) set (axish(ichan),'XTickLabel',[]); end
      set (axish(ichan),'XTickLabel',[]);
      % end of axis generation loop
   end
   
   myS.signal_name=siglist;
   myS.axis_name=axislist;
   myS.panel_number=panellist;
   myS.active_flag=activeflag;
   myS.pair_list=[];
   set(figh,'userdata',myS);
   
end;


%not initialization
%maybe eventually merge with mt_sftlr
% at least try and preserve paired panels across changes in choice of signals

siglist=myS.signal_name;
axislist=myS.axis_name;
panellist=myS.panel_number;
activeflag=myS.active_flag;

nall=length(activeflag);
oldactive=activeflag;
activeflag(:)=0;
panellist(:)=0;
if isempty(activelist)
   activeflag(:)=1;
   panellist=(1:nall)';
else
   nin=size(activelist,1);
   pcount=0;
   for ii=1:nin
      vv=strmatch(deblank(activelist(ii,:)),axislist,'exact');		%note: using axis list rather than signal list (currently the same anyway)
      if length(vv)~=1
         disp('mt_setft: Bad choice of time signals??');
         disp(activelist(ii,:));
      else
         activeflag(vv)=1;
         pcount=pcount+1;
         panellist(vv)=pcount;
      end;
   end;
end;

nchan=sum(activeflag);

if nchan==0
   disp('mt_setft: No active signals?? Current settings not changed');
   figure(oldfigh);         
   return;
end;


%work out colour scheme for all signals, regardless of how many are to be displayed
if docolours
   chancol=getchancol(siglist,suffm,suffl,spacef,minst);
end;




%oscillogram y label fontsize
ylabelsize=[20 18 14 12 10 10 10 10 8 8 8 8 6 ];
nx=length(ylabelsize);
fontsize=ylabelsize(min([nchan nx]));

%loop to activate/deactivate channels

axpos=subp_pos(nchan);
ichange=abs(oldactive-activeflag);
for ii=1:nall
   myax=findobj(figh,'type','axes','tag',deblank(axislist(ii,:)));
   mychild=get(myax,'children');
   hlab=get(myax,'ylabel');
   htit=get(myax,'title');
   
   %do colours regardless of whether signal is to be displayed
   %since choice of signals may be changed later without changing the
   %colour scheme
   if docolours
      %for the moment assume all children are oscillograms and get the same colour
      set(mychild,'color',chancol(ii,:));
      set(hlab,'color',chancol(ii,:));
      set(htit,'color',chancol(ii,:));
   end;
   
   if ~colouronly
      
      if activeflag(ii)
         
         set(myax,'visible','on');
         set(mychild,'visible','on');
         %axis location needed in case called after mt_sftlr
         set(myax,'position',axpos(panellist(ii),:),'yaxislocation','left');            
         
         set(hlab,'fontsize',fontsize);
         set(htit,'fontsize',fontsize);
         
         %      		keyboard;   
      else
         
         set(myax,'visible','off');	%also set dummy position??
         set(mychild,'visible','off');
         
      end;
      
   end;		%not colour only   
end;		%activation loop         


if colouronly
   figure(oldfigh);
   return;
end;



%adjust position of cursor axis
pos1=axpos(1,:);
posn=axpos(nchan,:);

%if doing it this way, need to use axis with highest panel number, rather than nchan
%pos1=get(axish(1),'position');
%posn=get(axish(nchan),'position');
axispos=[posn(1) posn(2) posn(3) pos1(2)-posn(2)+pos1(4)];

axiscurh=findobj(figh,'tag','cursor_axis');

set(axiscurh,'position',axispos);


%set up figure userdata
%userdata has list of signalnames, axisnames and panel numbers
%9.98 and sub_cut_flag and newdata flag, cf. mt_inixy
%10.01 and active_flag

myS.signal_name=siglist;
myS.axis_name=axislist;
myS.panel_number=panellist;
myS.active_flag=activeflag;
set(figh,'userdata',myS);
mt_newft(1);

%try and restore pairs
mypairs=myS.pair_list;
if ~isempty(mypairs)
   mt_sftlr(mypairs{1},mypairs{2})
end;




figure(oldfigh);

function chancol=getchancol(siglist,suffm,suffl,spacef,minst)

%default, match suffixes

colnum=coloursigs(siglist,suffm,suffl,spacef,minst);
maxcol=max(colnum);

mymap=hsv(maxcol);

chancol=mymap(colnum,:);

%red and green are cursor colours, so adjust slightly to avoid clash
%strictly get the cursor colours to check
lcol=size(chancol,1);
cadj=1/((lcol+1)*2);

vv=find(all((chancol==repmat([1 0 0],[lcol 1]))'));

if length(vv)==1 
   chancol(vv,:)=[1-cadj cadj cadj];
end;

vv=find(all((chancol==repmat([0 1 0],[lcol 1]))'));

if length(vv)==1 
   chancol(vv,:)=[cadj 1-cadj cadj];
end;

function chancol=getchancolold(nchan)
%oscillogram colours
%ensuring large contrast between neighbouring signals

chancol=1-hsv(nchan+2);		%allow for possible elimination of red and green

%red and green are cursor colours, so remove
%strictly get the cursor colours to check
lcol=size(chancol,1);
vv=find(all((chancol==repmat([1 0 0],[lcol 1]))'));

if ~isempty(vv) 
   chancol(vv,:)=[];
end;

lcol=size(chancol,1);
vv=find(all((chancol==repmat([0 1 0],[lcol 1]))'));

if ~isempty(vv) 
   chancol(vv,:)=[];
end;

%keyboard;

lcol=size(chancol,1);

ncol0=ceil(lcol/2);
ncol1=ncol0*2;
nvv=[1:ncol0;(ncol0+1):ncol1];
nvv=nvv(:);
nvv=nvv(1:lcol);

chancol=chancol(nvv,:);
