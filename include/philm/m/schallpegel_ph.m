function schallpegel_ph(varargin)
% SCHALLPEGEL_PH Real-time feedback of SPL
% function schallpegel_ph(varargin)
% schallpegel_ph: Version 7.5.07
%
%   Description
%       Based on DEMOAI_FFT from the Data acqusition toolbox
%       See Also DAQSCOPE_PH for real-time oscilloscope display
%       For primitive customization of target SPL level call
%       fixtarget(data,mytarget) from keyboard mode (see end of source code
%       below)
%       
%   Original DEMOAI_FFT help text
%    DEMOAI_FFT creates an analog input object associated with the 
%    winsound adaptor with device identification 0.  The incoming 
%    signal and the fft of the incoming signal of the created analog 
%    input object are plotted.
%
%    DEMOAI_FFT('ADAPTORNAME', ID, CHANID) creates an analog input object
%    associated with adaptor, ADAPTORNAME, with device identification,
%    ID.  A channel is assigned to the hardware channels specified in 
%    scalar CHANID.  The incoming signal from the created analog input
%    object and the fft of the incoming signal are both plotted.
%
%    The plot is continuously updated by programming the TimerFcn
%    property to plot the results from either GETDATA or PEEKDATA every 
%    0.1 seconds (GETDATA is called for the initial plot).
%
%    Examples:
%      demoai_fft
%      demoai_fft('winsound', 0, 1);
%       

%    MP 11-23-98
%    Copyright 1998-2002 The MathWorks, Inc.
%    $Revision: 1.6 $  $Date: 2002/04/04 22:11:58 $

% Error if an output argument is supplied.
if nargout > 0
   error('Too many output arguments.');
end

% Based on the number of input arguments call the appropriate 
% local function.
switch nargin
case 0
   % Create the analog input object.
   data = localInitAI;

   % Create the  figure.
   data = localInitFig(data);
   hFig = data.handle.figure;
   
case 1
   error('The ADAPTORNAME, ID and CHANID must be specified.');
case 2
   % Initialize variables.
   data = [];
   action=varargin{1};
   hFig=varargin{2};
   
   % This may fail if only the ADAPTORNAME and ID were input.  However,
   % if the ID was 0, this will work.
   try
      data=get(hFig,'UserData');
   end      
   
   % DATA will be empty if CHANID was not specified or if ID = 0.
   if isempty(data)
      error('The CHANID must be specified.');
   end
   
   % Based on the action, call the appropriate local function.
   switch action
   case 'close'
      localClose(data);
   case 'stop'
      data = localStop(data);
   end
case 3
      % User specified the input - adaptor, id, chanNum.
      % Create the analog input object.
      [data, errflag] = localInitAI(varargin{:});
      if errflag
         error(lasterr)
      end
      
      % Create the  figure.
      data = localInitFig(data);
      hFig = data.handle.figure;
end

% Update the figure's UserData.
if ~isempty(hFig)&ishandle(hFig),
   set(hFig,'UserData',data);
end

% Update the analog input object's UserData.
if isvalid(data.ai)
   set(data.ai, 'UserData', data);
end
keyboard;
% ***********************************************************************   
% Create the object and get the first fft.
function [data, errflag] = localInitAI(varargin)

% Initialize variables.
errflag = 0;
data = [];

% Either no input arguments or all three - ADAPTORNAME, ID and CHANNELID.
switch nargin
case 0
   adaptor = 'winsound';
   id = 0;
   chan = 1;
case 3
   adaptor = varargin{1};
   id = varargin{2};
   chan = varargin{3};
otherwise
   lasterr('The ADAPTORNAME, ID and CHANID must be specified.');
   errflag = 1;
   return;
end

% Error if more than one channel was specified.
if length(chan) > 1
   lasterr('Only a single channel can be created.');
   errflag = 1;
   return
end

