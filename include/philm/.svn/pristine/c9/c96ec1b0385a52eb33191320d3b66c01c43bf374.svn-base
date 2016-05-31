function hf=epg_rt(epgcmd,varargin);
% EPG_RT EPG data acquistion and real-time display
% function hf=epg_rt(epgcmd,varargin);
% epg_rt: Version 30.5.08
%
% Syntax
%   hf=epg_rt('ini',comname,filename,samplerate,maxframes);
%   epg_rt('recstart',trialnumber)
%   epg_rt('recstop')
%   epg_rt('shutdown')
%   hf=epg_rt('test')
%   epg_rt('replay',sampleratefactor,myframes) (myframes=[startframe endframe]; sampleratefactor and myframes are optional)
%   If the commands ini or test fail, then output argument hf is set to
%   zero. Otherwise it contains the handle of the EPG display figure
%   When recording is started with 'recstart' then it can be stopped by
%   hand with 'recstop', or will stop automatically after approximately
%   maxframes have been acquired.
%   A short synchronization pulse is output at the start and end of
%   recording.
%   At the end of recording the data is stored to disk in two formats:
%       First of all the raw epg data stream in raw binary format (9 bytes
%       per frame; 1st byte is check byte, last byte is front row)
%       Secondly, if all checkbytes are correct, and if the correct number
%       of frames marked at the onset of the synchronization pulses is
%       found then the data is output in mtnew compatible mat files.
%   If filename is empty (at initialization) or if trialnumber is <=0 (with command 'recstart')
%   then no data is stored. The program runs in pure display mode for any
%   length of time, until command 'recstop' is used (i.e any setting for
%   maxframes is ignored, and no synchronization pulses are generated).
%   Communication with calling programs (e.g prompt programs) is designed
%   to be handled via the userdata of the display figure.
%   e.g a calling program can look at fields userdata.logmessage or userdata.errorflag
%   for status information on the last recorded trial
%       Current values used for errorflag are
%       1 and 2: Error in epgcheck (checkframe and synch frame errors,
%       respectively)
%       4 Error in epg writecommand (probably timeout)
%       8 Bad frame detected in callback function
%       16 timeout callback function
%       The field userdata.item_id can be set by the calling program with
%       e.g a prompt code to be stored in the output mat file
%   Note on samplerate at initialization:
%       The input argument samplerate will normally be a scalar equal to
%       100 or 200, corresponding to the two samplerates that can currently
%       be chosen in the system.
%       However, it can also be a 2-element vector with the first element
%       being equal to 100 or 200, and the second element equal to the
%       samplerate to actually store in the samplerate variable of the
%       output mat files. This can save some fiddling around later, if it
%       has been empirically determined that there is slight discrepancy in
%       the clock rates between the EPG system and some other data
%       acquisition system. For example, comparisons with the Sony EX
%       system indicated an effective EPG samplerate of about 199.993 Hz
%       (as of Jan 2008). This is completely negligible if trials of only a
%       couple of seconds are to be recorded, but starts to be relevant for
%       synchronization of data when trials of 5 minutes or more are
%       envisaged. If in doubt, ignore and fix later (checkepgsync gives
%       the appropriate information).
%
%   Notes
%       Examples of com settings for various machines
%       (if the serial port is not found as expected then it will be
%       necessary to check in the device manager (look for usb-serial port
%       adapter)):
%       ibm r52 COM6, ibm r60 COM4, phil's desktop COM3, prompt pc COM3
%
%   See Also EPGXDIM Adds standard mtnew variables to the EPG mat files
%       CHECKEPGSYNC Counts epg frames based on scan signal between each
%       pair of synch pulses
%
%   Updates
%       5.08 replay function included

functionname='EPG_RT: Version 30.5.08';

epgcmd=lower(epgcmd);

if strcmp(epgcmd,'ini')

    inireturn=epgini(varargin{1},varargin{2},varargin{3},varargin{4},functionname);
    hf=inireturn;
    return;

end;

if strcmp(epgcmd,'test')
    inireturn=epgini(varargin{1},varargin{2},varargin{3},varargin{4},functionname);
    hf=inireturn;
    if inireturn
        recstart(0);
        pause(1);
        recstop;
        shutdown;
    else
        disp('EPG initialization failed. EPG_RT test mode ended');
    end;
    return;
