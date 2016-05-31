function mc52mat(tapadmode,inpath,outpath,triallist,logfile,sensorlist,commentfile,fixed_trafo,refobj,refsensors,rigidbodyname);
% MC52MAT Convert AG500 MC5recorder and Calcpos output to mat files for MT
% function mc52mat(tapadmode,inpath,outpath,triallist,logfile,sensorlist,commentfile,fixed_trafo,refobj,refsensors,rigidbodyname);
% mc52mat: Version 4.05.2005
%
%	Syntax
%       Based on tapad2mat programs
%		tapadmode
%			Possible choices are 'tap', 'raw', 'auto', 'head', 'ref'. Default=head
%			'head': Normal use: Output is in skull coordinates. Uses a reference object (see below)
%				to define compensation for rigid body movement. Thus this mode can also be
%				used e.g to extract the rigid body parameters of jaw movement.
%			'ref': Normal use: Output re. skull coordinates for reference trial, i.e retains head movement
%				More generally, this mode applies a single transformation (defined in 'fixed_trafo') to all data
%			'tap' and 'auto': output in tapad and autokal coordinates,
%			respectively. Note: auto is now the coordinate system of the
%			input data. So use this mode to store a trial when defining a
%			reference object
%			'raw' reads in the signed magnitude data from the .AMP files (=calcpos input)
%				and stores it in mat files. All other modes use .POS as input
%           Details of any processing applied to raw AMP or POS data should
%           be outlined in the comment file
%
%		triallist
%			List of trials to convert, i.e vector of trial numbers (refers
%			to the trial numbers generated by the ag500 software)
%
%		logfile
%           Logfile generated by the matlab prompt program and expanded by
%           ADJLOGFILE to explicitly specify the mapping from ag500 trial
%           number to output trial number.
%           First column is output trial number, 2nd column is AG500 trial
%           number, 3rd column is trial number generated by prompt software
%           (and possibly used to control video timer).
%           Text between square brackets is used for the label variable in
%           the output cutfile and in the item_id variable of the output
%           signal files. However, the complete log file record (including all versions 
%           of the trial numbers (output, AG500, prompt) is used in
%           the trialnumber.value/label structure stored in the cut file
%           (so additional comments on each trial can be included by
%           placing text outside the square brackes).
%           The motivation for this scheme was so that a long series of
%           AG500 trials can be subdivided into blocks of trials each
%           numbered from 1. Also to handle cases (hopefully only
%           temporary) where e.g transmitter timeouts cause the ag500
%           trial number to get out of step with the trial number generated
%           by the prompt software (and possibly recorded on synchronized
%           video recordings).
%           For backward compatibility if the the log file simply contains
%           a list of labels (without square brackes), then input and
%           output trialnumbers are assumed to be the same, and the first
%           label in the list corresponds to trial 1.
%
%		inpath
%			path to input data (i.e usually and AMPS or RAWPOS
%			subdirectory)
%
%		outpath
%			path plus common part of file name (i.e without trial number) for mat files
%				tapadmode is inserted in the output filename between outpath and the trial number
%
%		sensorlist
%			string matrix of sensor names, corresponding to channels 1 to n. 
%			Any channels with a blank name will not be processed
%
%		commentfile
%			Text file of comments to include in the comment variable in the mat files (Optional)
%
%		fixed_trafo
%			mat file containing transformation matrix to apply to all samples
%			necessary for 'ref' mode (as it consists of one fixed transformation) and will often
%			be needed in 'head' mode to define an anatomical normalization preceeding the head correction
%			using the reference object (see also refobj below)
%
%		refobj
%			mat file defining a reference object for use in e.g head movement correction
%			fixed_trafo and refobj are intended to be set up by MAKEREFOBJ
%			The two files have the same structure but are used in different ways;
%			in fact, one useful case is to use the same file for both the fixed transformation and the
%			reference object. Since the fixed transformation is carried out before samplewise mapping to the
%			reference object, this means that the rigid body parameters extracted when performing this mapping
%			can be related to an anatomically or functionally well-defined position of the reference object.
%
%		refsensors
%			Optional. Can be used to specify that only a subset of the sensors in refobj should be 
%			head correction. If absent, all sensors are used.
%			Note in particular that sensor orientation information is referred to as a virtual sensor with
%			'v_' prefixed to the sensor name. In short, refsensors must specify a subset of the sensors and
%			virtual sensors given in the reference object file generated by MAKEREFOBJ.
%           If a cell with two elements, each cell defines the refsensors
%           for a separate transformation. Only the result of the second is
%            stored as rigid body parameters. Use for jaw parameters, i.e
%            all data transformed to constant head position, then compute 
%             jaw rigid body paramters
%
%		rigidbodyname
%			Optional, only relevant in 'head' mode. Defaults to 'head_rig'.
%			In 'head' mode the reference sensors are used to define a rigid body. The 6 degrees of freedom
%			of this rigid body are stored as additional parameters in the output file.
%			The names of all these parameters use 'rigidbodyname' as a prefix, followed by
%			tx, ty, tz for the translations and rz, ry, rx for the rotations (about the z, y and x axes respectively).
%			If the rigid body movement is of no further interest then these parameters are strictly speaking superfluous.
%			(But they may be worth inspecting if there is suspicion of unusual features in the data).
%			If the rigid body movement is of interest, then using these parameters will generally be more effective
%			than using the raw coordinates of the original reference sensors.
%			In addition to the 6 rigid body parameters a measure of the accuracy of the reference object mapping
%			is stored in parameter 'taxdist' (short for 'average taxonomic distance'). Ideally, the reference sensors
%			can be mapped at every sample instant precisely onto the reference object. In practice, some distortion will
%			always remain; 'taxdist' is a measure of this, averaged over the reference sensors. For samples with unusually high values
%			the head-corrected movement data may not be reliable.
%			(The head has been assumed to be the most common rigid body, however the same procedures could be 
%			followed to derive the rigid body parameters of jaw movement.)
%
%		Output:
%			The main output is one MAT file per trial containing all the sensor data
%			In addition, in 'head' mode a MAT file (with suffix 'stats' instead of a trial number in the file name)
%			with various statistics on the head normalization is generated.
%			For each trial the average rigid body translations and rotations are stored, along with average value
%			of the taxonomic distance (just mentioned above) between the reference object and the best fit of the
%			reference sensors to it at each sample point. In addition, counts of any missing data are made.
%			These statistics are also plotted for inspection. It is worth checking them for unusual values of the
%			rigid body parameters (or the taxonomic distance) as this could indicate problems in performing accurate
%			head normalization.
%			The taxonomic distance should be a particularly useful summary measure indicating the reliability of the 
%			data. It is a kind of multidimensional counterpart to the stability of the distance between the two
%			reference sensors in the 2D system, which proved a very useful quality-control measure for the old system
%			since obviously this distance should remain constant over all trials.
%
%       Further input from user
%           Temporary? introduced 5.05:
%               User prompted for rms and posamp discontinuity threshold
%               (last two parameters in .POS files)
%               User also prompted for brief description of data
%                   This should be used to record what pre-processing has
%                   been done to raw data, e.g post-calibration of amps


%where can we get this from????
samplerate=200;

datamode='head';
if nargin
    datamode=tapadmode;
end;

%check for legal mode..... 

functionname='mc52mat: Version 4.05.2005';

inputext='.pos';
if strcmp(datamode,'raw') inputext='.amp'; end;

matpath=outpath;

inputunits='mm';
outputunits='cm';
outputscalefac=1/10;


[abint,abnoint,abscalar,abnoscalar]=abartdef;

%possibly could allow separate threshold for each channel
rms_thresh=abart('RMS threshold',10,0,60000,abint,abscalar);
posampdt_thresh=abart('Discontinuity threshold',0.5,0,60000,abnoint,abscalar);

badspec=[6 rms_thresh;7 posampdt_thresh];


briefcomment=abartstr('Brief description of any pre-processing');

comment=['Pre-processing: ' briefcomment crlf];
cutname=[matpath '_cut'];

comment=[comment 'Data mode: ' datamode crlf];
comment=[comment 'Input data path: ' inpath crlf];
%comment=[comment 'Result mat name: ' resultmatname crlf];
comment=[comment 'First, last, total trials converted: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf];
comment=[comment 'Log file name: ' logfile crlf];

comment=[comment 'RMS threshold: ' int2str(rms_thresh) crlf];
comment=[comment 'Discontinuity threshold: ' num2str(posampdt_thresh) crlf];


%parse log file for output trial nums (MT), input nums (AG),
%label
%also set up trialnumber label/value

[cutdata,cutlabel,agtrialnum,mttrialnum,trialnumS]=parselogfile(logfile);

ntrial=max(mttrialnum);

%check for existing cutfile
% this will happen if tapad2mat does not do all trials at once
%In order for this to work cutdata must be set up so that row number is
%equal to trial number.
%empty trials are deleted below before storing

if exist([cutname '.mat'],'file')==2
    disp('Using data from existing cut file');
    disp('Delete the cutfile and restart if this is not desired');
    tmpc=mymatin(cutname,'data');
    cutdata(tmpc(:,4),:)=tmpc;
end;


%number of digits to use for trial number
%need to do separately for in and out
ndigout=length(int2str(ntrial));
ndigin=4;                           %fixed


xcomment=readtxtf(commentfile);

if ~ischar(xcomment) xcomment='<No comment from external file>'; end;



%length of sensorlist should normally be 12, but with unused entries if
%appropriate
nsensor=size(sensorlist,1);
if nsensor~=12
    disp('Check length of sensor list');
    keyboard;
    return
end;

sensoruse=1:nsensor;

vv=find(sensorlist(:,1)~=' ');
sensorlist=sensorlist(vv,:);
sensoruse=sensoruse(vv);
nsensor=length(vv);


S=desc2struct(sensorlist);
comment=[comment 'Names of sensors used: ' strm2rv(sensorlist,' ') crlf];
comment=[comment 'Channel numbers of sensors used: ' int2str(sensoruse) crlf];




%intialize fixed transormation to no transormation (= auto mode)
hmat_fixed=[[eye(3) zeros(3,1)];[0 0 0 1]];

%load fixed transformation
% only relevant for ref and head modes


if nargin>7
    if ~isempty(fixed_trafo)
        htmp=mymatin(fixed_trafo,'private');
        if ~isempty(htmp)
            
            hmat_fixed=htmp.hmat;
            comment=[comment 'Fixed transformation input file: ' fixed_trafo crlf];  
            commentf=mymatin(fixed_trafo,'comment','<No comment for fixed transformation>');
            %document
            dataf=mymatin(fixed_trafo,'data');
            labelf=mymatin(fixed_trafo,'label');
            unitf=mymatin(fixed_trafo,'unit');
            
            if ~strcmp(deblank(unitf(1,:)),outputunits)
                %maybe try and repair automatically??
                error(['Translation in fixed transformation must be in ' outputunits]);
            end;
            
            
            comment=[comment 'Comment for fixed transformation' crlf commentf crlf];
            comment=[comment 'Reference object from fixed transformation' crlf];
            for ii=1:size(dataf,1)
                ss=num2str(dataf(ii,:));
                comment=[comment labelf(ii,:) ' ' ss crlf];
            end;
            
            comment=[comment 'Translations (tx, ty, tz) in ' outputunits ' and rotations (rz, ry, rx) in deg. from fixed transformation' crlf];
            hhh=showth(hmat_fixed);
            comment=[comment 'T: ' num2str(hhh(1:3)) ' R: ' num2str(hhh(4:6)*180/pi) crlf];
            
            
            
        end;
        %use refobj to document the fixed transformation?????   
    end;   
end;


if strcmp(datamode,'auto')
    comment=[comment 'X/Y/Z is in terms of autokal coordinates' crlf];
    comment=[comment 'For normal position of subject in EMA cube (looking towards forehead and chin transmitters)' crlf];
    comment=[comment 'X=Anterior-Posterior (increasing towards back)' crlf 'Y=Lateral (increasing to subject left)' crlf 'Z=Longitudinal (increase up)' crlf];
    
    hmat_fixed=[[eye(3) zeros(3,1)];[0 0 0 1]];     %autokal mode is now the zero transformation case
end;

if strcmp(datamode,'head')
    comment=[comment 'X/Y/Z is in terms of skull coordinates' crlf];
    comment=[comment 'X=Lateral (increase to left)' crlf  'Y = Anterior-posterior (increase from front to back)' crlf 'Z = Longitudinal (increase from foot to head)' crlf];

    %Normally this will be roughly like rotating the autokal coordinate
    %system 90 degrees in the xy plane
    
    %load and sort out reference object
    
    dataref=mymatin(refobj,'data');
    labelref=mymatin(refobj,'label');
    unitref=mymatin(refobj,'unit');
    if ~strcmp(deblank(unitref(1,:)),outputunits)
        %maybe try and repair automatically??
        error(['Translation in reference object transformation must be in ' outputunits]);
    end;
    rprivate=mymatin(refobj,'private');
    vdistance=rprivate.vdistance;
    hmat_ref=rprivate.hmat;
    
    if nargin<10 refsensors=labelref; end;
    if isempty(refsensors) refsensors=labelref; end;

    oneref=0;
    if size(refsensors,1)==1
        oneref=1;
    end;
    
    if oneref
        disp('Head correction with translation only');
    end;
    
    twot=0;
    if iscell(refsensors)
        if length(refsensors)==2
            refsensors2=refsensors{2};
            refsensors=refsensors{1};
            twot=1;
        end;
        
    end;
    
    
    nrefs=size(refsensors,1);
    
    vprefix='v_';
    
    refsensindex=zeros(1,nrefs);
    refvflag=zeros(1,nrefs);
    datarefuse=zeros(nrefs,size(dataref,2));
    
    for ii=1:nrefs
        tmps=deblank(refsensors(ii,:));
        vv=strmatch(tmps,labelref);
        if length(vv)~=1
            disp(refsensors);
            disp(labelref);
            error('refsensor not in refobj');
        end;
        
        datarefuse(ii,:)=dataref(vv,:);
        vv=findstr(vprefix,tmps);
        if ~isempty(strmatch(vprefix,tmps)) refvflag(ii)=1; end;
        tmps=strrep(tmps,vprefix,'');
        refsensindex(ii)=getfield(S,tmps);
    end;
    
    comment=[comment 'Reference object input file: ' refobj crlf];  
    commentr=mymatin(refobj,'comment','<No comment for reference object>');
    %document
    
    comment=[comment 'Comment for reference object' crlf commentr crlf];
    comment=[comment 'Reference object coordinates' crlf];
    for ii=1:size(dataref,1)
        ss=num2str(dataref(ii,:));
        comment=[comment labelref(ii,:) ' ' ss crlf];
    end;
    
    comment=[comment 'Translations (tx, ty, tz) in ' outputunits ' and rotations (rz, ry, rx) in deg. from reference object transformation' crlf];
    hhh=showth(hmat_ref);
    comment=[comment 'T: ' num2str(hhh(1:3)) ' R: ' num2str(hhh(4:6)*180/pi) crlf];
    
    comment=[comment 'Sensors used in transformation:' crlf strm2rv(refsensors,' ') crlf];
    
    
    %prepare for rigid body parameter output
    
    rigname='head_rig';
    if nargin>10 rigname=rigidbodyname; end;
    descrig=str2mat('tx','ty','tz','rz','ry','rx');
    unitrig=str2mat(outputunits,outputunits,outputunits,'deg','deg','deg');
    rigrotfac=180/pi;
    descrig=strcat([rigname '_'],descrig);
    descrig=str2mat(descrig,'taxdist');
    unitrig=str2mat(unitrig,outputunits);
    
    
    %set up second rigid body transformation
    if twot
        
        nrefs2=size(refsensors2,1);
        
        vprefix='v_';
        
        refsensindex2=zeros(1,nrefs2);
        refvflag2=zeros(1,nrefs2);
        datarefuse2=zeros(nrefs2,size(dataref,2));
        
        for ii=1:nrefs2
            tmps=deblank(refsensors2(ii,:));
            vv=strmatch(tmps,labelref);
            if length(vv)~=1
                disp(refsensors2);
                disp(labelref);
                error('refsensor2 not in refobj');
            end;
            
            datarefuse2(ii,:)=dataref(vv,:);
            vv=findstr(vprefix,tmps);
            if ~isempty(strmatch(vprefix,tmps)) refvflag2(ii)=1; end;
            tmps=strrep(tmps,vprefix,'');
            refsensindex2(ii)=getfield(S,tmps);
        end;
        
        
        
        comment=[comment 'Sensors used in transformation2:' crlf strm2rv(refsensors2,' ') crlf];
        
    end;        %second rigid body transformation   
    
    %keyboard   
    
end;



if strcmp(datamode,'ref')
    comment=[comment 'X/Y/Z is in terms of skull coordinates in reference trial (not compensated for head movement' crlf];
    comment=[comment 'X=Lateral (increase to left)' crlf  'Y = Anterior-posterior (increase from front to back)' crlf 'Z = Longitudinal (increase from foot to head)' crlf];
    
    %fixed transformation should already have been loaded
end;

if strcmp(datamode,'tap')
    comment=[comment 'X/Y/Z is in terms of native tapad coordinates' crlf];
%    hmat_fixed=[[eye(3) zeros(3,1)];[0 0 0 1]];
disp('tapad mode currently unavailable');
return;
%probably something like this, but needs checking
%hmat_fixed=inv(t2a);   
end;

if ~strcmp(datamode,'tap')
    comment=[comment 'Sensor orientation is given by the x, y and z coordinates' crlf];
    comment=[comment 'of a unit-length vector relative to the sensor position' crlf];
    comment=[comment '(the suffixes _ox, _oy, _oz are appended to the sensor name)' crlf];
end;



comment=[comment '<Start of comment from external file (' commentfile ')>' crlf];
comment=[comment xcomment crlf];
comment=[comment '<End of comment from external file (' commentfile ')>' crlf];






%assume loadpos_sph2car returns data like this, i.e orientation already
%converted from spherical to cartesian unit vector
descriptor=str2mat('px','py','pz','ox','oy','oz','rms','newflag');

Pout=desc2struct(descriptor);



unit=str2mat(outputunits,outputunits,outputunits,'norm','norm','norm','dig',' ');
scalefacs=[outputscalefac outputscalefac outputscalefac 1 1 1 1 1 ];		%scale input data to output units


if strcmp(datamode,'raw')
    descriptor=str2mat('_T1','_T2','_T3','_T4','_T5','_T6');	%temporary names for transmitters
    unit=(blanks(6))';
    scalefacs=ones(1,6);
end;


%=======================
%something similar may be useful again eventually
%=====================================
%add in fixtrace from result.mat
%descriptor=str2mat(descriptor,tracename);
%unit=str2mat(unit,'bitpattern');		%should really get this from unit of a result.mat file
%scalefacs=[scalefacs 1];

%==========================================

dbase=descriptor;
ubase=unit;
npar=size(descriptor,1);


%set up complete descriptors
for ii=1:nsensor
    sensorname=[deblank(sensorlist(ii,:)) '_'];
    
    
    dtmp=[rpts([npar 1],sensorname) dbase];
    if ii==1
        descriptor=dtmp;
        unit=ubase;
    else
        descriptor=str2mat(descriptor,dtmp);
        unit=str2mat(unit,ubase);
    end;
end;

%in head mode rigid body parameters are also stored
if strcmp(datamode,'head')
    descriptor=str2mat(descriptor,descrig);
    unit=str2mat(unit,unitrig);
end;



basecomment=comment;


%if head mode accumulate statistics on the reference object registration

badreg=ones(ntrial,1)*NaN;
taxx=ones(ntrial,1)*NaN;
taxsd=ones(ntrial,1)*NaN;
taxnansum=ones(ntrial,1)*NaN;

nancountbuf=ones(ntrial,nsensor)*NaN;

rigoutx=ones(ntrial,6)*NaN;
rigoutsd=ones(ntrial,6)*NaN;

%===================================================
%main loop, thru trials
%===================================================

%numbers in triallist refer to AG numbers
for itrial=triallist
    rawpath=[inpath  pathchar int2str0(itrial,ndigin) inputext];
    data=[];
    t0=0;
    
%look for corresponding output trial number

ppp=find(itrial==agtrialnum);
itrialout=mttrialnum(ppp);


%and its position in cutdata/label
item_id=deblank(cutlabel(itrialout,:));
    disp([rawpath ' ' item_id ' > trial ' int2str(itrialout)]);
    
    disp('loading ...');   
    
    
if strcmp(tapadmode,'raw')
    bigbuf=loadamp(rawpath);
else
    bigbuf=loadpos_sph2cart(rawpath,badspec);
end;
nd=size(bigbuf,1);

if ~nd disp('Input file empty or missing; skipping this trial'); end;
    
    
    if nd
        bigbuf=bigbuf(:,:,sensoruse);
        cutdata(itrialout,1:2)=[0 nd/samplerate];
        
        %must do scaling before any transformations
        
        bigbuf=bigbuf.*repmat(scalefacs,[nd 1 nsensor]);
        
%currently no NaNs in input, but maybe reintroduced (in loadpos_sph2cart?)
        
        %quick check for NaNs
        %assume checking one coordinate is sufficient
        nancount=sum(isnan(squeeze(bigbuf(:,Pout.px,:))));
        disp('Total NaNs per sensor in input data');
        disp(nancount);
        nancountbuf(itrialout,:)=nancount;
        
        
        %in head mode there is an additional check for NaNs in the reference sensors
        %since this will result in the result for all sensors being NaNs
        
        
        %for all modes do fixed transformation
        %probably better to do it before samplewise transformation to reference object
        % as it could make it easier to interpret the rigid-body parameters from the 
        % reference object transformation matrices
        
        disp('Performing fixed transformation');   
        bigbuf=rotor(bigbuf,Pout,hmat_fixed);
        
        
        
        %================
        %sample by sample mapping to reference object (head mode only)
        %=================
        
        
        %precompute rotations for all sample points
        
        if strcmp(datamode,'head')
if oneref
    disp('Doing head correction, translation only');
    ppp=[Pout.px Pout.py Pout.pz];
    ref1d=bigbuf(:,ppp,refsensindex(1));
    ns=size(bigbuf,3);
    for i1=1:ns
        bigbuf(:,ppp,i1)=bigbuf(:,ppp,i1)-ref1d;
    end;
    
nd=size(bigbuf,1);
%needed for output
taxdist=ones(nd,1)*NaN;
rigout=ones(nd,6)*NaN;

%does sign corrspond to usage for normal case?
rigout(:,1:3)=ref1d;

    
    
else
            
            disp('Computing transformation to reference object (head mode)');
            
% keyboard;
            [rotmatb,rotmatbi,taxdist]=getregemat(bigbuf,Pout,datarefuse,refsensindex,refvflag,vdistance);
            
            vbadreg=find(taxdist==-1);
nbadreg=length(vbadreg);
if nbadreg
    taxdist(vbadreg)=NaN;
    disp(['n unreliable registration : ' int2str(nbadreg)]);
end;

            %rather than defining the head-movement compensation the transformation can
            % also be seen as providing the rigid body parameters of head movement
            
            %display statistics of taxonomic distance as a measure of the reliability of the reference sensors         
            badreg(itrialout)=nbadreg;
            
            taxx(itrialout)=nanmean(taxdist);
            taxsd(itrialout)=nanstd(taxdist);
            taxnansum(itrialout)=sum(isnan(taxdist));
            
            disp(['Taxonomic distance mean/sd/nansum : ' num2str([taxx(itrialout) taxsd(itrialout)]) ' ' int2str(taxnansum(itrialout))]);
            
            %		also collect statistics of the rigid body parameters
            
            %output the transformation from ref object to data as the rigid
            %body parameters (see notes on getregemat)
            rigout=showth(rotmatbi);
            rigout(:,4:6)=rigout(:,4:6)*rigrotfac;
            rigoutx(itrialout,:)=nanmean(rigout);
            rigoutsd(itrialout,:)=nanstd(rigout);
            
            disp(['Rigid body means: ' num2str(rigoutx(itrialout,:))]);
            disp(['Rigid body sds  : ' num2str(rigoutsd(itrialout,:))]);
            
            disp('Performing transformation to reference object (head mode)');
            bigbuftmp=bigbuf;
            bigbuf=rotorm(bigbuf,Pout,rotmatb);
%            keyboard;
        end;        %only one ref sensor
            
            %note: if a second transformation is defined then it determines
            % the stored taxonomic distance and rigid body parameters 
            
            if twot
                disp('Computing transformation2 to reference object (head mode)');
                
                [rotmatb,rotmatbi,taxdist]=getregemat(bigbuf,Pout,datarefuse2,refsensindex2,refvflag2,vdistance);
                
                
                %display statistics of taxonomic distance as a measure of the reliability of the reference sensors         
                
                taxx(itrialout)=nanmean(taxdist);
                taxsd(itrialout)=nanstd(taxdist);
                taxnansum(itrialout)=sum(isnan(taxdist));
                
                disp(['Taxonomic distance (2nd trans.) mean/sd/nansum : ' num2str([taxx(itrialout) taxsd(itrialout)]) ' ' int2str(taxnansum(itrialout))]);
                
                %		also collect statistics of the rigid body parameters
                
                %output the transformation from ref object to data as the rigid
                %body parameters (see notes on getregemat)
                rigout=showth(rotmatbi);
                rigout(:,4:6)=rigout(:,4:6)*rigrotfac;
                rigoutx(itrialout,:)=nanmean(rigout);
                rigoutsd(itrialout,:)=nanstd(rigout);
                
                disp(['Rigid body means (2nd trans.): ' num2str(rigoutx(itrialout,:))]);
                disp(['Rigid body sds  (2nd trans.) : ' num2str(rigoutsd(itrialout,:))]);
                
                
            end;       %second transformation         
            
            
            
            disp('transformation complete');   
        end;
        
        
        %   keyboard;  
        
        
        
            %scale and rearrange bigbuf for output
            
            %      keyboard
            disp('storing');
            
            
            data=reshape(bigbuf,[nd npar*nsensor]);
            
            %add in rigid body parameters for storage
            if strcmp(datamode,'head')
                data=[data rigout taxdist];
            end;
            
            comment=basecomment;
%            comment=[basecomment 'Start of comment from result.mat =======' crlf rcomment crlf 'End of comment from result.mat =======' crlf];
            comment=framecomment(comment,functionname);
            
            
            % keyboard     
            save([matpath '_' datamode '_' int2str0(itrialout,ndigout)],'data','descriptor','unit','t0','samplerate','comment','item_id');
            
        
    end;		%nd > 0  
end;		%trial loop

%store cutfile

%display total nans

hfn=figure;
hlnan=plot(nancountbuf,'linewidth',2);
[hlegn,hlobj]=legend(hlnan,sensorlist);
title('Total missing data per trial');
hxx=findobj(hlobj,'type','text');
set(hxx,'interpreter','none');

%display and store figs of taxonomic distances

if strcmp(datamode,'head')
    hftx=figure;
    plot(taxx,'linewidth',2);
    title('Average taxonomic distance per trial');
    ylabel(outputunits);
    xlabel('Trial');
    hftsd=figure;
    plot(taxsd,'linewidth',2);
    title('SD of taxonomic distance per trial');
    ylabel(outputunits);
    xlabel('Trial');
    hftnans=figure;
    plot(taxnansum,'linewidth',2);
    title('Reference object registration: Total missing samples per trial');
    
    hfrxt=figure;
    hlrxt=plot(rigoutx(:,1:3));
    ylabel(outputunits);
    haltmp=legend(hlrxt,descrig(1:3,:));
    title('Rigid body translation: Means per trial');
    
    hfrsdt=figure;
    hlrsdt=plot(rigoutsd(:,1:3));
    ylabel(outputunits);
    haltmp=legend(hlrsdt,descrig(1:3,:));
    title('Rigid body translation: SDs per trial');
    
    hfrxr=figure;
    hlrxr=plot(rigoutx(:,4:6));
    ylabel(unitrig(4,:));
    haltmp=legend(hlrxr,descrig(4:6,:));
    title('Rigid body rotation: Means per trial');
    
    hfrsdr=figure;
    hlrsdr=plot(rigoutsd(:,4:6));
    ylabel(unitrig(4,:));
    haltmp=legend(hlrsdr,descrig(4:6,:));
    title('Rigid body rotation: SDs per trial');
    
    save([matpath '_' datamode '_stats'],'nancountbuf','taxx','taxsd','taxnansum','rigoutx','rigoutsd','descrig','unitrig','badreg');
    
end;

keyboard;



data=cutdata;
label=cutlabel;

%eliminate trials without segment data
vv=find(isnan(data(:,1)));
data(vv,:)=[];
label(vv,:)=[];


[descriptor,unit,valuelabel]=cutstrucn;
valuelabel.trial_number=trialnumS;

save(cutname,'data','label','comment','descriptor','unit','valuelabel');


%do inverse for autokal to tapad?????
function AT=t2a
%transformation matrix from tapad to autokal
%9.02 converted to homogeneous matrix with zero translation

AT = [ -5.7735026962962970e-001  5.7735026962962970e-001 -5.7735026962962970e-001;...
        -7.0710678222222210e-001 -7.0710678222222210e-001  0.0000000000000000e+000;...
        -4.0824829037037030e-001  4.0824829037037030e-001  8.1649658074074060e-001];

AT=[[AT zeros(3,1)];[0 0 0 1]];


function bufout=rotor(bufin,P,rotmat)
%applies same transformation to all samples of all channels
%rotmat must be a homogeneous matrix specifying rotation and translation and
% must be designed for use as M*v where v is a column matrix of coordinates
% thus we have to fiddle around with transpostion here

bufout=bufin;
ns=size(bufin,3);	%number of sensors
nd=size(bufin,1);	%number of data
rotonly=rotmat(1:3,1:3);


for ii=1:ns
    tmp=([bufin(:,[P.px P.py P.pz],ii) ones(nd,1)])';
    tmp=(rotmat*tmp)';
    bufout(:,[P.px P.py P.pz],ii)=tmp(:,1:3);
    %orientations are only rotated, not translated
    bufout(:,[P.ox P.oy P.oz],ii)=(rotonly*(bufin(:,[P.ox P.oy P.oz],ii))')';
end;


function bufout=rotorm(bufin,P,rotmatb);
% basically same as rotor (see above) but
% does all samples for multiple channels; separate rotation for each sample
%

%keyboard
ns=size(bufin,3);	%number of sensors
nd=size(bufin,1);	%number of data
bufout=bufin;

for isamp=1:nd
    rotmat=rotmatb(:,:,isamp);
    rotonly=rotmat(1:3,1:3);
    tmp=[squeeze(bufin(isamp,[P.px P.py P.pz],:));ones(1,ns)];
    %   disp('1');keyboard;
    tmp=rotmat*tmp;
    %   disp('2');keyboard;
    bufout(isamp,[P.px P.py P.pz],:)=tmp(1:3,:);
    %   disp('3');keyboard;
    
    tmp=squeeze(bufin(isamp,[P.ox P.oy P.oz],:));
    tmp=rotonly*tmp;
    bufout(isamp,[P.ox P.oy P.oz],:)=tmp;
end;

function [rotmatb,rotmatbi,taxdist]=getregemat(bigbuf,P,datarefuse,refsensindex,refvflag,vdistance);
%get transformation matrices to map data samplewise to reference object (in
%rotmapb
%rotmapbi contains the mapping from the reference object to the data
% use this as e.g head movement components
%Not clear why the translations and rotations derived from rotmapbi are not
%identical to the negative of those from rotmapb.
% They are usually pretty close, but by no means the same.
% (maybe only identical when taxonomic distance is zero)

%get cartesian coordinates for all sensors, whether virtual or not

tmpd=bigbuf(:,[P.px P.py P.pz],refsensindex);
nref=length(refsensindex);
%convert orientation information to virtual sensor
for ii=1:nref
    if refvflag(ii)
        tmpo=bigbuf(:,[P.ox P.oy P.oz],refsensindex(ii));
        tmpd(:,:,ii)=tmpd(:,:,ii)+(tmpo*vdistance);
    end;
end;

%rearrange for use by rege_h, i.e sensors*coordinates*time

tmpd=permute(tmpd,[3 2 1]);

[rotmatb,taxdist]=rege_h(datarefuse,tmpd);

%keyboard;

%temporary: test reverse direction
rotmatbi=ones(size(rotmatb))*NaN;
taxdisti=ones(size(taxdist))*NaN;
disp('reversing rigid body transformation')
for ii=1:size(rotmatb,3)
    [rotmatbi(:,:,ii),taxdisti(ii)]=rege_h(tmpd(:,:,ii),datarefuse);
end;

%keyboard;

function hmati=invrotmat(hmat);
%reverse the direction of the transformation

hmati=hmat;
np=1;
if ndims(hmat)>2 np=size(hmat,3); end;

for ii=1:np
    tmp=hmat(1:3,1:3,ii);
    hmati(1:3,1:3,ii)=tmp';
    hmati(1:3,4)=-hmat(1:3,4);
end;
