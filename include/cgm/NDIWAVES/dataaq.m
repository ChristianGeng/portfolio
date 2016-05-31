function [lh]=dataaq(src,event)
%


hfDAQFound=findobj('Tag','hfDAQ');
figure(hfDAQFound)

global DAQData srate nSampsAcquired datsize nchan unit NIsession private daqOutFile axYlims


idxSt=nSampsAcquired+1;


% not clear yet how to treat overrun
if (nSampsAcquired>=datsize)
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
   
    nSampsAcquired=nSampsAcquired+nNewRows;
    DAQData(idxSt:nSampsAcquired,:)=event.Data;
    doplot=1;
    whos event.Data
    
    if doplot
        for idX=1:nchan
            subplot(nchan,1,idX)
            plot(event.TimeStamps, event.Data(:,idX))
            set(gca,'Ylim',axYlims{idX})
            
            
        end
    end
    
end