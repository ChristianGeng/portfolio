function cut2matrix_t(cutfile,outsuffix)
% CUT2MATRIX_T Convert segment file to table of observations (grouping based on trial number)
% function cut2matrix_t(cutfile,outsuffix)
% cut2matrix_t: Version 2.2.07
%
%   Description
%       All cutfile entries from same trial are converted to one record
%       column names in output matrix are taken from cut_type_label (or
%       valuelabel structure)
%       with suffixes '_on', '_off', and '_dur'
%       (Currently assumes each segment type occurs only once for each
%       trial; if this occurs a warning is issued (only the first occurrence will be stored))
%
%   See Also
%       CUT2MATRIX groups by labels instead of trials

functionname='cut2matrix_t. Version 2.2.07';


load(cutfile);

labelu=unique(data(:,4));
nlab=size(labelu,1);

labout=cell(nlab,1);

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
    vv=find(labelu(ilab)==data(:,4));
    nv=length(vv);
    datatmp=data(vv,:);
    labtmp=label(vv,:);
%    disp([labtmp num2str(datatmp)]);

    labout{ilab}=labtmp(1,:);       %arbitrary; use first label 
    
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
            disp(['Multiple tokens with same cut type ' int2str(datatmp(ii,3)) ' in record ' int2str(vv(ii)) ' trial ' int2str(datatmp(ii,4))]);
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
label=char(labout);
descriptor=strvcat(don,doff,ddur);
unit=repmat('s',[size(data,2) 1]);

comment=framecomment(comment,functionname);

save([cutfile outsuffix],'data','descriptor','unit','label','comment');
