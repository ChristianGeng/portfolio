function mt_setvd(axlist,trajlist,vlength,copre);
% MT_SETVD Turn on Cartesian vector display in mtnew
% function mt_setvd(axlist,trajlist,vlength,copre);
% mt_setvd: Version 28.11.12
%
%	Syntax
%		axlist: List of axes in the mt_xy figure
%			If missing or empty vector display is turned on in all axes
%			in the mt_xy figure
%		trajlist: List of trajectories. Corresponds to the trajectory names
%			used when initializing the xy axes
%			If missing or empty vector display is turnded on for all trajectories.
%			If a non-empty argument is supplied, be careful if the axes
%			have different trajectories (call mt_setvd separately for each
%			axis if necessary)
%		vlength: Length of vector. Optional; defaults to 5
%		copre: Common part of the names of the orientation vectors. Default
%			to 'o'
%
%	Notes
%		Currently assumes the Cartesian orientation vectors have suffixes
%		ox, oy, oz
%		This is actually a bad choice because the standard names in the mat
%		files is 'orix' etc.
%		In the latter case call like this: mt_setvd([],[],[],'ori')
%
%	Updates
%		3.10 make common part of vector names configurable
%
%	See Also MT_GXYAD

axuse=[];
if nargin>0 axuse=axlist; end;
%get all axes
if isempty(axuse) axuse=mt_gxyad; end;

nax=size(axuse,1);

vuse=5;
if nargin>2 
	if ~isempty(vlength)
	vuse=vlength; end;
end;


%make this configurable?
colist='xyz';
nco=length(colist);
coprefix='o';
if nargin>3 coprefix=copre; end;



for iax=1:nax
	myax=deblank(axuse(iax,:));
	trajuse=[];
	if nargin>1 trajuse=trajlist; end;
	if isempty(trajuse) trajuse=mt_gxyad(myax,'trajectory_names'); end;

	mysiglist=cellstr(trajuse);

	for ico=1:nco
		myco=colist(ico);
		mt_sxyadv(myax,[myco '_mode'],'signal_data',[myco '_spec'],char(strcat(mysiglist,coprefix,myco)))
	end;

	%use this to scale vector length
	mt_sxyadv(myax,'xform',int2str(vuse));
	mt_sxyad(myax,'v_mode','cartesian')


end;
