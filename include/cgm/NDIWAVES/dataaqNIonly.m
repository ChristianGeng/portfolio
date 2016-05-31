%% DOCUMENT TITLE
% INTRODUCTORY TEXT
%%
function [lh]=dataaqNIonly(src,event)
%


%lh = s.addlistener('DataRequired', @(src,event)...
%     src.queueOutputData([outputData0 outputData1]));


%lh = addlistener('eventName',@callback)
%lh = addlistener('eventName', @(src, event) expr)

%
%
% feature memstats
%
% user = memory
% anzahl floats (user.MaxPossibleArrayBytes/8)
%
% Anzahl Elemente bei 2 Kanaelen:
% user.MaxPossibleArrayBytes/8
% anzahl sekunden bei 2 channels 
% (((user.MaxPossibleArrayBytes/8)/2)/25000)
% und das ganze in Stunden: 
% (((user.MaxPossibleArrayBytes/8)/2)/25000)/3600
%  9.6570
%
%disp(srate)

hfDAQFound=findobj('Tag','hfDAQ');
figure(hfDAQFound)

global DAQData srate nSampsAcquired datsize nchan unit NIsession private daqOutFile


% get from workspace
% DAQData=evalin('caller','DAQData');
% srate=evalin('caller','srate');
% nSampsAcquired=evalin('caller','nSampsAcquired');
% datsize=evalin('caller','datsize');

idxSt=nSampsAcquired+1;


% not clear yet how to treat overrun 
if (nSampsAcquired>=datsize)
    % nchan=evalin('caller','nchan');
    % unit=evalin('caller','unit');
    %NIsession=evalin('caller','NIsession');
    %private=evalin('caller','private');
    
    % daqOutFile=evalin('caller','daqOutFile');
    %warning('Size of Allocated data exceeded, saving data and stopping aquisition');
    NIsession.stop();
    disp(['bufsize exceeded, saving data to ' daqOutFile]);
    DAQData(nSampsAcquired+1:end,:)=[];
    save (daqOutFile,'DAQData','nSampsAcquired','srate','nchan','unit','private');
    disp(['aquired ' num2str(nSampsAcquired) ' samples']);
    %disp(srate)
    disp(['recorded '  num2str(nSampsAcquired/srate) ' secs.' ])
    disp(['typing <return> will not save data again' ])
    
else
    nNewRows=(size(event.Data,1));
    
    % hardcoded samplerate
    nsecs=nNewRows/srate;
    %disp([nNewRows nsecs])
    nSampsAcquired=nSampsAcquired+nNewRows;
    %disp(nSampsAcquired)
    DAQData(idxSt:nSampsAcquired,:)=event.Data;
    % back to workspace
    %assignin('caller','DAQData',DAQData);
    %assignin('caller','nSampsAcquired',nSampsAcquired);
    doplot=1;
    whos event.Data
    
    if doplot
        subplot(1,1,1)
        plot(event.TimeStamps, event.Data(:,1))
        %set(gca,'Ylim',[-0.1 0.1])
        
%        subplot(2,1,2)
%        plot(event.TimeStamps, event.Data(:,2))
        %dat=event.Data;
        set(gca,'Ylim',[-5 5])
    end
    
end