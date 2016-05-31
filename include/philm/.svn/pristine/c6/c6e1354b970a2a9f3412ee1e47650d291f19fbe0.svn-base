function y=makepctracks(data,pcconfig)
% MAKEPCTRACKS Calculate signal tracks from principal component analysis
% function y=makepctracks(data,pcconfig)
% makepctracks: Version 25.09.2013
%
%   Description
%       Mainly designed for calling as part of the calc string when
%       calculating new signals with mtsigcalc
%
%   Syntax
%       data
%           If the selectvec config field is not present then data must
%           be arranged such that the columns contain the desired input signals
%           from which to calculate the new signal tracks. Thus the number
%           of columns in data must match the number of rows in the eigvec
%           config field.
%           (This will be the typical case with e.g. EMA data
%              e.g makepctracks([tipx midx backx tipy midy backy],pcconfig)
%           If the selectvec field is present it is assumed that data is
%           multidimensional with time (or observations) as the last dimension. If data is
%           two-dimensional then selectvec directly specifies the rows to
%           use. The length of selectvec must match the number of rows in
%           eigvec.
%           If data is three-dimensional (e.g. image data), then the first
%           two dimensions are flattened to make a two-dimensional
%           variable, and selectvec is then used as above (dimensions
%           higher than 3 not yet supported)
%           Using selectvec is necessary for e.g spectral slice, or image
%           data. So if no selection is to made it must still be present,
%           and set to the full range of the data.
%           If present, it is essential that selectvec corresponds to the
%           selection used in the PC analysis
%
%       pcconfig: Either a struct with the following fields, or the name
%           of a mat file containing struct pcconfig with the same fields
%           eigvec: required. The number of signal tracks generated
%               corresponds to the number of columns. See above for number
%               of rows. (eigvec corresponds to the coeff output of
%               princomp, reducing the number of columns to only the first
%               few components, if necessary.)
%               Could also be linear coefficients from discriminant or
%               regression analyis.
%           means: The column means of the data input to the PC
%               analysis. Length of means must equal number of rows in
%               eigvec.
%           selectvec: See above
%           sds: Optional. Column standard deviations of input to PC analysis. Not needed if
%                  PC analysis used covariance method. If PC analysis used
%                  correlation method (zscores as input to princomp) it
%                  must be supplied.
%           const: Optional. Constant term to add to the final parameter
%               tracks. Must be line vector with length corresponding to
%               the number of columns in eigvec (i.e the number of tracks
%               to be generated). Const could, for example, be the constant
%               term in a discrimance function.
%           makeerrortrack [0]: If true, compute additional track with rms
%               difference between raw data and modelled data
%           filtercoff: Optional. Vector of FIR coefficients to filter the
%               PC tracks
%           modelfile: Optional. If present, data is reconstructed using
%               the PC scores and stored using this field as file name.
%               Reconstructed data will have the same structure as the raw
%               input data.
%           The following fields are currently rather ad hoc for handling
%               image data (all are optional):
%           selectrow and selectcol are vectors to define e.g. the region
%               of interest in the image
%           imagescalefac must be an appropriate specification for the
%               'scale' argument in the imresize function
%           selectrow, selectcol and imagescalefac are all applied before
%               selectvec and enable the amount of imaged data to be reduced
%               before any analysis is carried out. Any settings made here must
%               of course match the settings actually used in the PC analysis
%       y: Output parameter tracks
%
%   Updates
%       4.2013 Add const field
%       6.2013 Allow filtering of PC tracks. Prepare for storage of
%           modelled data. Calculation of rms distance between raw and modelled
%           data at each time point
%
%   See Also
%       PCSCORES Underlying function to multiply the input data by the
%           eigenvectors
%       PC2MODEL Reconstruction of modelled data from PC scores

functionname='makepctracks: Version 25.09.2013';

y=[];

tmps=pcconfig;
sok=0;
if ~isstruct(pcconfig)
    if ischar(pcconfig)
        if exist([pcconfig '.mat'],'file')
            load(pcconfig)
            if isstruct(pcconfig)
                sok=1;
            end;
        end;
    end;
else
    sok=1;
end;

if ~sok
    disp('Problem with pcconfig');
    disp(tmps);
    return;
end;

ndimsin=ndims(data);
simpledata=1;       %set to 0 for image or e.g. spectral slice data, where time is last dimension

%should check dimensions are appropriate ....
if isfield(pcconfig,'selectrow')
    disp('pre-selecting rows');
    data=data(pcconfig.selectrow,:,:);
end;

if isfield(pcconfig,'selectcol')
    disp('pre-selecting columns');
    data=data(:,pcconfig.selectcol,:);
end;
if isfield(pcconfig,'imagescalefac')
    disp('resizing image');
    nframe=size(data,3);
    for ii=1:nframe
        tmpb=imresize(data(:,:,ii),'scale',pcconfig.imagescalefac);
        if ii==1
            datax=repmat(0,[size(tmpb,1) size(tmpb,2) nframe]);
        end;
        datax(:,:,ii)=tmpb;
    end;
    data=datax;
    
end;

%also needed if reconstructing image data from PCs
nrowin=size(data,1);
ncolin=size(data,2);

%selectvec field is used to assume data is not spreadsheet-style
%so must be present, even if all data is selected
if isfield(pcconfig,'selectvec')
    if ndims(data)>2
        data=reshape(data,[nrowin*ncolin size(data,3)]);
    end;
    data=(data(pcconfig.selectvec,:))';
    simpledata=0;
end;
disp('makepctracks');
disp(pcconfig);
if isfield(pcconfig,'sds')
    y=pcscores(data,pcconfig.eigvec,pcconfig.means,pcconfig.sds);
    
else
    y=pcscores(data,pcconfig.eigvec,pcconfig.means);
%generate default sds if not present, as needed below
    pcconfig.sds=ones(size(pcconfig.means));
end;

[nrow,ncol]=size(y);

if isfield(pcconfig,'const')
    myconst=pcconfig.const;
    myconst=(myconst(:))';
    if length(myconst)~=ncol
        disp('Length of const field does not match number of output parameter tracks');
        return;
    end;
    myconst=repmat(myconst,[nrow 1]);
    y=y+myconst;
end;

disp(['Size of new data : ' int2str([nrow ncol])]);

if isfield(pcconfig,'filtercoff')
    disp('Filtering PC tracks');
    mycoff=pcconfig.filtercoff;
    for ifi=1:ncol
        y(:,ifi)=decifir(mycoff,y(:,ifi));
    end;
end;

%keyboard;
%mt_gcsid: 'signalpath', 'ref_trial'
%mt_gsigv: 'mat_name', 'descriptor', 'dimension', 'class_mat'



modeldone=0;
makeerrortrack=0;
if isfield(pcconfig,'makeerrortrack') makeerrortrack=pcconfig.makeerrortrack; end;
if makeerrortrack
    disp('Making error track');
    
    modeldata=pc2model(y,pcconfig.eigvec,pcconfig.means,pcconfig.sds);
    modeldone=1;
    %keyboard;
    xxx=(modeldata-data).^2;
    xx=mean(xxx')';
    ye=sqrt(xx);
    y=[y ye];
end;

if isfield(pcconfig,'modelfile')
    disp(['reconstructing data from ' int2str(ncol) ' components']);
    if ~modeldone
        modeldata=pc2model(y,pcconfig.eigvec,pcconfig.means,pcconfig.sds);
    end;
    
    %default should normally be ok for image data, as then there is usually
    %only 1 raw signal involved
    
    mysig=mt_gsigv;
    mysig=deblank(mysig(1,:));
    if isfield(pcconfig,'mtnew_name') mysig=pcconfig.mtnew_name; end;
    
    %get relevant variables for setting up new signal file
    %mt_gcsid: 'signalpath', 'ref_trial'
    %mt_gsigv: 'mat_name', 'descriptor', 'dimension', 'class_mat'
    reftrial=mt_gcsid('ref_trial');
    ndig=length(reftrial);
    mytrial=mt_gtrid('number');
    oldfile=[mt_gcsid('signalpath')  mt_gsigv(mysig,'mat_name') int2str0(mytrial,ndig)];
    
    newfile=[pcconfig.modelfile int2str0(mytrial,ndig)];
    copyfile([oldfile '.mat'],[newfile '.mat']);
    private=mymatin(oldfile,'private');
    private.makepctracks=pcconfig;
    descriptor=mt_gsigv(mysig,'descriptor');
    descriptor=[descriptor '_pcmodel'];     %configurable?
    
    comment=mymatin(oldfile,'comment');
    comment=['See private.pcconfig for details of setting' crlf comment];
    comment=framecomment(comment,functionname);
    
    
    
    dimension=mt_gsigv(mysig,'dimension');
    
    %dimension needs re-arranging to take care of cropping and resizing
    %re-arrange data for output
    
    %convert from double?
    %rather ad hoc
    %note: single retains NaN information, but uint8 sets NaN to 0 (which may
    %not be ideal for cases based on image data)
    
    myclass=mt_gsigv(mysig,'class_mat');
    if strcmp(myclass,'uint8')
        modeldata=uint8(modeldata);
        tmpd=uint8(0);
    else
        modeldata=single(modeldata);
        tmpd=single(0);
    end;
    %currently only worked out for image data
    if ~simpledata
        if ndimsin==3
            
            %nrow refers to the array with the PC tracks
            data=repmat(tmpd,[nrowin*ncolin nrow]);
            
            data(pcconfig.selectvec,:)=modeldata';
            data=reshape(data,[nrowin ncolin nrow]);

        decstep=[1 1];
        if isfield(pcconfig,'imagescalefac') decstep=round(1./pcconfig.imagescalefac); end;
        if length(decstep)==1 decstep=[decstep decstep]; end;
%needs to be done for dimension.external.axis as well
        axtmp=dimension.axis;
        axt1=axtmp{1};
        axt2=axtmp{2};
        if isfield(pcconfig,'selectrow')
            axt1=axt1(pcconfig.selectrow);
        end;
        if isfield(pcconfig,'selectcol')
            axt2=axt2(pcconfig.selectcol);
        end;
        axt1=axt1(1:decstep(1):end);
        axt2=axt2(1:decstep(2):end);
        axtmp{1}=axt1;
        axtmp{2}=axt2;
        dimension.axis=axtmp;
        
        
        
        
        end;        %ndimsin==3
    end;        %~simpledata
    
%    keyboard;
    
    save(newfile,'-append','data','descriptor','dimension','comment','private');
end;
