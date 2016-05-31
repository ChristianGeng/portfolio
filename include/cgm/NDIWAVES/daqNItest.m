%function daqNItest

daqreset

% session = daq.createSession ('vendor')
% device = daq.getDevices

%% Prepare Starting Stopping of WAVE SYSTEM
try, 
[s] = wave_connect(2900)
%s.getSoTimeout,
catch,
    disp('NDI SCU not turned on??')
    disp('type <return> to continue')
    keyboard
end

        
q.data='Version 1.0';
q.type=1;
p = wave_negPackage (s,q);
disp(char(p.data'))

% cString = 'SetByteOrder LittleEndian' 'false'
q.data='SetByteOrder LittleEndian';
q.type=1;
p = wave_negPackage (s,q);

disp(char(p.data'))

qStart=assembleStartRecordingPacket(1);
qStop=assembleStartRecordingPacket(0);


%% SETUP DAQ
hfDAQ=figure('Tag','hfDAQ');
subplot(2,1,1)
%set(gca,'Ylim',[-5 5])
subplot(2,1,2)
set(gca,'Ylim',[-5 5])

daqOutFile='tempdaqdata'
daqreset
vendor=daq.getVendors

NIsession = daq.createSession (vendor.ID)
nchanNI9234=2;
nchan9215=0;
srate=25600;

%set(NIsession,'DurationInSeconds',nsecs)
set(NIsession,'IsContinuous',1)
% Alle Sekunde einen Callback: 
set(NIsession,'NotifyWhenDataAvailableExceeds',srate)
 %2560
devs=daq.getDevices

[channels,indexes]=NIsession.addAnalogInputChannel(devs(1).ID,0:nchanNI9234-1,'voltage')
%[channelsM2,indexesM2]=NIsession.addAnalogInputChannel(devs(2).ID,0:nchan9215-1,'voltage')
%set(channels,'Name',str2mat('Synch NDI Wave', 'Audio Participant'));    
set(channels(1),'Name',str2mat('Synch NDI Wave'))
set(channels(2),'Name',str2mat('Audio Participant'))

%NIsession.removeChannel(1)
set(NIsession,'Rate',srate)
lh=NIsession.addlistener('DataAvailable', @plotData);

%NIsession.addlistener('ErrorOccurred', @devicewarn); 
% function devicewarn(src,event)

NIChannels=get(NIsession,'Channels'); 
NIChanProps=get(NIChannels)
nchan=length(NIChanProps);

private.devs=get(devs);
private.NISession=get(NIsession);
private.channels=get(channels);
private.vendor=get(vendor)
unit=cat(1,private.channels.MeasurementType);

mymem=memory;
nbytes=8; % DAQ data are 32bit long
%nsecs=3600*3; %% Allocate 3h of data ... 
%nsecs=800; %% allocate space for measurement data ... 
nsecs=floor(mymem.MaxPossibleArrayBytes/(nchan*nbytes*srate));
disp(['There is space for ' num2str(nsecs/3600) 'h of data!'])
nsecs=2600; 
datsize=nsecs*srate;


%% Action: 

% Reset NI buffers 
disp(['allocating ' num2str(nsecs) ' of data'])
DAQData=zeros(datsize,nchan);
%pack
nSampsAcquired=0;
pause(1)
disp('Starting aquisition')
NIsession.startBackground;
%[data,timeStamps,triggerTime]=s.startForeground;
%pause(nsecs)
%s.wait();
%%pause(1)
%for ll=1:2
%    pause(1.3)
%    p = wave_negPackage (s,qStart);
%    disp('pausing')
%    pause(3)
%    p = wave_negPackage (s,qStop);
%    disp(p)
%    pause(1.3)
%end



disp('type <return> to stop data acquisition ')
keyboard

% only do this if callback has not already stopped aquisition due to excess
% of max. samples allocated
if get(NIsession,'IsRunning')
    NIsession.stop();
    DAQData(nSampsAcquired+1:end,:)=[];
    %disp(nSampsAcquired)
    %disp(srate)
    disp(['recorded '  num2str(nSampsAcquired/srate) ' secs.' ])
    disp(['saving data to ' daqOutFile])
    save (daqOutFile,'DAQData','nSampsAcquired','srate','nchan','unit','private');
    %disp('after Stopping:')
    %get(NIsession)
end



%nscans=get(NIsession,'ScansAcquired')
%srate=get(NIsession,'Rate')

% myloggingmode='Disk'

% set(NIsession, 'LoggingMode', myloggingmode);
% set(AIADLINK2213, 'LogFileName', logfilename); 
% set(AIADLINK2213, 'logtodiskmode','Index')


