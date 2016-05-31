function ylimlist=mt_gextr(clist);
% mt_gextr Get extremes used for signal scaling
% function ylimlist=mt_gextr(clist);
% mt_gextr: Version 07.10.2000
%
%	Syntax
%		clist: String matrix of axes in mt_f(t)
%		ylimlist: nchan*2 matrix of current min (col.1) and max (col.2) settings
%			Returns NaNs if axes name not found (ylimlist is empty if clist is empty)
%	See also
%   mt_sextr: Set extremes. mt_zoom2: zoom up and down

hfig=mt_gfigh('mt_f(t)');
ylimlist=[];

ll=size(clist,1);
if (ll==0) return; end;
ylimlist=zeros(ll,2);

ibad=0;
for ich=1:ll
   cl=deblank(clist(ich,:));
   ho=findobj(hfig,'tag',cl,'type','axes');
   if ~isempty(ho)
      ylimlist(ich,:)=get(ho,'ylim');
   else
      disp (['mt_gextr: Bad axes name ' cl]);
      ylimlist(ich,:)=[NaN NaN];
      ibad=1;
   end;
end

if ibad
   myS=get(hfig,'userdata');
   axislist=myS.axis_name;
   disp('Valid axes are:');
   disp(axislist);
   
end;
