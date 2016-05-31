function myS=mt_getft(fieldname)
% mt_getft get f(t) figure data
% function myS=mt_getft(fieldname)
% mt_getft: Version 25.9.98
%
% Syntax
%   Returns figure data of mt_f(t); no input arg returns complete structure
%  myS=struct('signal_name',siglist,'axis_name',axislist,'panel_number',panellist);
%	3.2002 pair_list added
%		structure also includes: active_flag, sub_cut_flag, bookmark
%
% See Also
%   mt_setft

	myS=[];
	figh=mt_gfigh('mt_f(t)');
   
        
   mydata=get(figh,'userdata');
   
        
        if nargin==0
           myS=mydata;
           return;
        end;
        
        fieldlist=fieldnames(mydata);
        
        vi=strmatch(fieldname,fieldlist);
        
        if isempty(vi)
           disp(['mt_getft: Bad field name? ' fieldname]);
           return;
        end;
        if length(vi)~=1
           disp(['mt_getft: Ambiguous field name? ' fieldname]);
           return;
        end;
        
        myS=getfield(mydata,fieldlist{vi});
        
              
           
