function P=sonix_getsettings
% SONIX_GETSETTINGS Get sonix settings
% function P=sonix_getsettings
% sonix_getsettings: Version 07.02.2013
%
%   Description
%       Currently gets the complete struct set up by sonix_ctrl('ini')

P=[];
hf=findobj('type','figure','name','ultrasonix');

if ~isempty(hf)
    P=get(hf(1),'userdata');
end;
