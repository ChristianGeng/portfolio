function prompter_ini_base(functionname,stimfile,logfile,Sin)
% PROMPTER_INI_BASE Basic initialization of prompter programs
% function prompter_ini_base(functionname,stimfile,logfile,Sin)
% prompter_ini_base: Version 18.09.2013
%
%   Description
%       Basic intialization of prompter programs, i.e read stimulus file, open log
%       file, create subject and investigator figures, initialize main data
%       structures.
%       Most settings (except stimfile and logfile) are controlled by the
%       fields of the struct Sin provided as input to the main program
%       (e.g. prompter_parallel_main)
%        i.e before calling prompter_parallel_main set up Sin with lines
%        like 
%           Sin.trial_duration=2;
%       Details of each field is given below under Settings, with default
%       in [], and one of these abbreviations for the data structure where it is
%       accessible after program start: <P>, <S>, <W> corresponding to the functions
%       prompter_smaind, prompter_sstimd, prompter_swaved for setting and
%       their counterparts prompter_gmaind etc. for retrieving current
%       values.
%
%	Syntax
%
%       stimfile
%           Name of text file containing stimuli for experiment.
%           First line must be number of lines in the prompt text for each
%           stimulus.
%           Each prompt must thus consist of the same number of lines. If
%           necessary pad with blank lines.
%           For each stimulus, the prompt (seen by the subject) must be
%           followed by a one-line code (stored in the log file).
%           If the first line of the prompt to the subject starts with
%           '<IMAGE>' then the rest of the line e.g '01', '21', is treated as the index
%           into a cell array of images, and the prompt will consist of an
%           image display, not text.
%           If any image prompts are found when the stimulus file is
%           loaded, then struct Sin must include the field 'imagefile'
%           giving the name of a mat file containing variable 'data' (cell
%           array with the images).
%
%       logfile
%           Name of text file to which to write experiment log
%
%   Settings
%
%		fontsize [0.1] <P> (but after program start use texthandles for modifications) 
%           Size of font for stimulus display to subject. Given in
%           normalized units.
%		    See documentation of matlab text function for details.
%           If the specified size is too large to fit the stimulus text on the
%           screen, then it is automatically reduced. The reduction factor is
%           displayed to the user, so it is possible to do a test run to
%           determine a fontsize that will not require reduction for any
%           stimulus. This will be necessary if you want to be sure the font
%           size is the same for all stimuli.
%
%		trial_duration [2.5] <P>
%           Specify in seconds.           
%           Click in running time display in investigator window to terminate trial by hand
%           before the end of the set duration.
%
%		wavstart [] <P>
%           Name of wav file to play at start of trial (e.g. beep as
%           acoustic signal to subject; playback is initiated immediately before trafficlights turn green).
%           The data from the wav file is read in as part of the initialization
%           procedures.
%           If it is necessary to access the data for the wavstart sound while
%           the experiment is running use the prompter_g/swaved utility
%           function to access the fields wavstart_d, wavstart_sf,
%           wavstart_bits.
%           
%       usestartwav [0] <P>
%           Flags whether the wavstart sound is to be used. Automatically
%           set to 1 if the file given in wavstart is successfully loaded.
%           Can be used to e.g. temporarily suspend use of the wavstart
%           sound during the experiment.
%
%       wavstart_async [0] <A>
%           If set to 1 the program does not wait for the wavstart sound to
%           finish playing before continuing.
%           For applications with AG500 etc. control the wavstart sound is
%           played immediately after the attn signal is detected from the
%           sybox. For these cases it will normally be preferable to set
%           wavstart_async to 1.
%
%       wavend [] <P>
%           See wavstart for details
%
%       useendwav [0] <P>
%           See usestartwav for details
%
%       wavend_async [0] <A>
%           See wavstart_async for details.
%
%		wavlist [] <S>
%           In addition to wavstart and wavend
%           there is a separate facility for giving a different audio
%           prompt to the subject for each stimulus. 
%           This must be a list of wav files, exactly corresponding to the
%           number of stimuli.
%           Note that unlike wavstart and wavend these wav files are not
%           read until the stimulus is used, so any problems with the wav
%           files will not become apparent during the initialization phase.
%           Once the experiment is running the wavlist can be manipulated by hand
%           using the utility function prompter_sstimd.
%           Note: userstartfunc is called after wavlist playback, but
%           before wavstart playback
%
%       usewavlist [0] <P>
%           Flags whether the sounds in wavlist are to be used. Automatically
%           set to 1 if wavlist specified during initialization.
%           Can be used to e.g. temporarily suspend use of the wavlist
%           sounds during the experiment.
%
%       wavlist_async [0] <S>
%           If set to 1 the program does not wait for the wavlist sound to
%           finish playing before continuing.
%
%       ai_duration [0] <P>
%       ai_object [] <P>
%       ai_settings [] <P>
%           Intended to be freely used by user programs to help in
%           interfacing with analog input hardware (e.g. for acquiring data
%           from ADLINK multichannel board when running ultrasound
%           experiments)
%           Suggested use: Assume ai should be run if ai_duration > 0
%               ai_object: use to make the analog input object created by
%               the data acquistion toolbox available from any user
%               function in the prompt program
%               ai_settings: struct for overriding default settings e.g.
%               for samplerate, input range, channel names
%
%       TL <P>
%           'Traffic-light' colours for telling subject when to speak.
%           This is itelf a struct with the following fields and defaults:
%                   TL.stop=[1 0 0], TL.go=[0.1 0.8 0.1], TL.getready=[1 1 0]
%                   i.e red, green(ish) and yellow, respectively.
%           Thus setting all to [0 0 0] will result in no change of
%           colour in the text (or image) frame when trials start and stop.
%
%       texthandle <P> !!n.b: do not modify. treat as read-only!!
%           The text objects in the subject and investigator window with
%           the prompt text are accessible via this handle, allowing their
%           properties to be modified.
%           Useful settings include 'font' (e.g use an Arabic
%           font), or 'horizontalalignment' (default is 'left').
%           This is best used in conjuction with the usersetfunc setting
%           (see below).
%           i.e. define a function with lines like the following
%               P=prompter_gmaind;
%               ht=P.texthandle;
%               set(ht,'fontweight','bold');
%           then specify the name of this function for usersetfunc
%                   (Alternatively, modifications to text attributes of parts of
%                   individual prompts can be obtained using the stream
%                   modifiers explained in the documentation of the text
%                   function (in combination with the backslash operator,
%                   e.g inserting \bf into the prompt of a particular stimulus causes following characters to be bold.
%                   (Special symbols can also be obtained in this way))
%
%       usersetfunc [] <P>
%           Name of function to call at end of settings, before
%           starting actual prompting, e.g to modify text attributes etc.
%
%       userset2func [] <P>
%           User function called by prompter_restorefigpos
%           Some settings cannot be done by usersetfunc because special
%           versions of the program (e.g for AG500 and Sonix control)
%           create figures after usersetfunc has been called at the end of
%           basic initialization
%
%       useragsetfunc [] <P>
%           For AG control. Called at end of AG initialization
%
%       usersonixsetfunc [] <P>
%           For control of Sonix ultrasound. Called at end of Sonix initialization
%
%       sonixfilename [] <P>
%           Base filename for ultrasound. Copied to filenamebase by
%           prompter_inisonix
%
%       userstartfunc [] <P>
%           For more sophisticated modifications of prompts etc. it
%           is possible to specify matlab code to be called at the
%           start of each trial (i.e. at the beginning of the next command)
%
%       userstopfunc [] <P>
%           Name of function to execute at the end of each trial.
%           See userstartfunc for details 
%           Executed AFTER display of new stimulus (cf.
%           userparallelstopfunc)
%
%       userattnfunc [] <P>
%           Name of function to execute when the AG500 attention signal is
%           detected.
%
%       userparallelstartfunc [] <P>
%           User function called when the 'start' command is issued to
%           function prompter_paralleloutctl. Use as an alternative to
%           userstartfunc when precise synchronization with an external
%           event (i.e sync pulse to parallel port) is desired).
%           Note that this function is executed even no parallel port mode
%           is active.
%
%       userparallelstopfunc [] <P>
%           User function called when the 'stop' command is issued to
%           function prompter_paralleloutctl.
%           (executed before display of new stimulus)
%
%       hidemode [0] <P>
%           If > 0 (true), no messages about repeats or change of stimulus are
%           shown to the subject. Also the current stimulus is not shown to
%           the subject until the 'next' command is issued (rather than immediately at the end
%           of the previous trial). If > 1 the stimulus is not made visible
%           at the 'next' command either, so controlling visibility of the
%           stimulus is completely under user control (e.g using
%           userstartfunc, or userattnfunc (with AG500)).
%           If set to 1 could e.g. be combined with using userstartfunc to define a
%           pause, to give precise control about how long the prompt is
%           visible before the trial starts.
%
%       paralleloutmode ['simple'] <P>
%           Determines the use made of the parallel output port.
%           simple:     Uses line determined by synchline to signal start and
%                       end of trial. Uses parallel port interface of data
%                       acquisition toolbox
%           porttalk:   Same as 'simple', except that the lptwrite function
%                       (and the porttalk interface package) is used.
%                       This is necessary when e.g a PCI express parallel
%                       port card is used, that does use the 'traditional' io-addresses for LPT1, 2 or 3
%                       (The data acquistion toolbox is restricted to the
%                       standard addresses)
%                       See e.g. http://psychtoolbox.org/FaqTTLTrigger for
%                       more background.
%           vtg55:      Controls vtg55 video timer
%                       Use this setting to get
%                       prompter_parallel_trigagmain to work like the old
%                       ag500 prompt programs. Does not currently work if
%                       porttalk-style access is required.
%           any other values: No signalling via the parallel port
%           Note: Changing parallel port settings has no effect after the
%           end of the initialization phase.
%
%       parallelinmode ['none'] <P> (but set to 'ag500' by prompter_parallel_trigagmain)
%           Determines use made of parallel input port
%           Currently only used to handle status signals from ag500 sybox
%
%       synchline [8] <P>
%           parallel port line to signal start and end of trial.
%           Default of 8 is compatible with also controlling the vtg55
%			This is the appropriate setting if using the additional connection on the special box used
%			at Munich to connect the parallel port input to the AG500 and the output to the VTG55
%			video timer.
%			Set to 1 if using a cable like that used for synch output from Phil's version
%			of the AG100 software.
%           In 'porttalk' mode this is the VALUE to write to the port (i.e.
%           normally a power of 2 to access a specific line (1, 2 .....
%           128)
%
%       lptaddress ['LPT1'] <P>
%           Address to use for access to parallel port.
%           For access via data acquistion toolbox use this style (i.e. a
%           string that can be LPT1/2/3).
%           For porttalk mode there is no default. This must the hardware
%           address to use (specified as a normal double value, not a
%           string). For example, for a PCIe card intalled in the IPS
%           ultrasound control PC (as of 2.2013) this was 4352.
%           If necessary look up the address in the device manager and
%           convert from hex (i.e. this was hex2dec('1100'))
%
%       vtgtrialflag [0] <P>
%           Set to 0 to completely turn off display of
%           trial number on the video timer. One reason for doing this
%           is that the setting can be q0uite slow, so it speeds up the
%           start of the next trial (e.g when using auto-next mode)
%
%       vtgtrialfix [1] <P>
%           Set to 1 to always use same trial number (1)
%           on video timer display (alternative way of speeding up the display)
%
%       compromptflag [0] <P>
%           Set to 1 to activate use of VT200-style terminal for prompt display
%           via serial port.
%
%       repeatmsg ['!Repeat!'] <P>
%           Message to subject when repeating a stimulus
%
%       changestimmsg ['!Change of Stimulus!'] <P>
%           Message to subject when changing stimulus
%
%       endmsg ['!!END!!'] <P>
%           Message to subject when end of stimulus list is reached
%
%       newsequencemsg ['!New Sequence!'] <P>
%           Message to subject when starting stimulus sequence
%           i.e. if the program is not terminated when the end of the
%           stimulus list is reached
%
%       freecode [] <P>
%           Added to the code that is output to the log file
%           Could be used to indicate e.g a second pass through the
%           stimulus list (use prompter_smaind)
%
%       imagefile [] <P>
%           If the stimulus file indicates the use of images as prompts
%           this must contain the name of the mat file with the image data.
%           See notes on stimfile above
%
%       infohandle <P> !!n.b: do not modify. treat as read-only!!
%           handles of the two text objects at the top of the investigator
%           window (trial number and running time; stimulus number and
%           code)
%
%       htinforuncol ['k'] <P>
%           Color of text objects given by infohandle (see above)
%           when trial is not running.
%           Normally no change. May be useful if normal traffic-light
%           colours are not used for the prompt itself
%
%       htinfostopcol ['k'] <P>
%           Counterpart to htinforuncol (see above). Color when trial is
%           not running
%
%       autonextbackgroundcolor ['r'] <P>
%           Background color of the lower text object in the investigator
%           window when autonext mode is in operation (indicates where to
%           click to cancel autonext)
%
%       marklist [] <P>
%           List of stimuli that have been marked for possible repeat later
%           (by pushing onto stimulus stack)
%
%       stimstack [] <P>
%           If not empty, next stimulus is taken from this stack rather
%           than incrementing last stimulus
%           Normally, when stimuli are added to an empty stack (e.g. from
%           the marklist) then the last item in the stack should be
%           the stimulus from which to resume normal progress through the
%           stimulus file (prompter_markedstim2stimstack handles this
%           automatically)
%
%       stimfromstack [0] <P>
%           flags whether current stimulus was taken from stack
%
%       showrunningtime [1] <P>
%           flag whether running time in trial is updated in investigator window
%
%       pausetimewhiletrialrunning [0.02] <P>
%           time resolution for updating running trial time in investigator
%           window. Also the interval at which the program checks for mouse
%           click to terminate trial. Together with showrunningtime this
%           setting gives some control over how much time is available
%           for background processes to run
%
%       abortnext [0] <P>
%           intended for use by userstartfunc to cause rest of next command
%           to be ignored

philcom(1)
imageprefix='<IMAGE>';
P.imageprefix=imageprefix;

ipi=findstr(':',functionname);

P.function_name=lower(functionname(1:(ipi-1)));
P.function_version=functionname((ipi+1):end);
%is this an appropriate default for all prompt versions?
trial_duration=2.5;
if isfield(Sin,'trial_duration')
    if ~isempty(Sin.trial_duration)
    trial_duration=Sin.trial_duration;
end;
    Sin=rmfield(Sin,'trial_duration');
end;
P.trial_duration=trial_duration;

%note: fontsize currently stored in userdata of text object, not main
%structure
fontsize=0.1;
if isfield(Sin,'fontsize') 
    fontsize=Sin.fontsize; 
    Sin=rmfield(Sin,'fontsize');
end;
P.fontsize=fontsize;

synchline=8;
if isfield(Sin,'synchline') 
    synchline=Sin.synchline; 
    Sin=rmfield(Sin,'synchline');
end;
%only relevant in paralleloutmode simple and porttalk
P.synchline=synchline;

%only relevant in paralleloutmode vtg55
P.vtgtrialflag=0;     %trial number on VTG video timer. Disable if not needed, as setting can be rather slow
P.vtgtrialfix=1;      %If true, trial number always 1 (also to speed up, if trial number not essential)

%handling of parallel port output lines
%simple/porttalk: just signal start and stop via synchline
%vtg55: control fora vtg55
%currently any other setting means parallel out is not used
P.paralleloutmode='simple';
P.parallelinmode='none';        %set to 'AG500' to handle sybox status signals

P.lptaddress='LPT1';


P.compromptflag=0;    %prompt on serial VT100 style monitor


P.irun=1;
P.istim=1;
P.laststim=[];
P.finished=0;
P.ok2rec=1;   %if false, blocks n command following m command
P.abortnext=0;  %can be used by userstartfunc to skip rest of next command
P.newsequencemsg='!New Sequence!';
P.changestimmsg='!Change of Stimulus!';
P.endmsg='!!END!!';
P.repeatmsg='!Repeat!';
P.repeat4log='!!Repeat!!';
P.rubbish4log='!!Rubbish!!';
P.mark4log='!!Marked!!';
P.stack4log='!!From stack!!';
P.repeatstr='';
%P.rubbishstr='';
%controls whether next prompt is shown immediately to subject
%currently also suppresses messages to subject like repeat, change of
%stimulus. This may be made more flexible in future
P.hidemode=0;       
P.freecode='';
%P.freecomment='';
P.logtext_trial='';
P.logtext_sup='';   %additional log text like, trial duration, autonext, comment
P.autonext=0;
P.autodelay=0;

P.daqok=1;      %prompter_parallel sets to zero if no access to parallel port

P.usestartwav=0;
P.useendwav=0;
P.usewavlist=0;

S.wavlist=[];
S.wavlist_async=0;

%fields for interfacing with analog input hardware (added 9.2013)
P.ai_duration=0;
P.ai_object=[];
P.ai_settings=[];



%matlab commands, or script or function file, to be executed at start and
%end of trial (i.e the string specified here is passed to the eval
%function)
%Using a function is preferable, to reduce chances of inadvertently
%changing program variables
%This mechanism could be used as an alternative way of handling audio
%output depending on current stimulus. Should mainly be useful for
%modifying the prompt display in various ways.
%could also be used to enforce a minimum 'getready' duration.

P.userstopfunc=''; %called at end of trial, just before new stimulus is displayed (so e.g could be used to make
%stimulus invisible until the next 'next' command
P.userstartfunc=''; %called during the next command, before start of trial. Specifically, after any audio
%output specified in wavlist has been done. 
% In prompter_parallel_trigag it is called before the signal to the AG500
% control server to start the trial
% In prompter_parallel_trigin it is called before the program waits for the
% attention signal.
P.userattnfunc=''; %called after the program has detected the attention function, but after the prompt colour has
%changed to 'go' and after the wavstart sound has been output.
%The will allow more precise temporal alignment to AG500 activity than
%using userstartfunc. If good temporal alignment is important than using
%the wavstart sound as well should probably be avoided

P.userparallelstartfunc=''; %called by prompter_paralleloutctl after start signal has been sent to parallel port
P.userparallelstopfunc=''; %called by prompter_paralleloutctl after start signal has been sent to parallel port


P.usersetfunc=''; %called at the end of initialization, e.g to make graphics settings
P.userset2func=''; % called by prompter_restorefigpos, i.e could be useful for graphic setting
%that can only be done when all figures have been created and are at the
%desired size
P.useragsetfunc=''; %called at the end of ag initialization, e.g. timeout settings/messages
P.usersonixsetfunc=''; %called at the end of sonix initialization.
P.sonixfilename=''; %copied to filenamebase by sonix initialization

%these settings can be useful if a lot of background processing is going on
%while the trial is running
P.showrunningtime=1;    %flag whether running time in trial is updated in investigator window
P.pausetimewhiletrialrunning=0.02;  %= video field date (appropriate if investigator window recorded on video)

P.marklist=[];      %marked stimuli (may be repeated later by pushing onto stimstack)
P.stimstack=[];     %if stimstack is not empty, next stimulus is taken from stack rather than incrementing last stimulus
P.stimfromstack=0;


[ps,cs,s1line,nstim,nline,prepareimage,maxcol]=parsestimfile(stimfile,P.imageprefix);
S.ps=ps;
S.cs=cs;
S.s1line=s1line;

P.nstim=nstim;
P.nline=nline;
P.prepareimage=prepareimage;
P.maxcol=maxcol;
P.stimfile=stimfile;
P.logfile=logfile;

helpwin(P.function_name);

helpwin(s1line,stimfile);


fid=fopen(logfile,'w');
if fid<3
    disp('unable to open log file');
    return
end;
ts=['<' functionname '>' crlf];
status=fwrite(fid,ts,'uchar');
if status~=length(ts)
    disp('Problem writing to log file');
    fclose(fid);
    error;
end;
P.logfilefid=fid;

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
set(haxp,'tag','text');

haxi=[];
%vi=strmatch(imageprefix,ps);
%if ~isempty(vi)
    imagedata=[];
if prepareimage
    disp('Preparing for image data');
    haxi=axes;
    set(haxi,'position',get(haxp,'position'));
    set(haxi,'tag',imageprefix);
    hi=image;
    set(hi,'tag',imageprefix);
    %make sure axis ticks and labels are not visible when axes is visible
    %but see note below
    set(haxi,'ycolor',get(hfsub,'color'),'xcolor',get(hfsub,'color'));
    %7.10 use axes rather than figure color to cue the subject
    set(haxi,'color','r','linewidth',10);
    set(haxi,'visible','off');
    set(hi,'visible','on');
    
    %image file name must be in input struct
    if isfield(Sin,'imagefile')
        disp(['Loading image data from ' Sin.imagefile]);
        %assumes that the mat file contains variable 'data' with the image data
        %no checks yet. program will simply crash if any problems
        imagedata=mymatin(Sin.imagefile,'data');

        %11.2012
        %userdata of haxi is set below after axes have been copied from
        %subject to investigator window
        %(to avoid having a superfluous copy of the whole image file)
        
        %        set(haxi,'userdata',mymatin(Sin.imagefile,'data'));
        P.imagefile=Sin.imagefile;
        Sin=rmfield(Sin,'imagefile');
%        tmpxx=get(haxi,'userdata');
        tmpxx=imagedata{1};
        set(hi,'cdata',tmpxx);
        axis(haxi,'image');

%maybe one way of deciding on scaling for imagestif2mat
%but can only be done after final figure positions have been set
%not the best way of getting the handle
%haxi=findobj(1,'type','axes','tag','<IMAGE>');
%tmpunit=get(haxi,'units');
%        set(haxi,'units','pixel');
%        postmp=get(haxi,'position');
%       set(haxi,'units',tmpunit);
%   disp(['Image axis x/y size in pixels : ' int2str(postmp(3:4))]);
        
        
        tmpdim=ndims(tmpxx);
        if tmpdim==2
            if isfield(Sin,'colormap')
                set(get(haxi,'parent'),'colormap',Sin.colormap);
                Sin=rmfield(Sin,'colormap');
            else
                %should normally be ok for monochrome (0/1 (logical)) or grayscale (0..255)
                %data
                maxval=double(max(tmpxx(:)));
                disp(['Setting color map for image display to gray(' int2str(maxval+1) ')']);
                disp('If this is not appropriate set colormap explicitly using colormap field of input struct');

                set(get(haxi,'parent'),'colormap',gray(maxval+1));
            end;
            
        else
            disp('Assuming input is true color');
        end;
        
        clear tmpxx;
        
        %Notes on settings: normally set axis image or axis equal (not sure
        %what happens with axis image if image size varies)
        %But for the normal case of same-size images then axis image is better.
        %(axis equal will leave additional strips in the axis color with size
        %depending on precise image dimensions, - and also little notches in the
        %background color at the tick location (can be fixed with e.g
        %set(haxi,'xtick',[]);
        
        
    else
        disp('Input struct must include field imagefile with filename of image data');
        %or allow to continue??
        return;
    end;
    
    
    set(hi,'visible','off');
    
end;

hfinv=[];
hfinv=figure;
set(hfinv,'color',get(hfsub,'color'));
set(hfinv,'menu','none');
set(hfinv,'colormap',get(hfsub,'colormap'));	%ensure colormaps are same, especially for image mode

copyobj([haxsub haxi],hfinv);
ht(2)=findobj(hfinv,'type','text','tag','prompt');
set(hfinv,'name','Investigator');
%show trial number and current time in investigator prompt window
%make axes a bit smaller to give room for text above
haxinv=findobj(hfinv,'type','axes');
mypos=get(haxinv(1),'position');
mypos(1:2)=[0.05 0.01];
mynewsize=mypos(3:4)*0.8;		%factor will depend on how many lines of text
mypos(3:4)=mynewsize;
set(haxinv,'position',mypos);
haxa=findobj(haxinv,'tag','text');
axes(haxa); %make sure these text objects are created in the text axes
%for trial number and time counter while trial is running
tmptsize=0.08;
tmptbase=1.2;
htinfo(1)=text(0,tmptbase,' ','fontweight','bold','fontunits','normalized','verticalalignment','bottom','tag','info1');
%for stimulus and code
htinfo(2)=text(0,tmptbase-(tmptsize*1.2),' ','fontweight','bold','fontunits','normalized','verticalalignment','bottom','interpreter','none','tag','info2');
%shows text written to log file. Mainly for when investigator figure is
%video-recorded
htinfo(3)=text(0,tmptbase-(tmptsize*1.4),' ','fontweight','bold','fontunits','normalized','verticalalignment','top','interpreter','none','tag','info3');

set(htinfo(1:2),'fontsize',tmptsize,'erasemode','xor');
set(htinfo(3),'fontsize',tmptsize*0.75,'erasemode','xor');
set(hfinv,'doublebuffer','on');

if ~isempty(imagedata)
set(haxi,'userdata',imagedata);
clear imagedata;
end;




%could be used to indicate stopped/running if normal traffic lights are not
%used for this (or if not visible on video)
P.htinforuncol='k';
P.htinfostopcol='k';
P.autonextbackgroundcolor='r';  %set in htinfo(2)
P.infohandle=htinfo;
P.texthandle=ht;

P.figurebasecolor=get(hfsub,'color');
P.promptmode='text';


%colors for signal to subject
%normal colours
TL.stop=[1 0 0];
TL.go=[0.1 0.8 0.1];
TL.getready=[1 1 0];

%no change in colours
%TL.stop=[0 0 0];
%TL.go=[0 0 0];
%TL.getready=[0 0 0];

P.TL=TL;

%audio start and end
%no error checking. Program will just crash if audio data is not available
P.wavstart=[];
if isfield(Sin,'wavstart')
    P.wavstart=Sin.wavstart;
    Sin=rmfield(Sin,'wavstart');
    [tmpd,A.wavstart_sf,A.wavstart_bits]=wavread(P.wavstart);
    P.usestartwav=1;
    A.wavstart_player=audioplayer(tmpd,A.wavstart_sf,A.wavstart_bits);
end;

P.wavend=[];
if isfield(Sin,'wavend')
    P.wavend=Sin.wavend;
    Sin=rmfield(Sin,'wavend');
    [tmpd,A.wavend_sf,A.wavend_bits]=wavread(P.wavend);
    P.useendwav=1;
    A.wavend_player=audioplayer(tmpd,A.wavend_sf,A.wavend_bits);
end;

%if true, program continues without waiting for end of sound
%most appropriate default may depend on prompt function
A.wavstart_async=0;
A.wavend_async=0;

if isfield(Sin,'wavstart_async')
    A.wavstart_async=Sin.wavstart_async;
    Sin=rmfield(Sin,'wavstart_async');
end;

if isfield(Sin,'wavend_async')
    A.wavend_async=Sin.wavend_async;
    Sin=rmfield(Sin,'wavend_async');
end;

if isfield(Sin,'wavlist') 
    wavlist=Sin.wavlist; 
    if (size(wavlist,1)==nstim)
        S.wavlist=wavlist;
        P.usewavlist=1;
    else
        disp('wavlist does not match number of stimuli and will not be used');
        keyboard;
    end;
    Sin=rmfield(Sin,'wavlist');
end;

if isfield(Sin,'wavlist_async') 
        S.wavlist_async=Sin.wavlist_async;
    Sin=rmfield(Sin,'wavlist_async');
end;



%===============================================


%for cancelling autonext mode
%set(hfinv,'userdata',0,'windowbuttondownfcn','prompter_cb');
set(htinfo(2),'userdata',0,'buttondownfcn','prompter_cb');
%for cancelling trial in progress
set(htinfo(1),'userdata',0,'buttondownfcn','prompter_cb');
%set(0,'userdata',0,'buttondownfcn','prompter_cb');

P.figure_names=str2mat('Subject','Investigator');

%handle any remaining settings in input struct....

set(hfsub,'userdata',P);
set(haxp,'userdata',S); %in text axes of subject figure
%text axes of investigator will be used for audio data

haxa=findobj(hfinv,'type','axes','tag','text');
set(haxa,'tag','wave');
set(haxa,'userdata',A);

%use any remaining fields of Sin to make settings in P
sfield=fieldnames(Sin);
nfield=length(sfield);
for ifi=1:nfield
    myfield=sfield{ifi};
    if isfield(P,myfield)
disp(['Setting ' myfield]);
        P.(myfield)=Sin.(myfield);
    end;
end;

prompter_smaind(P);

prompter_evaluserfunc(P.usersetfunc,'set');


%can also adjust text properties, traffic light colours etc. by hand
%disp('Adjust figure positions, if desired; then type return');
%disp('(Optionally adjust other settings)');
%dummy;

prompter_dotrafficlights('stop');

drawnow;
prompter_updatefigs;
%set(gcf,'menu','none')

%============================================
%end of basic initialization
%==============================================
%
