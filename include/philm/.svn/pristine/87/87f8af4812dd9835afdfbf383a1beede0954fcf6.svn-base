function myS=mt_gcsid(fieldname)
% MT_GCSID Get common signal data
% function myS=mt_gcsid(fieldname)
% mt_gcsid: Version 15.4.99
%
%	Syntax
%		Returns common signal data; no input arg returns complete structure
%
%	See Also
%		MT_SCSID for details of field names
%		MT_ORG MT_SSIG MT_GTRID MT_GSIGV

myS=[];
figorgh=mt_gfigh('mt_organization');
saxh=findobj(figorgh,'tag','signal_axis');


mydata=get(saxh,'userdata');


if nargin==0
   myS=mydata;
   return;
end;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
   disp(['mt_gcsid: Bad field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldname);



