function usedtime=mt_audio(segspec,chan,audiosf,nrep,idelay);
% mt_audio Audio output for mt functions
% function mt_audio(segspec,chan,audiosf,nrep,idelay,linuxsoundmode);
% mt_audio: Version 29.06.2012
%
%   Syntax
%       segspec: Compulsory.
%		    Either one of the following predefined strings
%			    'trial', 'cut', 'screen', 'cursor'  or 'marker(n)'
%			    'left_screen', 'right_screen', 'left_cut', 'right_cut'
%			    'xleft_screen', 'xright_screen', 'xleft_cut', 'xright_cut'
%		    Or numeric
%			    Either a two-element vector specifying time in current trial
%			    Or the actual data to be output (if length > 2)
%       chan:       Optional, defaults to value of 'audio_channel' from mt_gcsid
%       audiosf:    Optional; defaults to true samplerate.
%       nrep:       Optional. Number of repetitions
%       idelay:     Optional. Output delay (in s.), for use with videomovie
%       usedtime:   Optional output argument. Time corresponding to 'segspec'.
%
%   Notes
%       Default is to autoscale the signal before output.
%       This can be turned off with mt_scsid('audio_autoscale',0);
%       It may then be necessary to scale the audio signal appropriately
%       to avoid clipping (e.g. if audio range is 5V)
%       mt_scsid('audio_fsd',5)
%       By default, Linux uses an external wav player application.
%       Switch to using matlab's audioplayer with
%       mt_scsid('linux_usematlabsound',1);
%       This may give better synchronization with movie and video display,
%       but currently I do not know what combinations of linux and matlab
%       work well with the matlab audioplayer.
%       If an external player is used this can be configured with
%       mt_scsid('linuxwavplayer','aplay');
%       (aplay is the default)
%
%   See Also
%       mtkmcs: handles interactive call of mt_audio. mt_gcsid. mt_scsid
%
%	Updates
%		12.09
%           Start making linux sound utility configurable (and change
%           from using hear_raw to aplay as normal utility)
%       06.2012 
%           Change from sound to audioplayer (because matlab R2012 now
%           treats sound as a blocking function) for Windows (optionally also for Linux).
%           linux sound now configurable via mt_scsid
%           autoscaling now configurable

S=mt_gcsid;

audiochan=S.audio_channel;
autoscale=S.audio_autoscale;
fsd=S.audio_fsd;
if autoscale fsd=1; end;

fsdfac=0.95/fsd;        %keep maximum signal level slightly below fsd of da convertor


%12.09 introduced because hear_raw was not working correctly
%linuxsoundmode=0;		%use matlab sound
linuxsoundmode=~S.linux_usematlabsound;		%use linux sound utility
linuxwavplayer=S.linuxwavplayer;


%low limit on sound card samplerate
%not accurate for all hardware, but seems to be typical for soundblaster
%(needs to be taken into account for synchronization with movie functions. See below)

sf_lowlim=5000;

%Should probably use some kind of configuration file to e.g handle fsd and
%external sound application for linux systems (store in persistent variable
%on first call)



myrep=1;
if nargin>3 myrep=nrep;end;
mydelay=0;
if nargin>4 mydelay=idelay; end;


if nargin<2 chan=audiochan; end;
if nargin<3 audiosf=mt_gsigv(chan,'samplerate');end;
myver=version;
scratch=[];

if nargout usedtime=[0 0];end;


if isstr(segspec)
    cutpos=[mt_gccud('start') mt_gccud('end')];
    scrpos=mt_gdtim;
    curpos=mt_gcurp;
    scrpos(2)=min([scrpos(2) cutpos(2)]);
    
    switch segspec
        case 'trial'
            audiotime=[0 max(mt_gtrid('signal_tend'))];
        case 'cut'
            audiotime=cutpos;
        case 'screen'
            audiotime=scrpos;
        case 'cursor'
            audiotime=curpos;
        case 'left_screen'
            audiotime=[scrpos(1) curpos(1)];
        case 'right_screen'
            audiotime=[curpos(2) scrpos(2)];
        case 'left_cut'
            audiotime=[cutpos(1) curpos(1)];
        case 'right_cut'
            audiotime=[curpos(2) cutpos(2)];
        case 'xleft_screen'
            audiotime=[scrpos(1) curpos(2)];
        case 'xright_screen'
            audiotime=[curpos(1) scrpos(2)];
        case 'xleft_cut'
            audiotime=[cutpos(1) curpos(2)];
        case 'xright_cut'
            audiotime=[curpos(1) cutpos(2)];
            
        otherwise
            
            %might be marker specification
            if findstr(segspec,'marker')
                mymark=[];
                
                lm=length('marker');
                ls=length(segspec);
                
                if ls>lm
                    tmpchar=segspec((lm+1):ls);
                    try
                        mymark=str2num(tmpchar);      %catch errors???
                    catch
                        disp('mt_audio: uninterpretable marker number?');
                    end;
                end;
                
                audiotime=mt_gmark('cut',mymark);
                if isempty(audiotime) audiotime=zeros(1,2);end;
                %If marker boundary not set attempts to use active cursor
                if any(isnan(audiotime));
                    curh=mt_gcurh;
                    curfree=mt_tcurs(curh,1);
                    
                    iactive=getfirst(find(curfree==1));
                    if isnan(audiotime(1)) audiotime(1)=curpos(iactive);end;
                    if isnan(audiotime(2)) audiotime(2)=curpos(iactive);end;
                end;
                if diff(audiotime)<=0 audiotime=zeros(1,2);end;
                
            end;  %could be marker
            
    end;	%case
    
