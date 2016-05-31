function prompter_epg(stimfile,logfile,trial_duration,fontsize,startwav,endwav,epgstruc);
% PROMPTER_EPG Stimulus display with monitoring of AG500 status and video timer control
% function prompter_epg(stimfile,logfile,trial_duration,fontsize,startwav,endwav,epgstruc);
% prompter_epg: Version 12.2.08
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
%		startwav and endwav (optional; set to empty if not required). WAV files played at start and end, respectively
%				could be just a bell, but could also be e.g a synch inpulse
%               There is a separate facility for giving a different audio
%               prompt to the subject for each stimulus. See explanation of
%               'wavlist' below
%       epgstruc: Compulsory for the EPG version. A structure with the following fields:
%           comname,filename,samplerate,maxframes;
%           These are passed to the ini command of EPG_RT. See
%           documentation of the latter function for more details
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
%
%   See Also
%       VTGCTRL Control FORA VTG55 video timer via parallel port
%       COMPROMPT Display prompt on VT200 terminal using serial COM port
%       PROMPTCB Callback so user can interrupt auto-next mode
%
%   Updates
%       1.08 Delay in auto mode

% Monitors ag500 status signals
% test version with prompt triggered by ag500 syncbox
% Incorporates video timer control and synch output from PC
% Prompt output also to serial monitor (see COMPROMPT)


functionname='prompter_epg: Version 12.2.08';



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


compromptflag=0;    %prompt on serial VT100 style monitor
vtgtrialflag=1;     %trial number on VTG video timer. Disable if not needed, as setting can be rather slow
vtgtrialfix=0;      %If true, trial number always 1 (also to speed up, if trial number not essential)



daqok=1;
try
    parport = digitalio('parallel','LPT1');
catch
    daqok=0;

    %eventually it should be possible to continue without parallel port
    %functions

    disp('Parallel port not available');
    disp('Check you have administrator privileges');
end;




if daqok
    vtgctrl('ini',parport);
    start(parport);
end;


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

helpwin prompter_epg;

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
    axis equal
    set(haxi,'visible','off');
    set(hi,'visible','off');
    disp('load image data');
    keyboard;

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

hfepg=epg_rt('ini',epgstruc.comname,epgstruc.filename,epgstruc.samplerate,epgstruc.maxframes);
maxtrialtime=epgstruc.maxframes/epgstruc.samplerate(1);

epguserdata=get(hfepg,'userdata');

%This is used as a flag that acquistion has terminated
%Can be set by timer callback, error condition, maxframes reached, or user
%click in epg figure
hlepg=epguserdata.datahandle;


if isempty(trial_duration) trial_duration=maxtrialtime; end;
timer_duration=trial_duration;
htimer=timer('timerfcn',{@epgtimercb,hlepg},'startdelay',timer_duration,'tag','prompter_epg_timer');




all_done=0;
irun=1;
showhelp
ok2rec=1;

