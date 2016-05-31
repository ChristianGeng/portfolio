function insert_t(mainfile,markerfile,gettype,typelabel)
% INSERT_T Insert segments of desired type from marker cut file into main cut file
% function insert_t(mainfile,markerfile,gettype,typelabel)
% insert_t: Version 20.9.2005
%
%   Syntax
%       mainfile: file into which segments from markerfile will be inserted
%       markerfile
%       gettype: Cut type to move from marker file to main file, e.g 7 (or
%       column vector
%       typelabel: Name of this cut type, e.g 'sentence', or string matrix same
%       length as gettype

[status,msg]=copyfile([mainfile '.mat'],[mainfile '.mak']);
if ~status disp(msg); end;
load(mainfile)

%markerfile=[mainfile markerext];
mdata=mymatin(markerfile,'data');
mlabel=mymatin(markerfile,'label');

ntype=length(gettype);
for ii=1:ntype
vv=find(mdata(:,3)==gettype(ii));
disp(['Inserting ' int2str(length(vv)) ' segments of type ' int2str(gettype(ii))]);

data=[data;mdata(vv,:)];
label=str2mat(label,mlabel(vv,:));

end;

[data,label]=sortcut(data,label);

cut_type_value=[cut_type_value;gettype];	%assumes row vector
cut_type_label=str2mat(cut_type_label,typelabel);

save(mainfile,'data','label','cut_type_value','cut_type_label','-append');
