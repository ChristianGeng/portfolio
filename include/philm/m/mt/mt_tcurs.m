function curfree=mt_tcurs(curh,freespec);
% mt_tcurs toggle cursors fixed/free
% function curfree=mt_tcurs(curh,freespec);
% mt_tcurs: Version 17.4.2009
%
% Syntax
%   curh: two-column vector (or matrix) with handles of cursors. Optional. Use to speed up the function
%   freespec: Optional. Use to initialize fix/free state of the cursors.
%             must be 2-element vector.0=fixed, 1=free.
%             if present but length ~= 2, current status reported in curfree
%             If freespec is absent, the status of the cursors is simply toggled
%
%	Updates
%		3.09
%			adjust linestyle and visibility of cursors in xy figure:
%				fixed cursors have no lines (just markers), and the vector
%				cursor is not visible
%
% See also
%   mt_gcurh: To get cursor handles, mt_gfigd and mt_sfigd to access cursor variables in figure axis

%
status=0;
if nargin < 1 curh=mt_gcurh;end;

if nargin > 1
	status=length(freespec)~=2;
end;

%determine current status


curfree=mt_gfigd('cursor_status');



if status return;end;
if nargin>1
	curfree=freespec;
else
	curfree=1-curfree;
end;
mt_sfigd('cursor_status',curfree);
colbuf=mt_gfigd('cursor_colours');


c1=curfree+1;
set (curh(:,1),'Color',colbuf(c1(1)));
set (curh(:,2),'Color',colbuf(c1(2)));

[xyindex,sfxy,timestampxy,xycontourh,xycontourhv]=mt_gxycd;
if ~isempty(xyindex)

	%rows are contour linetype, contour marker, vector linetype vector marker. Columns are free, fixed
	%original settings:
	%xycursor_settings={'-','none';'o','o';'-','none';'o','none'};

	xycs=mt_gfigd('xycursor_settings');


	freep=find(curfree);


	fixedp=find(~curfree);

	set(xycontourh(:,freep),'linestyle',xycs{1,1},'marker',xycs{2,1});
	set(xycontourh(:,fixedp),'linestyle',xycs{1,2},'marker',xycs{2,2});

	%xy display may be active without vector display
	if all(ishandle(xycontourhv(:)))
		set(xycontourhv(:,freep),'linestyle',xycs{3,1},'marker',xycs{4,1});
		set(xycontourhv(:,fixedp),'linestyle',xycs{3,2},'marker',xycs{4,2});

	end;

end;
