function lida_rtmon2file(pospath,displaychans,timerspec,sensorlist)
% LIDA_RTMON2FILE Monitor AG500/501 realtime data stream. Store trialwise tofile
% function lida_rtmon2file(pospath,displaychans,timerspec)
% lida_rtmon2file: Version 28.05.2013
%
%   Description
%       Monitor AG500/501 realtime data stream. Store data trialwise, and
%       call show_trialox to display it. Stores rms signal amplitude as
%       'parameter 7'
%       Numeric display runs all the time
%
%   Syntax
%       pospath: optional. If present, store pseudo position files,
%           whenever a trial is completed
%       displaychans: optional. Default to 1:12
%		timerspec: optional. Default to 1/25. Update interval for graphics
%           and trial data buffer.
%           No longer really an accurate timer interval; simply the fastest
%           rate at which the program will try and update display and data
%           storage
%       sensorlist: List of sensor names.
%           Must correspond to the number of sensors in the input data
%           stream. Currently (10.2012), this is 12 for AG500 and 16 for
%           AG501.
%           The argument is optional, but should be used if at all
%           possible, since sensor names are passed to the output files,
%           and thence to display by show_trialox
%
%	Assumptions
%		The following line should be placed in startup.m (replacing
%			topleveldir as appropriate)
%			javaaddpath([topleveldir 'phil/3dnew/lida/java/recmon/dist/recmon.jar']);
%		cs5recorder must be running before this program is started
%
%	Updates
%		10.2012 First version, based on lida_rtmon, but using show_trialox
%		to do graphics
%
%       See Also getemaall, lida_connect, show_trialox
%

functionname='lida_rtmon2file: Version 28.05.2013';
nsensor=24;     %maximum number of sensors
%ndim=6;    %not used
npar=7;     %number of parameters returned by getemaall (x, y, z, phi, theta, rms, spare)
%spare will be used for pegel

maxsamp=30000;

datab=ones(maxsamp,npar,nsensor)*NaN;
samplenum=ones(maxsamp,1)*NaN;
sampletime=ones(maxsamp,1)*NaN;

sampi=1;

ndig=4;
ampfac=1000;
pars2print=1:npar;      %manipulate to e.g. restrict display to signal amplitude
rmslim=30;      %input argument?
rmsuse=rmslim;
lidatimeout=200;	%possibly higher value sometimes useful to prevent apparent lost connection?

hf2=[];         %trigger initialization of show_trialox


chanlist=[];
if nargin>1 chanlist=displaychans; end;
if isempty(chanlist) chanlist=1:12; end;

sensornames='';
if nargin>3
    sensornames=sensorlist;
end;

%needed for tcip socket
import java.io.*;
import java.net.*;
% this should be placed in startup.m




try
    [socket,agname]=lida_connect(lidatimeout);
catch
    error('Failed to connect. Is "cs5recorder" running?');
end


timerperiod=1/25;
if nargin>2 timerperiod=timerspec; end;



%length of orientation vectors in mm
orilength=10;

deg2rad=pi/180;


hf=figure;

pause(1);

%first call seems to return all zeros, so do twice

firstok=0;
while ~firstok
    try
        pause(0.2)
        [active,sample,sweep,dataS,dataC,pos] = getemaall (socket,agname);
        pause(0.2)
        [active,sample,sweep,dataS,dataC,pos] = getemaall (socket,agname);
        firstok=1;
    catch
        disp('lida_rtmon2file. problem with first call to getemaall');
        disp(lasterr);
        %    keyboard;
        
        %    error(['An error occured when trying to read from the socket.' crlf lasterr]);
    end;
end;

pegel=eucdistn(dataS,zeros(size(dataS)));
pos(:,npar)=pegel*ampfac;

nchanin=size(pos,1);

