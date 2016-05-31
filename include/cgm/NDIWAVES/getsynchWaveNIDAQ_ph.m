function getsynchWaveNIDAQ(daqFile,smpte_chn,NDIsessionroot,session,filelist)
% so far this is  a version for just one large DAQ file
%  smpte_chn: channel on the NI daq file

cgdebug=0;
timingDebug=1;

namestr='';
functionname=[rmextension(mfilename), ': Version 20-Oct-2011'];

cutname=[daqFile '_syncCh',num2str(smpte_chn)];
namestr=[namestr 'Output cut file: ' cutname crlf];

disp (functionname);
maxcut=20000;
[abint,abnoint,abscalar,abnoscalar]=abartdef;

timdat=ones(maxcut,4)*NaN;
timdat(:,3)=0;
maxtlen=length(int2str(maxcut));
cutlabel=setstr(zeros(maxcut,maxtlen));

NIDAQ=load(daqFile);
private=NIDAQ.private;
disp('decoding NIDAQ file ...')
NILEN=length(NIDAQ.DAQData)/NIDAQ.srate;
disp([' NIDAQ length (sec.) : ' num2str(NILEN)]);
% keyboard
% [smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(NIDAQ.DAQData(:,smpte_chn),NIDAQ.srate,25,0);
soundout=soundsc_cg(NIDAQ.DAQData(:,smpte_chn),NIDAQ.srate);
[smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(soundout,NIDAQ.srate,25,0);



% soundout=soundsc_cg(NIDAQ.DAQData(:,smpte_chn),NIDAQ.srate);
% [smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(soundout,NIDAQ.srate,25,0);


smpteDur_NI=smpte_NI(end,end)-smpte_NI(1,end);
if timingDebug
    disp([ 'last SMPTE frame at ' num2str(smpte_NI(end,end))])
    disp([ 'first SMPTE frame at ' num2str(smpte_NI(1,end))])
    % Das ist die Dauer der Art Daten
    disp(['length of Code according to SMPTE NI capture  ( last - first ) ' num2str(smpteDur_NI)])
end


diary getsynch_NIDAQ.log

if cgdebug
    daqinfo = daqread(daqFile,'info');
    adlink_chn=cat(1,daqinfo.ObjInfo.Channel.Index)';
    adlink_desc=char(daqinfo.ObjInfo.Channel.ChannelName);
    adlink_unit=daqinfo.ObjInfo.Channel.Units;
    % Scale
    adlink_signalzero=cat(1,daqinfo.ObjInfo.Channel.NativeOffset);
end

lastdat=0;
nchanin=NIDAQ.nchan;

sftemp=NIDAQ.srate;
dectemp=0;
sfchannel=sftemp/(dectemp+1);

sfbase=sfchannel*nchanin;
sf=sfchannel;

totalsamp=size(NIDAQ.DAQData,1); % assuming that 

lastdat=0;
% lastdat=1;   % I have to set this to 1, is 0 in Phil original!
icut=1;
nsamp=0;
mystart=1;

%% read NI-DAQ Data  
%samplerateNIDAQ=25600;
%NI=load('Z:/myfiles/Matlab/cgm/NDIWAVES/DAQData');
% smpte_NI TC: 5 column matrix with hh mm ss ff audio_time
%smpte_chn=1;
%[smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(NIDAQ.DAQData(:,smpte_chn),NIDAQ.srate,25,0);

smpteDur_NI=smpte_NI(end,end)-smpte_NI(1,end);
if timingDebug
    disp([ 'last SMPTE frame at ' num2str(smpte_NI(end,end))])
    disp([ 'first SMPTE frame at ' num2str(smpte_NI(1,end))])
    % Das ist die Dauer der Art Daten
    disp(['length of Code according to SMPTE NI capture  ( last - first ) ' num2str(smpteDur_NI)])
end


data=nan(length(filelist),4);
data(:,3)=0;
totalcuts=0;




for fnum=filelist   
    
    totalcuts=totalcuts+1;
    
   
    
    %%
    infWavSynch = [NDIsessionroot session '/MySession_' session '_' int2str0(fnum,3) '_sync.wav'];
    disp('++++++++++++++++++++++++++++++++++++++++++')
    disp('')
    disp(['Processing file ' infWavSynch])
    disp('')
    %[dataSy,samplerateSy,NBITSSy,opts]=wavread(infWavSynch);
    infile=[NDIsessionroot session '/rawdata/MySession_' session '_' int2str0(fnum,3) '.wav']
    [dataSYNCH,samplerate,NBITS]=wavread(infile);
    
    if timingDebug
        %disp(['length of synched WAVE data in sec.: ' num2str(length(dataSy)/samplerateSy)])
        disp(['length of UNsynched WAVE data in sec.: ' num2str(length(dataSYNCH)/samplerate)])
    end
    %% SMPTE
    [smpte smpte_str,errN] = SMPTE_dec(dataSYNCH(:,2),samplerate,25,0);
    smpteDur=smpte(end,end)-smpte(1,end);
    if timingDebug
        disp([ 'first SMPTE frame at ' num2str(smpte(1,end))])
        disp([ 'last SMPTE frame at ' num2str(smpte(end,end))])
    end
    
    
    %% Articulatory Data - Spread Sheet
    % 
    
    % TODO: Stimmt die Time Axis?
    
    srArt=200;
    insheet=[NDIsessionroot session '/MySession_' session '_' int2str0(fnum,3) '_sync.tsv'];
    [dataArt,descr]=importfile(insheet);
    durDiff=dataArt(end,1)-dataArt(1,1);
    if timingDebug
        disp(['length of Art data in sec. from Dat Leng: ' num2str(length(dataArt)/srArt)])
        disp([' first articulatory Stamp: ' num2str(dataArt(1,1))])
        disp([' last articulatory Stamp: ' num2str(dataArt(end,1))])
        disp([' Diff Art: ' num2str(durDiff)])
    end
    
    [c,iNIDAQ,iWAVE]=intersect(smpte_NI(:,1:4),smpte(:,1:4),'rows');
    % Startpoint of NI Sample
    TStartNIDAQ=smpte_NI(iNIDAQ([1]),5)-smpte(iWAVE([1]),5);
    % Endpoint of NI Sample - Use the duration of already synched wav-File to calculate NIDAQ-EOF:
    wavduration=length(dataSYNCH)/samplerate;
    TEndNIDAQ=TStartNIDAQ+wavduration;
    disp(['NI: ' num2str(TStartNIDAQ) ' - ' num2str(TEndNIDAQ) ' (' num2str(wavduration) ')'])
    data(totalcuts,1)=TStartNIDAQ;
    data(totalcuts,2)=TEndNIDAQ;
    data(totalcuts,4)=fnum;
    cutlabel(totalcuts,:)=int2str0(totalcuts,maxtlen);
end


samplerate=NIDAQ.srate;

comment=[namestr];
%comment=[namestr sonycomment];
comment=framecomment(comment,functionname)

[descriptor,unit,valuelabel]=cutstrucn;
label=cutlabel(1:totalcuts,:)
% private
disp(data)
eval (['save ' cutname ' data label descriptor unit comment valuelabel samplerate private']);
%eval (['save ' cutname ' data label descriptor unit comment private valuelabel']);
diary dodo
diary off
