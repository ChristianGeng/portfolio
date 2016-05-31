function prompter_parallel_trigagmain(stimfile,logfile,S);
% PROMPTER_PARALLEL_TRIGAGMAIN Prompt program, controlling AG500 via TCPIP and monitoring via parallel port
% function prompter_parallel_trigagmain(stimfile,logfile,S);
% prompter_parallel_trigagmain: Version 28.02.2013
%
%	Syntax
%       stimfile and logfile are required input arguments.
%       S is optional. If present it must be a struct whose fields control
%       optional settings (override defaults).
%       See prompter_ini_base for full details on the fields.
%
%   Description
%		This version uses lida_connect, getemaall and togglestatus in  phil\3dnew\lida\matlab
%		This directory must be added to matlab's path (with any local
%		prefix in the full path name)
%		Also, in order to access the underlying java functions for tcpip
%		the following java path should be placed in startup.m
%		javaaddpath([localprefix 'Phil/3dnew/lida/java/recmon/dist/recmon.jar']);
%
%   See Also PROMPTER_PARALLEL_TRIGIN, PROMPTER_PARALLEL_TRIGAG
%

%needed for tcip socket
import java.io.*;
import java.net.*;

functionname='PROMPTER_PARALLEL_TRIGAGMAIN: Version 28.02.2013';

Sin=[];
if nargin>2 Sin=S; end;

prompter_ini_base(functionname,stimfile,logfile,Sin)

parport=prompter_getparport;
prompter_paralleloutctl('ini',parport);
P=prompter_gmaind;
P.parallelinmode='AG500';
%P.irun='';  %overwrite default from prompter_ini_base (1)
prompter_smaind(P);
prompter_parallelinctl('ini',parport);


prompter_iniag500fig;

set(parport,'TimerFcn',@showagstatus,'TimerPeriod',prompter_gagd('monitorinterval'));
start(parport);


%This should be placed after all figures have been created
%i.e after any additional figures for ema, epg, transshift etc.
prompter_restorefigpos;

%disp('Position AG500 status figure, and check status. Type return to continue');
%keyboard;

%Check tcpip connection is working
timeout0=prompter_getemaall;
disp('Check AG status figure');
disp('If using TCPIP, check AG500 positions and amplitudes are plausible. Type return to continue');
keyboard;


