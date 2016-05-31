function Data = loadcampb(AmpFileName);
% loadcampb Load AG500 complex amplitude data from binary files
% function Data = loadcampb(AmpFileName);
% loadamp: Version 25.6.08
%
%   Description
%       Load AG500 complex amplitude data from the given file
%       format as for linux version of ag500 software as of 6.08
%   ????see burkhards mail??.
%       Returns a 3d data matrix (complex) arranged nsamp*ntrans*nkanal (with ntrans=6 and nkanal=12)
%       Give file name with extension.
%       If file not found Data is returned empty
%
%   See Also
%       LOADPOS LOADAMPB

Ndim=6;     %Number of transmitters
Nchan=12;

%note: header is really 2*int32, tailer 40 * byte
headersize=2;
trailersize=10;

ndcol=Nchan*Ndim;
Ncol=(2*ndcol)+headersize+trailersize;


Data=[];

if (nargin ~= 1),
    error('Syntaxerror: Wrong number of arguments. Try Loadamp(PosFileName)')
end


[fid, msg] = fopen([AmpFileName], 'r');	% open data file
if fid == -1,
    disp([msg ' Filename: ' AmpFileName]);
    return;
end

[RawData, DSize] = fread(fid, inf, 'single');	% read raw data

NumSamples = floor(length(RawData) / Ncol);
fclose(fid);

if mod(length(RawData), Ncol) ~= 0
    disp('WARNING: File length is not a whole-numbered multiple of sample length!!!')
end

Data=(reshape(RawData,[Ncol NumSamples]))';
sindata=Data(:,(headersize+1):(headersize+ndcol));
cosdata=Data(:,(headersize+ndcol+1):(headersize+ndcol+ndcol));

%to return as 3d array uncomment this (could be an option)
sindata=reshape(sindata,[NumSamples Ndim Nchan]);
cosdata=reshape(cosdata,[NumSamples Ndim Nchan]);

Data=complex(cosdata,sindata);
