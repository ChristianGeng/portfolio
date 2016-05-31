function makeposamps_raw(posdir,triallist)
% MAKEPOSAMPS_RAW Calculate posamps, store as raw binary file
% function makeposamps(posdir,triallist)
% makeposamps: Version 8.10.07
%
%   Syntax
%       posdir: Without backslash. Folder directory containin position data. Must contain subdirectory posamps
%
%   See Also MAKEPOSAMPS Store posamps as mat file, CALCAMPS


for iti=triallist
    disp(iti)
    mytrial=int2str0(iti,4);
    pp=loadpos([posdir '\' mytrial]);
    if ~isempty(pp)

        pa=calcamps(pp);

        saveamp([posdir '\posamps\' mytrial '.amp'],pa);
    else
        disp('Trial missing or empty?');
    end;        %pp not empty
end;
