function prompter_parallel(stimfile,logfile,trial_duration,fontsize,startwav,endwav);
% PROMPTER_PARALLEL Prompt program with synch signal output on parallel port. Will also run when port n.a
% function prompter_parallel(stimfile,logfile,trial_duration,fontsize,startwav,endwav);
% prompter_parallel: Version 4.12.09
%
%	Syntax
%		fontsize: (eventually) If missing, try and set automatically???
%				note: is used with fontunits = normalized
%		trial_duration: in s. if empty stop interactively (key press)
%		startwav and endwav (optional). WAV files played at start and end, respectively
%				could be just a bell, but could also be e.g a synch
%				inpulse.
%				If start/endwav are string matrices the same length as stimfile
%				then a different file can be used for each trial (not yet implemented)
%
%   Description
%       Outputs synch signal to parallel port at start of trial.
%       Simple version of prompter_parallel_trigin, without video timer
%       control and monitoring of AG500 status
%       This version can be used when daq toolbox access to parallel port
%       not available.
%       Thus also useful for testing integrity of prompt files before
%       experiment because it can be run when parallel port in not
%       accessible (this requires administrator privileges on Windows XP
%       It is intended that this program will eventually be merged with
%       prompter_parallel_trigin
%
%   See Also PROMPTER_PARALLEL_TRIGIN

functionname='PROMPTER_PARALLEL_V: Version 26.08.2010';

philcom(1)
imageprefix='<IMAGE>';

synchline=8;        %compatible with vtgctrl (otherwise use 1)
%synchline=1;
wavlist=[];
wavlistsynch=0;		%12.09

iscreen=1;      %additional prompt figure for investigator

daqok=1;
try
    parport = digitalio('parallel','LPT1');
    lines_OUT_1 = addline(parport,[0:7],0,'out');
    
    putvalue(parport.Line(synchline),0);
catch
    disp('parallel port not available, try logging in as administrator');
    daqok=0;
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
wavstart_async=0;
wavend_async=0;

[ps,cs,s1line,nstim,nline,prepareimage,maxcol]=parsestimfile(stimfile);

helpwin prompter_parallel;

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
		return;
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
%but see note below
    set(haxi,'ycolor',get(hfsub,'color'),'xcolor',get(hfsub,'color'));
%7.10 use axes rather than figure color to cue the subject
	set(haxi,'color','r','linewidth',10);
	set(haxi,'visible','off');
    set(hi,'visible','on');

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
    
end;

hfinv=[];
if iscreen
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
mynewsize=mypos(3:4)*0.85;		%factor will depend on how many lines of text
mypos(3:4)=mynewsize;
set(haxinv,'position',mypos);
    htinfo(1)=text(0,1.12+0.02,' ','fontweight','bold','fontunits','normalized','verticalalignment','bottom');
    htinfo(2)=text(0,1.02,' ','fontweight','bold','fontunits','normalized','verticalalignment','bottom','interpreter','none');
set(htinfo,'fontsize',0.1,'erasemode','xor');
set(hfinv,'doublebuffer','on');

%could be used to indicate stopped/running if normal traffic lights are not
%used for this (or if not visible on video)
htinforuncol='k';
htinfostopcol='k';

end;

figh=[hfsub hfinv];


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




%can also adjust text properties, traffic light colours  etc. by hand
disp('Position Subject and Investgator figures, then type return');
keyboard;

dotrafficlights(TL.stop,ht,figh);

drawnow;
updatefigs;
%set(gcf,'menu','none')

all_done=0;
irun=1;

disp('Commands are:');
disp('n = next (default');
disp('r = repeat');
disp('R = repeat with old trial number');
disp('g = goto');
disp('m = message');
disp('M = message and resume');
disp('q = quit');
disp('k = keyboard');

while ~all_done
    ts=datestr(now);
    ts=['<Start of Sequence> ' ts crlf];
    status=fwrite(fid,ts,'uchar');
    showg(ht,'\fontname{Helvetica}!New Sequence!');
    %   showg(ht,str2mat('!new!','!sequence!'));
    disp('Starting prompt sequence');
    disp('hit any key to continue');
    pause;   
    
    istim=1;
    repeatstr='';
    showg(ht,ps{istim});
    %   set(ht,'color','r');
    
    dotrafficlights(TL.stop,ht,figh);
    
    %set(ht,'edgecolor','r');
    updatefigs;
    disp(ps{istim});
    disp(['<CODE> ' cs{istim}]);
	set(htinfo(2),'string',[int2str(istim) ' : ' cs{istim}]);
    finished=0;
    
    while ~finished
        mycmd=abartstr('Command: ','n');
        %      mycmd=lower(mycmd);
        if mycmd=='n'
            iruns=int2str(irun);
            set(htinfo(1),'string',iruns,'color',htinfostopcol);
            drawnow;
            sx=int2str([irun istim]);
            %use mysound????, what about scaling????     
            %audio output from list here
            if ~isempty(wavlist)
                try
                    tmpname=deblank(wavlist(istim,:));
                    [audioprompt,audiopromptsf]=wavread(tmpname);
                    sound(audioprompt,audiopromptsf,16);
						if wavlistsynch pause(length(audioprompt)/audiopromptsf); end;

				catch
                    disp('problem playing audio');
                end;
            end;
            
            
            
            
            
            if ~isempty(wavstart)
                soundsc(wavstart_d,wavstart_sf,wavstart_bits);
                if ~wavstart_async
                    tmppause=length(wavstart_d)/wavstart_sf;
                    pause(tmppause);
                end;
            end;
            
            disp(['Recording ' int2str([irun istim])]);
            mytime=now;
            %         set(ht,'color',[0.1 0.8 0.1]);
            %         set(ht,'edgecolor','g');
            dotrafficlights(TL.go,ht,figh);
            
            drawnow;
            updatefigs;
            tic;
            if daqok putvalue(parport.Line(synchline),1); end;
            set(htinfo(1),'color',htinforuncol);
            drawnow;
            if isempty(trial_duration)
                pause
            else
                while toc<trial_duration
%                pause(trial_duration);
            pause(0.015);       %no point in updating any faster
            set(htinfo(1),'string',[iruns ' : ' num2str(toc,'%4.3f')]);
            drawnow;
        end;
        
            end;
            %use mysound????, what about scaling????     
            if daqok putvalue(parport.Line(synchline),0); end;
            set(htinfo(1),'string',[iruns ' : ' num2str(toc,'%4.3f')],'color',htinfostopcol);
            
            if ~isempty(wavend)
                soundsc(wavend_d,wavend_sf,wavend_bits);
                if ~wavend_async
                    tmppause=length(wavend_d)/wavend_sf;
                    pause(tmppause);
                end;
            end;
            
            mytoc=toc;         
            
            disp('Stopped');
            [dodo,mytime]=strtok(datestr(mytime));         
            sx=[sx ' ' mytime];
            sx=[sx ' ' num2str(mytoc)];
            
            
            if istim<nstim
                %display new stimulus immediately to subject
                showg(ht,ps{istim+1});
	set(htinfo(2),'string',[int2str(istim+1) ' : ' cs{istim+1}]);
                
                %            set(ht,'color','r');
                %            set(ht,'edgecolor','r');
                dotrafficlights(TL.stop,ht,figh);
                drawnow;
                updatefigs;
                
            end;
            
            
            mycomm=philinp('Comment : ');
            if ~isempty(mycomm) mycomm=['_' mycomm]; end;
            mycomm=[' [' cs{istim} repeatstr mycomm ']' crlf];
            repeatstr='';
            %write trial number and time of day
            sx=[sx mycomm];
            status=fwrite(fid,sx,'uchar');
            
            
            irun=irun+1;
            istim=istim+1;
            
            if istim<=nstim            
                disp(ps{istim});
                disp(['<CODE> ' cs{istim}]);
            else
                disp('End of stimuli');
                finished=1;
                showg(ht,'\fontname{Helvetica}!!END!!');
	set(htinfo(2),'string','');
            end;
            
            
        end;
        
        if mycmd=='q'
            finished=1;
            showg(ht,'\fontname{Helvetica}!!END!!');
	set(htinfo(2),'string','');
        end;
        if mycmd=='k'
            keyboard;
        end;
        
        if ((mycmd=='r') | (mycmd=='R'))
            disp('Repeating!!');
            repeatstr='!!Repeat!!';
            istim=istim-1;
            if mycmd=='R'
                irun=irun-1;
                disp('Re-using previous trial number');   
            end;
            showg(ht,'\fontname{Helvetica}!Repeat!');
            
            disp('hit any key to continue');
            pause
            showg(ht,ps{istim});
                dotrafficlights(TL.stop,ht,figh);
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
	set(htinfo(2),'string',[int2str(istim) ' : ' cs{istim}]);
            
        end;
        
        if mycmd=='g'
            istim=abart('New stimulus number',istim,1,nstim,abint,abscalar);
            showg(ht,'\fontname{Helvetica}!Change of Stimulus!');
            disp('hit any key to continue');
            pause
            showg(ht,ps{istim});
                dotrafficlights(TL.stop,ht,figh);
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
	set(htinfo(2),'string',[int2str(istim) ' : ' cs{istim}]);
            
        end;
        
        if mycmd=='m'
            set(ht,'visible','off');
            mymess=philinp('Enter message to subject ');
            mymess=rv2strm(mymess,crlf);
            showg(ht,mymess);
            set(ht,'visible','on','edgecolor','m');
            
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
            dotrafficlights(TL.stop,ht,figh);
            
            %   set(ht,'edgecolor','r');
            disp(ps{istim});
            disp(['<CODE> ' cs{istim}]);
            
        end;
        
    end;
    mystr=abartstr('Terminate ? ','y');
    mystr=lower(mystr);
    
    if mystr~='n' all_done=1; end;
end;

status=fclose(fid);

disp('hit any key to exit program');
pause;
hfinv=findobj('type','figure','name','Investigator');
delete([hfsub;hfinv]);
if daqok
    delete(parport);
    clear parport;
end;




function showg(ht,mys);

%imageprefix='<IMAGE>';

hfsub=findobj('type','figure','name','Subject');
P=get(hfsub,'userdata');

hi=findobj('type','image','tag',P.imageprefix);
if ~isempty(hi) set(hi,'visible','off'); end;
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
                    set(hi,'visible','on');
                    set(hai,'visible','on');
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

%turn off axes containing image if last prompt was image
if strcmp(P.promptmode,'image')
                    set(hai,'visible','off');
%    hfinv=findobj('type','figure','name','Investigator');
%    set([hfsub hfinv],'color',P.figurebasecolor);
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

function updatefigs
hfi=findobj('type','figure','name','Investigator');

if isempty(hfi) return; end;        %assume separate figure not needed

hfs=findobj('type','figure','name','Subject');

ppps=get(hfs,'position');
pppi=get(hfi,'position');

set(hfi,'position',ppps);
set(hfi,'position',pppi);

return;

figure(hf);

refresh(hf);
drawnow;

%ppos=get(0,'pointerlocation');
%fpos=get(hf,'position');
%newpos=ppos;
%newpos=[fpos(1)+fpos(3)/2 fpos(2)+fpos(4)/2];
%set(0,'pointerlocation',newpos);
hf=findobj('type','figure','name','Subject');
figure(hf);
refresh(hf);
drawnow;
%set(0,'pointerlocation',ppos);

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