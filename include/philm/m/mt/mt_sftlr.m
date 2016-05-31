function mt_sftlr(axlistl,axlistr,lrcol);
% MT_SFTLR Set up overlapping left/right axes in time display
% function mt_sftlr(axlistl,axlistr,lrcol);
% mt_sftlr: Version 26.03.02
%
%	Syntax
%		1st 2 args. Compulsory matching list of already existing axes.
%			No pairing is done if any member of a pair is not active
%			i.e if necessary, axes (signals) must first be activated with MT_SETFT
%		3rd arg. optional. 2-element string to specify colour of left and
%			right y axis labels (and corresponding oscis). Otherwise colours left unchanged
%		If there are no input arguments, or if the first two are both empty, then axis pairing
%		is turned off.
%
%	See Also MT_SETFT

figh=mt_gfigh('mt_f(t)');

myS=mt_getft;

axislist=myS.axis_name;

doreset=0;
if ~nargin doreset=1; end;

if nargin==1;
   disp('mt_sftlr: Wrong number of arguments');
   return
end;


if nargin>=2
   nl=size(axlistl,1);nr=size(axlistr,1);
   if nl==0 doreset=1; end;
   if nl~=nr
      disp('mt_sftlr: unequal axes lists');
      return;
   end;
end;



%if both empty?? reset to no l/r overlap
%ie mt_setft with complete signal list??

if doreset
   myS.pair_list=[];
   set(figh,'userdata',myS);
   mt_setft(axislist);
   return;
end;

checklist=unique(str2mat(axlistr,axlistl),'rows');
if size(checklist,1)~=(nl+nr)
   disp('left/right lists not unique');
   return
end;

fixcol=0;
if nargin>2
   if length(lrcol)==2
      if isstr(lrcol)
         fixcol=1;
      end;
   end;
end;

axislist=myS.axis_name;
activeflag=myS.active_flag;

%check for legal signal names and whether paired signals are active
% if either member of a pair is not active the pairing is not made
% leave already active unpaired signals active

%in pairflag, 1=single, 2=left, 3=right  (0= not active
pairflag=activeflag;

vpweg=[];

for ii=1:nl
   vvl=strmatch(deblank(axlistl(ii,:)),axislist,'exact');
   if length(vvl)~=1
      disp(['mt_sftlr: Unknown axis name (left) : ' axlistl(ii,:)]);
      disp('Signal arrangement not changed');
      return;
   end;
   vvr=strmatch(deblank(axlistr(ii,:)),axislist,'exact');
   if length(vvr)~=1
      disp(['mt_sftlr: Unknown axis name (right) : ' axlistr(ii,:)]);
      disp('Signal arrangement not changed');
      return;
   end;
   
   if ((activeflag(vvl)==0) | (activeflag(vvr)==0))
      vpweg=[vpweg ii];
   else
      pairflag(vvl)=2;
      pairflag(vvr)=3;
   end;
end;

%store the complete list, even if not currently active
% then the pair will be displayed if the signals are made active again

lout=axlistl;
rout=axlistr;


if ~isempty(vpweg)
   axlistl(vpweg,:)=[];
   axlistr(vpweg,:)=[];
   
end;

nr=size(axlistr,1);	%adjust

nchan=length(activeflag);   



%totax=size(axislist,1);
totalactive=sum(activeflag);
npanel=totalactive-nr;


ppbase=npanel-nr;		%pair panels start at ppbase+1 (single panels start at 1)


axpos=subp_pos(npanel);


%figh=mt_gfigh('mt_f(t)'); done at beginning
figure(figh);            
%===========================
%oscillogram y label fontsize
%should be same as mt_setft

ylabelsize=[20 18 14 12 10 10 10 10 8 8 8 8 6 ];
nx=length(ylabelsize);
fontsize=ylabelsize(min([npanel nx]));

newpanel=zeros(nchan,1);

spcount=0;

for ii=1:nchan
   axname=deblank(axislist(ii,:));
   colind=0;
   ipanel=0;
   
   %order of single panels may get changed
   %need to use old order of single panels in panellist
   
   if pairflag(ii)==1
      spcount=spcount+1;
      ipanel=spcount;
      yal='left';
      colind=0;      
   end;
   
   if pairflag(ii)==2
      
      jj=strmatch(axname,axlistl,'exact');
      rightname=deblank(axlistr(jj,:));
      rightp=strmatch(rightname,axislist,'exact');
      spcount=spcount+1;
      ipanel=spcount;
      yal='left';
      if fixcol colind=1; end;   
   end;
   
   
   if ipanel
      newpanel(ii)=ipanel;
      ha=findobj(figh,'tag',axname,'type','axes');
      set(ha,'position',axpos(ipanel,:),'yaxislocation',yal,'visible','on');
      hlab=get(ha,'ylabel');
      set(hlab,'fontsize',fontsize);
      htit=get(ha,'title');
      set(htit,'fontsize',fontsize,'horizontal','right');
      
      hosc=findobj(ha,'type','line');
      set(hosc,'visible','on');   
      
      
      %set label colour????
      if colind
         set(hlab,'color',lrcol(colind));
         set(htit,'color',lrcol(colind));
         set(hosc,'color',lrcol(colind));
      end;
      
      %repeat for right axes
      if pairflag(ii)==2
         
         newpanel(rightp)=ipanel;
         ha=findobj(figh,'tag',rightname,'type','axes');
         set(ha,'position',axpos(ipanel,:),'yaxislocation','right','visible','on');
         hlab=get(ha,'ylabel');
         set(hlab,'fontsize',fontsize);
      htit=get(ha,'title');
      set(htit,'fontsize',fontsize,'horizontal','left');
         
         hosc=findobj(ha,'type','line');
         set(hosc,'visible','on');   
         
         
         %set label colour????
         if colind
            set(hlab,'color',lrcol(2));
            set(htit,'color',lrcol(2));
            set(hosc,'color',lrcol(2));
         end;
         
      end;		%pairflag 2, do right axes
      
      
      
   end;
   
end;
%channel loop


pos1=axpos(1,:);
posn=axpos(npanel,:);

axispos=[posn(1) posn(2) posn(3) pos1(2)-posn(2)+pos1(4)];

%adjust position of cursor axis
%pos1=get(hlist(1),'position');
%posn=get(hlist(npanel),'position');

axiscurh=findobj(figh,'tag','cursor_axis');

set(axiscurh,'position',axispos);


%set up figure userdata
%userdata has list of signalnames, axisnames and panel numbers
% 3.2002 and the pair lists
myS.panel_number=newpanel;
myS.active_flag=activeflag;

paircell=cell(1,2);
paircell{1}=lout;
paircell{2}=rout;

myS.pair_list=paircell;



set(figh,'userdata',myS);
mt_newft(1);
