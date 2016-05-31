function [Data,varargout] = LoadAmp(AmpFileName,dataspec);
% LOADAMP Load AG50x amplitude data
% function [Data,varargout] = LoadAmp(AmpFileName,dataspec);
% loadamp: Version 14.08.2012
%
%   Description
%       Load AG500 amplitude data from the given file (either .mat or raw binary with .amp extension).
%       Returns a 3d data matrix arranged nsamp*ntrans*nkanal
%       Give file name without extension.
%       If mat file is found, the data variable is read, and the function
%       returns.
%       If .mat file is not found, tries to open .amp file.
%       If the .amp file is in the old headerless format (before mid 2012)
%       then the arrangement of the data can be specified in the optional second input
%       argument, arranged [ntrans nsensor].
%       However, if this is not present the function tries to open an ini
%       file of the same name as the amp file.
%       This is parsed to determine the number of sensors (channels) and
%       the number of transmitters.
%       (This is mainly useful to automatically distinguish between old
%       AG500 files with 6 transmitters and preliminary data from the AG501
%       up to about mid 2012)
%       If no header is present, and also no second argument and no ini file is found, then
%       defaults for the AG500 are used (12 channels, 6 transmitters).
%       (For AG501 files the data will have 9 transmitters. The number of
%       channels will depend on the hardware configuration.)
%       If no mat or amp file is found Data is returned empty.
%
%   Output arguments
%       The second output argument is optional.
%       For raw amp input it is a struct with header information
%       (for old AG500 and early AG501 files it contains default values for
%       nchan, ntrans and samplerate).
%       For matlab input it is a struct containing all variables from the
%       mat file except the data variable
%
%   Updates
%       02.2012 handle ag500 and ag501
%       08.2012 Start preparing for AG501 files with header. Allow optional
%       second output argument for header information
%
%   See Also
%       LOADPOS, PARSEAGINIFILE, READAGHEADER

if nargout>1 varargout{1}=[]; end;

%default to AG500
Ndim=6;     %Number of transmitters
Nchan=12;

fileext='.amp';
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
                Ndim=dataspec(1);
                Nchan=dataspec(2);
            else
                %try and read ini file
                S=parseaginifile(AmpFileName);
                if ~isempty(S)
                    Ndim=S.ntrans;
                    Nchan=S.nchan;
                end;
                
            end;
            H.nchan=Nchan;
            H.ntrans=Ndim;
            H.samplerate=200;
        else
            Ndim=H.ntrans;
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
        disp(['Loadamp: No file ' AmpFileName]);
        
    end;
    
end;
