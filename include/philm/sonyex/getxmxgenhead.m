function H=getxmxgenhead(fid);
% GETXMXGENHEAD Get generic header of Sony EX xmx file
% function H=getxmxgenhead(fid);
% getxmcgenhead: Version 6.1.08
%
%   See Also GETXMX

[tmp,count]=fread(fid,3,'int32');
H.uniquefiletype=tmp(1);
H.fileversion=tmp(2);
H.filesubversion=tmp(3);

[tmp,count]=fread(fid,8,'int16');

H.creationdatetime=tmp(1:7)';

[tmp,count]=fread(fid,7,'int32');

H.numchan=tmp(1);
H.offsetchanhead=tmp(2);
H.offseteventhead=tmp(3);
H.triggerflag=tmp(4);
H.preposthistorypercent=tmp(5);
H.totalevents=tmp(6);
H.mikeflag=tmp(7);

[tmp,count]=fread(fid,1,'single');

H.mikesamplerate=tmp(1);

[tmp,count]=fread(fid,4,'int32');

H.bitsinuse=tmp(1);

%(remaining 3*int32 are spare bytes);