end;

if strcmp(epgcmd,'debug')
    hf=findobj('type','figure','tag','EPGRT');
    userdata=get(hf,'userdata');
    comport=userdata.comport;
    get(comport);
    keyboard;
    return;
end;

if strcmp(epgcmd,'recstart')
    mytrial=0;
    if nargin>1 mytrial=varargin{1}; end;
    recstart(mytrial);
    return;

end;

if strcmp(epgcmd,'replay')
    sampleratefactor=1;
    if nargin>1 sampleratefactor=varargin{1}; end;
    myframes=[];
    if nargin>2 myframes=varargin{2}; end;

    replay(sampleratefactor,myframes);
    return;

end;

if strcmp(epgcmd,'recstop')
    recstop;
    return;
end;

if strcmp(epgcmd,'shutdown')
    shutdown;
    return;
end;

function replay(sampleratefactor,myframes);

global EPGDATA

hf=findobj('type','figure','tag','EPGRT');
userdata=get(hf,'userdata');

sfuse=userdata.samplerate*sampleratefactor;

totalframes=userdata.totalframes;

if isempty(myframes) myframes=[1 totalframes]; end;

if myframes(2)>totalframes myframes(2)=totalframes; end;
if myframes(1)<1 myframes(1)=1; end;

nframes=diff(myframes);
disp(['epgrt replay: Start and end frames : ' int2str(myframes)]);


if nframes<1
    disp('frame range not valid');
    return;
end;

epgcode=makeepgcode;

finished=0;
tic;
while ~ finished
    mytoc=toc;
    frameoff=round(mytoc*sfuse);
    iframe=myframes(1)+frameoff;
    if iframe>myframes(2) finished=1; end;
    if ~finished
        mydata=EPGDATA(:,iframe);

        %display
        dispframe=double(mydata(2:end));


        %convert to 64 element vector
        framebuf=(epgcode(dispframe+1,:))';

        framebuf=framebuf(:);

        xdatause=get(userdata.gridhandle,'xdata');
        xdatause(~framebuf)=NaN;

        set(userdata.datahandle,'xdata',xdatause);
        %        drawnow;

        set(userdata.titlehandle,'string',int2str([totalframes iframe]));
        drawnow;
    end;
end;




function inireturn=epgini(comname,filename,samplerate,maxframes,functionname);

global EPGDATA
%will be set to figure handle if successful
inireturn=0;

hf=findobj('type','figure','tag','EPGRT');
if ~isempty(hf)
    disp('Existing figures will be deleted');
    keyboard;
    close(hf);
end;




%first byte in frame should always be 170 (Hex AA)
%   This corresponds to a pattern of alternating on and off electrodes
%   (which is probably articulatorily impossible)
%   so if a pattern like this occurs in the epg display there has probably
%   been a hiccup in the data transfer

epgcfg.epgcheckbyte=170;

%synchronized frames are marked with bits 1 and 8 set in the last byte of
%the frame, i.e the two bits not normally used in the frontmost row
epgcfg.epgsynchbit=129;
epgcfg.epgbytesperframe=9;
epgcfg.epgbaudrate=57600;
epgcfg.timeout=2;
%try this as a way of distinguishing start and end of trials in long audio
%files
%note: short durations are not very accurate (appears to be a mimimum of
%about 20ms)
epgcfg.beeplengthstart=0.020;
epgcfg.beeplengthend=0.020;

epgcfg.commandpause=0.020;



epgcfg.updaterate=10;              %number of times per second to collect data/update display
epgcfg.serialbufferseconds=5;      %size of serial input buffer in seconds

%allow 1 second extra to shut down at end of trial
%Should be plenty, but if it is ever too short then the program
%will warn that the final chunk of data could not be stored, which may mean
%that the second marked frame may be lost
maxframesx=maxframes+samplerate(1);
EPGDATA=repmat(uint8(0),[epgcfg.epgbytesperframe maxframesx]);



%make row and column indices for 64 element vector
[ax1,ax2]=makeepgrowcolindex;



sampleratelist=[100 200];
sampleratecodes='AB';

vs=find(samplerate(1)==sampleratelist);
if ~isempty(vs)
    sampleratecodeuse=sampleratecodes(vs);
