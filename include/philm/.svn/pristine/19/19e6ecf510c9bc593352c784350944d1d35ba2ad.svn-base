function makestart4rtmon(stats)
% MAKESTART4RTMON Compute start position and store in rtmon_cfg
% function makestart4rtmon(stats)
% makestart4rtmon: Version 3.10.08
%
%   Description
%       Uses stats2start_cartf to compute start positions for use by tapad from
%       statistics provided e.g by show_trialox. Stores the result in rtmon_cfg
%       stats must be a 3-dimensional array with records (trials) as 1st
%       dimension, coordinates (orientation as unit vector) as 2nd
%       dimension and sensors as 3rd dimension
%
%   See Also STATS2START_CARTF SHOW_TRIALOX SHOWSTATS

startpos=stats2start_cartf(stats);
try
save('rtmon_cfg','startpos','-append');
catch
    disp('Unable to store start positions to rtmon_cfg');
    disp(lasterr);
    keyboard;
    return;
end;
