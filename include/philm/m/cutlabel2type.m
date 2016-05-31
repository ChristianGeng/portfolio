function cutlabel2type(cutfile,labellist,typelabel,typelist,retainflag,deletelabelflag)
% CUTLABEL2TYPE Use labels to determine cut type
% function cutlabel2type(cutfile,labellist,typelabel,typelist,retainflag)
% cutlabel2type: Version 24.09.2013
%
%   Syntax
%       cutfile: Note: The input file is modified! (no new output file)
%       labellist, typelist: labellsit is a list of labels (string matrix) to be searched for in
%       cutfile. Whereever a label is found the the cut type is set to the
%       corresponding entry in typelist.
%       retainflag: Optional [0]. If true, only retain data whose cut type
%           has been changed
%       typelabel: If empty use labellist to set new
%           valuelabel.cut_type.label
%       deletelabelflag: Optional [0]. If present and true, delete the
%           string in labellist when found in an existing label

functionname='cutlabel2type: Version 24.09.2103';

label=mymatin(cutfile,'label');
data=mymatin(cutfile,'data');
label=cellstr(label);
comment=mymatin(cutfile,'comment');
valuelabel=mymatin(cutfile,'valuelabel');

nd=size(data,1);

doretain=0;
if nargin>4 
    if ~isempty(retainflag)
    doretain=retainflag; 
    end;
    
end;

dodelete=0;
if nargin>5 dodelete=deletelabelflag; end;

if isempty(typelabel) typelabel=labellist; end;


changeflag=zeros(nd,1);

nl=size(labellist,1);

for ili=1:nl
    mylabel=deblank(labellist(ili,:));
fc=strfind(label,mylabel);
aa=cellfun('isempty',fc);
vv=find(~aa);
nf=length(vv);
data(vv,3)=typelist(ili);
changeflag(vv)=1;
disp([int2str(nf) ' ' mylabel]);
%maybe delete the mylabel string in label???
%label=label(vv,:);
if dodelete
    label=strrep(label,mylabel,'');
end;
end;

label=char(label);

if doretain
    vv=find(changeflag);
    data=data(vv,:);
    label=label(vv,:);
end;

vl=valuelabel.cut_type.label;
vt=valuelabel.cut_type.value;

typelist=typelist(:);
vl=str2mat(vl,typelabel);
vt=[vt;typelist];

if doretain
    vl=typelabel;
    vt=typelist;
end;
[vt,si]=sort(vt);
vl=vl(si,:);
valuelabel.cut_type.label=vl;
valuelabel.cut_type.value=vt;


%sort. and if doretain simply set vt to typelist
comment=framecomment(comment,functionname);


   save(cutfile,'data','label','comment','valuelabel','-append');
   