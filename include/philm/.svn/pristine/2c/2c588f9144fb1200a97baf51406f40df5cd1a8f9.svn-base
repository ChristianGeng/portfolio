function myS=mt_geditd(fieldname)
% MT_GEDITD get edit data
% function myS=mt_geditd(fieldname)
% mt_geditd: Version 01.06.2004
%
% Syntax
%   Returns edit data; no input arg returns complete structure
%		See mt_seditd for list of fields
%
% See Also
%   MT_SEDITD MT_SIGEDIT

myS=[];
figorgh=mt_gfigh('mt_organization');
taxh=findobj(figorgh,'tag','editor_axis');


mydata=get(taxh,'userdata');


if nargin==0
    myS=mydata;
    return;
end;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
    disp(['mt_geditd: Bad field name? ' fieldname]);
    return;
end;

myS=getfield(mydata,fieldname);