else       %isstr(segspec)
    ll=length(segspec);
    if ll<2 return;end;
    if ll==2
        audiotime=segspec;
    else
        
        scratch=segspec;
        if size(scratch,1)==1 scratch=scratch';end;
        audiotime=[0 length(scratch)./audiosf];
        actualtime=audiotime;
    end;
    
    
end;

if audiotime(2)<=audiotime(1)
    disp('mt_audio: segment has zero length');
    return;
end;


if isempty(scratch)
    [scratch,actualtime]=mt_gdata(chan,audiotime);
end;

if nargout usedtime=actualtime; end;

if isempty(scratch)
    disp('mt_audio: segment is empty');
    return;
end;

maxabs=max(abs(scratch));
if maxabs==0 maxabs=1; end;

%   mycomputer=computer;


if autoscale scratch=scratch./maxabs; end;
scratch=scratch*fsdfac;

%handle low limit on sound card sample frequency
%e.g for synchronization with very slow motion movie functions

%could use proper interpolation, but simply replicating samples
%is probably ok in practice

%disadvantage of all this is that very large vectors could result

iadj=1;
audiouse=audiosf;
if audiosf<sf_lowlim
    iadj=ceil(sf_lowlim/audiosf);
    audiouse=audiosf*iadj;
    scratch=(repmat(scratch,1,iadj))';
    scratch=scratch(:);
end;





if myrep>1
    scratch=repmat(scratch,myrep,1);
end;
if mydelay>0
    scratch=[zeros(round(mydelay*audiouse),1);scratch];
end;




%add some zero samples, theres a bug somewhere in windows audio!!
scratch=[scratch;zeros(1050,1)];

myplayer=[];
if strcmp(myver(1),'4')
    saxis('auto');
    sound (scratch,audiouse);
else
    
    if ispc
        try
            myplayer=audioplayer(scratch,audiouse,16);
            play(myplayer);
        catch
            disp('mt_audio: Sound device unavailable?');
        end;
        
    else
        %Linux
        %It has usually been better to use an external utility for Linux.
        %The reason for normally NOT using matlab sound for linux is that it does
        %not work asynchronously
        % and before version 7 also did not allow variable samplerates
        %However, if the sound utility does not work properly then it needs
        %to possible to disable it.
        badlinux=0;
        if linuxsoundmode
            try
                %				%could easily be upgraded for more efficient operation%
                %				fid=fopen('tmp.raw','w');
                %				if fid>=3
                %					scratch=round(scratch*32767.);
                %					cc=fwrite(fid,scratch,'short');
                %					eval(['!hear_raw rate=' int2str(round(audiouse)) ' tmp.raw&']);
                %				else
                %					disp('mt_audio: Unable to open temporary audio file');
                %				end;
                %could easily be upgraded for more efficient operation
                %				fid=fopen('tmp.raw','w');
                wavwrite(scratch,audiouse,16,'tmp.wav');
                [sysstat,sysresult]=system([linuxwavplayer ' tmp.wav&']);
                if sysstat
                    disp(['mt_audio: Problem with Linux audio using ' linuxwavplayer '?']);
                    disp('sysresult');
                    
                    badlinux=1;
                end;
                
                
            catch
                badlinux=1;
            end;
        end;
        if badlinux | ~linuxsoundmode
            %			try
            %				sound(scratch,audiouse);
            %			catch
            %				disp('mt_audio: Sound device unavailable?');
            %			end;
            try
                myplayer=audioplayer(scratch,audiouse,16);
                play(myplayer);
            catch
                disp('mt_audio: Sound device unavailable?');
            end;
            
        end;
        
        
    end;
end;

%For asynchronous playback this is essential, otherwise playing stops when
%the function returns, because myplayer is no longer in scope.
%In addition, animation functions could handle synchronization by quering
%the CurrentSample property of the audioplayer
%Also playback could be repeated without calling mt_audio by simply calling
%play(myplayer)

mt_scsid('audioplayer',myplayer);
