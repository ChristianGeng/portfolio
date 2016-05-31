function iocode=showferr(fid,info);
% SHOWFERR Examine ferror
% iocode=showferr(fid,info);
%   if error, display info string, return error number

[message errnum]=ferror(fid);
if errnum
    disp (['File id ' int2str(fid)]);
    disp (info);
    disp(message);
    disp(errnum);
end
iocode=errnum;
