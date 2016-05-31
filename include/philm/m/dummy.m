function dummy(evalstr)
% DUMMY Gives a separate workspace in which to use keyboard or eval
% function dummy(evalstr)
% dummy: Version 2.2.98
%
%   Description
%       If input argument present tries to evaluate it
%       Otherwise calls keyboard

    if nargin
       if isstr(evalstr)
          %catch errors??
          eval(evalstr);
       end;
    else
        keyboard;
    end;


