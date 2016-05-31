function P=prompter_gagd(myfield);
% prompter_gagd Get structure with ag500 settings
% function P=prompter_gagd(myfield)
%
%   Syntax
%       If no input argumdent return complete structure
%       see prompter_iniag500fig for overview of main fields


hf=findobj('type','figure','name','AG500mon');

P=get(hf,'userdata');

if ~nargin return; end;

if isfield(P,myfield)
    P=P.(myfield);
else
    disp(['Field ' myfield ' not found in AG data structure']);
    disp('Returned value will be empty');
    keyboard;
    P=[];
end;
