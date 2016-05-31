function testSMPTE
%
% Wenn kein SMPTE generiert werden kann, 
% dann wird auch kein tsv erzeugt. 
% 
% Idealerweise das binary format haben
% Workaround SMPTE von NDI nutzen, 
% oder das Trigger Signal mit genauer Reliabilitaet aufzeichnen koennen. 
% 
% Mail Melanie
% 
% I also confirmed that the issue Mark raised regarding the time signal
% in the first column of the data file is a rounding issue. The time
% shown in the first column is actually calculated from the WavID in the
% third column. That means that you can re-create a non-rounded time
% stamp from the data shown in the third column (WavId) fairly easily.
% The WavID is the actual sample number in the Wav file closest to the
% kinematic sample. For the first time stamp, divide WavID by 22,050,
% assuming that the audio sampling rate is 22,050 Hz (in excel:
% =C2/22050 ). Then take the difference between two adjacent WavId's,
% devide by 22,050 and add to the previous time stamp (in excel:
% =(C3-C2)/22050+D2 ) (where D is the new column in excel for the newly
% calculated non-rounded time stamps). I've attached an excel example to
% this email.
% 
% Best regards,
% Melanie
%

clear variables
verbose=0
clc
mysession='49';
fnum=02;

sessionroot='c:/ndigital/collections/MySession_';

infWavSynch = [sessionroot mysession '/MySession_' mysession '_' int2str0(fnum,3) '_sync.wav'];
[dataSy,samplerateSy,NBITSSy,opts]=wavread(infWavSynch);

infile=[sessionroot mysession '/rawdata/MySession_' mysession '_' int2str0(fnum,3) '.wav'];
[data,samplerate,NBITS]=wavread(infile);

if verbose
    disp(['length of synched WAVE data in sec.: ' num2str(length(dataSy)/samplerateSy)])
    
    disp(['length of UNsynched WAVE data in sec.: ' num2str(length(data)/samplerate)])
end
%% SMPTE
[smpte smpte_str,errN] = SMPTE_dec(data(:,2),samplerate,25,0);
smpteDur=smpte(end,end)-smpte(1,end);
if verbose
    disp([ 'first SMPTE frame at ' num2str(smpte(1,end))])
    disp([ 'last SMPTE frame at ' num2str(smpte(end,end))])
end

%% Articulatory Data - Spread Sheet
srArt=200;
insheet=[sessionroot mysession '/MySession_' mysession '_' int2str0(fnum,3) '_sync.tsv'];
[dataArt,descr]=importfile(insheet);
durDiff=dataArt(end,1)-dataArt(1,1);
if verbose
    disp(['length of Art data in sec. from Dat Leng: ' num2str(length(dataArt)/srArt)])
    disp([' first articulatory Stamp: ' num2str(dataArt(1,1))])
    disp([' last articulatory Stamp: ' num2str(dataArt(end,1))])
    disp([' Diff Art: ' num2str(durDiff)])
end

%% calculate correct Time Axis for articulatory data (see snippets of mail / Xls-File by Melanie)
%myStamps='Z:\myfiles\potsdam\NDIWaves\Melaniesstamps.xls'
%xlsfinfo(myStamps)
%[status,sheets,format]=xlsread(myStamps,'stamps');
WaveSR=22050;
%The WavID is the actual sample number in the Wav file closest to the kinematic sample.
 wavId=dataArt(:,3);
wavIdShift=circshift(wavId,-1);
sampdur= (wavIdShift -  wavId) ./ WaveSR ;
wavId_1=wavId(1)./WaveSR; % compare: disp(status(1,4))
% timeAx: Artikulatorische ZeitAchse in Sekunden 
timeAx=wavId_1 + cumsum(sampdur);
timeAx=[wavId_1  ; timeAx(1:end-1) ];

%% read NI-DAQ Data  
samplerateNIDAQ=25600;
NI=load('Z:/myfiles/Matlab/cgm/NDIWAVES/DAQData');
% smpte_NI TC: 5 column matrix with hh mm ss ff audio_time
smpte_chn=1;
[smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(NI.DAQData(:,smpte_chn),NI.srate,25,0);

smpteDur_NI=smpte_NI(end,end)-smpte_NI(1,end);
if verbose
    disp([ 'last SMPTE frame at ' num2str(smpte_NI(end,end))])
    disp([ 'first SMPTE frame at ' num2str(smpte_NI(1,end))])
    % Das ist die Dauer der Art Daten
    disp(['length of Code according to SMPTE NI capture  ( last - first ) ' num2str(smpteDur_NI)])
end

[c,iNIDAQ,iWAVE]=intersect(smpte_NI(:,1:4),smpte(:,1:4),'rows');
% Startpoint of NI Sample
TStartNIDAQ=smpte_NI(iNIDAQ([1]),5)-smpte(iWAVE([1]),5);
% Endpoint of NI Sample - Use the duration of already synched wav-File to calculate NIDAQ-EOF:
wavdurationSY=length(dataSy)/samplerateSy;
TEndNIDAQ=TStartNIDAQ+wavdurationSY;


% The sample that 

% Bin File
%infileArt=[sessionroot mysession '/rawdata/MySession_' mysession '_' int2str0(fnum,3) '.raw'];

%for skipB=0:10
%    skipB=0
%data=loadPosNDI(infileArt,'float',skipB)
%end
%dataArt(1:3,1:3)
%data(1:20)