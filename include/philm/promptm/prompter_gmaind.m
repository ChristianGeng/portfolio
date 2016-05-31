function P=prompter_gmaind(myfield);
% prompter_gmaind Get structure with main settings
% function P=prompter_gmaind(myfield)
%
%   Syntax
%       If no input argument return complete structure
%       see prompter_ini_base for overview of main fields


hf=findobj('type','figure','name','Subject');

P=get(hf,'userdata');

if ~nargin return; end;

if isfield(P,myfield)
    P=P.(myfield);
else
    disp(['Field ' myfield ' not found in main data structure']);
    disp('Returned value will be empty');
    keyboard;
    P=[];
end;
