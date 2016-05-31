function pdperg2mat(ergfile)
% PDPERG2MAT Convert PDP11 ERG files to MAT
% function pdperg2mat(ergfile)
% PDPERG2MAT: Version 9.7.03
%
%   Syntax
%       Ergfile name without extension.
%       Output file is  erfile'_erg.mat'

%fid=fopen('r:\ergetc1\hta0a1.erg','r');
fid=fopen([ergfile '.erg'],'r');
myhead=fread(fid,8,'int16');
nent=myhead(3);
npar=myhead(4);

%keyboard;

data=zeros(nent,npar);
myoff=npar*4;       %data starts at offset corresponding to lenght of 1 record
for ii=1:nent
for jj=1:npar
data(ii,jj)=fixpdpfp(fid,myoff);
myoff=myoff+4;
end;
end;

data(data==-3333)=NaN;



disp('current offset');
disp(myoff);

myoff=ceil(myoff/512)*512;

stat=fseek(fid,myoff,'bof');

comment=fread(fid,[1 512],'uchar');
comment(comment==0)=[];
comment=char(comment);
disp(comment);

descriptor=cell(npar,1);
unit=cell(npar,1);

for ii=1:npar
    dd=fread(fid,[1 8],'uchar');
    dd(dd==0)=[];

    %descriptors may not always be legal field names
    descriptor{ii}=char(dd);
    uu=fread(fid,[1 8],'uchar');
    uu(uu==0)=[];
    unit{ii}=char(uu);
end;
%keyboard
descriptor=char(descriptor);
unit=char(unit);
disp([descriptor repmat(' ',[npar 1]) unit]);

fclose(fid);
save([ergfile '_erg'],'data','descriptor','unit','comment');
