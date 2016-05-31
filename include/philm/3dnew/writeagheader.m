function writeagheader(fid,S)
% WRITEAGHEADER Write header of AG50x amp and pos files
% function writeagheader(fid,S)
% writeagheader: Version 06.05.2013
%
%   Syntax
%       amp or pos file must be opened (and closed) by calling program
%
%   Description
%       Based on readagheader
%       S is a struct containing fields to be written to the header
%           NumberOfChannels: default to 16
%           fields nchan and samplerate are converted to NumberOfChannels and
%           SamplingFrequencyHz respectively
%       Special fields:
%           vernum: default to '002'
%
%   Updates
%       name of samplerate field in header changed to SamplingFrequencyHz
%
%   See Also READAGHEADER contains Burkhards description of the preliminary
%       format of the header

functionname='writeagheader: Version 06.05.2013';


headerid=agheaderid;
nchan=16;
samplerate=200;
vernum='002';
verlen=length(vernum);
offsetlen=8;
offsetplaceholder='<offset>';   %check it is the right length
nh=length(headerid);

if isfield(S,'vernum')
    if length(vernum)==verlen
        vernum=S.vernum;
        S=rmfield(S,vernum);
    end;
end;

if isfield(S,'nchan')
    S.NumberOfChannels=S.nchan;
    S=rmfield(S,'nchan');
end;
if isfield(S,'samplerate')
    S.SamplingFrequencyHz=S.samplerate;
    S=rmfield(S,'samplerate');
end;
if ~isfield(S,'NumberOfChannels')
    S.NumberofChannels=nchan;
end;
if ~isfield(S,'SamplingFrequencyHz')
    S.SamplingFrequencyHz=samplerate;
end;

%remove further fields that might have been introduced by readagheader
%possible eventually use to override default???
if isfield(S,'headerid')
    S=rmfield(S,'headerid');
end;
if isfield(S,'headerversion')
    S=rmfield(S,'headerversion');
end;
if isfield(S,'dataoffset')
    S=rmfield(S,'dataoffset');
end;
if isfield(S,'ntrans')
    S=rmfield(S,'ntrans');
end;
%this is particularly important because otherwise we end up with
%duplicate fields
if isfield(S,'header')
    S=rmfield(S,'header');
end;



headerstr=[headerid vernum char(10) offsetplaceholder char(10)];

myfields=fieldnames(S);
nfield=length(myfields);

%still not sure looping thru all fields is a good idea
%maybe better to have an explicit list of those that must be written
for ifi=1:nfield
    
    fieldn=myfields{ifi};
    fieldv=S.(fieldn);
    if isnumeric(fieldv)
%default settings of num2str may not always be appropriate
        fieldv=num2str(fieldv);
    end;
    
    headerstr=[headerstr fieldn '=' fieldv char(10)];
end;
headerstr=[headerstr char(10) char(0) char(26)];

mylen=length(headerstr);
mylen=int2str0(mylen,offsetlen);
headerstr=strrep(headerstr,offsetplaceholder,mylen);

fwrite(fid,headerstr,'uchar');
