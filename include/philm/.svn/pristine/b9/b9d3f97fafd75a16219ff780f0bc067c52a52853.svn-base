function txt=readtxtf(filename);
% READTXTF Read ascii file into row vector
% function txt=readtxtf(filename);
% readtxtf: Version 1.9.97
%
% See Also
%    file2str: Reads into string matrix
%
% Notes
%   If file error, then argument returned is numeric, not string

	fid=fopen(filename,'r');
        if fid <=2
           disp (['readtxtf: ASCII file not found ' filename]);
           txt=fid;
           return;
        end;

        txt=fread (fid,'uchar');
        txt=setstr(txt');
        fclose (fid);

