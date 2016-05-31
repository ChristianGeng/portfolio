function prompter_smaind(P,myval);
% prompter_smaind Set structure with main settings
% function prompter_smaind(P,myval)
%
%   Syntax
%       If one input argument, this represents the complete struct
%       (as returned by prompter_gmaind without any field specification)
%       If two arguments, first argument is field and second argument is
%       new value


hf=findobj('type','figure','name','Subject');

if nargin==1
    if isstruct(P)
        set(hf,'userdata',P);
    else
        disp('Input argument must be struct if no second argument');
        keyboard;
    end;
    return;
    
end;

if nargin==2
    myfield=P;
    P=get(hf,'userdata');
    if isfield(P,myfield)
        P.(myfield)=myval;
        set(hf,'userdata',P);
        
    else
        disp(['Field ' myfield ' not found in main data structure']);
        disp('No changes will be made');
        keyboard;
    end;
    return;
end;

disp('prompter_smaind: Wrong number of input arguments?');
