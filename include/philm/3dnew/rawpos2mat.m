function rawpos2mat(rawpath,matpath,triallist,samplerate,briefcomment,sensornames,posampflag,rmslim,privatebase)
% RAWPOS2MAT Convert pos files (e.g from cs5calcpos) to mat files
% function rawpos2mat(rawpath,matpath,triallist,samplerate,briefcomment,sensornames,posampflag,rmslim,privatebase)
% rawpos2mat: Version 22.04.2013
%
%	Syntax
%		rawpath and matpath without pathchar
%			rawpath is the subdirectory where the .pos files from e.g
%			cs5calcpos are located (normally named 'rawpos')
%		matpath must be created by hand, if necessary
%		posampflag: Optional. Defaults to 0 (false)
%			If present and true, read posamps from subdirectory posamps
%			below rawpath, and store in new subdirectory below matpath
%			(this new posamps subdirectory will be created if necessary)
%           if > 1 use this number as the number of transmitters (to handle
%           ag501 data. otherwise default to 6 transmitters (ag500)
%		rmslim: Optional. Defaults to 30
%			Not currently clear whether calcpos ever sets output to missing
%			data. So probably best to catch obviously bad data here
%			i.e all data exceeding this limit is set to NaN (note: only in
%			position files, not in posamp files)
%       samplerate: Normally leave empty. Only use to override the
%           samplerate returned by loadpos (this should never be necessary for
%           new AG501 files with header. Should hardly ever be necessary with
%           old headerless files either)
%       sensornames: If the input is from headerless pos files the number
%           of names in this list tells the program how many channels to assume
%           in the raw input file (12 for old AG500 files).
%           If the input is from ag501 files with header then the program
%           can determine itself how many channels are in the input file.
%           If the length of the sensornames list is less than the actual 
%           number of channels in the file then the program gives a warning
%           for the first trial and omits the additional channels in the
%           output (note that this means it is only possible to dicard e.g 
%           channels 13 to 16 (keeping 1-12). Its not possible to discard e.g.
%           channel 1, keeping channels 2-13).
%       privatebase: optional. Can be used by calling program to provide a
%           basic private struct giving more information on processing history
%
%	Notes
%		If an appropriate set of amp files is available in mat-format
%		then one of these can be read to get samplerate, briefcomment?, and
%		sensornames (from dimension.axis{3})
%		Or, preferably, if filteramps is used to generate filtered raw amp
%		files it will also store a small mat file (info.mat) with this
%		information which can be read by the wrapper script that calls
%		rawpos2mat
%       Since ag500 and ag501 potentially use different numbers of sensors
%       it is important that the sensornames variable is set up
%       appropriately.
%
%
%	See Also
%		KALMAN_FB, FILTERAMPS, LOADPOS, LOADAMP
%
%	Updates
%		8.2010 conversion of posamps included, rms limit included
%       2.2012 prepare for ag501
%       9.2012 prepare for ag501 files with header
%       10.2012 include privatebase as input argument
%       10.2012 insert distance from origin as 'parameter 7'
%       11.2012 allow unused sensors to be removed (corrected 0.4.2013)

functionname='rawpos2mat: Version 22.04.2013';

maxchan=24; %only used for rmsbuf
maxused=0;
[descriptor,unit,dimension]=headervariables;

descriptor=cellstr(descriptor);
descriptor{7}='orgdist';
descriptor=char(descriptor);
unit(7,:)=unit(1,:);

P=desc2struct(descriptor);
dimension.axis{3}=sensornames;
dimension.axis{2}=descriptor;

sampleratein=samplerate;
nchan=size(sensornames,1);

comment=framecomment(briefcomment,functionname);

ndig=4;

doposamps=0;
if nargin>6 doposamps=posampflag; end;
if doposamps
    posamppathout=[matpath pathchar 'posamps'];
    mkdir(posamppathout);
    posamppathin=[rawpath pathchar 'posamps'];
end;

rmsuse=30;
if nargin>7
    if ~isempty(rmslim)
    rmsuse=rmslim;
    end;
    
end;

private=[];
if nargin>8
    if isstruct(privatebase)
        private=privatebase;
    end;
end;



myversion=version;
myversion=myversion(1);

rmsbuf=zeros(max(triallist),2,maxchan);  %store n rms over threshold, and maximum
disp('Converting position data');
for itrial=triallist
    disp(itrial);
    trials=int2str0(itrial,ndig);
    inname=[rawpath pathchar trials];
    outname=[matpath pathchar trials];
    %    data=loadpos(inname);
    %note: nchan will be ignored by loadpos if the pos file has a header
    [data,S]=loadpos(inname,nchan);    %prepare for ag501
    if ~isempty(data)
        %for files with header check actual size matches nchan as determined from sensorlist
        nchanfile=size(data,3);
        if nchanfile<nchan
            disp(['Number of channels in data (' int2str(nchanfile) ') does not match length of sensorlist (' int2str(nchan) ')']);
            return;
        end;
        if nchanfile>nchan
            if itrial==triallist(1)
                disp(['Number of channels in data (' int2str(nchanfile) ') is greater than length of sensorlist (' int2str(nchan) ')']);
                disp(['Channels ' int2str(nchan+1) ' to ' int2str(nchanfile) ' will be discarded']);
                disp('Type ''return'' to continue');
                keyboard;
            end;
            data(:,:,(nchan+1):nchanfile)=[];
            
        end;
        
        nsensor=nchan;
        if nsensor>maxused maxused=nsensor; end;
        for ii=1:nsensor
            vv=find(data(:,P.rms,ii)>rmsuse);
            if ~isempty(vv)
                nbad=length(vv);
                maxrms=max(data(vv,P.rms,ii));
                disp([int2str(nbad) ' bad samples in sensor ' int2str(ii) '; max rms: ' int2str(maxrms)]);
                rmsbuf(itrial,:,ii)=[nbad maxrms];
                data(vv,:,ii)=NaN;
            end;
            tmpd=data(:,1:3,ii);
            orgdist=eucdistn(tmpd,zeros(size(tmpd)));
            data(:,P.orgdist,ii)=orgdist;
        end;
        
        
        data=single(data);
        samplerate=S.samplerate;
        if ~isempty(sampleratein)
            if sampleratein~=samplerate
                disp(['overriding samplerate from loadpos: ' num2str(samplerate)]);
                samplerate=sampleratein;
            end;
        end;
        private.loadpos=S;
        %save as mat file with standard variables
%skip if e.g. just scanning rms statistics
        if ~isempty(matpath)
        if myversion=='6'
            save(outname,'data','descriptor','dimension','samplerate','comment','unit','private');
        else
            save(outname,'data','descriptor','dimension','samplerate','comment','unit','private','-v6');
        end;
end;

    else
        disp('No input file?');
    end;
    
end;

if isfield(private,'loadpos')
    private=rmfield(private,'loadpos');
end;


%probably best if posamps match amp files
if nchanfile>nchan
    dummys=repmat('unused',[nchanfile-nchan,1]);
    sensornames=str2mat(sensornames,dummys);
end;



if doposamps
    disp('Converting posamp data');
    
    for itrial=triallist
        disp(itrial);
        trials=int2str0(itrial,ndig);
        inname=[posamppathin pathchar trials];
        outname=[posamppathout pathchar trials];
        [data,PA]=loadamp(inname);
        if ~isempty(data)
            data=single(data);
    [descriptor,unit,dimension]=headervariables(1,sensornames,[PA.ntrans PA.nchan]);
            
private.loadamp=PA;

            %save as mat file with standard variables
            if myversion=='6'
                save(outname,'data','descriptor','dimension','samplerate','comment','unit','private');
            else
                save(outname,'data','descriptor','dimension','samplerate','comment','unit','private','-v6');
            end;
            
        else
            disp('Rawpos2mat: No input file?');
        end;
        
    end;
end;

data=rmsbuf(:,:,1:maxused);
rmsfile=[rawpath pathchar 'rawpos2mat_rmsstats_' int2str(rmsuse)];

tmpd=squeeze(data(:,1,:));
tmpd=sum(tmpd);

disp('Total samples for each sensor with rms above threshold');
disp(tmpd);

tmpd=squeeze(data(:,2,:));
tmpd=max(tmpd);
disp('Max rms for each sensor');
disp(tmpd);
disp(['See ' rmsfile '.mat for details']);

descriptor=str2mat('n_rmsoverthresh','maxrms');
comment=['rms statistics (dim 2) over trials (dim 1) and sensors (dim 3)' crlf briefcomment];
save(rmsfile,'data','descriptor','comment');