else
    disp('EPGINI: Samplerate not available');
    disp(samplerate(1));
    return;

end;


serialbuffersize=epgcfg.epgbytesperframe*samplerate(1)*epgcfg.serialbufferseconds;     %assume program will empty buffer continuously with fread



comport=serial(comname);
%baudrate seems to be the only essential setting
set(comport,'baudrate',epgcfg.epgbaudrate);

set(comport,'inputbuffersize',serialbuffersize);
set(comport,'bytesavailablefcnmode','byte');

updatesamples=round(samplerate(1)/epgcfg.updaterate);
updatebytes=updatesamples*epgcfg.epgbytesperframe;

set(comport,'bytesavailablefcncount',updatebytes);
set(comport,'bytesavailablefcn','');
set(comport,'timeout',epgcfg.timeout);
%also set up a callback for errors (timeout)
%    set(comport,'errorfcn',@epgerrorcb);

hf=figure;
set(hf,'tag','EPGRT');

hlgrid=plot(ax1,ax2,'.','tag','epggrid');
hold on;
hldata=plot(ax1,ax2,'o','tag','epgdata');
set(hldata,'markersize',12)
set(hldata,'linewidth',2)

set(hldata,'erasemode','xor');
xlim([0 9]);ylim([0 9]);

set(hldata,'userdata',0);   %will be used to flag termination

userdata.comport=comport;
userdata.filename=filename;
userdata.trialnumberdigits=4;
userdata.samplerate=samplerate;
userdata.sampleratecode=sampleratecodeuse;
userdata.gridhandle=hlgrid;
userdata.datahandle=hldata;
userdata.maxframes=maxframes;
userdata.totalframes=0;
userdata.synchexpected=2;
userdata.synchfound=0;
userdata.currenttrial=0;
userdata.functionname=functionname;
userdata.errorflag=0;
userdata.logmessage='';
userdata.item_id='';


userdata.epgcfg=epgcfg;


htit=title('0 0');          %will be used for frame count, and bytes in input buffer
set(htit,'erasemode','xor');
userdata.titlehandle=htit;

set(hf,'userdata',userdata);
set(hf,'backingstore','off');
set(hf,'doublebuffer','off');

set(hf,'windowbuttondownfcn',{@epgfigcb,hldata});

%open is now done each time by recstart but do here too to check that
%comport is available
try
    fopen(comport);
catch
    disp('EPGINI: Problem opening COM port');
    disp(lasterr);
    disp('Try restarting with another choice of port');
    close(hf);
    delete(comport);
    return;
end;


disp('Position EPG figure, then type return');

keyboard;
inireturn=hf;
fclose(comport);


function shutdown;
hf=findobj('type','figure','tag','EPGRT');

userdata=get(hf,'userdata');

comport=userdata.comport;
epgcfg=userdata.epgcfg;
%make sure EPG is no longer running

if strcmp(get(comport,'Status'),'closed')
    fopen(comport);
end;

epgok=writecmd('D',epgcfg.commandpause);

fclose(comport);
delete(comport);
delete(hf);


function recstart(itrial);
global EPGDATA
hf=findobj('type','figure','tag','EPGRT');

%check figure ok

userdata=get(hf,'userdata');
userdata.logmessage='';
userdata.errorflag=0;
userdata.synchfound=0;

if isempty(userdata.filename) itrial=0; end;

comport=userdata.comport;
epgcfg=userdata.epgcfg;

fopen(comport);

%make sure input buffer is empty and EPG not already running
framesa=0;
% if recstart always does fopen(comport) then this ought to be superfluous
%[tmp,framesa]=getframes(comport,1);
if framesa
    %put in log message??
    disp('RECSTART: Data already present in input buffer?');
    %most likely reason EPG not stopped properly for previous recording?
    fwrite(comport,'D');
    pause(epgcfg.commandpause);
    [tmp,framesa]=getframes(comport,1);
    if framesa
        disp('EPG was probably already running');
    end;
end;



%expand byte battern of 8 bits into 8 bytes
epgcode=makeepgcode;

epgok=writecmd(userdata.sampleratecode,epgcfg.commandpause);


totalframes=0;


