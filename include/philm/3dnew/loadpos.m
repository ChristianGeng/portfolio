function [Data,varargout] = loadpos(AmpFileName,nchan);
% LOADPOS Load AG50x position data
% function [Data,varargout] = loadpos(PosFileName,nchan);
% loadpos: Version 26.10.2012
%
%   Description
%       Load AG500 position data from the given file (either .mat or raw binary with .pos extension).
%       Returns a 3d data matrix arranged nsamp*npar*nkanal
%       Organisation of second dimension: x, y, z, phi, theta, rms, extra
%       Give file name without extension.
%       If mat file is found, the data variable is read, and the function
%       returns.
%       If .mat file is not found, tries to open .pos file.
%       If the .pos file is in the old headerless format (before mid 2012)
%       then the number of channels can be specified in the optional second input
%       argument.If absent it defaults to the AG500 value of 12.
%       If no mat or pos file is found Data is returned empty.
%
%   Output arguments
%       The second output argument is optional.
%       For raw pos input it is a struct with header information
%       (for old AG500 and early AG501 files it contains default values for
%       nchan and samplerate).
%       For matlab input it is a struct containing all variables from the
%       mat file except the data variable
%
%   Updates
%       02.2012 add optional nchan input argument
%       09.2012 Start preparing for AG501 files with header. Allow optional
%       second output argument for header information
%
%   See Also
%       LOADAMP, READAGHEADER

%default to AG500
if nargout>1 varargout{1}=[]; end;

Ndim=7;     %Number of parameters
Nchan=12;

fileext='.pos';
datatype='single';      %for read from raw binary files
Data=[];


if exist([AmpFileName '.mat'],'file')
    S=load(AmpFileName);
    Data=double(S.data);
    if nargout>1
        S=rmfield(S,'data');
        varargout{1}=S;
    end;
    return;
    
else
    if exist([AmpFileName fileext],'file')
        [fid, msg] = fopen([AmpFileName fileext], 'r');	% open data file
        if fid == -1,
            disp([msg ' Filename: ' AmpFileName]);
            return;
        end
        
        H=readagheader(fid);
        
        [RawData, DSize] = fread(fid, inf, datatype);	% read raw data
        fclose(fid);
        
        if isempty(H)
            if nargin>1
                Nchan=nchan;
            end;
            H.nchan=Nchan;
            H.npar=Ndim;
            H.samplerate=200;
        else
            %preliminary version of header does not specify number of parameters in pos
            %files, but this ought to change
            %        Ndim=H.npar???;
            H.npar=Ndim;
            Nchan=H.nchan;
        end;
        
        
        Ncol=Nchan*Ndim;
        
        
        NumSamples = floor(length(RawData) / Ncol);
        
        if mod(length(RawData), Ncol) ~= 0
            disp('WARNING: File length is not a whole-numbered multiple of sample length!!!')
        end
        
        Data=(reshape(RawData,[Ncol NumSamples]))';
        
        Data=reshape(Data,[NumSamples Ndim Nchan]);
        
        if nargout>1 varargout{1}=H; end;
    else
        disp(['Loadpos: No file ' AmpFileName]);
    end;
    
end;
