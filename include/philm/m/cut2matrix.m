function cut2matrix(cutfile,outsuffix,labelv,skiptypes,deletestring,replacestring)
% CUT2MATRIX Convert segment file to table of observations (grouping based on label)
% function cut2matrix(cutfile,outsuffix,labelv,skiptypes,deletestring,replacestring)
% cut2matrix: Version 02.10.2013
%
%   Description
%       All cutfile entries with same label are converted to one record
%       Column names in output matrix are taken from cut_type_label (or
%       valuelabel structure) with suffixes '_on', '_off', and '_dur'
%       Currently assumes each segment type occurs only once for each
%       label.
%       If multiple items occur a warning is issued (only the first
%       occurrence will be stored)
%       Optional input argument labelv is a vector indicating the columns of the label variable to use
%           (can be useful if the labels of different segments differ
%           slightly). Note: This is applied AFTER any changes to the label
%           from use of the deletestring/replacestring arguments.
%       skiptypes: Optional. List of segment types to be ommitted. e.g. can be used to
%           eliminate the copy of the segment used to control mtnew.
%           May be useful for suppressing messages 'Multiple tokens with same
%           cut type' if these apply to uninteresting segments
%           May also make it easier to define a convenient range of the
%           label to use.
%       deletestring and replacestring: Optional. If the deletestring
%           argument is present then any occurrences of this in the label will
%           be deleted (if no further arguments) or replaced (if replacestring
%           argument is also present)
%           This is mainly intended to be used to remove the
%           trailing slashes in the label inserted by the mtnew marker
%           functions (which will usually make the label look more like the original
%           code from the prompt software; also, different segments sometimes have
%             different numbers of slashes, which can be awkward to handle otherwise).
%
%   Updates
%       24.8.07. Input argument labelv added
%       15.09.2013 Input argument skiptypes added
%       30.10.2013 deletestring/replacestring added

functionname='cut2matrix. Version 02.10.2013';


load(cutfile);


orgrecnum=1:size(data,1);
if nargin>3
    if ~isempty(skiptypes)
        vv=find(ismember(data(:,3),skiptypes));
        if ~isempty(vv)
            data(vv,:)=[];
            label(vv,:)=[];
            orgrecnum(vv)=[];
            disp('cut2matrix: skiptypes');
            disp(skiptypes);
            disp([int2str(length(vv)) ' segments eliminated']);
        end;
    end;
    
end;

repchar=''; %default is delete
delchar='';
delslash=0;
if nargin > 4
    if ischar(deletestring)
        delchar=deletestring;
        delslash=1;
        if nargin>5
            if ischar(replacestring) repchar=replacetring; end;
        end;
    end;
end;

if delslash
    disp(['cut2matrix: replacing ' delchar ' with ' repchar]);
    label=cellstr(label);
    label=strrep(label,delchar,repchar);
    label=char(label);
end;

if nargin>2
    if ~isempty(labelv)
        label=label(:,labelv);
    end;
    
end;


labelu=unique(label,'rows');
nlab=size(labelu,1);

typeu=unique(data(:,3));
ntype=length(typeu);

if exist('valuelabel','var')
    cut_type_label=valuelabel.cut_type.label;
    cut_type_value=valuelabel.cut_type.value;
end;


dataon=ones(nlab,ntype)*NaN;
dataoff=ones(nlab,ntype)*NaN;
datadur=ones(nlab,ntype)*NaN;

for ilab=1:nlab
    vv=strmatch(labelu(ilab,:),label);
    disp(labelu(ilab,:));
    nv=length(vv);
    datatmp=data(vv,:);
    %      keyboard;
    for ii=1:nv
        ipi=find(datatmp(ii,3)==typeu);
        idoub=0;
        if isnan(dataon(ilab,ipi))
            dataon(ilab,ipi)=datatmp(ii,1);
        else
            idoub=1;
        end;
        if isnan(dataoff(ilab,ipi))
            dataoff(ilab,ipi)=datatmp(ii,2);
        else
            idoub=1;
        end;
        
        if idoub
            disp(['Multiple tokens with same cut type ' int2str(datatmp(ii,3)) ' in record ' int2str(orgrecnum(vv(ii)))]);
        else
            datadur(ilab,ipi)=datatmp(ii,2)-datatmp(ii,1);
        end;
        
    end;
end;

dbase=cell(ntype,1);
for ii=1:ntype
    ipi=find(typeu(ii)==cut_type_value);
    dbase{ii}=deblank(cut_type_label(ipi,:));
end;


dbase=char(dbase);

%remove empty columns

don=dbase;
vv=find(all(isnan(dataon)));
dataon(:,vv)=[];
don(vv,:)=[];

doff=dbase;
vv=find(all(isnan(dataoff)));
dataoff(:,vv)=[];
doff(vv,:)=[];

ddur=dbase;
vv=find(all(isnan(datadur)));
datadur(:,vv)=[];
ddur(vv,:)=[];

don=strcat(don,'_on');
doff=strcat(doff,'_off');
ddur=strcat(ddur,'_dur');


data=[dataon dataoff datadur];
label=labelu;
descriptor=strvcat(don,doff,ddur);
unit=repmat('s',[size(data,2) 1]);

comment=framecomment(comment,functionname);

save([cutfile outsuffix],'data','descriptor','unit','label','comment');
