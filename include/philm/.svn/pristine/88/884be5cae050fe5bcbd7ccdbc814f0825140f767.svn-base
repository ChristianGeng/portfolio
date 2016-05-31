function varargout=sonix_ctrl(cmdstr,parameterid,parval)
% SONIX_CTRL control Sonix ultrasound via ulterius sdk
% function varargout=sonix_ctrl(cmdstr,parameterid,parval)
% sonix_ctrl: Version 12.02.2013;
%
%   Syntax
%       Commands: 'ini','getversion','console','getframedata','getpar','setpar','getfreeze','togglefreeze','getpreset';
%           getpar, setpar: parameterid, either as original sonix name as
%               used by ulterius sdk, or matlab field name
%           setpar: parval. desired value
%           getframedata: parameterid and parval correspond to datatype and
%               filename
%
%   See Also
%       sonix_getsettings, sonix_setsettings

%0: ### CONSOLE MODE ###
%no additional parameters needed
%1: ### GET FRAME DATA MODE ###
%USAGE:> ultaInteract.exe 1 2 outputFilePath
%where 2 is the uData flag (see SDK documentation)
%2: ### GET PARAMETER MODE ###
%USAGE:> ultaInteract.exe 2 parameterID
%3: ### SET PARAMETER MODE ###
%USAGE:> ultaInteract.exe 2 parameterID parameterValue
%4: ### GET FREEZE STATE MODE ###
%no additional parameters needed
%5: ### TOGGLE FREEZE STATE MODE ###
%no additional parameters needed
%6: ### GET PRESET MODE ###
%no additional parameters needed

functionname='sonix_ctrl: Version 12.02.2013';

hf=findobj('type','figure','name','ultrasonix');

if isempty(hf)
    disp('sonix_ctrl not initialized');
else
    
    P=get(hf,'userdata');
    Bx=P.bmode_xref;
    Bv=P.bmode_val;
end;


%could maybe even set up the list dynamically by parsing the usage message
%when ultraInteract is called with no input args
modelist={'ini','getversion','console','getframedata','getpar','setpar','getfreeze','togglefreeze','getpreset'}';
%commands from console onwards are specific commands for ultraInteract
%(i.e. assume console mode is command 0)
nmode=length(modelist);
modenum=(1:length(modelist))-3;

for ifi=1:nmode M.(modelist{ifi})=modenum(ifi); end;

cmdstr=lower(cmdstr);
vm=strmatch(cmdstr,modelist);
if length(vm)==1
    mycmd=modenum(vm);
else
    disp('Unknown command');
    disp(cmdstr);
    disp('must be in this list: ');
    disp(modelist);
end;

%ulteriusexe='"C:\sonixsdk\sdk_6.0.3_(00.036.203)\bin\ultraInteract.exe"';
ulteriusexe=sonix_getulteriusexe;


switch cmdstr
    case 'ini'
        ultini(ulteriusexe,functionname,M);
        
    case 'getversion'
        myversion=getversion(ulteriusexe);
        if nargout==1
            varargout{1}=myversion;
        else
            disp('Ulterius communication: current version');
            disp(myversion);
        end;
        
        
    case 'console'
        %        [status,result]=system([ulteriusexe ' ' int2str(mycmd)])
        %        eval(['!' ulteriusexe ' ' int2str(mycmd)])
        disp('console mode does not work from within matlab');
        disp('enter the following in a command window:')
        disp([ulteriusexe ' ' int2str(mycmd)]);
        
    case 'getframedata'
        %parameterid is here the data type code; parval is the filename
        filelength=getframedata(ulteriusexe,mycmd,parameterid,parval);
        if nargout==1
            varargout{1}=filelength;
        else
        disp([parval ' created. Length ' int2str(filelength)]);
        end;
        
        
    case 'getpreset'
        [preset_name,probe_name]=getactivepreset(ulteriusexe,mycmd);
        if nargout==2
            varargout{1}=preset_name;
            varargout{2}=probe_name;
        else
            disp(['preset and probe ' preset_name ' ' probe_name]);
        end;
        
    case 'getfreeze'
        myfreezestate=getfreezestate(ulteriusexe,mycmd);
        if nargout==1
            varargout{1}=myfreezestate;
        else
            disp(['Freezestate ' int2str(myfreezestate)]);
        end;
        
    case 'togglefreeze'
        myfreezestate=togglefreezestate(ulteriusexe,M);
        if nargout==1
            varargout{1}=myfreezestate;
        else
        disp(['Freezestate toggled to ' int2str(myfreezestate)]);
        end;
    case 'getpar'
        myid=parameterid;
        ipi=findstr('.',parameterid);
        if length(ipi)==1
            field1=parameterid(1:(ipi-1));
            field2=parameterid((ipi+1):end);
            myid=Bx.(field1).(field2);
        end;
        parval=getparameter(ulteriusexe,mycmd,myid);
        if nargout==1
            varargout{1}=parval;
        else
            disp([myid ' = ' int2str(parval)]);
        end;
        
    case 'setpar'
        myid=parameterid;
        ipi=findstr('.',parameterid);
        if length(ipi)==1
            field1=parameterid(1:(ipi-1));
            field2=parameterid((ipi+1):end);
            myid=Bx.(field1).(field2);
        end;
        newval=setparameter(ulteriusexe,M,myid,parval);
        disp([myid ' set to ' int2str(newval)]);
        if length(ipi)==1
            Bv.(field1).(field2)=newval;
            P.bmode_val=Bv;
            set(hf,'userdata',P);
        end;
        
