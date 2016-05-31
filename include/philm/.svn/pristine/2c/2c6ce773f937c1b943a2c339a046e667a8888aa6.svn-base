function paramsub(infile,outfile,a1,a2,a3,a4,a5,a6,a7,a8,a9)
% PARAMSUB Substitute parameters in command file
% function paramsub(infile,outfile,a1,a2,a3,a4,a5,a6,a7,a8,a9)
% paramsub: Version 17.7.97
%
% Syntax
%   infile: input text file. Parameters must currently be called 'P1' etc.
%   outfile: output text file with parameters replaced by strings in a1 etc.
%   Note: nothing to stop strings being multiline
%   Not yet fully recursive. But lower number strings can include reference to higher number parameters
%   Could be done more elegantly with varargin in matlab 5
%   or maybe use string matrices

%

        intxt=readtxtf(infile);
        np=nargin-2;
        for ii=1:np
            target=[quote 'P' int2str(ii) quote];
            eval(['intxt=strrep(intxt,target,a' int2str(ii) ');']);
        end;
	fid=fopen(outfile,'w');
        if fid <=2
           disp (['paramsub: Unable to open output file ' outfile]);
           return;
        end;

        status=fwrite (fid,intxt,'uchar');
        fclose (fid);
