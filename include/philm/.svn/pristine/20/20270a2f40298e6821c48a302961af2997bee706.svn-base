function mv410_ctrl(mylayout,justdate)
% function mv410_ctrl(mylayout,justdate)
% mylayout: 1 for ema, 2 for ultrasound
% justdate: default to true: just set date and exit
%ema setup
%instrhwinfo ('serial')

sstmp=instrfind;
if ~isempty(sstmp)
    fclose(sstmp);
    delete(sstmp);
    clear sstmp;
    
end;

ss=serial('COM1');
fopen(ss)
set(ss,'term','CR/LF')
%other default settings seem to be ok

layoutnum=int2str0(mylayout,2);

dateflag=1;
if nargin>1 dateflag=justdate; end;

oldtimeout=get(ss,'Timeout');
set(ss,'Timeout',2);    %default is 10; set to 2 to get a quick timeout if not turned on

%if mv410 not turned on, timeout gives a warning (but not an error) for
%fscanf and no bytes are read (fprintf doesn't seem to give a warning or
%error)
fprintf(ss,['SDS0' layoutnum]);       %choose layout
myrep=fscanf(ss);

if isempty(myrep)
    disp('MV410 probably not turned on');
    disp('Please check and try again');
    keyboard;
    fclose(ss);
    delete(ss);
    clear ss;
    return;
end;

set(ss,'Timeout',oldtimeout);   %restore default setting
disp(['Setting layout: ' myrep]);       %should be 'OK'

flist=[60 59.94 50]; %0, 1, 2
reslist=[1280 1024;1360 768;1600 1200;1920 1200;1440 900;1680 1050;1920 1080;1280 720];

%not sure if output frequency and resolution needs setting after chosing layout

if mylayout==1
    fcode=2;        %50 Hz, for EMA with pal camera
end;
if mylayout==2
    fcode=1;        %59.94 Hz, for ultrasound with ntsc minicam
end;

fcheck=getfrequency(ss);
disp(['Current frequency setting ' int2str(flist(fcheck+1))]);

if fcheck~=fcode
    
    fprintf(ss,['SOF0' int2str0(fcode,1)]);       %set output frequency 0=60, 1 = 59.94, 2 = 50
    myrep=fscanf(ss);
    fcheck=getfrequency(ss);
    if fcheck~=fcode
        disp('Output frequency setting not successful');
        keyboard;
    else
        disp(['Output frequency set to ' int2str(flist(fcode+1))]);
    end;
    
end;


resnum=6;
%set output resolution
%note: if resolution is changed all settings must be re-done
rescheck=getresolution(ss,mylayout);
pixlim=reslist(rescheck+1,:);
disp(['Current screen size : ' int2str(pixlim)]);

if rescheck~=resnum
    
    dateflag=0;     %all settings must be re-done
    fprintf(ss,['SLO0' layoutnum int2str0(resnum,2)]);       %set output resolution
    myrep=fscanf(ss);
    disp(['Setting output resolution: ' myrep]);       %should be 'OK'
    
    %should use pixlim when defining window positions
    
    %check setting
    rescheck=getresolution(ss,mylayout);
    if rescheck~=resnum
        disp('Resolution not set?');
        keyboard;
    else
        pixlim=reslist(resnum+1,:);
        disp(['Using screen size : ' int2str(pixlim)]);
        
    end;
    
end;
screenw=pixlim(1);
screenh=pixlim(2);

%always set date and time
mytime=now;
ds1=datestr(mytime,'HH:MM:SS');
ds1=strrep(ds1,':','');

ds2=datestr(mytime,'yy/mm/dd');
ds2=strrep(ds2,'/','');

ds=[ds2 ds1];

fprintf(ss,['SDT' ds]);
myrep=fscanf(ss);
disp(['Setting time: ' myrep]);       %should be 'OK'

date2tit=datestr(mytime,'dd-mmm-yyyy'); %put date in a title?
settit(ss,mylayout,80,1,4,date2tit);        %put date as title of clock; midsize, red

if dateflag
    %close serial connection
    fclose(ss);
    delete(ss);
    clear ss;
    
    return;
    
end;
disp('layout set after ''return''');
keyboard;

winlist=[1 2 3 4 80];   %clock is 80
nwin=length(winlist);

