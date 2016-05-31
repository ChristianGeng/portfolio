function mt2mavis_3v(mtname,emasuff,audsuff,sensorlist,maxtrial,cutname,varprefix)
% MT2MAVIS_3V Export MT data to mavis, omitting lateral dimension,orientation as virtual sensor
% function mt2mavis_3v(mtname,emasuff,audsuff,sensorlist,maxtrial,cutname,varprefix)
% mt2mavis_3v: Version 08.01.2012
%
%   Description
%       Assume subdirectory mat for input and mavis2v for output
%       emasuffix can be sensor-specific, if length is same as sensorlist
%       (otherwise same for all sensors)
%       This version for recalulated position data. Different quality control:
%       rms, difference (mm) between merged and tapad recursive version
%       This version exports all 3 spatial dimensions (unlike mt2mavis_2v)
%       with 'virtual' sensors (at fixed distance from actual sensor) but no pre-computed velocities
%       rms and compdist in separate fields, so they are not treated as 'spatial' data by mview
%       Basic sensor has 'POS' appended to sensor name
%       Virtual sensor has 'ORI' appended to sensor name
%       Sensor names changed to uppercase and any underscores removed
%       File names sometimes have to be changed (rather ad hoc), to be both legal matlab variable names and file names
%       Diary file mavisexport.txt records any renaming

pathsuff='3v';
mtpath=['mat' pathchar];
%mavispath='maviscc2\';
mavispath=['mavis' pathsuff pathchar];
mkdir(mavispath);

diary([mavispath 'mavisexport.txt']);


vsensdist=5;      %distance of virtual sensor from actual sensor (in mm, assuming mm input)

nsensor=size(sensorlist,1);

nsuff=size(emasuff,1);

cutdata=mymatin(cutname,'data');
cutlabel=mymatin(cutname,'label');



if nsuff<nsensor emasuff=repmat(emasuff,[nsensor 1]); end;



cm2mm=1;       %assume change from cm to mm

ndig=length(maxtrial);

triallist=unique(cutdata(:,4));

%maxtrial=str2num(maxtrial);

audname='AUDIO';

ipi=findstr('.',audsuff);
if ~isempty(ipi)
    audname=audsuff(ipi+1:end);
    audsuff=audsuff(1:ipi-1);
end;

%for mytrial=1:maxtrial
for mytrial=triallist'
    ts=int2str0(mytrial,ndig);
    
    
    %audio
    inname=[mtpath mtname audsuff ts];
    if exist([inname '.mat'],'file')
        
        disp(inname);
        load(inname);
        ipi=strmatch(audname,descriptor);
%mview does not like stereo audio channels
%tries to treat as sensor x/y coordinates

        if length(ipi)~=1
            disp('Specification for audio channel may be wrong or ambiguous');
            disp(descriptor(ipi,:));
        end;
        S(1).SIGNAL=double(data(:,ipi));
        S(1).SRATE=samplerate;
        S(1).NAME='audio';
        
        lastsuff='';
        
        
        for jj=1:nsensor
            
            mysuff=deblank(emasuff(jj,:));
            if ~strcmp(mysuff,lastsuff)
                %                disp(['Loading ' mysuff]);
                inname=[mtpath mtname mysuff ts];
                load(inname);
                descriptor=flatdescriptor(descriptor,dimension);
                P=desc2struct(descriptor);
                
                lastsuff=mysuff;
            end;
            
            
            mysensor=deblank(sensorlist(jj,:));
%   mview does this internally anyway
            mysensorout=strrep(mysensor,'_','');
            mysensorout=upper(mysensorout);
            
            ii=jj+1;        %allow for audio channel
            %            pp=[getfield(P,[mysensor '_px']) getfield(P,[mysensor '_py']) getfield(P,[mysensor '_pz'])];
            pp=[getfield(P,[mysensor '_posy']) getfield(P,[mysensor '_posx']) getfield(P,[mysensor '_posz'])];
%            pp=[getfield(P,[mysensor '_posy']) getfield(P,[mysensor '_posz'])];
            posdata=data(:,pp);
            S(ii).SIGNAL=posdata*cm2mm;
            pp=[getfield(P,[mysensor '_oriy']) getfield(P,[mysensor '_orix']) getfield(P,[mysensor '_oriz'])];
%            pp=[getfield(P,[mysensor '_oriy']) getfield(P,[mysensor '_oriz'])];
            odata=data(:,pp);
            
            %convert orientation to a "virtual sensor" at a fixed distance from the
            %actual sensor
            
            odata=posdata+odata*vsensdist;
            S(ii+nsensor).SIGNAL=odata*cm2mm;

            chkoffset=nsensor*2;
            %new data; different quality control parameters
            pp=[getfield(P,[mysensor '_rms']) getfield(P,[mysensor '_compdist'])];
            xdata=data(:,pp);
            S(ii+chkoffset).SIGNAL=xdata(:,1);
            S(ii+chkoffset+nsensor).SIGNAL=xdata(:,2);
            
            S(ii).SRATE=samplerate;
            S(ii+nsensor).SRATE=samplerate;
            S(ii+chkoffset).SRATE=samplerate;
            S(ii+chkoffset+nsensor).SRATE=samplerate;

            %note: mview converts names to uppercase and removes underscore
            S(ii).NAME=[mysensorout 'POS'];
            S(ii+nsensor).NAME=[mysensorout 'ORI'];
            S(ii+chkoffset).NAME=[mysensorout 'RMS'];
            S(ii+chkoffset+nsensor).NAME=[mysensorout 'CHK'];
            
        end;
        
        
        
        try
            %should also check for duplicate names .... ??????
            
            %use cutlabel rather than item_id
            
            ici=find(cutdata(:,4)==mytrial);
            if isempty(ici)
                disp('Trial not in cut file');
            else
                mylabel=deblank(cutlabel(ici,:));
                old_id=item_id;
                item_id=mylabel;
                item_id=strrep(item_id,'^','v');
                item_id=strrep(item_id,'!!','X_');
                item_id=strrep(item_id,'!','X_');
                item_id=strrep(item_id,' ','_');
%this is rather ad hoc!!
                item_id=strrep(item_id,'$','C');
                item_id=strrep(item_id,'&','X');


                item_id=strrep(item_id,'.','_');
                item_id=strrep(item_id,'ß','ss');
                item_id=strrep(item_id,'ö','oe');
                item_id=strrep(item_id,'ä','ae');
                item_id=strrep(item_id,'ü','ue');
                
                
                disp([item_id ' ' old_id]);          
                item_id=[varprefix item_id '_' ts];
                
                myfile=[mavispath item_id '.mat'];
                if exist(myfile,'file')
                    disp('unable to store. Filename already exists');
                else
                    eval([item_id '=S;']);
%                    save([mavispath item_id],item_id,'-v6');
                    save([mavispath item_id],item_id);
                end;
            end;        %trial not in cut file
            
        catch
            disp('Problem with item_id as variable name??');
 %           disp(item_id);
        end;        %try catch
        
    end;        %input file exists
end;        %trial loop


diary off
