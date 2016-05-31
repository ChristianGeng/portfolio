function fpx=fixpdpfp(fid,offset);
% FIXPDPFP Read fp values stored in pdp11 format
% function fpx=fixpdpfp(fid,offset);
% fixpdpfp: Version ??
%
%   uses a dummy file to juggle byte order
%   no error checking!!!

status=fseek(fid,offset,'bof');
temp=fread(fid,4,'uchar');
temp(2)=temp(2)-1;
vv=[3 4 1 2];
temp=temp(vv);
fidd=fopen ('dummy.tmp','w+');
cc=fwrite (fidd,temp,'uchar');
status=fseek(fidd,0,'bof');
fpx=fread(fidd,1,'float');
fclose (fidd);
delete ('dummy.tmp');
