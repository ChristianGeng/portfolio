function loadpalate3(palatefile,xy_axes,contour_tag)
% LOADPALATE3 Show palate contour in xy figure; 3D version 
% function loadpalate3(palatefile,xy_axes,contour_tag)
% loadpalate3: Version 22.7.03
%
%   Notes
%       In fact any appropriate contour can be used
%       x/y/z coordinates must be in first three columns of 'data' (or x/y
%       in first two)
%       Assumes that xy views in mtnew are normally set up as underlyingly
%       3D (even if only a 2D view is shown), with matching arrangement of
%       the x, y and z axes
%       'unit' must also be defined (should be 'cm' or 'mm')
%
%   Syntax
%		palatefile: optional, defaults to 'mypalate.mat'
%		xy_axes: optional. Default to 'xy'. (Not needed at all if xy figure only has one axes)
%		contour_tag: optional. Defaults to 'palate_contour. Only needed if more than one contour
%			is to be used (and if its properties need to be manipulated)
%
%   See Also
%       MT_SXYV Sets view of axes in MT xy figure, e.g xy, yz, xz

oldf=gcf;
olda=gca;

hf=mt_gfigh('mt_xy');
if isempty(hf)
   disp('loadpalate: No xy figure?');
   return;
end;

myfile='mypalate';
if nargin myfile=palatefile; end;

try
load(myfile);
catch
   disp('loadpalate: Unable to load file?');
   return;
end;


if ~exist('data','var')
   disp('loadpalate: No data variable');
   return;
end;

if ~exist('unit','var')
   disp('loadpalate: No unit variable');
   return;
end;



myax='xy';
if nargin>1 myax=xy_axes;end;
if isempty(myax) myax='xy';end;
%check if only one axes anyway??

axlist=mt_gxyad;
if size(axlist,1)==1
   myax=deblank(axlist);
end;



hh=findobj(hf,'type','axes','tag',myax);

if isempty(hh)
   disp('loadpalate: Bad axes name?');
   return;
end;


xpec=mt_gxyad(myax,'x_spec');


dataunit=mt_gsigv(xpec(1,:),'unit');
dataunit=upper(deblank(dataunit));

datascale=1;
if strcmp(dataunit,'CM') datascale=100;end;
if strcmp(dataunit,'MM') datascale=1000;end;


punit=upper(deblank(unit(1,:)));
pscale=1;
if strcmp(punit,'CM') pscale=100;end;
if strcmp(punit,'MM') pscale=1000;end;


myscale=pscale/datascale;

data=data/myscale;
   
   
figure(hf);
axes(hh);

mytag='palate_contour';
if nargin>2 mytag=contour_tag;end;


%could also check unit variable
if size(data,2)>2
hl=line(data(:,1),data(:,2),data(:,3));
else
hl=line(data(:,1),data(:,2));
end;



set(hl,'color','w','linewidth',2,'tag',mytag);

figure(oldf);
axes(olda);
