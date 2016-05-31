function cut2matrix_g(cutfile,outsuffix,grouptype)
% CUT2MATRIX_G Convert segment file to table of observations using grouping segment
% function cut2matrix_g(cutfile,outsuffix,grouptype)
% cut2matrix_g: Version 24.8.07
%
%   Description
%       All cutfile entries within the same grouping cut are converted to one record
%       Column names in output matrix are taken from cut_type_label (or valuelabel structure)
%       with suffixes '_on', '_off', and '_dur'
%       (Currently assumes each segment type occurs only once for each
%       record; if this occurs a warning is issued (only the first occurrence will be stored))
%       First checks the labels of the grouping segments are unique. If
%       this is not the case the program terminates (use cleanmarkerfile
%       beforehand to check for this)
%
%   Updates
%       19.2.07 corrected error with label variable in first version (of 14.2.07)
%       24.8.07 Check for cases where same segment is within more than one
%       grouping cut. This can happen where there are multiple grouping
%       cuts per trial, and these overlap.
%       In this case the program terminates. Use cut2matrix (group by label
%       instead)

%
%   See Also CUT2MATRIX, CUT2MATRIX_T, CLEANMARKERFILE

functionname='cut2matrix_g: Version 24.8.07';


load(cutfile);

vv=find(data(:,3)==grouptype);
datagrp=data(vv,:);
labelgrp=label(vv,:);


labelu=unique(labelgrp,'rows');
nlab=size(labelu,1);

if nlab~=size(labelgrp,1)
    disp('Labels of grouping cut are not unique');
    disp('Check with cleanmarkerfile');
    keyboard;
    return;
end;


typeu=unique(data(:,3));
ntype=length(typeu);

if exist('valuelabel','var')
    cut_type_label=valuelabel.cut_type.label;
    cut_type_value=valuelabel.cut_type.value;
end;


dataon=ones(nlab,ntype)*NaN;
dataoff=ones(nlab,ntype)*NaN;
datadur=ones(nlab,ntype)*NaN;

%check segment already found in another grouping cut
datachk=zeros(size(data,1),1);


for ilab=1:nlab

       vv=find(data(:,4)==datagrp(ilab,4) & data(:,1)>=datagrp(ilab,1) & data(:,2)<=datagrp(ilab,2));
    disp(labelu(ilab,:));
    nv=length(vv);

    if any(datachk(vv))
        disp('Segments are in more than one grouping segment');
        disp('Unable to continue')
        disp('Use cut2matrix instead');
        keyboard;
        return
    end;
    datachk(vv)=1;
    
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
            disp(['Multiple tokens with same cut type ' int2str(datatmp(ii,3)) ' in record ' int2str(vv(ii))]);
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
label=labelgrp;
descriptor=strvcat(don,doff,ddur);
unit=repmat('s',[size(data,2) 1]);

comment=framecomment(comment,functionname);

save([cutfile outsuffix],'data','descriptor','unit','label','comment');