end;

function ultini(ulteriusexe,functionname,M);

bpar_deffile='sonix_b_parameters';
hf=figure;
P.functionname=functionname;
P.ulteriusexe=ulteriusexe;
P.ulteriusversion=getversion(ulteriusexe);
P.bpar_deffile=which([bpar_deffile '.mat']);
P.filenamebase='';      %prompt program etc. can add trial number
P.currentfile='';
P.datatype=2;
P.item_id='';       %store in output mat file
P.message='';       %make error messages etc. available
P.errorflag=0;
P.freezedelay=1/25;     %delay after changing freeze state; must be implemented by calling program; not used by subfunction togglefreeze
P.triggervalue=2;       %2=frame, 1=line. Note: this is not the current setting, but rather the setting that should be used by e.g. prompt program
P.triggermode='user';   %if 'continuous', then user program (i.e. prompt program) should ignore command to turn off trigger 
set(hf,'name','ultrasonix');
P.figurename='ultrasonix';
P.titlehandle=title(' ');
P.axeshandle=gca;
P.replaymode='';    %currently 'header2help','header2message'; eventually also data display?

set(hf,'userdata',P);

[P.preset_name,P.probe_name]=getactivepreset(ulteriusexe,M.getpreset);
if isempty(P.probe_name)
    disp('ultrasonixctrl: ini failed to get active preset');
    close(hf);
    return;
end;

%   maybe generate an image or surf object for preliminary viewing of data files
if ~exist([bpar_deffile '.mat'],'file')
    disp('Use make_b_parameter_struct to generate b mode parameter definition file');
    close(hf)
    return;
end;

%load struct that cross references from matlab struct fields to ultrasonix
%parameter id
Bx=mymatin(bpar_deffile,'Bx');

%struct to store values has same structure as cross-reference struct
Bv=Bx;

%loop thru the two field levels of Bx
fieldnames1=fieldnames(Bx);
nf1=length(fieldnames1);
disp('Getting current settings ');
for if1=1:nf1
    myfield1=fieldnames1{if1};
    tmpS=Bx.(myfield1);
    fieldnames2=fieldnames(tmpS);
    nf2=length(fieldnames2);
    for if2=1:nf2
        myfield2=fieldnames2{if2};
        myid=Bx.(myfield1).(myfield2);
        parval=getparameter(ulteriusexe,M.getpar,myid);
        Bv.(myfield1).(myfield2)=parval;
    end;
end;
P.bmode_val=Bv;
P.bmode_xref=Bx;

set(hf,'userdata',P);
ddd=datestr(now);
ddd=strrep(ddd,' ','_');
ddd=strrep(ddd,':','_');
ddd=strrep(ddd,'-','_');
%may be useful if getting settings for recordings made with AAA
comment='Sonix parameters at initialization';
private.sonix=P;    %for compatibility with storage in getframedata
save(['sonix_parameters_' ddd],'private','comment');


drawnow;


function myversion=getversion(ulteriusexe);
[status,result]=system(ulteriusexe);
myversion=result;

function filelength=getframedata(ulteriusexe,mycmd,usetype,usefile);
%input arguments take precedence over settings in struct

typelist={'bpr','b8','rf'};
typenum=[2 4 16];

filelength=0;

P=sonix_getsettings;
P.message='';
pok=0;
if ~isempty(P)
    datatype=P.datatype;
    datafile=P.currentfile;
    pok=1;
end;
if nargin>2
    if ~isempty(usetype)
        datatype=usetype;
    end;
