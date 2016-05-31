function A=prompter_gwaved
% function S=prompter_gwaved
% Get wave data for start and end signals (may eventually allow optional argument for specific
% field)

hf=findobj('type','figure','name','Investigator');
haxi=findobj(hf,'type','axes','tag','wave');

A=get(haxi,'userdata');
