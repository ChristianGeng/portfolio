function makeposamps(posdir,ampdir,triallist)
% MAKEPOSAMPS Calculate posamps
% function makeposamps(posdir,ampdir,triallist)
% makeposamps: Version 8.10.07
%
%   Syntax
%       posdir: Without backslash. Folder directory containing position data
%                   Subdirectory posamps must be present inside posdir
%       ampdir: Without backslash
%
%   Notes
%       Normally the data in ampdir should be that used to calculate  the
%       positions in posdir.
%       Currently the ampdir is not actually used (it is just used to
%       provide values for the additional variables like samplerate,
%       descriptor, dimension, etc.)
%       but in future, recalculation of rms values may be included, in
%       which case it will be essential

%
%   See Also MAKEPOSAMPS_RAW Store posamps as raw binary file, CALCAMPS

ndig=4;

functionname='makeposamps: Version 08.10.07';

newcomment=['makeposamps: pos file: ' posdir crlf 'makeposamps: amp file ' ampdir crlf];

posampdir=[posdir pathchar 'posamps'];
%keyboard;
%mkdir(posampdir);
posampdir=[posampdir pathchar];
ampdir=[ampdir pathchar];
posdir=[posdir pathchar];

for iti=triallist
    disp(iti)
    mytrial=int2str0(iti,ndig);

    
    
    pp=loadpos([posdir mytrial]);
    if ~isempty(pp)

    copyfile([ampdir pathchar mytrial '.mat'],[posampdir mytrial '.mat']);
        data=calcamps(pp);

        comment=mymatin([posdir mytrial],'comment');
        comment=[newcomment comment];
        comment=framecomment(comment,functionname);
        
        save([posampdir mytrial],'data','comment','-append');
    else
        disp('Trial missing or empty?');
    end;        %pp not empty
end;
