function promptimagestif2mat(tifpath,matname,nfiles);
% PROMPTIMAGESTIF2MAT Convert prompt images to single mat file
% function promptimagestif2mat(tifpath,matname,nfiles);
% promptimagestif2mat: Version 3.4.08
%
%   Description
%       read individual tif files of prompts. store as single cell array
%       for use in prompter_parallel_trigin etc.
%       tifpath: Common part of tif file number without 'page' number
%       Basic idea is to set up a PDF file with one page per stimulus. Then
%       use 'save as' in full version of Acrobat to store each page as
%       single tif file

functionname='promptimagestif2mat: Version 3.4.08';

comment=['tifpath: ' tifpath];
comment=framecomment(comment,functionname);

%number of digits for page number, adjust leading zeros in tifpath if
%necessary
ndig=length(int2str(nfiles));

data=cell(nfiles,1);
for ii=1:nfiles 
disp(ii);
    y=imread([tifpath int2str0(ii,ndig) '.tif']); 
    data{ii}=flipdim(y,1);
end;
save(matname,'data','comment');
