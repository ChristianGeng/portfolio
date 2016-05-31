function mt_sxyv(axisname,myview)
% MT_SXYV Set xy view
% function mt_sxyv(axisname,myview)
% mt_sxyv: Version 20.3.2002
%
%	Syntax
%		axisname: Axis name in xy figure (currently restricted to one only)
%		myview: String specifying the arrangement and direction of the 3 possible axes
%			as a 2D view, e.g 'xy','yz'. Prefix axis letter with '-' to reverse direction,
%			e.g '-xy', 'y-z','-x-z'.
%			To get the default 3D view use '3D'.
%			For compatibility with an older version, a numeric value is also accepted to
%			select some of the main views:
%				1=xy; 2=xz; 3=yz; 4=yx; 5=3d
%
%	Notes
%		Some of the views seem to end up with the axis labels in strange locations.
%		The only way round this at the moment is to re-order the assignment of the signals
%		to matlabs x, y and z axes when setting up the xy figure, so that unproblematic views
%		can be used.

if nargin ~=2
   help mt_sxyv;
   return;
end;

if size(axisname,1) ~=1 return; end;


hxyf=mt_gfigh('mt_xy');
if isempty(hxyf) return; end;
hxya=findobj(hxyf,'tag',axisname,'type','axes');
if isempty(hxya) return; end;

% Old View definitions

%1=xy; 2=xz; 3=yz; 4=yx; 5=3d
vs=str2mat('xy','xz','yz','yx','3d');

l=size(vs,1);
%    viewbuf=[0 90;0 0;90 0;90 -90;-37.5 30];

if isnumeric(myview)
   if (myview<1) | (myview>l) return; end;
   
   myview=vs(myview,:);
end;

c=makeviews;
vs=c(:,1);         

vv=strmatch(myview,vs,'exact');
if isempty(vv)
   disp(['mt_sxyv: Unknown view: ' myview]);
   return;
end;
vv=vv(1);		%unnecessary?    



set(hxya,'view',c{vv,2});

myvec=c{vv,3};
if length(myvec)==3
   set(hxya,'cameraupvector',myvec);
end;



function c=makeviews

c{1,1}='xy';c{1,2}=[0 90];
c{2,1}='xz';c{2,2}=[0 0];
c{3,1}='yx';c{3,2}=[90 -90];
c{4,1}='yz';c{4,2}=[90 0];
c{5,1}='zx';c{5,2}=[180 0];c{5,3}=[1 0 0];
c{6,1}='zy';c{6,2}=[-90 0];c{6,3}=[0 1 0];

c{7,1}='-xy';c{7,2}=[180 -90];
c{8,1}='-xz';c{8,2}=[180 0];
c{9,1}='-yx';c{9,2}=[-90 90];
c{10,1}='-yz';c{10,2}=[-90 0];
c{11,1}='-zx';c{11,2}=[0 0];c{11,3}=[1 0 0];
c{12,1}='-zy';c{12,2}=[90 0];c{12,3}=[0 1 0];

c{13,1}='x-y';c{13,2}=[0 -90];
c{14,1}='x-z';c{14,2}=[180 0];c{14,3}=[0 0 -1];
c{15,1}='y-x';c{15,2}=[90 90];
c{16,1}='y-z';c{16,2}=[-90 0];c{16,3}=[0 0 -1];
c{17,1}='z-x';c{17,2}=[0 0];c{17,3}=[-1 0 0];
c{18,1}='z-y';c{18,2}=[90 0];c{18,3}=[0 -1 0];

c{19,1}='-x-y';c{19,2}=[180 90];
c{20,1}='-x-z';c{20,2}=[0 0];c{20,3}=[0 0 -1];
c{21,1}='-y-x';c{21,2}=[-90 -90];
c{22,1}='-y-z';c{22,2}=[90 0];c{22,3}=[0 0 -1];
c{23,1}='-z-x';c{23,2}=[180 0];c{23,3}=[-1 0 0];
c{24,1}='-z-y';c{24,2}=[-90 0];c{24,3}=[0 -1 0];
c{25,1}='3d';c{25,2}=[-37.5 30];

