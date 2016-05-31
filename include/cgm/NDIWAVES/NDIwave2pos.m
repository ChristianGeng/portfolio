function NDIwave2pos(inpath,outpath,sessfile,triallist,sensornames,ndig,filterspecs,idownfac)
% NDIwave2pos(inpath,outpath,sessfile,triallist,sensornames,ndig,filterspecs,idownfac)
% convert pos files




orifac = pi/180;

if nargin < 1,
	eval('help NDIwave2pos');
	return;
end;

%clear variables
ndiguse=4;
if nargin > 5
    ndiguse=ndig;
end

filterspec=[];
if nargin>6
    filterspec=filterspecs;
end;

idown=1;
if nargin>7
    if ~isempty(idownfac)
        idown=idownfac;
    end;
end;

maxSensor=16;
nsensorsMin=12;

cofbuf=cell(maxSensor,1);
filtername=cell(maxSensor,1);
filtercomment=cell(maxSensor,1);
filtern=zeros(maxSensor,1);

nfrow=size(filterspec,1);

for ifi=1:nfrow
    tmpname=filterspec{ifi,1};
    fchan=filterspec{ifi,2};
    mycoffs=mymatin(tmpname,'data');
    mycomment=mymatin(tmpname,'comment');
    myn=length(mycoffs);
    nc=length(fchan);
    for ific=1:nc
        mychan=fchan(ific);
        cofbuf{mychan}=mycoffs;
        filtername{mychan}=tmpname;
        filtercomment{mychan}=mycomment;
        filtern(mychan)=myn;
    end;
end;

myblanks=(blanks(maxSensor))';