end;
if nargin>3
    if ~isempty(usefile)
        datafile=usefile;
    end;
end;

vt=find(datatype==typenum);
if isempty(vt)
    disp(['Type ' int2str(datatype) ' not supported for file output']);
    disp(['Use one of these : ' int2str(typenum)]);
    filelength=0;
    P.message='unsupported data type';
    sonix_setsettings(P);
    return;
end;

myext=typelist{vt};
filename=[datafile '.' myext];

%convert filelength to frames???
P.currentfile=filename;

[status,result]=system([ulteriusexe ' ' int2str(mycmd) ' ' int2str(datatype) ' ' filename]);
ssr=rv2strm(result,char(10));
%disp(result);
%also set error flag??

ve=strmatch('Error:',ssr);
if ~isempty(ve)
    disp('Error getting frame data');
    disp(ssr);
    P.message='Error getting frame data';
    sonix_setsettings(P);
    return;
end;

D=dir(filename);
if length(D)==1
    filelength=D(1).bytes;
    if filelength==0
        disp(filename);
        disp('Zero length file after getframedata');
        P.message='zero length file';
    end;
end;
if length(D)==0
    disp(filename);
    disp('File not created by getframedata');
    P.message='File not created';
end;
if length(D)>1
    disp(filename);
    disp('Unexpected dir after getframedata');
    disp(D);
    P.message='Unexpected dir';
end;
%P.filelength=filelength;

sonix_setsettings(P);
if filelength>0
    if pok
        tmpname=P.functionname;
        comment=framecomment('',tmpname);
        item_id='';
        if isfield(P,'item_id')
            item_id=P.item_id;
        end;
        samplerate=1000000/P.bmode_val.SYNC.frame_period;   %more accurate than what is reported in bpr header (but still may not be absolutely precise)
        
        private.sonix=P;
        save([datafile '_info'],'comment','item_id','samplerate','private');
        if strcmp(P.replaymode,'header2help')
            H=sonix_readheader(filename,1);
        end;
        if strcmp(P.replaymode,'header2message')
            H=sonix_readheader(filename);
                P.message=evalc('disp(H)');
                sonix_setsettings(P);

        end;
        
    end;
end;
%maybe display filelength etc. somewhere in sonix figure




function newval=setparameter(ulteriusexe,M,parameterid,parval);
%if unable to set parameter newval will be returned empty
%(otherwise returns with same value as in parval)
%If an attempt is made to set a parameter that does not exist,then a
%timeout should ok.
%Unfortunately this will not happen if the new value is zero
% since currently getparameter returns 0 as the value of a non-existent
% parameter (but no error)


toggletimeout=0.1;
newval=getparameter(ulteriusexe,M.getpar,parameterid);
if isempty(newval)
    disp('Unable to get old value before setting parameter');
    return;
end;

if newval==parval
    disp('No need to set parameter as no change to current value');
    return;
end;

[status,result]=system([ulteriusexe ' ' int2str(M.setpar) ' "' parameterid '" ' int2str(parval)]);
ssr=rv2strm(result,char(10));
%disp(result);
ve=strmatch('Error:',ssr);
if ~isempty(ve)
    disp('Error setting parameter');
    disp(ssr);
    newval=[];
    return;
end;


tic;
toggled=0;
timeoutflag=0;
while ~toggled
    %    disp('waiting for toggle')
    
    newval=getparameter(ulteriusexe,M.getpar,parameterid);
    if isempty(newval)
        disp('Unable to get new value after setting parameter');
        return;
    end;
    
    if newval==parval
        toggled=1;
    end;
    if toc>toggletimeout
        timeoutflag=1;
        toggled=1;
    end;
    
end;
if timeoutflag
    disp('Time out waiting for parameter to be set');
    newval=[];
end;





function myval=getparameter(ulteriusexe,mycmd,parameterid)
%note: parameterid is the actual string required by the ulterius interface
%not the version used as a matlab field name.
% Use the cross-reference in struct Bx in sonix_b_parameters.mat
% to get the parameter id given the submenu and fieldname used in the
% matlab struct that stores the actual values

%put parameter id in " because it often contains blanks

%note: if parameter does not exist a value of 0 is returned but no error

[status,result]=system([ulteriusexe ' ' int2str(mycmd) ' "' parameterid '"']);
ssr=rv2strm(result,char(10));
myval=[];
%disp(result);
ve=strmatch('Error:',ssr);
if ~isempty(ve)
    disp('Error getting parameter');
    disp(ssr);
    return;
