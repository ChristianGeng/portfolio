function mergetable(file1,file2,fileout,labelv,deletestring,replacestring)
% MERGETABLE Merge mat files across columns, matching by label
% function mergetable(file1,file2,fileout,labelv)
% mergetable: Version 30.09.2013
%
%   Description
%       Looks for labels in file2 matching labels in file1
%       Thus records in file2 without a matching record in file1 will be
%       ignored.
%       labelv: Optional. Vector to select columns of label.
%           Default to 1:(length of labels in file1)
%           Note: This is applied AFTER any changes to the label
%           from use of the deletestring/replacestring arguments.
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
%   See Also
%       CUT2MATRIX

functionname='mergetable: version 02.10.2013';

copyfile([file1 '.mat'],[fileout '.mat']);

data=mymatin(file1,'data');
label=mymatin(file1,'label');
descriptor=mymatin(file1,'descriptor');
unit=mymatin(file1,'unit');
comment=mymatin(file1,'comment');


data2=mymatin(file2,'data');
label2=mymatin(file2,'label');
descriptor2=mymatin(file2,'descriptor');
unit2=mymatin(file2,'unit');
comment2=mymatin(file2,'comment');

descriptor=str2mat(descriptor,descriptor2);
%check new descriptor is unique

uu=unique(descriptor,'rows');
if size(uu,1)~=size(descriptor,1)
    disp('descriptors of file1 and file2 have common elements');
    return;
end;


unit=str2mat(unit,unit2);

m1=size(data,1);
n2=size(data2,2);

done2=zeros(1,size(data2,1));
newdat=ones(m1,n2)*NaN;


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
    disp(['mergetable: replacing ' delchar ' with ' repchar]);
    label=cellstr(label);
    label=strrep(label,delchar,repchar);
    label=char(label);
    label2=cellstr(label2);
    label2=strrep(label2,delchar,repchar);
    label2=char(label2);
end;


labl1=size(label,2);
vl=1:labl1;
if nargin>3
    if ~isempty(labelv)
    vl=labelv;
    end;
end;



labl2=size(label2,2);

if labl1~=labl2
    disp(['Note: Different label lengths for file1 and file2 : ' int2str([labl1 labl2])]);
    keyboard;
end;
vx=find(vl>labl2);
if ~isempty(vx)
    vl(vx)=[];
    disp('labelv truncated to match file2');
    disp(vl);
    disp('Consider using a different specification for labelv');
    keyboard;
end;


label2=label2(:,vl);

%should check all labels unique

uu=unique(label(:,vl),'rows');
if size(uu,1)~=size(label,1)
    disp('labels of file1 are not unique');
    return;
end;



for ii=1:m1
    lab1=label(ii,vl);
    vv=strmatch(lab1,label2,'exact');

    if length(vv)==1
        newdat(ii,:)=data2(vv,:);
        done2(vv)=1;
    else
        disp(['label in file2 missing or ambiguous: ' lab1 ' ' int2str(length(vv))]);
    end;
end;

%check records in data2 not transferred


if ~all(done2)
disp('Records not used in file2');
disp(label2(~logical(done2),:));
end;

        
data=[data newdat];

comment=framecomment(comment,'mergetable: comment from first input file');
comment2=framecomment(comment2,'mergetable: comment from second input file');


comment=[comment crlf comment2];
comment=framecomment(comment,functionname);

save(fileout,'data','descriptor','unit','comment','-append');