%Mode C is no use for synchronization as no buzzer ttl signal
%fwrite(comport,'C');
epgok=writecmd('E',epgcfg.commandpause);



if itrial

    % use R rather than T for buzzer TTL signal, as T interrupts the scan signal
    epgok=writecmd('R',epgcfg.beeplengthstart);
    epgok=writecmd('U',epgcfg.commandpause);
else
    %wait a similar length of time to normal trial mode so it will be obvious
    %if the EPG is transferring data
    pause(epgcfg.commandpause*4);
end;


%what to do if ~epgok at this stage???

%flush frames up to now before activating callback function
% for storage and realtime display

[newframes,framesa]=getframes(comport,epgcfg.epgbytesperframe);

badcheck=0;
if framesa
    if newframes(1,1)~=epgcfg.epgcheckbyte
        disp('RECSTART: Bad checkbyte at start of data');
        %terminate immediately???
        badcheck=1;
    end;


    if itrial
        ipi1=totalframes+1;
        totalframes=totalframes+framesa;
        EPGDATA(:,ipi1:totalframes)=newframes;

    end;
end;

disp(['RECSTART: total frames ' int2str(framesa)]);

userdata.totalframes=totalframes;
if framesa==0 | badcheck==1
    set(userdata.datahandle,'userdata',1);
else
    set(userdata.datahandle,'userdata',0);
end;

userdata.currenttrial=itrial;

set(hf,'userdata',userdata);

set(comport,'bytesavailablefcn',{@epgrt_cb,hf,epgcode});

%callback function does storage and display

function epgrt_cb(cbobj,cbdata,hf,epgcode);
global EPGDATA
userdata=get(hf,'userdata');
epgcfg=userdata.epgcfg;

comport=cbobj;

finished=get(userdata.datahandle,'userdata');

if finished return; end;

itrial=userdata.currenttrial;

%what happens if we force getframes to get exactly the number of frames
%corresponding to bytesavailablefcncount?

[newframes,framesa]=getframes(comport,epgcfg.epgbytesperframe);

totalframes=userdata.totalframes;
ipi1=totalframes+1;

%store framesa in global??

if framesa
    if itrial
        totalframes=totalframes+framesa;
        EPGDATA(:,ipi1:totalframes)=newframes;

    end;
    %display latest frame

    %make sure checkbyte is OK
    %only frame to be displayed is actually checked
    badcheck=0;
    if newframes(1,end)~=epgcfg.epgcheckbyte

        ss='EPGRT_CB: Bad checkbyte in display frame';
        disp(ss);
        userdata.logmessage=[userdata.logmessage ss '. '];
        userdata.errorflag=userdata.errorflag+8;
        badcheck=1;
    end;
    dispframe=double(newframes(2:end,end));


    %convert to 64 element vector
    framebuf=(epgcode(dispframe+1,:))';

    framebuf=framebuf(:);

    xdatause=get(userdata.gridhandle,'xdata');
    xdatause(~framebuf)=NaN;

    set(userdata.datahandle,'xdata',xdatause);
    %        drawnow;

    %also finish if keypress, buffer overflow etc.
    cbfinished=(totalframes>userdata.maxframes) | badcheck;

    %check whether program is failing to keep up with realtime
    %bufsize=get(comport,'inputbuffersize');
    %bytesa=get(comport,'bytesavailable');
    %fillpercent=round((bytesa/bufsize)*100);


    %disable callbacks
    if cbfinished
        set(comport,'bytesavailablefcn','');
        set(userdata.datahandle,'userdata',1);

    end;

    set(userdata.titlehandle,'string',int2str([totalframes framesa]));

    userdata.totalframes=totalframes;
    set(hf,'userdata',userdata);
    if cbfinished recstop; end;
end;

function recstop
global EPGDATA

hf=findobj('type','figure','tag','EPGRT');


userdata=get(hf,'userdata');
set(userdata.datahandle,'userdata',1);

comport=userdata.comport;

%check port is not already closed???

if strcmp(get(comport,'Status'),'closed')
    disp ('RECSTOP: Port already closed?');
    return;
end;



%disable callbacks
set(comport,'bytesavailablefcn','');
epgcfg=userdata.epgcfg;

itrial=userdata.currenttrial;


