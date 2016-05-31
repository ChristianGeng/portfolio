function newcomment=framecomment(oldcomment,functionname);
% FRAMECOMMENT Frame existing comment with function name
% function newcomment=framecomment(oldcomment,functionname);
% framecomment: Version 8.5.08
%
%   Updates
%       5.08 date in both start and end string, and in same line

mydate=[' [' datestr(now,0) ']'];
namestr=['<Start of Comment> ' functionname mydate crlf];
endstr=[crlf '<End of Comment> ' functionname mydate crlf];
%if strcmp(myversion(1),'5')
%   namestr=[namestr datestr(now,0) crlf];
%end;

newcomment=[namestr oldcomment endstr];
