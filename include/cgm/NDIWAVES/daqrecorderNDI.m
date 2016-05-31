function daqrecorder(varargin)

daqreset
% logfilename=['LogFileNN.daq']
logfilename=['test.daq']
if (nargin>0)
logfilename=varargin{1};
end;




% Configure LOGGING
% myloggingmode='Disk&Memory';
myloggingmode='Disk'
% intialize fig for synch data
hfsyncdat=figure;
colordef(hfsyncdat,'none');
set(hfsyncdat,'menu','none');
set(hfsyncdat,'menu','figure'); % to turn back on
set(gca,'position',[0.05 0.05 0.9 0.9]);
set(hfsyncdat,'name','ADLINK CAPTURE');
 
AIADLINK2213= analoginput('mwadlink', 0)%Opens the analog input functionality of device #0 (DAQ-2213)
set(AIADLINK2213, 'InputType', 'Differential')
nchannel=5;
names = makenames('Channel',1:nchannel);

addchannel(AIADLINK2213, 0:nchannel-1, names) % 4 channels are ok for the moment

% sr=22050;
sr=32000;
set(AIADLINK2213, 'SampleRate', sr)              %Set SampleRate to sr
set(AIADLINK2213, 'SamplesPerTrigger', inf);     % Data Aquistion must be interrupted by stop signal
                                                 % convertor to run until stopped
                                                 % If TriggerRepeat is set to its default value of zero, 
                                                 % then the trigger executes once
set(AIADLINK2213, 'TriggerRepeat',0);

out = daqhwinfo(AIADLINK2213)


% Specify range of analog input subsystem
% Description

% InputRange:
% InputRange is a two-element vector that specifies the range of voltages that can be accepted by the analog input (AI) subsystem. 
% You should configure InputRange so that the maximum dynamic range of your hardware is utilized.

% SensorRange:
% You use SensorRange to scale your data to reflect the range you expect from your sensor. 
% You can find the appropriate sensor range from your sensor's specification sheet. 
% The data is scaled while it is extracted from the engine with the getdata function according to the formula
% scaled value = (A/D value)(units range)/(sensor range)

% UnitsRange:
% Specify range of data as engineering units
% You use UnitsRange to scale your data to reflect particular engineering units.
% For analog input objects, the data is scaled while it is extracted from the engine with the getdata function according to the formula
% scaled value = (A/D value)(units range)/(sensor range)
% The A/D value is constrained by the InputRange property, which reflects the gain and polarity of your analog input channels. 
% The sensor range is given by the SensorRange property, which reflects the range of data you expect from your sensor.


% 
% % Inputranges=[-5 5;
% %             -10 10;
% %             -10 10;
% %             -10 10;
% %             -10 10];

% Inputranges=[-5  5;
%               0  5;
%             -10 10;
%               0  5;
%             -10 10];

%         Inputranges=[-5  5;
%               0  5;
%             -5 5;
%               0  5;
%             -5 5];


Inputranges=[-10 10;
              0  5;
            -10 10;
              0  5;
            -10 10];


        for rr=1:nchannel
            evalstring = ['ActualRange = setverify(AIADLINK2213.Channel',num2str(rr),',''InputRange''',',' ,...
                '[',num2str(Inputranges(rr,1)),' ',num2str(Inputranges(rr,2)),']);';];
          eval(evalstring)
        end        
        

names{2}='Sync CS6';
names{4}='Sync CS5';

set(AIADLINK2213, 'LoggingMode', myloggingmode);
set(AIADLINK2213, 'LogFileName', logfilename); 
set(AIADLINK2213, 'logtodiskmode','Index')

% Initialize multichannel oscilloscope
%Work out the number of samples per screen
samplerate=sr;
screentime=0.5; %(in secs)
nsampscreen=round(samplerate*screentime);
zerosignal=zeros(nsampscreen,1);
timedata=((0:(nsampscreen-1))/samplerate)';
figure(hfsyncdat)

dbmin=-90;
  for rr=1:nchannel
    hfsyncaxes(rr)=subplot(nchannel,1,rr);
    hl(rr)=plot(timedata,zeros(nsampscreen,1));
% Sth. wrong with the db
%     ylim([dbmin 0]);
%     ylabel('dB');
    ylim(Inputranges(rr,:))
    ylabel(names{rr});
%     if (rr==3)
%         ylim([dbmin 0])
%     end
%     if (rr==5)
%         ylim([dbmin 0])
%     end
        
    if (rr==1)
        htitle=title('Press anywhere to start/stop recording!');
    end;
    if (rr==nchannel)
        xlabel('Time (s)');
    end
    
    if ~(rr==nchannel)
        set(hfsyncaxes(rr),'Xtick',[]);
    end
    
    %Label the x axis
  end
  
% % from myscope_3.m
% % should not go here CHANGE!
% dbmin=-90;
%
% ydata=[dbmin;0];
% %hl=plot(xdata,ydata);
% 
% %display only makes sense with fixed y axis
% %As matlab normalizes the data from the windows AD convertor to +/- 1, set
% %the maximimum db value intially to 0
%
% Callbacks for Osciwindow:
%samples to process
set(AIADLINK2213,'samplesacquiredfcn',{@plotcb,hl,nsampscreen,htitle});
%This defines how often the callback function should run
set(AIADLINK2213,'samplesacquiredfcncount',nsampscreen);