if nchanin~=size(sensornames,1)
    sensornames=strcat('Sensor',int2str0((1:nchanin)',2));
    if nargin>3
        disp('Using dummy sensor names');
        disp('Input sensor list does not match number of channels in data');
        keyboard;
    end;
end;



nchan=length(chanlist);     %note: not necessarily the same as the number of channels in the input data

%tmpdig=length(int2str(max(chanlist));
chanstr=int2str(chanlist');
sensornx=sensornames(chanlist,:);
chanstr=[chanstr blanks(nchan)' sensornx];

oridata=ones(size(pos,1),3);
[oridata(:,1),oridata(:,2),oridata(:,3)]=sph2cart(pos(:,4)*deg2rad,pos(:,5)*deg2rad,orilength);


%allow for a list of sensor names
hax=axes;
ht=text(0,0,[chanstr blanks(nchan)' int2str(round(pos(chanlist,:)))],'fontsize',8,'fontname','Courier','fontweight','bold','interpreter','none');
xtmp=get(ht,'extent');
set(gca,'xlim',[xtmp(1) xtmp(1)+xtmp(3)],'ylim',[xtmp(2) xtmp(2)+xtmp(4)]);
set(ht,'clipping','off','tag','list_display');
htit=title(['x, y, z, phi, theta, rms(resid), rms(amp)*' int2str(ampfac)]);
set(gca,'visible','off');
set(htit,'visible','on','tag','list_title');


set(hf,'doublebuffer','on','tag','lida_rtmon2file');

%set simple button-down callback
set(hf,'windowbuttondownfcn',@figure_cb);

set(hf,'userdata',0);
keyboard;
tic;
lasttoc=0;

finished=0;

disp('Click in text display figure to pause and exit');
oldactive=0;        %does it matter if this is actually not correct?

while ~finished
    
    mybutton=get(hf,'userdata');
    if mybutton
        disp('type finished=1 to terminate');
        disp('Change data in text window by choosing columns with pars2print');
        keyboard;
        set(hf,'userdata',0);
    end;
    
    
    newtoc=toc;
    if (newtoc-lasttoc)>timerperiod
        lasttoc=newtoc;
        skipnew=1;
        
        if ~skipnew
            readok=0;
            while ~readok
                try
                    [active,sample,sweep,dataS,dataC,pos] = getemaall (socket,agname);
                    readok=1;
                catch
                    disp('Reconnecting ...');
                    %		disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
                    
                    retrycount=0;
                    connected=0;
                    retrylimit=10;
                    while ~connected
                        try
                            socket.close; %close the socket in any case, maybe timeout
                            %was for different reasons than a broken
                            %socket
                            [socket,agname]=lida_connect(lidatimeout);
                            [active,sample,sweep,dataS,dataC,pos] = getemaall (socket,agname);
                            
                            connected=1;
                        catch
                            retrycount=retrycount+1;
                            if retrycount==retrylimit
                                disp('Unable to reconnect?');
                                disp('Is cs5recorder running?');
                                
                                keyboard;
                                socket.close; %close the socket in any case, maybe timeout
                                [socket,agname]=lida_connect(lidatimeout);
                                [active,sample,sweep,dataS,dataC,pos] = getemaall (socket,agname);
                                connected=1;
                            end;
                        end;
                    end;
                end;
            end;
        end
        
        skipold=0;
        
        if ~skipold
            conrepeat=0;
            maxconrepeat=10;
            %==================
            while 1
                try
                    [active,sample,sweep,dataS,dataC,pos] = getemaall (socket,agname);
                catch
                    %disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
                    socket.close; %close the socket in any case, maybe timeout
                    %was for different reasons than a broken
                    %socket
                    if (conrepeat >= maxconrepeat)
                        disp('Failed to connect. Is "cs5recorder" running?');
                        disp('Type return to try again.');
                        keyboard;
                        conrepeat=0;
                        disp('Type return to stop');
                        continue;
                    end
                    conrepeat=conrepeat+1;
                    disp(['Connection lost. Auto reconnect try ' num2str(conrepeat) ' of ' num2str(maxconrepeat) '.']);
                    try
                        pause(0.02);
                        [socket,agname]=lida_connect(lidatimeout);
                        connected=true;
                    catch
                    end
                    continue
                end
                break;
            end
        end
        %==================
        
        
        nchanin=size(pos,1);
        pegel=eucdistn(dataS,zeros(size(dataS)));
        pos(:,npar)=round(pegel*ampfac);
        
        
        
        %new trial has started. Get relative time in trial; activate trace?
        if active & ~oldactive
            tic;
            lasttoc=0;
            sampi=1;
            mytrial=sweep;
        end;
        
        if active
            set(hf,'name',['Trial ' int2str(sweep) ' running: ' num2str(toc) 's']);
            
            if sampi<=maxsamp
                datab(sampi,:,1:nchanin)=pos';
                samplenum(sampi)=sample;
                sampletime(sampi)=toc;
                sampi=sampi+1;
                %also save time from toc
                
            else
                disp('Buffer full for current trial');
            end;
            
            
        end;
        
        trialfinished=0;
        if ~active & oldactive
            meaninterval=nanmean(diff(sampletime));
            samplerate=1/meaninterval;       %used in output file
            timnum=[meaninterval timerperiod];
            timnum=int2str(round(1./timnum));
            %samplerate probably not very accurate.
            %samplenum probably gives more accurate version of temporal
            %location of each sample (but how to convert it to time?)
            set(hf,'name',['Trial ' int2str(mytrial) ' lasted ' num2str(toc) 's. Timer rate (Hz: actual,set): ' timnum]);
            trialfinished=1;
            tic;
            lasttoc=0;
        end;
        
        
        chanstr=int2str(chanlist');
        sensornx=sensornames(chanlist,:);
        chanstr=[chanstr blanks(nchan)' sensornx];
        
        set(ht,'string',[chanstr blanks(nchan)' int2str(round(pos(chanlist,pars2print)))]);
        if trialfinished
            sampuse=sampi-1;
            sampi=1;
            if ~isempty(pospath)
                %occasionally screwy values for trial number have occurred
                %which presumably means the data stream must have been
                %corrupt at some stage
                trialnumok=1;
                if mytrial<0 trialnumok=0;end;
                trials=int2str0(mytrial,ndig);
                if length(trials)>ndig trialnumok=0; end;
                
                if trialnumok
                    outname=[pospath trials];
                    %check for rmslim. set to nan
                    %note: number of channels in output file is equal to the number
                    %of channels in the tcpip data stream
                    %Quite often the number of channels used for the text display will be fewer
                    data=datab(1:sampuse,:,1:nchanin);
                    
                    for ii=nchanin
                        if sum(sum(data(:,:,ii)))==0
                            data(:,:,ii)=NaN;
                        else
                            vv=find(data(:,6,ii)>rmsuse);
                            if ~isempty(vv)
                                disp([int2str(length(vv)) ' bad samples in sensor ' int2str(ii)]);
                                data(vv,:,ii)=NaN;
                            end;
                        end;
                    end;
                    
                    %also set deactivated channels to NaN......???
                    
                    data=single(data);
                    
                    [descriptor,unit,dimension]=headervariables;
                    dimension.axis{3}=sensornames;
                    descriptor=cellstr(descriptor);
                    descriptor{npar}='RMS_sigamp';
                    descriptor=char(descriptor);
                    unit=cellstr(unit);
                    unit{npar}=['normamp * ' int2str(ampfac)];
                    unit=char(unit);
                    
                    dimension.axis{2}=descriptor;
                    
                    comment=framecomment('Data from realtime TCPIP data stream. Note that samplerate and sampling interval is only approximate',functionname);
                    %use samplenum to interpolate to equidistant samples
                    %descriptor esp for signal rms
                    save(outname,'data','descriptor','dimension','samplerate','comment','unit','-v6');
                    
                    %call show_trialox
                    graphstep=1;
                    tanflag=0;  %so rms sig amp is displayed
                    maxminflag=1;   %also more useful for rms sig amp
                    %??indicator in show_trialox for the range setting
                    dofigpos=0;
                    if isempty(hf2)
                        dofigpos=1;
                        mytrial=-mytrial;       %always try and load existing statistics
                    end;
                    [statxb,statsdb,nancntb,hf2]=show_trialox(pospath,mytrial,chanlist,hf2,graphstep,tanflag,maxminflag);
                    if dofigpos
                        disp('Position figures and type return');
                        keyboard;
                    end;
                else
                    disp(['Trial number probably corrupt : ' int2str(mytrial)]);
                    disp('Skipping storage and display');
                end;
                
            end;        %pospath not empty
            datab(1:sampuse,:,1:nchanin)=NaN;
            samplenum(1:sampuse)=NaN;
            sampletime(1:sampuse)=NaN;
        end;            %trialfinished
        oldactive=active;
        
    end;        %newtoc-lasttoc > timerperiod
end;            %not finished

disp('Type return to stop');
keyboard;


socket.close;

function figure_cb(cbobj,cbdata)
% Indicates button press in figure 1

set(cbobj,'userdata',1);