if itrial
    %pause(rectime);
    epgok=writecmd('R',epgcfg.beeplengthend);
    epgok=writecmd('U',epgcfg.commandpause);
end;

epgok=writecmd('D',epgcfg.commandpause);

%what to do if ~epgok

%allow more time for remaining bytes to transfer??

%how to make sure all callbacks are finished??
[newframes,framesa]=getframes(comport,epgcfg.epgbytesperframe);


if ~itrial
    [newframes,framesa]=getframes(comport,1);
    if framesa disp('RECSTOP: Remaining bytes flushed from input buffer'); end;


    fclose(comport);

    return;

end;



totalframes=userdata.totalframes;
if framesa
    ipi1=totalframes+1;
    totalframes=totalframes+framesa;
    %This should be very unlikely, so don't bother trying to store the final
    %chunk come what may
    if totalframes>size(EPGDATA,2)
        disp('RECSTOP: Unable to store final chunk');
        totalframes=totalframes-framesa;
    else
        EPGDATA(:,ipi1:totalframes)=newframes;
    end;


end;

%keyboard;

%check totalframes not zero???
if totalframes>0

    data=EPGDATA(:,1:totalframes);


    ndig=userdata.trialnumberdigits;
    %write raw data to binary file
    %may be superseded by streaming to disk, in which case read from binary
    %file here
    binname=[userdata.filename '_' int2str0(userdata.currenttrial,ndig) '.epg'];
    fid=fopen(binname,'w');
    nbin=fwrite(fid,data,'uint8');
    fclose(fid);

    %return number of synch found
    [data,errorflag,mymessage,nsynch]=epgcheck(data,epgcfg);

    userdata.errorflag=userdata.errorflag+errorflag;
    userdata.logmessage=[userdata.logmessage mymessage];
    userdata.totalframes=totalframes;
    userdata.synchfound=nsynch;
    set(hf,'userdata',userdata);

    if ~errorflag
        comment=['Trial ' int2str(userdata.currenttrial) ', total frames ' int2str(totalframes) '. ' userdata.logmessage];

        nout=size(data,2);

        %    disp(['Output frames ' int2str(nout)]);


        %convert all data to 64 vector of uint8, and store as mat file
        epgcode=makeepgcode;

        %rather an indirect way of defining this
        ncontacts=size(data,1)*size(epgcode,2);

        dataout=repmat(uint8(0),[ncontacts nout]);

        %additional choices for output:
        %(1)discard the two unused electrodes? This may unnecessarily complicate
        %computing row and column sums etc. (and e.g conversion back to a bit
        %pattern for export). Currently this is handled graphically: See
        %epgxdim.
        %(2) Reverse order of data so front electrodes come first?

        for ii=1:nout
            dispframe=double(data(:,ii));
            %This will put the front row as the first byte (i.e row 1)
            dispframe=flipud(dispframe);
            framebuf=(epgcode(dispframe+1,:))';
            framebuf=framebuf(:);

            dataout(:,ii)=framebuf;

        end;

        data=dataout;
        matname=[userdata.filename '_epg_' int2str0(userdata.currenttrial,ndig)];

        functionname=userdata.functionname;
        comment=framecomment(comment,functionname);

        samplerate=userdata.samplerate;
        samplerate=samplerate(end); %use second element if present
        item_id=userdata.item_id;
        private.epgrt=userdata;

        %don't store compressed data
        %can be done later if desired
        %(assume no versions earlier than version 6 will be used)
        myversion=version;
        saveop='-v6';
        if myversion(1)=='6' saveop=''; end;


        save(matname,'data','samplerate','comment','item_id','private',saveop);
        %use epgxdim to add additional variables (descriptor, unit, dimension)
        epgxdim(matname);

    else
        disp('No MAT file stored');
    end;

else
    disp(['RECSTOP: 0 Frames. No bin file stored. Error flag ' int2str(userdata.errorflag) '. ' userdata.logmessage]);

end;
%what happens if incomplete frames?? any way of resetting?
%input buffer will also be flushed when port is reconnected with fopen in
%recstart
[newframes,framesa]=getframes(comport,1);
if framesa disp('RECSTOP: Remaining bytes flushed from input buffer'); end;


fclose(comport);

