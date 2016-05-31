function mapmat2newvaluelabel(matfile,matfileout,myfield,newvaluelabel);
% MAPMAT2NEWVALUELABEL Adjust parameter values in mat file to conform to new valuelabel
% function mapmat2newvaluelabel(matfile,matfileout,myfield,newvaluelabel);
% mapmat2newdescriptor: Version 15.09.2011
%
%   Syntax
%       myfield: descriptor entry specifying parameter to adjust, e.g.
%           'cut_type'
%           Input file must have this field in the valuelabel variable.
%           newvaluelabel should be a struct with fields label and value
%           e.g as returned by some versions of anagest_clust
%           or by extracting from an existing valuelabel variable:
%           S=valuelabel.cut_type;

functionname='mapmat2newvaluelabel: Version 15.09.2011';

olddata=mymatin(matfile,'data');
label=mymatin(matfile,'label');
descriptor=mymatin(matfile,'descriptor');
oldvaluelabel=mymatin(matfile,'valuelabel');


comment=mymatin(matfile,'comment');

ipi=strmatch(myfield,descriptor,'exact');
if length(ipi)~=1
    disp('no descriptor entry matching desired field');
    disp(myfield);
    keyboard;
    return;
end;

Sold=oldvaluelabel.(myfield);
oldlabel=Sold.label;
oldvalue=Sold.value;

newlabel=newvaluelabel.label;
newvalue=newvaluelabel.value;

nout=length(newvalue);

data=olddata;
data(:,ipi)=NaN;    %to track values not specified in new valuelabel

newnotinold=logical(zeros(nout,1));
oldnotinnew=logical(ones(length(oldvalue),1));

for ii=1:nout
    mylabel=deblank(newlabel(ii,:));
    vv=strmatch(mylabel,oldlabel,'exact');
    if length(vv)==1
        oldval=oldvalue(vv);
        vx=find(olddata(:,ipi)==oldval);
        data(vx,ipi)=newvalue(ii);
        oldnotinnew(vv)=0;
        
    else
        if length(vv)==0
            newnotinold(ii)=1;
        else
%probably should not be possible for this to occur
            disp('label match ambiguous?');
            disp(mylabel);
            keyboard;
            return;
        end;
    end;
end;
%
if any(newnotinold)
    disp('No match found in old file for these entries');
    disp(newlabel(newnotinold,:));
end;
if any(oldnotinnew)
    disp('These entries in old file have not been mapped to new values');
    disp('The corresponding records will be deleted from the data variable');
    disp(oldlabel(oldnotinnew,:));
end;

vn=find(isnan(data(:,ipi)));
data(vn,:)=[];
label(vn,:)=[];

valuelabel=oldvaluelabel;
valuelabel.(myfield)=newvaluelabel;
comment=framecomment(comment,functionname);
copyfile([matfile '.mat'],[matfileout '.mat']);

save(matfileout,'data','label','valuelabel','comment','-append');
