function mt_sextr(clist,ylimlist);
% mt_sextr Set extremes used for signal scaling
% function mt_sextr(clist,ylimlist);
% mt_sextr: Version 07.10.2000
%
% Syntax
%   clist: String matrix of axes in mt_f(t)
%   ylimlist: nchan*2 matrix of desired min (col.1) and max (col.2) settings
% See also
%   MT_GEXTR: Get extremes. MT_ZOOM2: Zoom up and down MT_HEXTR: Homogenize extremes.

        
hfig=mt_gfigh('mt_f(t)');

ll=size(clist,1);
if (ll==0) return; end;


if (ll~=size(ylimlist,1)) return; end;

ibad=0;
for ich=1:ll
   cl=deblank(clist(ich,:));
   ho=findobj(hfig,'tag',cl,'type','axes');
   if ~isempty(ho)
      if (ylimlist(ich,2)>(ylimlist(ich,1)+(10*eps)))
         set(ho,'ylim',ylimlist(ich,:));
      end;
   else
      disp (['mt_sextr: Bad axes name ' cl]);
      ibad=1;
      
   end;
end
if ibad
   myS=get(hfig,'userdata');
   axislist=myS.axis_name;
   disp('Valid axes are:');
   disp(axislist);
end;
