function Data = LoadAmpb(AmpFileName);
% LOADAMPB Load AG500 amplitude data from raw binary files
% function Data = LoadAmpb(AmpFileName);
% loadamp: Version 27.1.06
%
%   Description
%       Load AG500 amplitude data from the given file
%       Expected is a binary file with 72 single values per sample.
%       Returns a 3d data matrix arranged nsamp*ntrans*nkanal (with ntrans=6 and nkanal=12)
%       Give file name with extension.
%       If file not found Data is returned empty
%
%   See Also
%       LOADPOS

Ndim=6;     %Number of transmitters
Nchan=12;
Ncol=Nchan*Ndim;


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

    %to return as 3d array uncomment this (could be an option)
    Data=reshape(Data,[NumSamples Ndim Nchan]);

