function S=prompter_gstimd;
% function S=prompter_gstimd
% Get stimulus variables (may eventually allow optional argument for specific
% field)

hf=findobj('type','figure','name','Subject');
hax=findobj(hf,'type','axes','tag','text');

S=get(hax,'userdata');