%window left, top, width, height
winposb=ones(nwin,4)*NaN;
%title left and top
%seems to be actual screen position, not relative position within window
wintitposb=ones(nwin,2)*NaN;
winpriority=ones(1,nwin);
titsizen=zeros(1,nwin); %default small
titcolorn=ones(1,nwin); %default??

wincropb=ones(nwin,4)*NaN;

if mylayout==1
    winlist(3)=NaN; %don't set window 3
    wintitle=str2mat('1. PAL, frontal','2. DVI prompt PC','','4. VGA free',date2tit);
    
    %setpos(ss,mylayout,80,5,1920-260,1080-260,256,256,1920-260-8,1080-260);%clock
    %80. clock
    winposb(end,:)=[screenw-260 screenh-260 256 256];
    wintitposb(end,:)=[winposb(end,1)-8 winposb(end,2)];
    winpriority(end)=5;
    titsizen(end)=1;    %midsize
    titcolorn(end)=4;
    
    %1. pal frontal
    winposb(1,:)=[screenw-1024 0 1024 768];
    wintitposb(1,:)=[winposb(1,1)+8 8];
    winpriority(1)=5;
    titcolorn(1)=4;
    
    %2. dvi prompt pc
    winposb(2,:)=[0 0 1280 1024];
    wintitposb(2,:)=[8 8];
    winpriority(2)=1;
    titcolorn(2)=4;
    
    %4. spare vga
    winposb(4,:)=[screenw-1024 720 480 360];
    wintitposb(4,:)=[winposb(4,1)+8 screenh-40];
    winpriority(4)=1;
    titcolorn(4)=4;
end;

if mylayout==2
    winlist(3)=NaN; %don't set window 3
    wintitle=str2mat('1. NTSC minicam','2. DVI US','','4. VGA prompt',date2tit);
    %80 clock
    %setpos(ss,mylayout,80,5,1920-260,1080-260,256,256,1920-260-8,1080-260);%clock
    winposb(end,:)=[screenw-260 screenh-260 256 256];
    wintitposb(end,:)=[winposb(end,1)-8 winposb(end,2)];
    winpriority(end)=5;
    titsizen(end)=1;    %midsize
    titcolorn(end)=4;
    
    %1. minicam
    %setpos(ss,mylayout,1,1,0,0,960,720,8,8)
    winpriority(1)=1;
    winposb(1,:)=[0 0 960 720];
    wintitposb(1,:)=[winposb(1,1)+8 winposb(1,2)+8];
    titcolorn(1)=4;
    %2. ultrasound
    %ultrasound input resolution
    wwidthn=1024+(96*3);
    wheightn=768+(72*3);
    wleftn=screenw-wwidthn;      %need to check combination of width and left position after rounding
    wtopn=0;
    winposb(2,:)=[wleftn wtopn wwidthn wheightn];
    wintitposb(2,:)=[winposb(2,1)+100 30];
    winpriority(2)=5;
    %setpos(ss,mylayout,2,5,wleftn,wtopn,wwidthn,wheightn,700,30);
    
    %crop ultrasound
    %use these increments to keep aspect ratio, and allowing for required
    %rounding of sizes
    wincropb(2,:)=[96-48-24 96+48+24 72-36+18 72+36-18];
    
    %4. prompt
    %setpos(ss,mylayout,4,1,0,720,480,360,8,720)
    winpriority(4)=1;
    wtopn=720;
    winposb(4,:)=[0 wtopn 480 screenh-wtopn];
    wintitposb(4,:)=[8 wtopn];
    titcolorn(4)=4;
    
    
end;


nwin=length(winlist)

%maybe first check windows don't exceed screen dimensions (after rounding)
for iwin=1:nwin
    mywin=winlist(iwin)
    if ~isnan(mywin)
        setpos(ss,mylayout,mywin,winpriority(iwin),winposb(iwin,:),wintitposb(iwin,:));
        settit(ss,mylayout,mywin,titsizen(iwin),titcolorn(iwin),deblank(wintitle(iwin,:)));
        %crop setting if not nan?????
        setcrop(ss,mylayout,mywin,wincropb(iwin,:));
    end;
end;

