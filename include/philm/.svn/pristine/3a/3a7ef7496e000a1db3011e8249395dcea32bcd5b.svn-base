function mapmat2newdescriptor(matfile,matfileout,newdescriptor,newunit);
% MAPMAT2NEWDESCRIPTOR Rearrange mat file to conform to new descriptor
% function mapmat2newdescriptor(matfile,matfileout,newdescriptor,newunit);
% mapmat2newdescriptor: Version 15.09.2011
%
%   Syntax
%       newunit: Optional. If not present units from input file are used

functionname='mapmat2newdescriptor: Version 15.09.2011';

olddata=mymatin(matfile,'data');
olddescriptor=mymatin(matfile,'descriptor');
oldunit=mymatin(matfile,'unit');

useoldunit=1;
if nargin>3
    unit=newunit;       %check right length??
    useoldunit=0;
end;

if useoldunit unit=cell(nout,1); end;

comment=mymatin(matfile,'comment');

nout=size(newdescriptor,1);

data=ones(size(olddata,1),nout)*NaN;

newnotinold=logical(zeros(nout,1));
oldnotinnew=logical(ones(size(olddescriptor,1),1));

for ii=1:nout
    mydescrip=deblank(newdescriptor(ii,:));
    vv=strmatch(mydescrip,olddescriptor,'exact');
    if length(vv)==1
        data(:,ii)=olddata(:,vv);
        oldnotinnew(vv)=0;
        if useoldunit
            unit{ii}=oldunit(vv,:);
        end;
        
    else
        if length(vv)==0
            newnotinold(ii)=1;
        else
%probably should not be possible for this to occur
            disp('descriptor match ambiguous?');
            disp(mydescrip);
            keyboard;
            return;
        end;
    end;
end;
%
if any(newnotinold)
    disp('No match found in old file for these entries');
    disp(newdescriptor(newnotinold,:));
    if useoldunit
        disp('Please re-start providing the newunit input argument');
        return;
    end;
end;
if any(oldnotinnew)
    disp('These entries in old file have not been moved to new file');
    disp(olddescriptor(oldnotinnew,:));
end;

descriptor=newdescriptor;
unit=char(unit);
comment=framecomment(comment,functionname);
copyfile([matfile '.mat'],[matfileout '.mat']);

save(matfileout,'data','descriptor','unit','comment','-append');