% Channel 2 for sound card is not allowed.
if strcmp(lower(adaptor), 'winsound') & chan == 2
   warning('Channel 1 must be used for device Winsound.');
   chan = 1;
end

% Object Configuration.
% Create an analog input object with one channel.
ai = analoginput(adaptor, id);
addchannel(ai, chan);

% Configure the analog input object.
%set(ai, 'SampleRate', 44100);
mysf=22050;
set(ai, 'SampleRate', mysf);
winlen=0.025;     % in seconds
% Configure the analog input object to trigger manually twice.
samppertrig=round(winlen*mysf);
set(ai, 'SamplesPerTrigger', samppertrig)%1024);
%set(ai, 'SamplesPerTrigger', 5000)%1024);
set(ai, 'TriggerRepeat', 1);
set(ai, 'TriggerType', 'manual');

%disp(get(ai,'samplerate'));

% Initialize callback parameters.  The TimerAction is initialized 
% after figure has been created.
%how does this interact with samples per trigger??
%set(ai, 'TimerPeriod', 0.01);  
set(ai, 'TimerPeriod',winlen);  
%set(ai, 'BufferingConfig',[2048,20]);
set(ai, 'BufferingConfig',[samppertrig*2,20]);

% Object Execution.
% Start the analog input object.
start(ai);
trigger(ai);

% Obtain the available time and data.
[d,time] = getdata(ai, ai.SamplesPerTrigger);


% Calculate the fft.
Fs = get(ai, 'SampleRate');
blockSize = get(ai, 'SamplesPerTrigger');

rms=10*log10(mean(d.^2));
%[f,mag] = localDaqfft(d,Fs,blockSize);


% Update the data structure.
data.ai = ai;
data.getdata = [d time];
data.daqfft = rms;
%data.daqfft = [f mag];
data.handle = [];

% Set the object's UserData to data.
set(data.ai, 'UserData', data);

% ***********************************************************************   
% Create the display.
function data = localInitFig(data)

% Initialize variables.
btnColor=get(0,'DefaultUIControlBackgroundColor');

% Position the GUI in the middle of the screen
screenUnits=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);
figWidth=600;
figHeight=360;
figPos=[(screenSize(3)-figWidth)/2 (screenSize(4)-figHeight)/2  ...
      figWidth                    figHeight];

% Create the figure window.
hFig=figure(...                    
   'Color'             ,btnColor                 ,...
   'IntegerHandle'     ,'off'                    ,...
   'DoubleBuffer'      ,'on'                     ,...
   'DeleteFcn'         ,'demoai_fft(''close'',gcbf)',...
   'MenuBar'           ,'none'                   ,...
   'HandleVisibility'  ,'on'                     ,...
   'Name'              ,'Analog Input FFT demo'  ,...
   'Tag'               ,'Analog Input FFT demo'  ,...
   'NumberTitle'       ,'off'                    ,...
   'Units'             ,'pixels'                 ,...
   'Position'          ,figPos                   ,...
   'UserData'          ,[]                       ,...
   'Colormap'          ,[]                       ,...
   'Pointer'           ,'arrow'                  ,...
   'Visible'           ,'off'                     ...
   );


% % Create the FFT subplot.
%____________________________
hAxes = axes(...
   'Position'          , [0.1300 0.1100 0.7750 0.6878],...
   'Parent'            , hFig,...
   'XLim'              , [1.1 2]...
   );

% % Plot the data.
%n=length(data.getdata(:,1));
%rms=norm(data.getdata(:,1))/sqrt(n);
%rms=mean(data.getdata(:,1))
%rms=log(abs(rms))

xachse=1.1:0.1:2;
rms=data.daqfft;
%rmsvector(1:10)=mean(data.daqfft(:, 2));
%hFig = data.handle.figure;

%hLine=plot(xachse, rmsvector, 'r');
%hLine=rectangle('position',[xachse(1) rms-10 xachse(end)-xachse(1) 20]);
hLine=line('xdata',[mean(xachse);mean(xachse)],'ydata',[rms;rms],'linewidth',4);

