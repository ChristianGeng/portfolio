function add2philb(mystring);
% ADD2PHILB Add string to philinp input buffer
% function add2philb(mystring);
% add2philb: Version 27.10.98
%
%   Description
%       One way of giving a kind of macro facility

global PHILCBUFFER

if size(mystring,1)~=1 return; end;
if ~ischar(mystring) return; end;

try
   tmp=PHILCBUFFER;
   tmp=[tmp mystring];
   PHILCBUFFER=tmp;
catch
   disp('add2philb: Unable to add string to buffer');
   disp(lasterror);
end;
