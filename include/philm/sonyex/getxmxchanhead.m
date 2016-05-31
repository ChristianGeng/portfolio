function CC=getxmxchanhead(fid,myoffset,nchan);
% GETXMXCHANHEAD Get channel header of Sony EX xmx file
% function CC=getxmxchanhead(fid,myoffset,nchan);
% getxmxchanhead: Version 6.1.08
%
%   See Also GETXMX

%position file
status=fseek(fid,myoffset,'bof');

CC=cell(nchan,1);

for ichan=1:nchan



[tmp,count]=fread(fid,34,'*uchar');

vp=find(tmp==0);
C.channeltitle=(char(tmp(1:(vp(1)-1))))';

[tmp,count]=fread(fid,2,'int16');

C.inputmoduletype=tmp(1);
C.inputmodulesubtype=tmp(2);

[tmp,count]=fread(fid,10,'*uchar');
vp=find(tmp==0);
%seems this might be empty (default to V??)
tmpstr=(char(tmp(1:(vp(1)-1))))';
if isempty(tmpstr) tmpstr='V'; end;
C.engunits=tmpstr;

[tmp,count]=fread(fid,2,'int16');

C.inputrangeindex=tmp(1);
%tmp(2) is just padding

[tmp,count]=fread(fid,7,'int32');

C.mgnum=tmp(1);
C.imnum=tmp(2);
C.imchannum=tmp(3);

%next 4 longs reserved

[tmp,count]=fread(fid,3,'single');

C.samplerate=tmp(1);
C.calslope=tmp(2);
C.caloffset=tmp(3);

[tmp,count]=fread(fid,6,'int32');

C.xyzdir=tmp(1);
C.xyzpos=tmp(2);

%next 4 longs are reserved

CC{ichan}=C;
end;