set(hLine,'erasemode','xor');
% Label the plot.
%xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% Create a start/stop pushbutton.
htoggle = uicontrol(...
   'Parent'          , hFig,...
   'Style'           , 'pushbutton',...
   'Units'           , 'normalized',...
   'Position'        , [0.0150 0.0111 0.1 0.0556],...
   'Value'           , 1,...
   'String'          , 'Stop',...
   'Callback'        , 'demoai_fft(''stop'', gcbf);');

hmenu(1) = uimenu('Parent', hFig,...
   'Label', 'File');
hmenu(2) = uimenu(hmenu(1),...
   'Label', 'Close demoai_fft',...
   'Callback', 'demoai_fft(''close'',gcbf)');
hmenu(3) = uimenu('Parent', hFig,...
   'Label', 'Help');
hmenu(4) = uimenu(hmenu(3),...
   'Label', 'Data Acquisition Toolbox',...
   'Callback', 'helpwin(''daq'')');
hmenu(5) = uimenu(hmenu(3),...
   'Label', 'demoai_fft',...
   'Callback', 'helpwin(''demoai_fft'')');

% Store the handles in the data matrix.
data.handle.figure = hFig;
data.handle.axes = hAxes;
data.handle.line = hLine;
data.handle.toggle = htoggle;
data.state = 0;
data.targetdb=-10;

collist='ryggyr';

for ii=1:6
    gline(ii)=line('xdata',[xachse(1);xachse(end)],'ydata',[data.targetdb;data.targetdb],'linewidth',4,'color',collist(ii));
end;
data.handle.gline=gline;

fixaxes(data);





% Set the axes handlevisibility to off.
set(hAxes, 'ygrid', 'on');
set(hAxes, 'HandleVisibility', 'off');

% Store the data matrix and display figure.
set(hFig,'Visible','on','UserData',data,'HandleVisibility', 'off');
%set(hFig,'Visible','on','UserData',data);

% Configure the callback to update the display.
set(data.ai, 'TimerFcn', @localfftShowData);

% ***********************************************************************  
% Close the figure window.
function localClose(data)

% Stop the device if it is running and delete the object.
if isvalid(data.ai)
   if strcmp(get(data.ai, 'Running'), 'On')
      stop(data.ai);
   end
   delete(data.ai);
end

% Close the figure window.
delete(data.handle.figure);

% ***********************************************************************  
% Stop or start the device.
function data = localStop(data)

% Based on the state either stop or start.
if strcmp(data.ai.Running, 'On')
   % Stop the device.
   stop(data.ai);
   set(data.handle.toggle, 'String', 'Start');
   
   % Store the new state.
   data.state = 1;
else
   % Toggle the Start/Stop string.
   set(data.handle.toggle, 'String', 'Stop');
   
   % Store the new state.
   data.state = 0;
   
   % Start the device.
   start(data.ai);
end

% ***********************************************************************  
% Calculate the fft of the data.
function [f, mag] = localDaqfft(data,Fs,blockSize)

% Calculate the fft of the data.
xFFT = fft(data);
xfft = abs(xFFT);

% Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

mag = 20*log10(xfft);
mag = mag(1:blockSize/2);

f = (0:length(mag)-1)*Fs/blockSize;
f = f(:);

% ***********************************************************************  
% Update the plot.
function localfftShowData(obj,event)



% Get the handles.
data = obj.UserData;

hFig = data.handle.figure;
hAxes = data.handle.axes;
hLine = data.handle.line;

%ddd=get(hFig,'userdata');


% Execute a peekdata.
x = peekdata(obj, obj.SamplesPerTrigger);
%x = getdata(obj, obj.SamplesPerTrigger);

% FFT calculation.
%Fs = obj.SampleRate;
%blockSize = obj.SamplesPerTrigger;
%[f,mag] = localDaqfft(x,Fs,blockSize);

