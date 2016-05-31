function sonix_setsettings(P,myval)
% SONIX_SETSETTINGS Set fields in sonix struct
% function sonix_setsettings(P,myval)
% sonix_setsettings: Version 07.02.2013
%
%   Syntax
%       If one input argument, this represents the complete struct
%       (as returned by sonix_getsettings without any field specification)
%       If two arguments, first argument is field and second argument is
%       new value
%
%   Notes
%       This function is used to change the struct set up by
%       sonix_ctrl('ini'). It doesn't change hardware settings on the
%       ultrasound machine itself


hf=findobj('type','figure','name','ultrasonix');

if isempty(hf)
    disp('sonix_setsettings: Sonix not initialized?');
    keyboard;
    return;
end;

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
        disp(['Field ' myfield ' not found in sonix data structure']);
        disp('No changes will be made');
        keyboard;
    end;
    return;
end;

disp('sonix_setsettings: Wrong number of input arguments?');
