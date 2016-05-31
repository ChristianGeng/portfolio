function mt_setft(siglist);
% MT_SETFT Set up time display
% function mt_setft(siglist);
% mt_setft: Version 15.4.99
%
%	Description
%		Set up time display for list of signals. One axis (and panel) per signal
%		Initially axis tag and line tag are same = signal name
%		Use separate function to juggle axis positions and assignment of signals to axes
%		Should be extended to allow replace, add and delete modes
%		If no input argument, uses all signals
%
%	See also
%		MT_SHOFT MT_GETFT MT_NEWFT MT_GSIGV MT_GCSID


%if same signal occurs multiple times we need a suffix for the axis tag
% (display in axis title??)


%oscillogram colours
chancol='ymc';
lcol=length(chancol);


%assume initialized by mt_org

oldfigh=gcf;
figh=mt_gfigh('mt_f(t)');
figure(figh);

myS=mt_getft;
oldaxes=myS.axis_name;

allsigs=mt_gcsid('signal_list');

if nargin==0 siglist=allsigs;end;

%eliminate non-scalar signals
mycols=mt_gsigv(siglist,'mat_column');
vscalar=find(mycols~=0);
if length(mycols)>length(vscalar)
disp('mt_setft: Skipping non-scalar signals');
end;

if ~isempty(vscalar)
siglist=siglist(vscalar,:);
nchan=size(siglist,1);

axpos=subp_pos(nchan);


%axes names will be same as osci names unless same signal plotted twice
axislist=siglist;
panellist=(1:nchan)';


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

%keyboard;

for ichan=1:nchan
   
   chanstring=deblank(siglist(ichan,:));
   %make sure signal is available
   iguk=strmatch(chanstring,allsigs,'exact');
   if isempty(iguk)
      disp(['mt_setft: Bad signal name? ' chanstring]);
      %may need some tidying up
      figure(oldfigh);
      return;
   end;
end;

%delete any old axes
if ~isempty(oldaxes)
   ll=size(oldaxes,1);
   hdel=zeros(ll,1);
   for ii=1:ll
      hdel(ii)=findobj(figh,'type','axes','tag',deblank(oldaxes(ii,:)));
   end;
   hdel=unique(hdel);
   delete(hdel);
end;



%===========================
%graphics initialization
%===========================
%oscillogram y label fontsize
ylabelsize=[20 18 14 12 10 10 10 10 8 8 8 8 6 ];
nx=length(ylabelsize);
fontsize=ylabelsize(min([nchan nx]));

for ichan=1:nchan
   
   chanstring=deblank(siglist(ichan,:));
   axish(ichan)=axes;
   set (axish(ichan),'tag',deblank(axislist(ichan,:)),'position',axpos(ichan,:));
   %create line object for oscillogram, ev. other props. like colour, linetype
   %erase mode xor doesn't work if line segments overlap
   %use array for color spec
%   mycol=rem(ichan,lcol)+1;
   mycol=ichan;
   osch(ichan)=line('EraseMode','background','Color',chancol(mycol,:));
   set (osch(ichan),'tag',chanstring);
   myunit=deblank(mt_gsigv(chanstring,'unit'));
   lab=[chanstring ' (' myunit ')'];
   ylabel(lab,'color',chancol(mycol,:),'fontsize',fontsize,'interpreter','none');
   title(chanstring);
   htmp=get(gca,'title');
   set(htmp,'visible','off');        %may be useful eventually
%   if (ichan~=nchan) set (axish(ichan),'XTickLabel',[]); end
   set (axish(ichan),'XTickLabel',[]);
   % end of axis generation loop
end

%adjust position of cursor axis
pos1=get(axish(1),'position');
posn=get(axish(nchan),'position');
axispos=[posn(1) posn(2) posn(3) pos1(2)-posn(2)+pos1(4)];

axiscurh=findobj(figh,'tag','cursor_axis');

set(axiscurh,'position',axispos);


%set up figure userdata
%userdata has list of signalnames, axisnames and panel numbers
%9.98 and sub_cut_flag and newdata flag, cf. mt_inixy
myS.signal_name=siglist;
myS.axis_name=axislist;
myS.panel_number=panellist;

set(figh,'userdata',myS);
mt_newft(1);

end;		%no scalar signals

figure(oldfigh);
