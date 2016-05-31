function S=parseaginifile(filename)
% PARSEAGINIFILE Parse AG500 or AG501 ini file
% function S=parseaginifile(filename)
% parseaginifile: Version 24.02.2012
%
%   Syntax
%       specifiy filename without extension
%       S is a struct with fields ntrans and nchan
%       (additional fields may be added in due course)
%       If file not found S is empty

S=[];
myname=[filename '.ini'];

if exist(myname,'file')
    ss=file2str(myname);
    vv=strmatch('channel',ss);
    S.nchan=length(vv); %assume nothing more complicated is required
    sss=ss(vv(1),:);
    [mychan,mydata]=strtok(sss);
    mydata=str2num(mydata);
    S.ntrans=length(mydata);
end;
