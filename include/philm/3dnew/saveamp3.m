function saveamp3(AmpFileName,Data,S);
% saveamp3 Save amps in raw binary file
% function saveamp3(AmpFileName,Data,S)
% saveamp3: Version 11.09.2012
%
%   Syntax
%       Data must be 3D array arranged samples, transmitters, sensors
%       specify amp filename with extension (.amp)
%       The optional third parameter should be used for 9-transmitter
%       systems to specify the samplerate to put in the file header
%       as a struct: e.g. set up with S.samplerate=200
%       Default is 200
%       This argument is ignored for 6-transmitter systems
%       In future, it may be possible to include further fields to place in
%       the header of 9-transmitter systems.
%
%   Notes
%       This function replaces saveamp.
%       In order to handle ag500 and ag501 data it is necessary to assume
%       the input data is arranged appropriately.
%       From 9.2012 it will be assumed that 9-transmitter systems have a
%       header
%
%   See Also
%       WRITEAGHEADER

%it might be good if information like this could eventually be included in the header of
%ag501 files:

functionname='SAVEAMP3: Version 11.09.2012';

if (nargin < 2),
    help('SaveAmp');
    error('Syntaxerror: Wrong number of arguments.');
end

Ndim=size(Data,2);     %n transmitters
Nchan=size(Data,3);
Ncol=Nchan*Ndim;

%convert to 2D
    Data=reshape(Data,[size(Data,1) Ncol]);


[fid, msg] = fopen(AmpFileName, 'w');	% open data file
if fid == -1,
   error([msg ' Filename: ' AmpFileName]);
   return;
end

if Ndim==9
%preferably S should already contain the samplerate explicitly
%but if not, writeagheader will use the default of 200Hz
    S.nchan=Nchan;
    writeagheader(fid,S);
end;

%note transpose, as written in column order
mycount = fwrite(fid, Data', 'single');	

fclose(fid);