all_done=0;
prompter_showhelp;
while ~all_done
    P=prompter_gmaind;
    S=prompter_gstimd;
    ps=S.ps;
    cs=S.cs;
    ts=['<New Sequence> ' datestr(now) crlf '<Log> ' P.logfile crlf];
    
    prompter_writelogfile(ts);
    prompter_showmsg(P.newsequencemsg);
    
    %    disp('Starting prompt sequence');
    disp('Hit any key to continue');
    pause;
    
    P.istim=1;
    P.repeatstr='';
    prompter_showg(ps{P.istim});
    P=prompter_gmaind;
    prompter_dotrafficlights('stop');
    
    prompter_updatefigs;
    prompter_showstim2investigator(P.istim)
    
    
    P.finished=0;
    
    prompter_smaind(P);
    while ~P.finished
        
        if P.autonext
            mycmd='n';
            pause(P.autodelay);
        else
            
            mycmd=abartstr('Command: ','n');
        end;
        
        if mycmd=='n'
            if ~P.ok2rec
                disp('Use M command to continue');
            else
                prompter_flushlogtext;
                P=prompter_gmaind;
                if P.hidemode==1 prompter_makepromptvisible; end;
                prompter_dotrafficlights('getready');
                tcp_timeoutflag=prompter_checkagready4next;     %gets current trial number from AG500
                if ~tcp_timeoutflag
                    P=prompter_gmaind;
                    
                    prompter_paralleloutctl('reset');
                    prompter_paralleloutctl('trial',P.irun);
                    
                    if P.usewavlist
                        prompter_playwav('list',P.istim);
                    end;
                    prompter_evaluserfunc(P.userstartfunc,'start');
                    P=prompter_gmaind;
                    
                    iruns=int2str(P.irun);
                    htinfo=P.infohandle;
                    set(htinfo(1),'string',iruns,'color',P.htinfostopcol);
                    drawnow;
                    
                    attn_timeoutflag=prompter_startag;
                    if ~attn_timeoutflag
                        attn_time=now;
                        if P.usestartwav
                            prompter_playwav('start');
                        end;
                        prompter_dotrafficlights('go');
                        set(htinfo(1),'color',P.htinforuncol);
                        
                        prompter_evaluserfunc(P.userattnfunc,'attn');
                        %comment in if main data structure is needed between here and
                        %userparallelstartfunc
                        %                    P=prompter_gmaind;
                        
                        sweep_timeoutflag=prompter_wait4agsweep;
                        
                        if ~sweep_timeoutflag
                            
                            %video timer start will not be accurate if userattnfunc does not return
                            %until after start of sweep (could start video timer inside userattnfunc if
                            %necessary)
                            sweep_time=now;
                            %other versions of the program have had problems with tic/toc
                            %                            tic;
                            prompter_paralleloutctl('start');
                            P=prompter_gmaind;
                            tocoffset=0;
                            mytime=sweep_time;
                            AG=prompter_gagd;
                            A=AG.Alines;
                            %this should give the time in the trial accurately even if userattnfunc
                            %does not return until after start of sweep
                            
                            if AG.attntimebase
                                mytime=attn_time;
                                tocoffset=((sweep_time-attn_time)*(24*60*60))-AG.attn2sweep;
                            end;
                            
                            
                            drawnow;
                            
                            triggered=1;
                            while triggered
                                pause(P.pausetimewhiletrialrunning);        %give callback a chance to run
                                tmptime=((now-sweep_time)*24*60*60)+tocoffset;
                                timeok=tmptime<P.trial_duration;
                                AG=prompter_gagd;
                                
                                %note: if using tcpip without sybox the active flag in the tcpip data
                                %stream is not monitored here.
                                %So stopping the recording on the control server has no effect here
                                if AG.usesybox
                                    tmpstat=AG.statbuf;
                                    agstat=tmpstat(1,:);
                                    triggeredcb=all(~agstat([A.sweep A.trans]));
                                else
                                    triggeredcb=1;
                                end;
                                
                                
                                clickstop=get(htinfo(1),'userdata');
                                triggered=timeok & triggeredcb & ~clickstop;
                                if P.showrunningtime
                                    set(htinfo(1),'string',[iruns ' : ' num2str(tmptime,'%4.3f')]);
                                    drawnow;
                                end;
                                
                            end;
                            
                            prompter_agstop;
                            
                            
                            prompter_paralleloutctl('stop');
                            P=prompter_gmaind;
                            
                            %could uncomment this if it could be helpful when agtriggermode is manual
                            %traffic lights stop done in prompter_nextstim
                            %    prompter_dotrafficlights('stop');
                            
                            mytoc=prompter_agwait4sweepend;     %returns 'now' in mytoc
                            mytoc=((mytoc-sweep_time)*24*60*60)+tocoffset;
                            %                            mytoc=mytoc+tocoffset;
                            set(htinfo(1),'string',[iruns ' : ' num2str(mytoc,'%4.3f')],'color',P.htinfostopcol,'userdata',0);
                            
                            if P.useendwav
                                prompter_playwav('end');
                            end;
                            prompter_nextstim(mytime,mytoc);
                            
                            prompter_evaluserfunc(P.userstopfunc,'stop');
                            P=prompter_gmaind;
                            
                        end;    %timeoutsweep
                    end;    %timeoutattn
                end;    %tcp timeout
            end;    %ok2rec
        end;			%next
        
        
        prompter_commoncmd(mycmd);
        
        prompter_autonext;      %check for autonext cancellation
        P=prompter_gmaind;  %make sure P is up to date for next pass through while loop
    end;
    mystr=abartstr('Terminate ? ','y');
    mystr=lower(mystr);
    
    if mystr~='n' all_done=1; end;
end;

prompter_exit;

if P.daqok
    delete(parport);
    clear parport;
end;




function showagstatus(daqobj,daqevent)
agstat=prompter_parallelinctl('readlines');
AG=prompter_gagd;


nstat=length(agstat);
statbuf=AG.statbuf;
hlstat=AG.linehandle;

statbuf(1,:)=agstat;
changed=agstat~=statbuf(4,:);

%only update display if any changes. As signals are active low, turn off
%signals with logical 1
if any(changed)
    xx=1:nstat;
    xx(agstat)=NaN;
    set(hlstat(1),'xdata',xx);
    statbuf(4,:)=agstat;
end;

holdchanged=agstat~=statbuf(3,:);
holdchanged=holdchanged | statbuf(2,:);
if any(holdchanged~=statbuf(2,:))
    xx=1:nstat;
    xx(~holdchanged)=NaN;
    set(hlstat(2),'xdata',xx);
    statbuf(2,:)=holdchanged;
end;

AG.statbuf=statbuf;
prompter_sagd(AG);
