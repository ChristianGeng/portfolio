function S=gettdms_chprop(id)
% GETTDMS_CHPROP get channel properties in tdms file
% function S=gettdms_chprop(id)
% gettdms_chprop Version 12.11.2012
%
%   Description
%       id must be a struct with fields named 'Property1' etc.
%       Ignores properties where the name does not give a valid field name
%       for a structure.
%       But changes all '-' in the name to '_'

S=[];

nf=length(id.PropertyInfo);
%disp(nf)

for ifi=1:nf
    pfield=['Property' int2str(ifi)];
    if isfield(id,pfield)
        tmps=id.(pfield);
        
        myname=tmps.name;
        myval=tmps.value;
        if iscell(myval)
            if length(myval)==1
                myval=myval{1};
            end;
        end;
        
        mynamex=myname;
        myname=strrep(myname,'-','_');
        myname=strrep(myname,' ','_');
        if ~strcmp(myname,mynamex)
            disp([pfield '. Changing name from ' mynamex ' to ' myname]);
        end;
        
        %also datatype, cnt, samples
        try
            %        disp(myname);
            %        disp(myval);
            S=setfield(S,myname,myval);
            
        catch
            %       lasterror
            disp(pfield);
            disp('unable to set field');
            disp(myname);
            disp('value is');
            disp(myval);
        end;
    end;
    
end;

