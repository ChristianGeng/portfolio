function mt_sxyl(axesname,axisletter,mylimits)
% MT_SXYL Set xy limits
% function mt_sxyl(axesname,axisletter,mylimits)
% mt_sxyl: Version 13.12.2000
%
% Syntax
%   axesname: Axes name in xy figure (currently restricted to one only)
%	 axisletter: Label of axis for which limits are to be set
%	 mylimits: 2-element vector specifying limits ([min max])
%		If mylimits is an axis label then the scaling of this axis and the 
%		axisletter axis is made the same
%
% See Also
%	MT_SEXTR for f(t) figure. mt_gxyl to get values (not yet implemented)

if nargin <3
   help mt_sxyl;
   return;
end;

if size(axesname,1) ~=1 return; end;


hxyf=mt_gfigh('mt_xy');
if isempty(hxyf) return; end;
hxya=findobj(hxyf,'tag',axesname,'type','axes');
if isempty(hxya) return; end;

alist='xyz';   
labellist=cell(3,1);

for ii=1:3
   hs=get(hxya,[alist(ii) 'label']);
   hs=get(hs,'string');
   if isempty(hs) hs=alist(ii);end;
   labellist{ii}=hs;
end;

targeti=strmatch(axisletter,labellist);
if length(targeti)~=1
   disp(['mt_sxyl: unknown or ambiguous target axis label > ' axisletter]);
   return;   
end;



if isstr(mylimits)
   likeaxis=mylimits(1);
   likei=find(alist==likeaxis);
   
   likei=strmatch(mylimits,labellist);
   if length(likei)~=1
      disp(['mt_sxyl: unknown or ambiguous reference axis label > ' mylimits]);
      return;   
   end;
   
   
   daspect=get(hxya,'dataaspectratio');
   daspect(likei)=daspect(targeti);
   set(hxya,'dataaspectratio',daspect);
   
else
   
   
   if length(mylimits)~=2 return; end;
   
   
   
   try
      set(hxya,[alist(targeti) 'lim'],mylimits);
   catch
      disp(['mt_sxyl: Unable to set ' mylimits '(' alist(targeti) 'axis) limits in ' axesname]);
   end;
end;