newcomment=['Input, Output : ' inpath ' ' outpath crlf ...
    'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf];

filtercomment=strcat(int2str((1:maxSensor)'),' File: ',filtername,' " ',filtercomment,' ", ncof = ',int2str(filtern));
newcomment=[newcomment 'Filter specs for each channel:' crlf strm2rv(char(filtercomment),crlf) crlf];

%sessfile=[inpath 'HeadTest0/MySession_56/rawdata/used.cfg'
disp(['Reading session file ' sessfile])
private.sesscfg=NDIWaveParseSessionFile(sessfile);
samplerate=private.sesscfg.samplerate;


for rr=1:length(triallist)
    
    
    %infile='HeadTest0/MySession_56/MySession_56_007_sync.tsv';
    infile=[inpath, int2str0(triallist(rr),ndiguse),'_sync.tsv'];
    
    samplerate=samplerate/idown;
    disp(['loading ' infile ' with srate ' num2str(samplerate)]) 
    [data,NDIdescr]=NDIimport(infile,'SPHERICAL');
    
    
    
    %NDIdescriptor=char(NDIdescr);
    %II=strmatch('Sensor',NDIdescriptor);
    %II=II(1:2:end);
    %nsensors=length(II);
    %descriptor=NDIdescriptor([II(1)+2:II(1)+8],:);
    
    %data=nan(size(NDIdata,1), 7, nsensors);
    %data=single(data);
    
    
    %if(size(NDIdescriptor,1)>size(NDIdata,2))
    %    NDIdata(:, size(NDIdata,2)+1:size(NDIdescriptor,1)) = NaN;
    %end
    
%     for ll=1:nsensors
%         datIdx=[II(ll)+2:II(ll)+8];
%         NDIdescriptor(datIdx,:);
%         tmpdat=NDIdata(:,datIdx);
%         
%         % [r1 r2 r3] = quat2angle( tmpdat(:,4:7) );
%         % Mangles = quat2eulerAERO( tmpdat(:,4:7) );
%         datLL=zeros(size(tmpdat,1),4);
%         for mm=1:size(tmpdat,1)
%             rotquat=tmpdat(mm,4:7);
%             trans=tmpdat(mm,1:3);
%             %quat2H
%             H3x3=quat2H(rotquat(1),rotquat(2),rotquat(3),rotquat(4));
%             % H4x4=makerotmat4x4(H3x3,trans,'post');
%             % datLL=[trans 1]*(H4x4)'
%             H4x4=makerotmat4x4(H3x3,trans,'pre');
%             datLL(mm,:)=[(H4x4)*[trans 1]']';
%         end
%         
%         [theta,phi,r] = cart2sph(datLL(:,1),datLL(:,2),datLL(:,3));
%         data(:,4,ll)=(180/pi).*phi;
%         data(:,5,ll)=(180/pi).*theta;
%         
%         
%         %whos data phi NDIdata datLL
%         
%         
%         %[theta,phi,r] = cart2sph(r1,r2,r3);
%         
%         data(:,1:3,ll)=tmpdat(:,1:3);
%         %         data(:,4,ll)=(180/pi).*phi;
%         %         data(:,5,ll)=(180/pi).*theta;
%         
%         
%         
%         
%         % nanvar((180/pi).*THETA)
%         % nanvar((180/pi).*PHI)
%         
%         
%         %data(:,:,ll)=tmpdat;
%     end
%     
    ndatin=size(data,1);    
    ndat=length(1:idown:ndatin);      %assume decifir behaves like this
    
    nsensors=size(data,3);
    dataout=ones(ndat,7,nsensors)*NaN;
    dataout(:,6,:)=data(:,6,:);
    s2pad=nsensorsMin - nsensors;
    sensornamesuse=sensornames;
    if (nsensorsMin>nsensors),
        for idxPad=1:s2pad
            sensornamesuse=char(sensornamesuse,['unused' num2str(idxPad) '']);
        end
        data(:,:,size(data,3)+1 : nsensorsMin)=NaN;
        %warning('NaNs padded!!');
        nsensors=nsensorsMin;
    end
    
    
    ndimSph=5;
    ndimCart=6;
    
    for isensor=1:nsensors
        tmpdataF=data(:,1:ndimSph,isensor);
        pos1=tmpdataF(:,1:3);
        ori1=tmpdataF(:,4:5)*orifac; % das muss deg nach rad sein, da matlab rad fuer sph2cart benoetigt. 
                                     %  orifac ist oben als pi/180 definiert;
                                     %deg2rad: (pi/180) *alpha;
        % convert to orientation
        [ox1,oy1,oz1]=sph2cart(ori1(:,1),ori1(:,2),1);
%         if strcmp('TB',deblank(sensornames(isensor,:)))
%             keyboard
%         end
        d1=[pos1 ox1 oy1 oz1];

        if filtern(isensor)
            mycoff=cofbuf{isensor};
            ncof=length(mycoff);
            %The criterion here for having enough data to filter is more stringent than
            %that used by decifir
            if ndatin>ncof
                for idim=1:ndimCart
                    d1(:,idim)=decifir(mycoff,d1(:,idim));
                end;
                
            else
                disp(['Sensor ' int2str(isensor) ' : Not enough data for filtering']);
            end;
            % Convert back to orientations
            [d1(:,4),d1(:,5),dodo]=cart2sph(d1(:,4),d1(:,5),d1(:,6));
            d1(:,4:5)=d1(:,4:5)/orifac;      %convert back to degrees if necessary
            dataout(:,1:ndimSph,isensor)=d1(1:idown:end,1:ndimSph);
        else
            % Ist das ok? Sollte man nicht wirkliches decimate nehmen?
            dataout(:,:,isensor)=data(1:idown:end,:,isensor);
        end;
    end
    
    
    data=dataout;
    
    %unit=str2mat('mm','mm','mm');
    
    % ndim=3;
    % doamp=0;
    % dd=cell(ndim,1);
    % dd{1}='Time';
    % dd{2}='Coordinate';
    % if doamp dd{2}='Transmitter'; end;
    % sensname='Sensor';
    % dd{3}=sensname;
    
    % dimension.descriptor=char(dd);
    % uu=(blanks(ndim))';
    % dimension.unit=uu;
    
    % posfile='Z:/data/ema/recordeddata/speckletest1/ampsfilt/kalmanrt/workpos/0001.pos'
    % Example of Phil rawpos file:
    
    % aa=cell(ndim,1);
    % aa{1}=[];
    % aa{2}=descriptor;
    
    % ss=strcat(sensname,int2str((1:nsensors)'));
    % ss=char(strrep(cellstr(ss),' ','0'));
    % aa{3}=ss;
    % dimension.unit=uu;
    % dimension.axis=aa;
    
    %rawp=load('Z:/data/ema/recordeddata/speckletest1/ampsfilt/kalmanus/rawposm/0004.mat');
   
[descriptor,unit,dimension]=headervariablesNDI(size(sensornamesuse,1),sensornamesuse);
    
    comment=framecomment('NDIwave2mat',mfilename);
    
    outfilename=[outpath, int2str0(triallist(rr),ndiguse),'.mat'];
    disp(['writing ' outfilename])
    save(outfilename,'-v7','comment','data','descriptor','dimension','private','samplerate','unit' )
end


% MAKEREFOBJN erzeugt virtuallen Koordinaten selbst:
% anglefac=pi/180;
% [data,descriptor,unit,dimension,sensorsin]=loadpos_sph2cartm(matfile);
% td=datax([getfield(P,[sname '_px']) getfield(P,[sname '_py']) getfield(P,[sname '_pz'])]);
% tv=datax([getfield(P,[sname '_ox']) getfield(P,[sname '_oy']) getfield(P,[sname '_oz'])]);
% data3v(ii,:)=td+(tv*vdistance);

% RIGIDBODYANA(getregemat) AUCH:
%    tmpo=bigbuf(:,[P.orix P.oriy P.oriz],refsensindex(ii));
%         tmpd(:,:,ii)=tmpd(:,:,ii)+(tmpo*vdistance);

% Beim Abspeichern werden die Daten dann als ox oy oz gelassen

%
% rawp =
%
%        private: [1x1 struct]   - enhaelt nur Startwerte
%     samplerate: 200            - samplerate
%     descriptor: [7x7 char]
%           unit: [7x7 char]
%      dimension: [1x1 struct]
%        comment: [1x1194 char]
%           data: [64338x7x12 single]





