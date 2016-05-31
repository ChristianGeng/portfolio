function mt_sfigd(myfield,mydata)
% MT_SFIGD Set figure data
% function mt_sfig(myfield,mydata)
% mt_sfigd: Version 18.03.2009
%
%	Fields
%		figS.session_number=MT_SESSION_NUMBER;
%		figS.figure_list='mt_f(t)';
%		figS.foreground
%		figS.cursor_status=[0 1];
%		figS.cursor_colours='rg'; %for fixed/free
%		figS.time_cursor_handles=[curlh currh];
%		figS.xy_contour_handles;
%		figS.xy_vector_handles;
%		figS.autoimageupdateflag
%		figS.xycursor_settings
%
%	Updates
%		3.09 Set complete structure if one input argument
%			xycursor_settings added to list of fields
%
%	See Also
%		MT_GFIGD, MT_GCSID, MT_SSIG etc.

myS=[];
figorgh=mt_gfigh('mt_organization');
saxh=findobj(figorgh,'tag','figure_axis');

%set complete structure
if nargin==1
	if isstruct(myfield)
		set(saxh,'userdata',myfield);
		return;
	end;
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


