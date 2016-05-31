function prompter_parallel_sonixmain(stimfile,logfile,S);
% PROMPTER_PARALLEL_SONIXMAIN Prompt program with synch signal output on parallel port. Will also run when port n.a
% function prompter_parallel_sonixmain(stimfile,logfile,S);
% prompter_parallel_sonixmain: Version 04.02.2013
%
%	Syntax
%       stimfile and logfile are required input arguments.
%       S is optional. If present it must be a struct whose fields control
%       optional settings (override defaults).
%       See prompter_ini_base for full details on the fields.
%
%   Description
%       Simplest version of prompter programs. In addition to normal prompt
%       display it can
%       output synch signal to parallel port at start of trial.
%       Can also control vtg55 video timer.
%       This version can be used when daq toolbox access to parallel port
%       not available.
%       Thus also useful for testing integrity of prompt files before
%       experiment because it can be run when parallel port in not
%       accessible (this requires administrator privileges on Windows XP
%
%   See Also PROMPTER_PARALLEL_TRIGIN, PROMPTER_PARALLEL_TRIGAG
%

functionname='PROMPTER_PARALLEL_SONIXMAIN: Version 04.02.2013';

Sin=[];
if nargin>2 Sin=S; end;

prompter_ini_base(functionname,stimfile,logfile,Sin)


iniok=prompter_inisonix;
if ~iniok
    disp('Sonix initialization failed');
    return;
end;

prompter_sonixfreeze(1,1);  %activate the desired triggervalue
prompter_sonixfreeze(0);
prompter_sonixfreeze(1,0);  %but now turn off the trigger until the 'next' command if triggermode is not 'continuous'
prompter_sonixfreeze(0);


%could also add the main sonix struct to prompter_exit (but maybe not so
%important as also store in the individual mat _info files)


parport=prompter_getparport;
prompter_paralleloutctl('ini',parport);

%may need something like this if we want to attempt to monitor the sonix
%frame sync
%P.parallelinmode='AG500';
%P.irun='';  %overwrite default from prompter_ini_base (1)
%prompter_smaind(P);
%prompter_parallelinctl('ini',parport);

%This should be placed after all figures have been created
%i.e after any additional figures for ema, sonix, epg, transshift etc.
prompter_restorefigpos;

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
    prompter_smaind(P);
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
                prompter_smaind('abortnext',0);
                P=prompter_gmaind;
                if P.hidemode==1 prompter_makepromptvisible; end;
                prompter_dotrafficlights('getready');
                %abort if freeze unsuccessful???
                prompter_sonixfreeze(1,1);  %freeze and activate trigger if currently disabled
                
                prompter_paralleloutctl('reset');
                prompter_paralleloutctl('trial',P.irun);
                
                
                if P.usewavlist
                    prompter_playwav('list',P.istim);
                end;
                prompter_evaluserfunc(P.userstartfunc,'start');
                
                P=prompter_gmaind;
                if ~P.abortnext
                    
                    iruns=int2str(P.irun);
                    htinfo=P.infohandle;
                    set(htinfo(1),'string',iruns,'color',P.htinfostopcol);
                    drawnow;
                    
                    
                    if P.usestartwav
                        prompter_playwav('start');
                    end;
                    
                    prompter_dotrafficlights('go');
                    
                    set(htinfo(1),'color',P.htinforuncol);
                    prompter_updatefigs;
                    
                    
                    %sync signal has to be before unfreeze
                    %use userparallelstartfunc to
                    %control delay until unfreeze, and handle trigger to sync brightup etc.
                    
                    syncstarttime=now;
                    prompter_paralleloutctl('start');
                    
                    P=prompter_gmaind;
                    
                    prompter_sonixfreeze(0);
                    drawnow;
                    clickstop=0;
                    itoc=(now-syncstarttime)*24*60*60;
                    %                    itoc=toc(tstart);
                    %                    itoc=itoc+toff;
                    while ((itoc<P.trial_duration) & (~clickstop))
                        %user larger value to give more chance for background processing to run
                        %(and if running time display is not important)
                        pause(P.pausetimewhiletrialrunning);
                        clickstop=get(htinfo(1),'userdata');
                        %                        itoc=toc(tstart);
                        itoc=(now-syncstarttime)*24*60*60;
                        %                        itoc=itoc+toff;
                        if P.showrunningtime
                            set(htinfo(1),'string',[iruns ' : ' num2str(itoc,'%4.3f')]);
                            drawnow;
                        end;
                    end;
                    
                    prompter_sonixfreeze(1,0);  %freeze and disable trigger if triggermode not 'continuous'
                    
                    %use sonix freezedelay if necessary to ensure that
                    %sonix synch pulses stop before parallel sync is reset
                    syncstoptime=now;
                    prompter_paralleloutctl('stop');
                    P=prompter_gmaind;
                    mytoc=(syncstoptime-syncstarttime)*24*60*60;
                    set(htinfo(1),'string',[iruns ' : ' num2str(mytoc,'%4.3f')],'color',P.htinfostopcol,'userdata',0);
                    
                    
                    if P.useendwav
                        prompter_playwav('end');
                    end;
                    prompter_nextstim(syncstarttime,mytoc);
                    
                    
                    %write sonix data here
                    prompter_sonixwrite;
                    prompter_sonixfreeze(0);
                    prompter_evaluserfunc(P.userstopfunc,'stop')
                    P=prompter_gmaind;
                    
                end;    %~abortnext
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
    %porttalk mode would give a harmless error
    try
        delete(parport);
        clear parport;
    catch
        disp('');
    end;
    
end;
