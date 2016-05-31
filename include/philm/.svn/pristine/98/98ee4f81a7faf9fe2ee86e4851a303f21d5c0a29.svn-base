function mt_seditd(myfield,mydata)
% MT_SEDITD Set edit data
% function mt_seditd(myfield,mydata)
% mt_seditd: Version 01.06.2004
%
%   Syntax
%       If only one input arg, sets the whole userdata structure
%
%   Fields
%       editS.sig2edit='';
%       editS.sig4replace='';
%       editS.editmarker='o';
%       editS.unsavededits=0;
%       editS.interpmethod='linear';
%       editS.equations=''; %structure
%
%   See Also
%       MT_GEDITD MT_SIGEDIT

myS=[];
figorgh=mt_gfigh('mt_organization');
saxh=findobj(figorgh,'tag','editor_axis');

if nargin==1
    if isstruct(myfield)
        myS=myfield;
        set(saxh,'userdata',myS);
    end;
    return;
end;




myS=get(saxh,'userdata');

fieldlist=fieldnames(myS);
vi=strmatch(myfield,fieldlist);
if isempty(vi)
    disp(['mt_sfigd: Bad field name; ' myfield]);
    return;
end;


myS=setfield(myS,myfield,mydata);

set(saxh,'userdata',myS);


