function prompter_iniag500fig
% prompter_iniag500fig Set up ag500/ag501 control and status monitoring
% function prompter_iniag500fig 
% prompter_iniag500fig Version 11.11.2012
%
%   Description
%       Initalize figure for status monitoring and set up data structure
%       with AG settings
%       settings accessible with prompter_gagd/sagd
%
%       usesybox [0, but 1 if parallelinmode (prompter_gmaind) is 'AG500']
%           If 0, detection of sweep start and end is handled via the tcpip
%           connection
%       monitorinterval [1/20]
%       attn2sweep [0.1] Read only
%       attn_timeout [10]
%       sweep_timout [5]
%       attn2sweeptooslow_msg ['!!Program too slow between attention and
%       sweep !!']
%       attntimebase [1]
%       agtriggermode ['tcpip']
%           set to 'manual' if AG recording is to be started and stopped by
%           hand on the control server, and not using tcpip link from the
%           prompter program
%           If set to manual then probably usesybox must be 1
%           To set to manual, use this in the struct used to initialize the
%           main program:
%           P.useragsetfunc='prompter_sagd(''agtriggermode'',''manual'')'
%       Alines (read only: names of the status lines from sybox)
%       linehandle (read only: handles to line objects for display of status of sybox lines)
%       statbuf (read only: status of sybox lines)
%           arranged currentvalue, changestatus, holdvalue, lastvalue
%       Further fields contain the current values of the tcpip data stream

P=prompter_gmaind;

usesybox=0;
if strcmp(P.parallelinmode,'AG500') usesybox=1; end;
hfs=figure;
figname='AG500mon';
set(hfs,'name',figname);
AG.usesybox=usesybox;
%some of this settings are irrelevant if sybox not in use
AG.monitorinterval=1/20;      %i.e try and monitor 20 times per second (see timer period below)

%is this ever used
AG.attn2sweep=0.1;     %syncbox delay from attention to start of sweep

%8.10 added sweep_timout
AG.attn_timeout=10;    %return to command input if no attention signal after starting "next" command
AG.sweep_timeout=5;	%not clear why this is necessary, assuming attention has been correctly detected

%could be worth changing if e.g. userattnfunc is bound to cause this
%condition
AG.attn2sweeptooslow_msg='!!Program too slow between attention and sweep !!';

AG.attntimebase=1;      %work out position in trial from attention signal rather than sweep signal
AG.agtriggermode='tcpip';

nstat=4;
agstat=repmat(0,[1 nstat]);
ag500names='';

if usesybox
%create 2 line objects; one for current state, one for change indicator
%display will be toggled on off by manipulating NaNs in xdata
    ag500names=prompter_parallelinctl('getlinenames');
    agstat=prompter_parallelinctl('readlines');
    nstat=size(ag500names,1);
end;
    AG.Alines=desc2struct(ag500names);

hlstat=plot(ones(nstat,2)*NaN,repmat([1 2],[nstat 1]));
set(hlstat(1),'color','g','linestyle','none','marker','o','markerfacecolor','g','markersize',12);
set(hlstat(2),'color','r','linestyle','none','marker','o','markerfacecolor','r','markersize',12);

set(hlstat,'erasemode','xor');

set(hfs,'doublebuffer','on');
%set(hfs,'sharecolors','off');      %seems to no longer be in use

set(gca,'ylim',[0 length(hlstat)+1],'xlim',[0 nstat+1]);

set(gca,'ytick',[1 2]);
set(gca,'yticklabel',str2mat('current','change'));

set(gca,'xtick',1:nstat,'xticklabel',ag500names);
title('AG500 Monitor. All signals active green');

%arranged currentvalue, changestatus, holdvalue, lastvalue
statbuf=logical(zeros(4,nstat));
statbuf(1,:)=agstat;
statbuf(3,:)=agstat;
statbuf(4,:)=~agstat;       %trigger first display?

AG.linehandle=hlstat;
AG.statbuf=statbuf;
AG.socket=[];
set(hfs,'userdata',AG);

figlist=prompter_gmaind('figure_names');
figlist=str2mat(figlist,figname);
prompter_smaind('figure_names',figlist);
%set(hlstat(1),'userdata',statbuf);
myfunc=prompter_gmaind('useragsetfunc');
prompter_evaluserfunc(myfunc,'agset');