rms=10*log10(mean(x.^2));
%rms=10*log10(max(x.^2));



% Dynamically modify Analog axis as we go.
%maxX=max(x);
%minX=min(x);
%yax1=get(hAxes(1),'YLim');
%if minX<yax1(1),
%   yax1(1)=minX;
%end
%if maxX>yax1(2),
%   yax1(2)=maxX;
%end
%set(hAxes(1),'YLim',[-60 30])
%set(hAxes(1),'YLim',[dbbase dbtop],'ytick',[maximumgruen maximumgruen+targetrange])

% Dynamically modify Frequency axis as we go.
%maxF=max(f);
%minF=min(f);
%____________________
%xax=get(hAxes,'XLim');
%if minF<xax(1),
%  xax(1)=minF;
%end
%if maxF>xax(2),
%  xax(2)=maxF;
%end
%______________________
%set(hAxes,'XLim',xax)

% Dynamically modify Magnitude axis as we go.
%maxM=max(mag);
%minM=min(mag);
%_________________________
%yax2=get(hAxes,'YLim');
%if minM<yax2(1),
%   yax2(1)=minM;
%end
%if maxM>yax2(2),
%   yax2(2)=maxM;
%end
%________________________
%set(hAxes,'YLim',[-60, 30])
%set(hAxes,'YLim',[dbbase dbtop])


% Update the plots.

%set(hLine, 'XData', f(:,1), 'YData', mag(:,1));
%xachse=1.1:0.1:2;
%rmsvector(1:10)=mean(mag(:, 1));
%rmsvector=mean(mag(:, 1));

%set(hLine, 'XData', xachse, 'YData', rmsvector);

dbbase=get(hAxes,'ylim');
dbbase=dbbase(1);

%if rms<=dbbase 
%    rms=dbbase+0.1;
%end

set(hLine,'ydata',[dbbase;rms]);


%rms=min([rms dbtop]);
%totalrange=dbtop-dbbase;
%totalrange2=totalrange/2;
%gruendist=abs(rms-(dbbase+totalrange2));
%gruendist=gruendist/totalrange2;
%redval=gruendist;
%greenval=1-gruendist;


%set(hLine, 'position', [xachse(1) dbbase xachse(end)-xachse(1) rms-dbbase]);

%    set(hLine, 'faceColor',[redval greenval 0]);



%if rms<maximumgruen
%    set(hLine, 'Color', 'green')
%    set(hLine, 'faceColor', 'green')
%    set(hLine, 'LineWidth', 4);
%elseif rms>maximumgruen & rms<=(maximumgruen+targetrange)
%    set(hLine, 'Color', 'yellow')
%    set(hLine, 'faceColor', 'yellow')
%    set(hLine, 'LineWidth', 30);
%else set(hLine, 'Color', 'red')
%else set(hLine, 'faceColor', 'red')
%    set(hLine, 'LineWidth', 50);
%end


str=get(data.handle.toggle, 'String');
if strcmp(str,'Start')
    set(data.handle.toggle, 'String', 'Stop');
end

drawnow;
function fixtarget(data,mytarget)
data.targetdb=mytarget;
set(data.handle.figure,'userdata',data);

fixaxes(data);
function fixaxes(data)

targetdb=data.targetdb;

targetinc=3;
rangebelow=targetinc*6;
rangeabove=rangebelow;
dbbase=targetdb-rangebelow;
dbtop=targetdb+rangeabove;

gline=data.handle.gline;
glist=[targetdb-3*targetinc targetdb-2*targetinc targetdb-targetinc targetdb+targetinc targetdb+2*targetinc targetdb+3*targetinc];

for ii=1:length(gline)
    set(gline(ii),'ydata',[glist(ii);glist(ii)]);
end;
set(data.handle.axes,'ylim',[dbbase dbtop],'ytick',[dbbase:targetinc:dbtop]);
