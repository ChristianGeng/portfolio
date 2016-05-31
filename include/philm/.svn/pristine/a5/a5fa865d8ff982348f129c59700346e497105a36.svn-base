function myS=mt_gfigd(fieldname)
% MT_GFIGD get figure data
% function myS=mt_gfigd(fieldname)
% mt_gfigd: Version 20.4.98
%
% Syntax
%   Returns figure data; no input arg returns complete structure
%		See mt_sfigd for list of fields
%
% See Also
%   MT_SFIGD, MT_GCSID, MT_GTRID etc.

	myS=[];
	figorgh=mt_gfigh('mt_organization');
   taxh=findobj(figorgh,'tag','figure_axis');
   
        
   mydata=get(taxh,'userdata');
   
        
        if nargin==0
           myS=mydata;
           return;
        end;
        
        fieldlist=fieldnames(mydata);
        
        vi=strmatch(fieldname,fieldlist);
        
        if isempty(vi)
           disp(['mt_gfigd: Bad field name? ' fieldname]);
           return;
        end;
        
        myS=getfield(mydata,fieldname);
        
              
           