end;


vv=strmatch('VAL:',ssr);
if length(vv)==1
    tmps=strrep(ssr(vv,:),'VAL:','');
    myval=str2num(tmps);
    if isempty(myval)
        disp('Unable to convert value to numeric');
        disp(tmps);
    end;
else
    disp('No value returned?');
    disp(ssr);
end;



function [preset_name,probe_name]=getactivepreset(ulteriusexe,mycmd)


[status,result]=system([ulteriusexe ' ' int2str(mycmd)]);

%result contains this if unable to connect (but status is 0)
%### GET PRESET MODE ###
%Connecting to: ultrasch1
%Error: Could not connect
%
%Active Preset: monitorConnection(): CONNECTION_COMM lost
%
%checkConnection(): there is no connection
%monitorConnection(): WSAEnumNetworkEvents() ret SOCKET_ERROR (10093)
preset_name='';
probe_name='';

[status,result]=system([ulteriusexe ' ' int2str(mycmd)]);
ssr=rv2strm(result,char(10));
ve=strmatch('Error:',ssr);
if ~isempty(ve)
    disp('Error getting preset');
    disp(ssr);
    return;
end;

vp=strmatch('Active Preset:',ssr);
if length(vp)==1
    tmps=strrep(ssr(vp,:),'Active Preset: ','');
    ipib=findstr('(',tmps);
    if length(ipib)==1
        preset_name=tmps(1:(ipib-1));
        probe_name=tmps((ipib+1):end-1);
        ipib=findstr(')',probe_name);
        if length(ipib)==1
            probe_name=probe_name(1:(ipib-1));
            %make probe name a legal field name for matlab struct
            probe_name=strrep(probe_name,'/','_');
            probe_name=strrep(probe_name,'-','_');
            probe_name=strrep(probe_name,' ','_');
        end;
    else
        disp('Unable to parse preset and probe name');
        disp(tmps);
    end;
else
    disp('Unable to get active preset');
    disp(ssr);
end;


function freezestate=getfreezestate(ulteriusexe,mycmd)
%return 1 if frozen, 0 for unfrozen, empty for error
freezestate=[];

[status,result]=system([ulteriusexe ' ' int2str(mycmd)]);

%If unable to connect the following is returned
%Otherwise the 3rd line contains 'Successfully connected'

%### GET FREEZE STATE MODE ###
%Connecting to: ultrasch1
%Error: Could not connect
%FROZEN
%monitorConnection(): CONNECTION_COMM lost
%
%checkConnection(): there is no connection
%monitorConnection(): WSAEnumNetworkEvents() ret SOCKET_ERROR (10093)

ssr=rv2strm(result,char(10));
ve=strmatch('Error:',ssr);
if ~isempty(ve)
    disp('Error getting freeze state');
    disp(ssr);
    return;
end;
ve=strmatch('FROZEN',ssr);
if ~isempty(ve)
    freezestate=1;
    return;
end;
ve=strmatch('UNFROZEN',ssr);
if ~isempty(ve)
    freezestate=0;
    return;
end;

disp('Unable to determine freeze state');
disp(ssr);

function freezestate=togglefreezestate(ulteriusexe,M)
%return 1 if frozen, 0 for unfrozen, empty for error

toggletimeout=0.1;

freezestate=getfreezestate(ulteriusexe,M.getfreeze);
%keyboard;
%disp(['freeze before toggle ' int2str(freezestate)])
if isempty(freezestate)
    disp('Unable to determine current freezestate before toggling');
    return;
end;
oldstate=freezestate;

[status,result]=system([ulteriusexe ' ' int2str(M.togglefreeze)]);

ssr=rv2strm(result,char(10));
%error should be unlikely if first get freezestate was successful
ve=strmatch('Error:',ssr);
if ~isempty(ve)
    disp('Error toggling freeze state');
    disp(ssr);
    freezestate=[];
    return;
end;


%disp(result);


tic;
toggled=0;
timeoutflag=0;
while ~toggled
    %    disp('waiting for toggle')
    freezestate=getfreezestate(ulteriusexe,M.getfreeze);
    %disp(['freeeze after toggle ' int2str(freezestate)])
    
    if isempty(freezestate)
        disp('Unable to determine current freezestate after toggling');
        return;
    end;
    if freezestate~=oldstate
        toggled=1;
    end;
    if toc>toggletimeout
        timeoutflag=1;
        toggled=1;
    end;
    
end;
if timeoutflag
    disp('Time out waiting for freeze to toggle');
    freezestate=[];
end;
