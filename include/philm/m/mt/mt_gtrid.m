function myS=mt_gtrid(fieldname)
% MT_GTRID Get trial data
% function myS=mt_gtrid(fieldname)
% mt_gtrid: Version 11.4.98
%
%   Syntax
%       Returns trial data; no input arg returns complete structure
%
%   See Also
%       MT_GCSID

myS=[];
figorgh=mt_gfigh('mt_organization');
taxh=findobj(figorgh,'tag','trial_axis');


mydata=get(taxh,'userdata');


if nargin==0
    myS=mydata;
    return;
end;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
    disp(['mt_gtrid: Bad field name? ' fieldname]);
    return;
end;

myS=getfield(mydata,fieldname);



