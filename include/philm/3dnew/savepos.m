function SavePos(PosFileName,Data);
% SAVEPOS Save AG500 position data
% function SavePos(PosFileName,Data);
% savepos: Version 12.9.06
%
%       Save AG500 position data to the given file.
%       If filename has no extension, try to save a MAT file
%       If filename has extension .pos, store in binary file with 84 single precision values per sample.
%       Data input must be a 3D data matrix arranged nsamp*7*12 (i.e sensors as 3rd dimension)
%       Organisation of second dimension: x, y, z, phi, theta, rms, extra


if (nargin ~= 2),
    help('SavePos');
    error('Syntaxerror: Wrong number of arguments.');
end

Ndim=7;     %3+2+2
Nchan=12;
Ncol=Nchan*Ndim;

fileext='.pos';

dimin=ndims(Data);

if isempty(findstr(fileext,PosFileName))
    try
        data=single(Data);
        %temporary, assume pos file already exists
        % in future input should be able to be a structure with all variables (but
        % only in v7??)
        %        save(PosFileName,'data','-append','-v6');
        if exist([PosFileName '.mat'],'file')
            save(PosFileName,'data','-append');
            disp('savepos: appending to existing mat file');
        else
            disp('savepos: writing to new mat file');
            save(PosFileName,'data');
        end;    
        return;
    catch
        disp(['No MAT file ' PosFileName ' ?']);
    end;
    
else
    
    if dimin==3
        
        %convert to 2D
        Data=reshape(Data,[size(Data,1) size(Data,2)*size(Data,3)]);
    end;
    
%    keyboard;
    if size(Data,2)~=Ncol
        disp('SavePos: Unexpected number of columns');
        disp(size(Data,2));
    end;
    
    [fid, msg] = fopen(PosFileName, 'w');	% open data file
    if fid == -1,
        error([msg ' Filename: ' PosFileName]);
        return;
    end
    
    %note transpose, as written in column order
    mycount = fwrite(fid, Data', 'single');
    
    fclose(fid);
    
end;
