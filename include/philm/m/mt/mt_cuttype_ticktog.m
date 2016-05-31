function mt_cuttype_ticktog
% MT_CUTTYPE_TICKTOG Toggle whether cuttype indication on right of time figure is visible
% function mt_cuttype_ticktog

oncol=[1 0 0];	%fixed to red

hfb=[];
hf=mt_gfigh('mt_f(t)');
if ~isempty(hf) 
   hfb=[hfb;hf];
		axlist='cursor_axis';   
end;

hf=mt_gfigh('mt_sona');
if ~isempty(hf) 
   
   sonalist=mt_gsonaad;
   ns=size(sonalist,1);
   for ii=1:ns
   
   hfb=[hfb;hf];
   axlist=str2mat(axlist,[deblank(sonalist(ii,:)) '_cursor_axis']);
end;

end;

nf=length(hfb);

for ii=1:nf

hf=hfb(ii);

offcol=get(hf,'color');

hh=findobj(hf,'type','axes','tag',deblank(axlist(ii,:)));
tickcol=get(hh,'ycolor');

if all(tickcol==oncol)
   tickcol=offcol;
else
   tickcol=oncol;
end;

set(hh,'ycolor',tickcol);

end;
