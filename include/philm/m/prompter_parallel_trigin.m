function prompter_parallel_trigin(stimfile,logfile,trial_duration,fontsize,startwav,endwav);
% PROMPTER_PARALLEL_TRIGIN Stimulus display with monitoring of AG500 status and video timer control
% function prompter_parallel_trigin(stimfile,logfile,trial_duration,fontsize,startwav,endwav);
% prompter_parallel_trigin: Version 27.08.2011
%
%	Syntax
%       stimfile: Name of text file containing stimuli for experiment
%           First line must be number of lines in the prompt text for each
%           stimulus
%           Each prompt must thus consist of the same number of lines. If
%           necessary pad with blank lines.
%           For each stimulus, the prompt (seen by the subject) must be
%           followed by a one-line code (stored in the log file).
%           If the first line of the prompt to the subject starts with
%           '<IMAGE>' then the rest of the line e.g '01', '21', is treated as the index
%           into a cell array of images, and the prompt will consist of an
%           image display, not text.
%           If any image prompts are found when the stimulus file is
%           loaded, then the user will be prompted to load the image data
%           from keyboard mode.
%           Currently, this involves setting the 'userdata' of the axes
%           object used for image display to the cell array containing the
%           image data. This is accessible in keyboard mode via the handle
%           'haxi'. Alternatively use findobj to find axes with tag
%           '<IMAGE>'.
%           To avoid having to handle colormaps it will normally be easiest
%           to specifiy the image data as true color, i.e m*n*3
%       logfile: Name of text file to which to write experiment log
%		fontsize: Size of font for stimulus display to subject. Given in
%		    normalized units (see documentation of text function for details)
%           If the specified size is too large to fit the stimulus text on the
%           screen, then it is automatically reduced. The reduction factor is
%           displayed to the user, so it is possible to do a test run to
%           determine a fontsize that will not require reduction for any
%           stimulus. This will be necessary if you want to be sure the font
%           size is the same for all stimuli
%		trial_duration: in s. This should normally be set to the same
%		    duration as the AG500 sweep duration.
%           Since the program detects the end of a trial by monitoring the
%           AG500 sweep signal, a separate specification of trial_duration is
%           really superfluous. It was originally included because earlier
%           versions of the AG500 did not reset the sweep signal very precisely
%           at the end of the sweep. Specifying trial duration made it possible
%           to give the subject are more accurate indication of when recording
%           had terminated, because the prompt for the next trial is displayed
%           as soon as the trial duration is reached.
%           Currently, trial_duration should normally not be shorter than AG500
%           sweep duration, as this may distract the subject while they are
%           still speaking the current trial. If it is longer than AG500 sweep
%           duration then it will have basically no effect (it would function
%           as a kind of time-out in case the AG500 sweep signal does not
%           reset, but this has never been known to happen).
%           If you are running the AG500 without a pre-set sweep duration (i.e
%           terminating by hand), then set trial duration to some large value
%           (i.e comfortably longer than any expected sweep duration in the
%           experiment).
%		startwav and endwav (optional). WAV files played at start and end, respectively
%				could be just a bell, but could also be e.g a synch inpulse
%               There is a separate facility for giving a different audio
%               prompt to the subject for each stimulus. See explanation of
%               'wavlist' below
%
%       Additional Settings
%           There are a number of potentially useful settings that currently cannot
%           be specified by input arguments, but which can be made from
%           keyboard mode following the following message to the user:
%           'Position Subject and Investigator figures, then type return'
%           '(Optionally adjust other settings)'
%           For consistency, it is recommended to collect these settings in
%           a short script that can be run from keyboard mode
%           Here is a list of the settings most likely to be useful:
%               compromptflag: Set to 1 to activate use of VT200-style
%                   terminal for prompt display
%               vtgtrialflag: Set to 0 to completely turn off display of
%                   trial number on the video timer. One reason for doing this
%                   is that the setting can be quite slow, so it speeds up the
%                   start of the next trial (e.g when using auto-next mode)
%               vtgtrialfix: Set to 1 to always use same trial number (1)
%                   on video timer display (alternative way of speeding up the
%                   display)
%               'Traffic-light' colours for telling subject when to speak:
%                   These are set in structure TL, the default settings being
%                   TL.stop=[1 0 0], TL.go=[0.1 0.8 0.1], TL.getready=[1 1 0]
%                   i.e red, green(ish) and yellow, respectively.
%                   Thus setting all to [0 0 0] will result in no change of
%                   colour in the text (or image) frame when trials start and
%                   stop.
%               Properties of prompt text to subject
%                   The text object is accessible via handle 'ht' from
%                   keyboard mode, or by using something like
%                   findobj('type','text','tag','prompt').
%                   Usefully settings include 'font' (e.g use an Arabic
%                   font), or 'horizontalalignment' (default is 'left')
%                   Modifications to text attributes of parts of
%                   individual prompts can be obtained using the stream
%                   modifiers explained in the documentation of the text
%                   function (in combination with the backslash operator,
%                   e.g inserting \bf into the prompt of a particular stimulus causes following characters to be bold.
%                   (Special symbols can also be obtained in this way)
%               User start, stop and attn function
%                   For more sophisticated modifications of prompts etc. it
%                   is possible to specify matlab code to be called at the
%                   start and end of every trial (see source code below for
%                   details)
%
%   See Also
%       VTGCTRL Control FORA VTG55 video timer via parallel port
%       COMPROMPT Display prompt on VT200 terminal using serial COM port
%       PROMPTCB Callback so user can interrupt auto-next mode
%   Updates
%       Delay in auto mode

% Monitors ag500 status signals
% test version with prompt triggered by ag500 syncbox
% Incorporates video timer control and synch output from PC
% Prompt output also to serial monitor (see COMPROMPT)


functionname='prompter_parallel_trigin: Version 27.08.2011';



philcom(1)
imageprefix='<IMAGE>';

% Variable wavlist
%This is for giving an audio prompt to the subject (separate from the sound
%specified in startwav).
% It must be set up by hand when the program enters keyboard modus before
% start of the main command loop.
% It should be a string matrix containing a list of wav files (one per
% stimulus.
%Note that the audio file in wavlist is played as soon as the investigator
%gives the 'next' command, while the sound specified in startwav is played
%when the attention signal from the AG500 is detected (0.1s before start of
%AG500 sweep)

wavlist=[];
wavlistsynch=0;		%12.09. If not altered by user, wav is played asynchronously (i.e program does not wait)

%matlab commands, or script or function file, to be executed at start and
%end of trial (i.e the string specified here is passed to the eval
%function)
%Using a function is preferable, to reduce chances of inadvertently
%changing program variables
%This mechanism could be used as an alternative way of handling audio
%output depending on current stimulus. Should mainly be useful for
%modifying the prompt display in various ways.
%could also be used to enforce a minimum 'getready' duration.

userstopfunc=''; %called at end of trial, just before new stimulus is displayed (so e.g could be used to make
%stimulus invisible until the next 'next' command
userstartfunc=''; %called during the next command, before start of trial. Specifically, after any audio
%output specified in wavlist has been done. 
% In prompter_parallel_trigag it is called before the signal to the AG500
% control server to start the trial
% In prompter_parallel_trigin it is called before the program waits for the
% attention signal.
userattnfunc=''; %called after the program has detected the attention function, but after the prompt colour has
%changed to 'go' and after the wavstart sound has been output.
%The will allow more precise temporal alignment to AG500 activity than
%using userstartfunc. If good temporal alignment is important than using
%the wavstart sound as well should probably be avoided




compromptflag=0;    %prompt on serial VT100 style monitor
vtgtrialflag=1;     %trial number on VTG video timer. Disable if not needed, as setting can be rather slow
vtgtrialfix=0;      %If true, trial number always 1 (also to speed up, if trial number not essential)

attn2sweep=0.1;     %syncbox delay from attention to start of sweep

attn_timeout=10;    %return to command input if no attention signal after starting "next" command


daqok=1;
try
parport = digitalio('parallel','LPT1');
catch
    daqok=0;
    
    %eventually it should be possible to continue without parallel port
    %functions
    
    disp('Parallel port not available');
    disp('Check you have administrator privileges');
    return;
end;





vtgctrl('ini',parport);
lines_IN_1 = addline(parport,[0:3],1,'in');     %input lines on port1; need 4 for ag500 monitoring

%set all vtg control lines high, and synch out to low
%may be better to do this before turning on vtg



statnames=char(get(lines_IN_1,'LineName'));
statnames=strm2rv(statnames,' ');

statuslines=get(lines_IN_1,'Index');

%must match the pin assignment for input lines from port 1
%the five lines (0:4) of port 1 correspond to pins
%15 13 12 10 11

%thus Pin 11 is still free for other purposes (according to matlab help Pin
%11 is hardware inverted)

ag500names=str2mat('psr','attn','sweep','trans');
A=desc2struct(ag500names);
nstat=size(ag500names,1);

for ii=1:nstat set(lines_IN_1(ii),'LineName',deblank(ag500names(ii,:))); end;

agstat=getvalue(lines_IN_1);

%binary vector has first element on left, so names should match values
disp(statnames);
disp(strm2rv(ag500names,' '));
disp(agstat);

%set up display for background monitoring of ag500 status
hfs=figure;
monitorintervall=1/20;      %i.e try and monitor 20 times per second (see timer period below)

%create 2 line objects; one for current state, one for change indicator
%display will be toggled on off by manipulating NaNs in xdata

hlstat=plot(ones(nstat,2)*NaN,repmat([1 2],[nstat 1]));
set(hlstat(1),'color','g','linestyle','none','marker','o','markerfacecolor','g','markersize',12);
set(hlstat(2),'color','r','linestyle','none','marker','o','markerfacecolor','r','markersize',12);

set(hlstat,'erasemode','xor');

set(hfs,'doublebuffer','on');
set(hfs,'sharecolors','off');

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

set(hlstat(1),'userdata',statbuf);


%workaround as this did not work in matlab 7
%set(parport,'TimerFcn',{@showagstatus,statuslines,hlstat},'TimerPeriod',monitorintervall);
set(parport,'TimerFcn',{@showagstatus,lines_IN_1,statuslines,hlstat},'TimerPeriod',monitorintervall);



start(parport);
disp('Position AG500 status figure, and check status. Type return to continue');

keyboard;

%delete(parport);
%clear parport;
%return;


[abint,abnoint,abscalar,abnoscalar]=abartdef;

wavstart=[];
if nargin>4 
    wavstart=startwav;
    if ~isempty(wavstart)
        [wavstart_d,wavstart_sf,wavstart_bits]=wavread(wavstart);
    end;
end;



wavend=[];
if nargin>5 
    wavend=endwav;
    
    if ~isempty(wavend)
        [wavend_d,wavend_sf,wavend_bits]=wavread(wavstart);
    end;
end;


%if true, program continues without waiting for end of sound
%irrelevant when running from external trigger
%wavstart_async=0;
%wavend_async=0;

[ps,cs,s1line,nstim,nline,prepareimage,maxcol]=parsestimfile(stimfile);

helpwin prompter_parallel_trigin;

helpwin(s1line,stimfile);


fid=fopen(logfile,'w');
if fid<3
    disp('unable to open log file');
    return
end;


hfsub=figure;
set(hfsub,'color','w');
set(hfsub,'menu','none');
haxp=axes;
xlim([0 1]);
ylim([0 1]);
set(gca,'visible','off');
set(gca,'position',[0.05 0.05 0.9 0.9]);

ht=text(0.5,0.5,'***','horizontalalignment','left','verticalalignment','middle');
set(ht,'fontunits','normalized','fontsize',fontsize,'userdata',fontsize,'tag','prompt');
set(ht,'edgecolor','r','linewidth',5,'margin',15);

haxsub=gca;

set(hfsub,'name','Subject');

haxi=[];
%vi=strmatch(imageprefix,ps);
%if ~isempty(vi)

if prepareimage
	disp('preparing for image data');
	haxi=axes;
	set(haxi,'position',get(haxp,'position'));
	set(haxi,'tag',imageprefix);
	hi=image;
	set(hi,'tag',imageprefix);
	%make sure axis ticks and labels are not visible when axes is visible
%but see also note below
    set(haxi,'ycolor',get(hfsub,'color'),'xcolor',get(hfsub,'color'));
%7.10 use axes rather than figure color to cue the subject
	set(haxi,'color','r','linewidth',10);
	set(haxi,'visible','off');
	set(hi,'visible','on');
	%userdata of haxi must be set to a cell array containing the image for each
%stimulus
	disp('load image data');
%the loading script could show one image to allow size to be checked
%and should then normally set axis image or axis equal (not sure
%what happens with axis image if image size varies)
%But for the normal case of same-size images then axis image is better.
%(axis equal will leave additional strips in the axis color with size
%depending on precise image dimensions, - and also little notches in the
%background color at the tick location (can be fixed with e.g
%set(haxi,'xtick',[]);
%example for the loading script:
%===========================
%set(haxi,'userdata',mymatin('mca6_medgem_images','data'));

%assume monochrome image (not stored as truecolor)
%if data still stored as logical use this:
%set(get(haxi,'parent'),'colormap',gray(2));
%otherwise if resized and antialiased, use this:
%set(get(haxi,'parent'),'colormap',gray(256));
%tmpxx=get(haxi,'userdata');
%tmpxx=tmpxx{1};
%set(hi,'cdata',tmpxx);
%axis(haxi,'image');
%clear tmpxx;
%===============================


keyboard;
set(hi,'visible','off');
	drawnow;

end;



hfinv=[];
hfinv=figure;
set(hfinv,'color','w');
set(hfinv,'menu','none');

copyobj([haxsub haxi],hfinv);
ht(2)=findobj(hfinv,'type','text','tag','prompt');

set(hfsub,'name','Subject');
set(hfinv,'name','Investigator');

figh=[hfsub hfinv];

%set([hfsub hfinv],'sharecolors','off');

%for cancelling autonext mode
set(hfinv,'userdata',0,'windowbuttondownfcn','promptcb');


P.figurebasecolor=get(hfsub,'color');
P.promptmode='text';
P.imageprefix=imageprefix;

set(hfsub,'userdata',P);

%colors for signal to subject
%normal colours
TL.stop=[1 0 0];
TL.go=[0.1 0.8 0.1];
TL.getready=[1 1 0];

%no change in colours
%TL.stop=[0 0 0];
%TL.go=[0 0 0];
%TL.getready=[0 0 0];



%can also adjust text properties, traffic light colours etc. by hand
disp('Position Subject, Investigator and Help figures, then type return');
disp('(Optionally adjust other settings)');



keyboard;

if compromptflag
    disp('Make sure vt220 is connected and turned on');
end;



dotrafficlights(TL.stop,ht,figh);



if compromptflag comprompt('ini',nline,maxcol); end;


all_done=0;
irun=1;
showhelp
ok2rec=1;

while ~all_done
    ts=datestr(now);
    ts=['<Start of Sequence> ' ts crlf];
    status=fwrite(fid,ts,'uchar');
    %temporary
    status=fwrite(fid,['<Trial Duration: ' num2str(trial_duration) '>' crlf],'uchar');
    showg(ht,'\fontname{Helvetica}!New Sequence!',compromptflag);
    disp('Starting prompt sequence');
    disp('hit any key to continue');
    pause;   
    
    istim=1;
    repeatstr='';
    rubbishstr='';
    showg(ht,ps{istim},compromptflag);
    %    set(ht,'color','r');
    %    set(ht,'edgecolor','r');
    dotrafficlights(TL.stop,ht,figh);
    
    disp(ps{istim});
    disp(['<CODE> ' cs{istim}]);
    
    finished=0;
    
    autonext=0;
    autodelay=0;    
    
    freecomment='%[';
    while ~finished
        
        autochk=get(hfinv,'userdata');
        if autonext
            if autochk
                autonext=0;
                set(hfinv,'userdata',0);
            end;
        end;
        
        if autonext
            mycmd='n';
            pause(autodelay);
        else
            
            mycmd=abartstr('Command: ','n');
        end;
        
        %      mycmd=lower(mycmd);
        
        if mycmd=='h' showhelp; end;
        
        if mycmd=='a'
            
            autonext=1;
            disp('Starting autonext mode');
            autodelay=abart('Inter-trial interval',autodelay,0,1000,abnoint,abscalar);
            disp('Click in Investigator figure to cancel');
            disp('Type autonext=0 to cancel immediately; otherwise type return');
            keyboard;
        end;
        if mycmd=='n'
            
            if ~ok2rec
                disp('Use M command to continue');
            else
                
                dotrafficlights(TL.getready,ht,figh);
                
                drawnow;
                
                %audio output from list here
                if ~isempty(wavlist)
                    try
                        tmpname=deblank(wavlist(istim,:));
                        [audioprompt,audiopromptsf]=wavread(tmpname);
                        sound(audioprompt,audiopromptsf,16);
                    catch
                        disp('problem playing audio');
                    end;
                end;
                
            if ~isempty(userstartfunc)
                eval(userstartfunc,'disp(''Error evaluating userstartfunc'');disp(lasterr)');
            end;

                
                
                %            set(ht,'color','y');    %start imminent
                %                set(ht,'edgecolor','y');
                %needs testing
                %            if compromptflag comprompt('message','!Get Ready!); end;            
                %finish off last comment
                status=fwrite(fid,[rubbishstr freecomment ']' crlf],'uchar');
                freecomment='';
                rubbishstr='';
                
                %show trial number on video timer
                %do here as it is rather slow, i.e not usually enough time between
                %attention and start of sweep
                
                %allow trial number display to be skipped
                vtgtrialnum=irun;
                if vtgtrialfix vtgtrialnum=1; end;                    
                
                if vtgtrialflag vtgctrl('trial',vtgtrialnum); end;
                
                %it does not seem to be possible to turn off the timer callback with
                %stop(parport) and then restart with start(parport)
                %however, it does seen to be possible to modify the timer interval on the
                %fly. So while using polling mode below the timer interval could be set to
                %some large value. In fact the timer callbacks do not seem to get through
                %anyway while polling in the while loop.
                
                %check status in background monitoring is OK
                
                
                %need some way of escaping from while loops
                %currently timeout is used
                % other ways?
                % uicontrol? may not react very well as while loop may block
                % most other processing
                % additional hand operated abort? line
                
                %Note: as sweep and attn also active low, need to use NOT
                %operator
                
                %check a sweep has not been missed completely,
                %i.e check whether sweep is not running but sweep change indicator has changed since
                %last resetagstatus
                
                timeoutflag=0;
                
                tmpstat=get(hlstat(1),'userdata');
                agstat=tmpstat(1,:);
                chstat=tmpstat(2,:);
                
                if chstat(A.sweep) & agstat(A.sweep)
                    disp('May have missed agmaster completely!!!');
                    disp('Check trial number before continuing');
                    disp('Forcing a timeout .....');
                    status=fwrite(fid,['!!agmaster sweep without prompt !!' crlf],'uchar');
                    timeoutflag=1;
                end;
                %transmitter is running, but status has changed, so there has probably been
                %a resynch
                if chstat(A.trans) & ~agstat(A.sweep)
                    disp('There seems to have been a transmitter resynch!!!');
                    disp('Check trial number and transmitter status before continuing');
                    disp('Forcing a timeout .....');
                    status=fwrite(fid,['!!Probable transmitter resynch detetected !!' crlf],'uchar');
                    timeoutflag=1;
                end;
                
                
                %check not already triggered
                %strictly, separate attention and sweep
                %May be no real problem here except if sweep already active, since then videotimer
                %display will not be completely accurate
                %5.07 but to be on the safe side force a timeout
                
                agstat=getvalue(lines_IN_1);
                triggered=any(~agstat([A.sweep A.attn]));
                if triggered
                    disp('Sweep already running????')
                    %output to log file
                    status=fwrite(fid,['!!Prompt too late for sweep !!' crlf],'uchar');
                    timeoutflag=1;
                end;
                
                triggered=0;
                attn=0;
                disp('waiting for attention');
                
                tic;            
                
                
                %could also use this to break out while waiting for attention
                %(regardless of whether autonext is active or not)
                %i.e treat like time-out (except output a different message)
                %        autochk=get(hfinv,'userdata');
                %        if autonext
                %            if autochk
                %                autonext=0;
                %                set(hfinv,'userdata',0);
                %            end;
                %        end;
                
                
                
                while ~attn & ~timeoutflag
                    agstat=getvalue(lines_IN_1);
                    attn=~agstat(A.attn);
                    tcheck=toc;
                    timeoutflag=(tcheck>attn_timeout) | agstat(A.trans);
                    
                end;
                
                if timeoutflag
                    
                    %should reset autonext here!!! tell user to use a
                    %command to resume autonext
                    %            set(ht,'color','r');    %abort
                    dotrafficlights(TL.stop,ht,figh);
                    
                    %                    set(ht,'edgecolor','r');
                    %timeout is harmless if "next" command was given before
                    %ag500 was ready, but if it was caused by transmitter
                    %failure there maybe a mismatch with the trial number used
                    %by agmaster
                    disp('Timed out waiting for attention');
                    if agstat(A.trans)
                        disp('Transmitter not running??');
                        status=fwrite(fid,['!!Transmitter not running while waiting for attention !!' crlf],'uchar');
                    end;
                    disp('Type return to continue');
                    disp('If time-out caused by transmitter resynch, check transmitter status and trial number before continuing!!');
                    disp('Use "t" command to set trial number to number of next AG trial');
                    %output to log file
                    status=fwrite(fid,['!!Timed out waiting for attention !!' crlf],'uchar');
                    keyboard;
                    resetagstatus(hlstat);    
                else
                    
                    %alert subject after attention signal  
                    
                    if compromptflag comprompt('message'); end;            
                    
                    %               set(ht,'color',[0.1 0.8 0.1]);
                    %                    set(ht,'edgecolor',[0.1 0.8 0.1]);
                    dotrafficlights(TL.go,ht,figh);
                    
                    drawnow;            
                    
                    %note: start sound is output at attention signal, not start of
                    %sweep
                    %If different synchronization with sweep begin is desired, e.g
                    %splice in a pause to the start of the sound
                    
                    %maybe use daq da functions for sound
                    %i.e prepare sound beforehand and then trigger here
                    %may give more precise synchronization and quicker activation
                    %use mysound????, what about scaling????     
                    if ~isempty(wavstart)
                        soundsc(wavstart_d,wavstart_sf,wavstart_bits);
                    end;
                    
            if ~isempty(userattnfunc)
                eval(userattnfunc,'disp(''Error evaluating userattnfunc'');disp(lasterr)');
            end;


                    
                    %wait for actual sweep active
                    %check not already triggered
                    
                    agstat=getvalue(lines_IN_1);
                    triggered=~agstat(A.sweep);
                    if triggered
                        disp('Program too slow between attention and sweep')
                        %output to log file
                        status=fwrite(fid,['!!Program too slow between attention and sweep !!' crlf],'uchar');
                    end;
                    
                    
                    while ~triggered
                        agstat=getvalue(lines_IN_1);
                        triggered=~agstat(A.sweep);
                        
                    end;
                    
                    %start video timer and set synch out
                    vtgctrl('start');
                    %uses minutes units as flag that trial is running  (e.g for
                    %automatic detection in image data. reset by vtg reset below
                    %(needs changing so synch line doesn't get reset)
                    %            vtgctrl('minset');
                    
                    
                    sx=int2str([irun istim]);
                    disp('Recording');
                    mytime=now;
                    tic;
                    
                    %temporary, until sweep end signal from ag500 is accurate
                    while triggered
                        pause(0.05);        %give callback a chance to run
                        tmptime=toc;
                        timeok=tmptime<trial_duration;
                        
                        tmpstat=get(hlstat(1),'userdata');
                        agstat=tmpstat(1,:);
                        triggeredcb=all(~agstat([A.sweep A.trans]));
                        triggered=timeok & triggeredcb;
                    end;
                    
                    
                    
                    %                while triggered
                    %                    agstat=getvalue(lines_IN_1);
                    %                    triggered=~agstat(A.sweep);
                    %give call back a chance to run
                    %this means detection of end of sweep is not very
                    %accurate, but currently it is not accurate in the
                    %ag500 system either
                    
                    %alternative to pause and while loop would be waitfor
                    %but this will need setting up carefully
                    %                    pause(1/50);
                    
                    %                end;
                    
                    %stop video timer
                    vtgctrl('stop');
                    
                    %if using the minutes units as a flag its better to reset here
                    % but its also useful to see at what time the timer stopped
                    
                    %            vtgctrl('reset'); %all digits zero
                    
                    %if count up/down were implemented this could be done more elegantly
                    %increment the minutes digit to zero??
                    
                    if ~isempty(wavend)
                        soundsc(wavend_d,wavend_sf,wavend_bits);
                    end;
                    
                    if compromptflag comprompt('message',''); end;
                    
                    %m-file call?
                    
                    
                    
                    %wait for callback to also notice end of sweep, otherwise
                    %there is no point in doing resetagstatus
                    
                    
                    triggeredcb=1;
                    while triggeredcb
                        pause(0.05);
                        tmpstat=get(hlstat(1),'userdata');
                        agstat=tmpstat(1,:);
                        triggeredcb=all(~agstat([A.sweep A.trans]));
                    end;
                    
                    mytoc=toc;         
                    
                    disp(['Trial/Stimulus ' int2str([irun istim]) ' stopped after ' num2str(mytoc) ' s']);
                    [dodo,mytime]=strtok(datestr(mytime));         
                    sx=[sx ' ' mytime];
                    sx=[sx ' ' num2str(mytoc)];
                    
                    
                    if agstat(A.trans)
                        disp('Trial stopped because of transmitter problem?');
                        disp('Wait for transmitters to be active before continuing');
                        sx=[sx crlf '!!Trial stopped by transmitter problem??' crlf];
                        keyboard;
                    end;
                    
                    
                    
                    resetagstatus(hlstat);
                    
                        if ~isempty(userstopfunc)
                eval(userstopfunc,'disp(''Error evaluating userstopfunc'');disp(lasterr)');
            end;
                    
                    if istim<nstim
                        %display new stimulus immediately to subject
                        showg(ht,ps{istim+1},compromptflag);
                        
                        %                    set(ht,'color','r');
                        dotrafficlights(TL.stop,ht,figh);
                        
                        %                        set(ht,'edgecolor','r');
                        drawnow;    
                    end;
                    
                    
                    %10.03 free comment now has to be entered with explicit command
                    
                    mycomm=[' [' cs{istim} repeatstr ];
                    repeatstr='';
                    %write trial number and time of day
                    sx=[sx mycomm];
                    status=fwrite(fid,sx,'uchar');
                    
                    vtgctrl('reset'); %all digits zero
                    
                    irun=irun+1;
                    istim=istim+1;
                    
                    if istim<=nstim            
                        disp(ps{istim});
                        disp(['<CODE> ' cs{istim}]);
                    else
                        disp('End of stimuli');
                        finished=1;
                        showg(ht,'\fontname{Helvetica}!!END!!',compromptflag);
                        %finish off last comment
                        status=fwrite(fid,[freecomment ']' crlf],'uchar');
                        freecomment='';
                    end;
                end;            %~timeout            
                
            end;            %ok2rec    
            
            
        end;                %next
        
        if mycmd=='c'
            
            freecomment=philinp('Comment : ');
            freecomment=['_' freecomment];
            
        end;
        
        
        if mycmd=='q'
            finished=1;
            showg(ht,'\fontname{Helvetica}!!END!!',compromptflag);
            %finish off last comment
            status=fwrite(fid,[freecomment ']' crlf],'uchar');
            freecomment='';
        end;
        if mycmd=='k'
            keyboard;
        end;
        
        if ((mycmd=='r') | (mycmd=='R'))
            disp('Repeating!!');
            repeatstr='!!Repeat!!';
            rubbishstr='!!Rubbish!!';   %as comment is not closed until next "next" command this marks the trial with the problem
            istim=istim-1;
            if mycmd=='R'
                irun=irun-1;
                disp('Re-using previous trial number');   
            end;
            showg(ht,'\fontname{Helvetica}!Repeat!',compromptflag);
            
            disp('hit any key to continue');
            pause
            showg(ht,ps{istim},compromptflag);
dotrafficlights(TL.stop,ht,figh);
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
            
        end;
        
        if mycmd=='g'
            istim=abart('New stimulus number',istim,1,nstim,abint,abscalar);
            showg(ht,'\fontname{Helvetica}!Change of Stimulus!',compromptflag);
            rubbishstr=['!!Stimulus number changed to ' int2str(istim) ' !!'];
            repeatstr='!!May be first of several repeats!!';
            disp('hit any key to continue');
            pause
            showg(ht,ps{istim},compromptflag);
dotrafficlights(TL.stop,ht,figh);
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
            
        end;
        if mycmd=='t'
            irunold=irun;
            irun=abart('New trial number',irun,1,999,abint,abscalar);
                %finish off last comment
                status=fwrite(fid,[rubbishstr freecomment ']' crlf],'uchar');
                freecomment='';
                rubbishstr='';
                
                status=fwrite(fid,['!!Trial number changed!!' crlf],'uchar');
            
            if irunold<irun
                mytime=now;
                [dodo,mytime]=strtok(datestr(mytime));         
                for itmp=irunold:(irun-1)
                    sx=[int2str(itmp) ' 0 ' mytime ' 0 [!!No prompt (no video timer)!!]' crlf];
                    status=fwrite(fid,sx,'uchar');
                    
                end;
                rubbishstr='!!End of dummy trials!!';       %this will be written to log file at next 'next' command
            end;
            
            
        end;
        
        if mycmd=='m'
            set(ht,'visible','off');
            mymess=philinp('Enter message to subject ');
            mymess=rv2strm(mymess,crlf);
            showg(ht,mymess);
            set(ht,'visible','on','edgecolor','m');
            disp('Use M command to continue');
            ok2rec=0;
            
        end;
        if mycmd=='M'
            set(ht,'visible','off');
            mymess=philinp('Enter message to subject ');
            mymess=rv2strm(mymess,crlf);
            showg(ht,mymess);
            set(ht,'visible','on','edgecolor','m');
            disp('hit any key to continue');
            pause
            showg(ht,ps{istim});
            %            set(ht,'edgecolor','r');
            dotrafficlights(TL.stop,ht,figh);
            
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
            ok2rec=1;         
        end;
        
        %hopefully temporary!!!!
        if mycmd=='d'
            disp('Enter new trial duration');
            disp('Make sure this corresponds to the agmaster setting!!');
            trial_duration=abart('New duration',trial_duration,1,999,abnoint,abscalar);
            status=fwrite(fid,['<Trial Duration changed to ' num2str(trial_duration) '>' crlf],'uchar');
        end;
        
    end;
    mystr=abartstr('Terminate ? ','y');
    mystr=lower(mystr);
    
    if mystr~='n' all_done=1; end;
end;

status=fclose(fid);

disp('hit any key to exit program');
pause;
delete([hfsub;hfinv]);
delete(hfs);
delete(parport);
clear parport;
daqreset;
if compromptflag comprompt('reset'); end;



function showg(ht,mys,compromptflag);
%08.11 only automatically turn visibility on at end if current visibility
%is on
%Not yet sure this will work properly if mixing image and text prompts


oldhtvis=get(ht(1),'visible');      %if current visibility is 'off' (e.g because of action in userstopfunc, leave off at end)
hfsub=findobj('type','figure','name','Subject');
P=get(hfsub,'userdata');

hi=findobj('type','image','tag',P.imageprefix);
oldhivis='';
if ~isempty(hi) 
    oldhivis=get(hi,'visible');
    set(hi,'visible','off'); 
end;
hai=findobj('type','axes','tag',P.imageprefix);

set(ht,'visible','off');

mysc=char(mys);

if findstr(P.imageprefix,mysc(1,:))
    
    if ~isempty(hi)
        tmp=strrep(mysc(1,:),P.imageprefix,'');
        imnum=str2num(tmp);
        if ~isempty(imnum)
            if ~isempty(hai)
                imdata=get(hai(1),'userdata');
                if iscell(imdata)
                    imdata=imdata{imnum};
                    set(hi,'cdata',imdata);
                if strcmp(oldhivis,'on')
                        set(hi,'visible','on');     %handle axes visibility the same?
                    end;
                    P.promptmode='image';
                    set(hfsub,'userdata',P)
                    drawnow;
                    updatefigs;
                    return;
                end;
            end;
        end;
    end;
    
end;

%if image display not possible, treat as normal text display


%normal text display

%reset figure color if last prompt was image
if strcmp(P.promptmode,'image')
    hfinv=findobj('type','figure','name','Investigator');
    set([hfsub hfinv],'color',P.figurebasecolor);
end;

P.promptmode='text';
set(hfsub,'userdata',P);

tmpsize=get(ht(1),'userdata');
set(ht,'fontsize',tmpsize);
set(ht,'string',mys);
eee=get(ht(1),'extent');
ppp=get(ht(1),'position');

maxex=max(eee(3:4));
if maxex>1
    disp('Reducing font to fit');
    disp(1/maxex);
    tmpsize=get(ht(1),'fontsize')*(1/maxex);
    set(ht,'fontsize',tmpsize);
    eee=get(ht(1),'extent');
end;




xe=eee(3);
%disp('extent');
%disp(eee);



halign=get(ht(1),'horizontalalignment');
if strcmp(halign,'left')
    ppp(1)=0.5-xe/2;
else
    ppp(1)=0.5;
end;



set(ht,'position',ppp);

%disp('position')
%disp(ppp);
%disp('axes x/y lim');
%disp([get(gca,'xlim') get(gca,'ylim')]);

if strcmp(oldhtvis,'on')
    set(ht,'visible','on');
end;

drawnow;
updatefigs;

%should strip prompt string of any control information used by matlab text
%object
if nargin>2
    if compromptflag
        comprompt('prompt',mys);
    end;
end;

function updatefigs
%disabled
return;




%function showagstatus(daqobj,daqevent,statuslines,hlstat)
%agstat=getvalue(daqobj.Line(statuslines));
function showagstatus(daqobj,daqevent,lines_IN_1,statuslines,hlstat)
agstat=getvalue(lines_IN_1);

%original call and getvalue did not work in matlab 7
%changed 12.07


nstat=length(agstat);
statbuf=get(hlstat(1),'userdata');

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

set(hlstat(1),'userdata',statbuf);

function resetagstatus(hlstat);

statbuf=get(hlstat(1),'userdata');
nstat=size(statbuf,2);
statbuf(3,:)=statbuf(1,:);
statbuf(2,:)=logical(zeros(1,nstat));
set(hlstat(2),'xdata',ones(nstat,1)*NaN);
set(hlstat(1),'userdata',statbuf);

function showhelp
helpstr=str2mat(...
'Commands are:',...
'n = next (default)',...
'a = autonext',...
'c = comment',...
'd = set trial duration',...
'r = repeat',...
'R = repeat with old trial number',...
'g = goto',...
't = set trial number',...
'm = message',...
'M = message and resume',...
'q = quit',...
'k = keyboard',...
'h = help');
disp(helpstr);
helpwin(helpstr,'Prompt commands');


function dotrafficlights(tlcol,ht,figh);
P=get(figh(1),'userdata');
if strcmp(P.promptmode,'text')
    oldcol=get(ht(1),'edgecolor');
    if any(oldcol~=tlcol) set(ht,'edgecolor',tlcol); end;
end;
if strcmp(P.promptmode,'image')
    hai=findobj('type','axes','tag',P.imageprefix);
    oldcol=get(hai(1),'color');
    if any(oldcol~=tlcol) set(hai,'color',tlcol); end;
    %    oldcol=get(figh(1),'color');
    %    if any(oldcol~=tlcol) set(figh,'color',tlcol); end;
end;