% Callbacks for clicking to start/stop:
%activate callback, so sounds can be heard by clicking in any figure
set(hfsyncdat,'windowbuttondownfcn',{@playcb,hl,AIADLINK2213,htitle});


function playcb(obj,data,hl,AIADLINK2213,htitle);
% callback for start stop of engine
% samplerate=get(obj,'userdata');
% soundsc(get(hl,'ydata'),samplerate);

if strcmp(get(AIADLINK2213,'running'),'Off')
    tic;
    start(AIADLINK2213);
    titlestring=get(htitle,'string');
    titlestring = strrep(titlestring, 'Off', 'On');
    set(htitle,'string',titlestring,'color','r');
elseif strcmp(get(AIADLINK2213,'running'),'On')
    titlestring=get(htitle,'string');
    titlestring = strrep(titlestring, 'On', 'Off');
    set(htitle,'string',titlestring,'color','g');
    stop(AIADLINK2213);    
else, 
    daqreset
    error('undefined condition of the card, reset!!')
end

   
function plotcb(cb_obj,cb_data,hl,nsamp,htitle)
% A special feature of callback functions is that the first two input
% arguments are pre-defined. The 3 arguments we gave in the specification
% above (set(hai,'samplesacquiredfcn',{@plotcb,hl,nsamp,htitle});)
% thus have to be given here starting as the third input argument.

%The first argument ('cb_obj') is the handle of the object that has triggered the
%callback (in our case the analog input object); the second argument ('cb_data') gives
%more information about the event that triggered the interrupt (in our case
%the event is that the specified number of samples has been acquired).
%In our case we don't need to use the latter information, but it is quite
%possible for different objects and different kinds of events to call the
%same callback function, in which case it may be essential for the callback
% function to know 'why' it has been activated

% y=getdata(cb_obj,nsamp); % Phil: I do  logtodisk  so I use
% cb_obj is the AIADLINK
y = peekdata(cb_obj,nsamp);
% z = double(peekdata(cb_obj,nsamp,'native'));
% whos z

% z(:,[3 5])=(10.*log10(double(2^15)./abs((z(:,[3 5])))));

%y = 20*log10(sqrt((y.^2)));


% keyboard
nchan=size(y,2);

%update the oscillogram
for rr = 1:nchan
    set(hl(rr),'ydata',y(:,rr));
end

%(maxint/.abs(ActualVal)).*10*log10

%get the elapsed time since starting acquisition
mytoc=toc;


% Logfilename
% seconds remaining
% samples lost
% SIZE ON DISK!!!
%eval(['!dir /T ',tmpl])



 tmplogf=get(cb_obj,'LogFileName');
% evalstring=['[status, result] = system(''dir /W ', tmplogf,'''',')' ]
% eval(evalstring)


% Samples aqcuired
%              figure(hfsyncdat)
%                     if strcmp (myloggingmode,'Disk&Memory')
%                                [mondata,montime,monabstime,monevents] = getdata(AIADLINK2213,get(AIADLINK2213,'SamplesAvailable'));
%                               % my data for minitoring the result of sync attempts                  
%                               % hfinv=findobj('type','figure','name','emaep
%                               % gsync');
%                         elseif  strcmp (myloggingmode,'Disk')
%                             nsaquired=get(AIADLINK2213,'SamplesAcquired');
%                             disp([' aquired ',num2str(nsaquired),' samples']);                
%                         end
%       


%update the title text
%(num2str converts numeric data to a text string so that it can be
%displayed)
% set(htitle,'string',[num2str(round(mytoc)),' s. recorded ',num2str(327-round(mytoc)),'s. remaining ', get(cb_obj,'running'),' ' ,tmplogf]);
set(htitle,'string',[num2str(round(mytoc)),' s. recorded, Recording Status: ', get(cb_obj,'running'),', Filename: ' ,tmplogf]);
drawnow;



% 
% % from myscope_3.m
% % should not go here CHANGE!
% dbmin=-90;
% % xdata=[0;0]; % comm out:
% ydata=[dbmin;0];
% %hl=plot(xdata,ydata);
% 
% %display only makes sense with fixed y axis
% %As matlab normalizes the data from the windows AD convertor to +/- 1, set
% %the maximimum db value intially to 0
% ylim([dbmin 0]);
% ylabel('dB');
% 
% y=sqrt(mean(y.*y));
% %convert to dB
% y=20*log10(y);
% %get the existing ydata in case the user has changed the baseline value in
% %ydata(1)
% ydata=get(hl,'ydata');
% ydata(2)=y;
% %update the oscillogram
% set(hl,'ydata',ydata);






% DIGITAL IO
%
% status : 
% get(AIADLINK2213,'running')
%
%fn='LogFileN04.daq'
%[data, time, abstime, events, daqinfo] = daqread(fn);
%daqinfo = daqread(fn,'info')
%
%dio = digitalio('nidaq','Dev1');
%dio_device = digitalio( 'mwadlink', 0) %Opens DIO functionality of device #0 (DAQ-2013)
%di_lines = addline(dio_device, 0:7, 'out') %Adds channels 0-7 to dio_device and sets them as input
%di_value = getvalue(di_lines) %Read the digital input values on channels 0-7 of Port A
%putvalue(dio.Line(1:4),data)
%putvalue(dio_device.Line(1:4),data)

% should go to callback:

