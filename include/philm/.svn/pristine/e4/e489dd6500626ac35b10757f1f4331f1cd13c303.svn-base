function chandle=mt_gcurh
% mt_gcurh Get cursor handles (time display)
% function chandle=mt_gcurh
% mt_gcurh: Version 4.9.98
%
% Purpose
%   Speed up cursor movement by obtaining handles in advance
%   (cursor manipulation functions take the handles as an optional argument)
%
% Syntax
%   returns a 2-colum vector (or matrix), i.e left and right cursors, but not movie cursors!
%
% See also
%   mt_gcurp Get cursor positon
%   mt_scurp Set cursor position
%   mt_gfigd More general access to the data structure where the handles are stored

chandle=mt_gfigd('time_cursor_handles');
chandle=chandle(:,1:2);
