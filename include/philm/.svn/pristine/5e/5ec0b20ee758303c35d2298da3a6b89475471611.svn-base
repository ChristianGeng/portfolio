function checkepgsync(sonyfile,chans,thresh,sfepg)
% CHECKEPGSYNC Check epg sync signals
% function checkepgsync(sonyfile,chans,thresh,sfepg)
% checkepgsync: Version 8.5.08
%
%   Syntax
%       sonyfile: pcscanii-compatible file (without extension)
%           Synch output file (cut file) with '_synch' as filename suffix
%       chans: 2-element vector. chans(1): channel with beep (synch) signal
%       marking start and end of trial; chans(2): channel of scan signal
%       thresh: 2-element vector: Threshold values corresponding to chans
%           Note currently threshold values in raw values in bin file
%       sfepg: EPG samplerate
%       In the output sync file the fields of private.checkepgsync provide
%       additional details on the processing, in particular on the
%       estimated EPG samplerate that would give the best match in length
%       for triallength defined by the synch pulses and triallength defined
%       by the number of EPG frames
%
%   See Also 
%       DAT2MAT_II_FX Extract data from Sony file based on synch information
%       GETLSBC_II_F General-purpose program for synch pulse extraction
%       from Sony files

%Note: normally it should be possible to read in information on the
%expected number of frames for each trial

functionname='checkepgsync: Version 8.5.08';

namestr=['Sony file : ' sonyfile crlf 'Channels for EPG synch signals: ' int2str(chans) crlf 'Thresholds for EPG synch signals: ' int2str(thresh) crlf 'EPG samplerate: ' num2str(sfepg) crlf];


sm=file2str([sonyfile '.log']);
sonycomment=readtxtf([sonyfile '.log']);
sonycomment=framecomment(sonycomment,'Sony LOG file');

fid=fopen([sonyfile '.bin'],'r');

totalchan=str2num(getsonyf(sm,'TAPE_BC_MODE'));

chunksize=10000;

chansamp=str2num(getsonyf(sm,'VOLUME_CH'));
nchunk=floor(chansamp/chunksize);


beepch=chans(1);
scanch=chans(2);
beepthresh=thresh(1);
scanthresh=thresh(2);
sfaudio=1./str2num(strtok(getsonyf(sm,'FILE_INTVL_CH')));

disp(['Audio samplerate : ' num2str(sfaudio)]);

beeplist=[];
scanlist=[];


lastsamp=zeros(1,totalchan);
sampoffset=0;
nread=chunksize;
for ipi=1:nchunk
    if ipi==nchunk nread=inf; end;
    y=fread(fid,[totalchan nread],'int16');
    y=y';
    y=[lastsamp;y];
    y1=y(1:end-1,:);
    y2=y(2:end,:);
    beeptmp=find(y2(:,beepch)>beepthresh & y1(:,beepch)<=beepthresh);
    scantmp=find(y2(:,scanch)>scanthresh & y1(:,scanch)<=scanthresh);
    
    beeplist=[beeplist;(beeptmp+sampoffset)];
    scanlist=[scanlist;(scantmp+sampoffset)];
    
    nbeep=length(beeplist);
    nscan=length(scanlist);
    disp([ipi nchunk nbeep nscan]);
    lastsamp=y(end,:);
    sampoffset=sampoffset+chunksize;
    
end;

fclose(fid);
disp('checkepgsync: finished reading file');
%keyboard;

%no handling of difficult cases yet
%e.g odd number of beeps.
%   Should normally be clear from following output where the problem occurs

try
beeplist=reshape(beeplist,[2 length(beeplist)/2]);
catch
    disp('Problem reshaping beeplist. Check for odd number of synch pulses');
    keyboard;
    return;
end;

beeplist=beeplist';
nbeep=size(beeplist,1);
framenumbuf=ones(nbeep,1)*NaN;
epgtimebuf=ones(nbeep,1)*NaN;
audiotimebuf=ones(nbeep,1)*NaN;
frameintervalrange=ones(nbeep,1)*NaN;
for ibeep=1:nbeep
    
    disp(['Trial ' int2str(ibeep) ' of ' int2str(nbeep)]);
    vv=find(scanlist>beeplist(ibeep,1) & scanlist<beeplist(ibeep,2));
    
    scanframes=scanlist(vv);
    scanframesd=diff(scanframes);
    maxframed=max(scanframesd);
    minframed=min(scanframesd);
    
    frameintervalrange(ibeep)=maxframed-minframed;
    nframe=length(vv);
    beeptime=beeplist(ibeep,2)-beeplist(ibeep,1);
    beeptime=beeptime/sfaudio;
    
    epgtime=nframe/sfepg;
    
    framenumbuf(ibeep)=nframe;
    
    epgtimebuf(ibeep)=epgtime;
    audiotimebuf(ibeep)=beeptime;
    disp(['Number of frames ' int2str(nframe)]);
    disp(['Max and min frame interval (in samples) : ' int2str([maxframed minframed])]);
    disp(['EPG time, Audio time (s) ' num2str([epgtime beeptime])]);
    disp(['Time diff (ms) ' num2str((epgtime-beeptime)*1000)]);
    
end;
epgcumtime=sum(epgtimebuf);
audiocumtime=sum(audiotimebuf);
samplerate_factor=epgcumtime/audiocumtime;
sfepg_adj=sfepg*samplerate_factor;

private.checkepgsync.framecount=framenumbuf;
private.checkepgsync.epgaudiotimediff=epgtimebuf-audiotimebuf;
private.checkepgsync.sfepg_adj=sfepg_adj;
private.checkepgsync.frameintervalrange=frameintervalrange;
private.checkepgsync.sonycomment=sonycomment;

data=zeros(nbeep,4);
data(:,1:2)=beeplist/sfaudio;
data(:,4)=(1:nbeep)';

label=cell(nbeep,1);
for ii=1:nbeep label{ii}=int2str(ii); end;
label=char(label);

%comment=[namestr sonycomment];
comment=framecomment(namestr,functionname);


[descriptor,unit,valuelabel]=cutstrucn;

save([sonyfile '_sync'],'data','label','descriptor','unit','comment','valuelabel','private');
