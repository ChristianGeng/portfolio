function [mylabel,myvalue]=getvaluelabel(myfile,myfield);
% GETVALUELABEL Retrieve value-label pairs for parameters in mat files
% function [mylabel,myvalue]=getvaluelabel(myfile,myfield);
% getvaluelabel: Version 15.10.08
%
%   Description
%       If no output arguments displays values and labels
%
%   See Also SHOW_VALUELABEL
%
%	Updates
%		10.08 correct logic if valuelabel is present, but the wanted field
%		is only present as old-style additional variable

lab=[];
val=[];

warning off;
S=mymatin(myfile,'valuelabel');
warning on;

if ~isempty(S)
    if isfield(S,myfield)
        try
            lab=S.(myfield).label;
            val=S.(myfield).value;
        catch
            disp(['getvaluelabel: Problem getting fields for ' myfield]);
            if nargout
                myvalue=[];
                mylabel=[];
            end;
            
            return;
        end;
    end;
    
end;
if isempty(lab)
    %try and retrieve old-style separate variables
    lab=mymatin(myfile,[myfield '_label']);
    val=mymatin(myfile,[myfield '_value']);
end;

if size(val,1)==1 val=val'; end;

if size(val,1)~=size(lab,1)
    disp(['getvaluelabel: Length of value and label do not match for ' myfield]);
    if nargout
        myvalue=[];
        mylabel=[];
    end;
    
    return;
end;

if isempty(val)
    disp(['getvaluelabel: Problem getting fields for ' myfield]);
    if nargout
        myvalue=[];
        mylabel=[];
    end;
    return;
end;

if nargout
    mylabel=lab;
    myvalue=val;
else
    disp(strcat(int2str(val),' :',lab));
end;
