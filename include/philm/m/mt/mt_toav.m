function mt_toav(axlist)
% MT_TOAV Toggle organization axes visibility (and adjust subplot positions)
% function mt_toav(axlist)
% mt_toav: Version 30.9.99
%
%  Syntax
%	axlist is list of axes in the mt_organization figure
%	initial arrangement (from top to bottom):
%    'signal_axis'
%    'figure_axis' (not visible)
%    'cut_file_axis'
%    'trial_axis'
%    'current_cut_axis'

mylist=char(axlist);	%may be cell array

figh=mt_gfigh('mt_organization');

allh=findobj(figh,'type','axes');
axname=char(get(allh,'tag'));

curvis=get(allh,'visible');

ndo=size(mylist,1);

for ii=1:ndo
   vv=strmatch(deblank(mylist(ii,:)),axname);
   if ~isempty(vv)
      for jj=1:length(vv)
         oldvis=curvis{vv(jj)};
         if strcmp(oldvis,'on')
            curvis{vv(jj)}='off';
		disp(['mt_toav: ' axname(vv(jj),:) ' off']);
         else
            curvis{vv(jj)}='on';
		disp(['mt_toav: ' axname(vv(jj),:) ' on']);
         end;
      end;
   end;
end;

von=strmatch('on',curvis);
non=length(von);
voff=strmatch('off',curvis);
noff=length(voff);

axpos=subp_pos(non);
for ii=1:non
	set(allh(von(ii)),'visible','on');
	ch=get(allh(von(ii)),'children');
	set(ch,'visible','on');
	
   set(allh(von(ii)),'position',axpos(ii,:));
end;

for ii=1:noff
	set(allh(voff(ii)),'visible','off');
	ch=get(allh(voff(ii)),'children');
	set(ch,'visible','off');

end;

