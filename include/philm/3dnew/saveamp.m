function SaveAmp(AmpFileName,Data);
% SaveAmp Save amps in raw binary file
% SaveAmp(AmpFileName,Data)
%
%   Syntax
%       Data can be 2D or 3D array
%	    Column organisation if 2D:
%	    [Chan1_S1, Chan1_S2, Chan1_S3, Chan1_S4, Chan1_S5, Chan1_S6, Chan2_S1, ...]
%       If 3D, 2nd dim is transmitters, 3rd dim is sensors
%	    Resulting binary file will have 72 single values per sample. 

if (nargin ~= 2),
    help('SaveAmp');
    error('Syntaxerror: Wrong number of arguments.');
end

Ndim=6;     %n transmitters
Nchan=12;
Ncol=Nchan*Ndim;

dimin=ndims(Data);
if dimin==3
    
%convert to 2D
    Data=reshape(Data,[size(Data,1) size(Data,2)*size(Data,3)]);
end;

if size(Data,2)~=Ncol
    disp('SaveAmp: Unexpected number of columns');
    disp(size(Data,2));
end;

[fid, msg] = fopen(AmpFileName, 'w');	% open data file
if fid == -1,
   error([msg ' Filename: ' AmpFileName]);
   return;
end

%note transpose, as written in column order
mycount = fwrite(fid, Data', 'single');	

fclose(fid);