%==================
%original ema settings
%PAL frontal camera
%setpos(ss,mylayout,1,5,1920-1024,0,1024,768,1920-1024+8,8)
%settit(ss,mylayout,1,0,4,'1. PAL, frontal');
%spare vga
%setpos(ss,mylayout,4,1,1920-1024,720,480,360,1920-1024+8,1080-40)
%settit(ss,mylayout,4,0,4,'4. VGA free');
%investigator pc
%wwidthn=1280;
%wheightn=1024;
%wleftn=0;
%wtopn=0;
%setpos(ss,mylayout,2,1,wleftn,wtopn,wwidthn,wheightn,8,8);
%settit(ss,mylayout,2,0,4,'2. DVI prompt PC');
%===========================

disp('layout will be saved after ''return''');
keyboard;


%after finishing save layout

fprintf(ss,['SLS0' layoutnum]);       %choose layout
myrep=fscanf(ss);
disp(['Save layout: ' myrep]);
save(['mv410_settings_' int2str(mylayout)],'winlist','winpriority','winposb','wintitposb','wincropb','wintitle');


%close serial connection
fclose(ss);
delete(ss);
clear ss;

function setpos(ss,mylayout,ichan,mypriority,posb,titposb)

wleftn=posb(1);wtopn=posb(2);wwidthn=posb(3);wheightn=posb(4);
tleftn=titposb(1);ttopn=titposb(2);

%maybe allow 0,0 as default for title position

mychan=int2str0(ichan,2);       %80 for clock
disponoff='1';          %separate function to turn off?
ndig=4;

layoutnum=int2str0(mylayout,2);

layerpriority=int2str0(mypriority,2); %(01 to 05; 01 is lowest)


rou1=round([wleftn wtopn]/2)*2;
rou2=round([wwidthn wheightn]/8)*8;
rou3=round([tleftn ttopn]/2)*2;
rou=[rou1 rou2 rou3];


roustr=strm2rv(int2str0(rou',4),'');


%check position and size with respect to output screen resolution??

mypad=repmat('0',[1 16]);
mypad=[mypad '101'];
layouts=['SLD0' layoutnum mychan disponoff layerpriority roustr mypad];
fprintf(ss,layouts);

myrep=fscanf(ss);
disp(['Layout channel: ' myrep]);

%function setcrop(ss,mylayout,ichan,ctopn,cbotn,cleftn,crightn)
function setcrop(ss,mylayout,ichan,cropb)
%cropb arranged top, bot, left right
if any(isnan(cropb))
    return;
end;

mychan=int2str0(ichan,2);       %80 for clock
ndig=4;

layoutnum=int2str0(mylayout,2);

rou=round(cropb/4)*4;
roustr=strm2rv(int2str0(rou',4),'');

crops=['SCR0' layoutnum mychan roustr];
fprintf(ss,crops);
myrep=fscanf(ss);
disp(['crop : ' myrep]);

function settit(ss,mylayout,ichan,titsizen,titcolorn,titstr);
mychan=int2str0(ichan,2);

layoutnum=int2str0(mylayout,2);

disponoff='1';          %separate function to turn off?

if ismember(titsizen,0:2)
    titsize=int2str(titsizen);
else
    disp('Bad title size code');
    return;
end;
if ismember(titcolorn,0:8)
    titcolor=int2str0(titcolorn,2);
else
    disp('Bad title color code');
end;

if length(titstr)>16
    titstr=titstr(1:16);
    disp('Title truncated');
end;
tits=['STT0' layoutnum mychan disponoff titsize titcolor titstr];
fprintf(ss,tits);
myrep=fscanf(ss);
disp(['title : ' myrep]);


function  rescoden=getresolution(ss,mylayout)

%reslist=[1280 1024;1360 768;1600 1200;1920 1200;1440 800;1680 1050;1920 1080;1280 720];
layoutnum=int2str0(mylayout,2);

fprintf(ss,['RLO0' layoutnum]);
myrep=fscanf(ss);

if strcmp(['ALO0' layoutnum],myrep(1:6))
    rescode=myrep(7:8);
    rescoden=str2num(rescode);
    if ismember(rescoden,0:7)
        return;
        
    else
        disp(['unexpected resolution code ' rescode]);
        
    end;
    
else
    disp('Error requesting screen resolution');
end;

function fcheck=getfrequency(ss);
fprintf(ss,'ROF0');
myrep=fscanf(ss);

if strcmp('AOF0',myrep(1:4))
    fcheck=str2num(myrep(5));
    if ismember(fcheck,0:2)
        return
    else
        disp(['Unexpected frequency code: ' int2str(fcheck)]);
        fcheck=-1;
        return;
    end;
else
    disp('Error requesting output frequency');
end;


