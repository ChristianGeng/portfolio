function catmat(infiles,outfile,traceflag);
% CATMAT Concatenate mat files
% function catmat(infiles,outfile,traceflag);
% catmat: Version 11.1.08
%
%   Syntax
%       infiles: list of files to concatenate, as string matrix
%       outfile: name of output file
%
%   Description
%       The data and label variables are concatenated. An extra column is
%       added to data, with the number of the input file in the input list
%       The list of source files is placed in valuelabel.sourcefile.label
%       (and the corresponding number in valuelabel.sourcefile.value)
%       If the optional traceflag is present and zero, then the additional
%       column is suppressed
%
%   Updates:
%       1.08 traceflag added

functionname='CATMAT: Version 11.1.08';

dotrace=1;
if nargin>2 dotrace=traceflag; end;

nfile=size(infiles,1);

file1=deblank(infiles(1,:));
disp(file1);

copyfile([file1 '.mat'],[outfile '.mat']);

data=mymatin(file1,'data');
label=mymatin(file1,'label');
comment=mymatin(file1,'comment');
valuelabel=mymatin(file1,'valuelabel');
descriptor=mymatin(file1,'descriptor');
unit=mymatin(file1,'unit');

data=[data ones(size(data,1),1)];

for ifi=2:nfile
    myfile=deblank(infiles(ifi,:));
    disp(myfile);
    data2=mymatin(myfile,'data');
    label2=mymatin(myfile,'label');
    data2=[data2 ones(size(data2,1),1)*ifi];
    data=[data;data2];
    label=str2mat(label,label2);
end;



comment=['See valuelabel.sourcefile.label for list of input files' crlf comment];
comment=framecomment(comment,functionname);

valuelabel.sourcefile.label=infiles;
valuelabel.sourcefile.value=(1:nfile)';

if ~dotrace
    data(:,end)=[];
end;
if dotrace
    descriptor=str2mat(descriptor,'sourcefile');
    unit=str2mat(unit,' ');
end;


save(outfile,'data','label','comment','valuelabel','descriptor','unit','-append');
