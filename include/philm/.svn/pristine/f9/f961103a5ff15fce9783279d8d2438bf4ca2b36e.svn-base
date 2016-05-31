function getraw4showz(mytrial,mychans,calpath)
% GETRAW4SHOWZ Record rawdata as complex amplitudes on AG500 linux
% function getraw4showz(mytrial,mychans,calpath)
% getraw4showz: Version 14.07.08
%
%   Description
%   Data is stored in current directory as mytrial'.camp'
%       (mytrial 4 digits with leading zeros)
%   mychans: Choice of channels to show in showz (actually irrelevant for
%       the actual recording with getrawdata etc.)
%   calpath: Optional. Determines whether phase values from an existing
%       calibration will be used. Should be name of a directory (without
%       pathchar) below /srv/ftp/data/calibration/
%       Since phases normally don't change much there should be no problem
%       in using an old calibration with this function when doing a sensor
%       text prior to a fresh calibration
%
%   See Also
%       SHOWZ

calbase='-c /srv/ftp/data/calibration/&/TMP00000.tmp/stage2.xml';
ndig=4;

calstring='';

if nargin>2
    calstring=strrep(calbase,'&',calpath);
end;

trialstring=int2str0(mytrial,ndig);

mystat=system(['getrawdata | sincosdemod ' calstring ' > ' trialstring '.camp'])

showz('',mytrial,mychans);


