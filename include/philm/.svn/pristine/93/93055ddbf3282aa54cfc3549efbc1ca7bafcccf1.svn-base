function make_b_parameter_struct
% MAKE_B_PARAMETER_STRUCT Setup structs for cross-referencing and storing Sonix b-mode imaging parameters
% function make_b_parameter_struct
% make_b_parameter_struct: Version 08.02.2013;
%
%   Updates
%       2.2012. No longer query hardware for current values (use
%       sonix_ctrl('ini') for this

%If a version is ever needed to query the hardware then the program should
%be re-written to use the sonix_ctrl functions

functionname='make_b_parameter_struct: Version 08.02.2013';
outfile='sonix_b_parameters';
textfilein='b_mode_parameters.txt';
comment=['Input text file (based on Sonix xml file) : ' which(textfilein)];
ss=file2str(textfilein);      %from preliminary re-arrangement of xml file
ns=size(ss,1);
vb=find(ss(:,1)=='<');
nf=ns-length(vb);
idc=cell(nf,1);
namec=cell(nf,1);
fieldc=cell(nf,1);
descripmainc=cell(nf,1);
descripsupc=cell(nf,1);
submenuc=cell(nf,1);

ifi=1;
for isi=1:ns
    stmp=deblank(ss(isi,:));
    if stmp(1)=='<'
        mymenu=stmp(2:(end-1));
    else
        submenuc{ifi}=mymenu;
        ipi=find(stmp=='"');
        idtmp=stmp((ipi(1)+1):(ipi(2)-1));
        idc{ifi}=idtmp;
        namec{ifi}=stmp((ipi(3)+1):(ipi(4)-1));
        descriptmp=stmp((ipi(4)+1):end);
        descripmainc{ifi}=descriptmp;
        ixi1=findstr('<d>',descriptmp);
        if length(ixi1)==1
            ixi2=findstr('</d>',descriptmp);
            if length(ixi2)==1
                descripmainc{ifi}=descriptmp((ixi1+3):(ixi2-1));
                descriptmp(ixi1:(ixi2+3))=[];
                descripsupc{ifi}=descriptmp;
            end;
        end;
        
        
        %make a legal matlab field name
        idtmp=strrep(idtmp,'4b-focus','quad_focus');
        idtmp=strrep(idtmp,'[+]','_POS_');
        idtmp=strrep(idtmp,'[-]','_NEG_');
        idtmp=strrep(idtmp,'-','_');
        idtmp=strrep(idtmp,' ','_');
        
        fieldc{ifi}=idtmp;
        ifi=ifi+1;
    end;
end;
%keyboard;

Bd=struct('fieldname',fieldc,'id',idc,'name',namec,'submenu',submenuc,'descripmain',descripmainc,'descripsup',descripsupc);




%generate a struct in which current values will be filled in

getval=0;
%tic;
for ifi=1:nf
    myid=Bd(ifi).id;
    disp(myid);
    myval=[];
    if getval
        %use ulterius to query the value of the parameter with this id
        [status,result]=system(['"C:\sonixsdk\sdk_6.0.3_(00.036.203)\bin\ultraInteract.exe" 2 "' myid '"']);
        %disp(result);
        disp(status);
        ssr=rv2strm(result,char(10));
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
    end;
    Bv.(Bd(ifi).submenu).(Bd(ifi).fieldname)=myval;
    Bx.(Bd(ifi).submenu).(Bd(ifi).fieldname)=myid;
end;

%toc

preset_name='';
probe_name='';

if getval
    [status,result]=system('"C:\sonixsdk\sdk_6.0.3_(00.036.203)\bin\ultraInteract.exe" 6 "');
    ssr=rv2strm(result,char(10));
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
            end;
        else
            disp('Unable to parse preset and probe name');
            disp(tmps);
        end;
    else
        disp('Unable to get active preset');
        disp(ssr);
    end;
    
    disp(['preset and probe ' preset_name ' ' probe_name]);
    
end;

keyboard;
comment=[comment crlf 'Bd.fieldname: Fieldname used by matlab in Bx' crlf ...
    'Bd.id: Parameter id for use with ulterius' crlf ...
    'Bd.name: Name field in original sonix imaging.lst.xml' crlf ...
    'Bd.submenu: subdivision of parameters in Bx; corresponds to division in interactive research menus' crlf ...
    'Bd.descripmain: descriptive text from xml file' crlf ...
    'Bd.descripsup: any remaining text from xml file (currently best place to look for parameter units)' crlf ...
    'Bx: Struct based on matlab fieldnames, subdivided by submenu fields.' crlf ...
    ' Field value is id to use with ulterius to retrieve current parameter value.' crlf ...
    ' sonix_ctrl generates a data structure with the same arrangement as Bx in which the fieldnames are the actual parameter values.'];
comment=framecomment(comment,functionname);
%save('sonix_b_parameters','preset_name','probe_name','Bd','Bv','Bx','comment');
save(outfile,'Bd','Bx','comment');