function epgcode=makeepgcode;
%decode each possible 1-byte bit pattern into 8*uint8 vector of zero and one
epgcode=repmat(uint8(0),[256 8]);
for ii=0:255
    for jj=1:8
        epgcode(ii+1,jj)=bitget(ii,jj);
    end;
end;
function [ax1,ax2]=makeepgrowcolindex;
%set up x/y i.e column/row coordinates for 64 element vector
%(copied from epgxdim (internal dimension specification)

nrow=8;
ncol=8;
ax1=repmat((1:8)',[1 nrow]);
ax1=ax1(:);

ax2=repmat((1:8),[ncol 1]);
ax2=ax2(:);
function [newframes,framesa]=getframes(comport,framesize);

bytesa=get(comport,'bytesavailable');
newframes=[];
framesa=floor(bytesa/framesize);
if framesa
    newframes=uint8(fread(comport,[framesize framesa],'uint8'));

end;
function [dataout,errorflag,mymessage,nsynch]=epgcheck(data,epgcfg);

%also return number of synch found

errorflag=0;
dataout=[];
mymessage='';

lastgoodp=size(data,2);
vv=find(data(1,:)~=epgcfg.epgcheckbyte);
if ~isempty(vv)
    tmpstr=['EPCHECK: ' int2str(length(vv)) ' bad frames starting at frame ' int2str(vv(1))];
    mymessage=['%' tmpstr];
    disp(tmpstr);
    errorflag=errorflag+1;
    %any point in continuing??
    %    return;
    lastgoodp=vv(1)-1;
end;

%synch markers are in last byte of frame
%don't look for synch frames after any bad frames

nsynch=0;

if lastgoodp>0
    vv=find(bitand(epgcfg.epgsynchbit,data(epgcfg.epgbytesperframe,1:lastgoodp))==epgcfg.epgsynchbit);
    nsynch=length(vv);
end;

if nsynch==2
    nout=vv(2)-vv(1);
    tmpstr=['EPCHECK: Synch frames ' int2str(vv) '. n = ' int2str(nout)];
    disp(tmpstr);
    mymessage=[mymessage '%' tmpstr];
    %delete synch bits
    data(epgcfg.epgbytesperframe,[vv(1) vv(2)])=bitxor(epgcfg.epgsynchbit,data(epgcfg.epgbytesperframe,[vv(1) vv(2)]));
    %trim data to synchronized frames
    data=data(:,vv(1):(vv(2)-1));
else
    if nsynch==0

        tmpstr='EPGCHECK: No synch frames';
    else
        tmpstr=['EPGCHECK: Unexpected synch frames (first, last, n) :' int2str([vv(1) vv(end) length(vv)])];
    end;
    disp(tmpstr);
    mymessage=[mymessage '%' tmpstr];
    errorflag=errorflag+2;
end;

if ~errorflag
    %remove check byte
    data(1,:)=[];
    dataout=data;
end;

function epgok=writecmd(mycmd,mypause)

epgok=0;
hf=findobj('type','figure','tag','EPGRT');
userdata=get(hf,'userdata');
comport=userdata.comport;

if strcmp(get(comport,'Status'),'closed')
    disp(['Skipping write command ' mycmd '. Comport is closed']);
    return;
end;



try
    fwrite(comport,mycmd);
    pause(mypause);
catch
    %any other error apart from timeout possible?
    ss=['WRITECMD Error for command ' mycmd '. ' lasterr '. '];
    disp(ss);
    userdata.logmessage=[userdata.logmessage ss];
    userdata.errorflag=userdata.errorflag+4;
    set(userdata.datahandle,'userdata',1);
    set(hf,'userdata',userdata);
    fclose(comport);
    return;
end;
epgok=1;
function epgerrorcb(obj,data);
hf=findobj('type','figure','tag','EPGRT');

userdata=get(hf,'userdata');
userdata.errorflag=[userdata.errorflag+16];
set(userdata.datahandle,'userdata',1);
cbmessage=data.Data.Message;
ss=['EPG error callback function triggered. ' cbmessage '. '];
disp(ss);
userdata.logmessage=[userdata.logmessage ss];
set(hf,'userdata',userdata);
fclose(userdata.comport);
function epgfigcb(cbobj,cbdata,hl);
% click in epg figure
set(hl,'userdata',1);