while ~all_done
    epg_rt('recstart',0);
    ts=datestr(now);
    ts=['<Start of Sequence ' functionname '> ' ts crlf];
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

    tmpmessage=epgcheckerror(fid);

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

                epg_rt('recstop');    %stop monitoring display

                tmpmessage=epgcheckerror(fid);

                epguserdata=get(hfepg,'userdata');

                %Note: unlike in the log file only the repeated trial will be flagged, not
                %the 'rubbish' trial
                %This is stored in the epg mat file
                epguserdata.item_id=[cs{istim} repeatstr];
                set(hfepg,'userdata',epguserdata);

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



                dotrafficlights(TL.getready,ht,figh);

                drawnow;
                %needs testing
                %            if compromptflag comprompt('message','!Get Ready!); end;
                %finish off last comment
                status=fwrite(fid,[rubbishstr freecomment ']' crlf],'uchar');
                freecomment='';
                rubbishstr='';

                %show trial number on video timer

                %allow trial number display to be skipped
                vtgtrialnum=irun;
                if vtgtrialfix vtgtrialnum=1; end;

                if daqok
                    if vtgtrialflag vtgctrl('trial',vtgtrialnum); end;
                end;




                if compromptflag comprompt('message'); end;

                %               set(ht,'color',[0.1 0.8 0.1]);
                %                    set(ht,'edgecolor',[0.1 0.8 0.1]);

                %maybe use daq da functions for sound
                %i.e prepare sound beforehand and then trigger here
                %may give more precise synchronization and quicker activation
                %use mysound????, what about scaling????
                if ~isempty(wavstart)
                    soundsc(wavstart_d,wavstart_sf,wavstart_bits);
                end;

                %could also call any m-file either here or after sweep start (e.g
                %perform further timer controlled audio or image output


                %start video timer and set synch out
                %Note: start of the video timer will not be synchronous with the first
                %stored epg frame
                %If it is desired to now this precisely, it will be necessary to record the
                %synch out from the parallel port, as well as the epg synch (buzzer) signal
                if daqok vtgctrl('start'); end;
                %uses minutes units as flag that trial is running  (e.g for
                %automatic detection in image data. reset by vtg reset below
                %(needs changing so synch line doesn't get reset)
                %            vtgctrl('minset');


                sx=int2str([irun istim]);
                epg_rt('recstart',irun);

                tmpmessage=epgcheckerror(fid);
                dotrafficlights(TL.go,ht,figh);

                drawnow;
                disp('Recording');
                mytime=now;
                tic;

                timer_duration=trial_duration;
                set(htimer,'startdelay',timer_duration);
                start(htimer);
                waitfor(hlepg,'userdata',1);

                stop(htimer);

                epg_rt('recstop');

                %stop video timer
                if daqok vtgctrl('stop'); end;

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





                mytoc=toc;

                %get log message and error flag


                epglogmessage=epgcheckerror(fid);
                epglogmessage=['<' epglogmessage '>'];


                disp(['Trial/Stimulus ' int2str([irun istim]) ' stopped after ' num2str(mytoc) ' s']);
                [dodo,mytime]=strtok(datestr(mytime));
                sx=[sx ' ' mytime];
                sx=[sx ' ' num2str(mytoc)];


                epguserdata=get(hfepg,'userdata');
                repeatlast=0;
                if epguserdata.totalframes==0 | epguserdata.synchfound==0
                    repeatlast=1;
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
                sx=[sx mycomm epglogmessage];
                status=fwrite(fid,sx,'uchar');

                if daqok vtgctrl('reset'); end;
                %all digits zero

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

                epg_rt('recstart',0);       %re-start monitoring display
                tmpmessage=epgcheckerror(fid);
                if repeatlast mycmd='R'; end;       %best way of handling this?
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
                repeatstr=[repeatstr 'Trial number not incremented!!'];
            end;
            showg(ht,'\fontname{Helvetica}!Repeat!',compromptflag);

            disp('hit any key to continue');
            pause
            showg(ht,ps{istim},compromptflag);
            dotrafficlights(TL.stop,ht,figh);
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
            repeatlast=0;

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
            %maximum epg frames?????
            trial_duration=abart('New duration',trial_duration,1,maxtrialtime,abnoint,abscalar);
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

delete(htimer);

delete([hfsub;hfinv]);
epg_rt('recstop');

epg_rt('shutdown');

if daqok
    delete(parport);
    clear parport;
    daqreset;

end;

if compromptflag comprompt('reset'); end;



function showg(ht,mys,compromptflag);
imageprefix='<IMAGE>';

hi=findobj('type','image','tag',imageprefix);
if ~isempty(hi) set(hi,'visible','off'); end;

set(ht,'visible','off');

mysc=char(mys);
hfsub=findobj('type','figure','name','Subject');

P=get(hfsub,'userdata');
if findstr(imageprefix,mysc(1,:))

    if ~isempty(hi)
        tmp=strrep(mysc(1,:),imageprefix,'');
        imnum=str2num(tmp);
        if ~isempty(imnum)
            hai=findobj('type','axes','tag',imageprefix);
            if ~isempty(hai)
                imdata=get(hai(1),'userdata');
                if iscell(imdata)
                    imdata=imdata{imnum};
                    set(hi,'cdata',imdata);
                    set(hi,'visible','on');
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

set(ht,'visible','on');
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
    oldcol=get(figh(1),'color');
    if any(oldcol~=tlcol) set(figh,'color',tlcol); end;
end;
function logmessage=epgcheckerror(fid);

hfepg=findobj('type','figure','tag','EPGRT');
epguserdata=get(hfepg,'userdata');
epgerrorflag=epguserdata.errorflag;
logmessage=epguserdata.logmessage;
if epgerrorflag
    disp('EPG error');
    errormessage=[crlf '<EPG_RT Error ' int2str(epgerrorflag) ', ' logmessage ' Trial ' int2str(epguserdata.currenttrial) '>' crlf];
    disp(errormessage);
    keyboard;

    status=fwrite(fid,errormessage,'uchar');
    logmessage='';
end;
function epgtimercb(cbobj,cbdata,hlepg);
set(hlepg,'userdata',1);
