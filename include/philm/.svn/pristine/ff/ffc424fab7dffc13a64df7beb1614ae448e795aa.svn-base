function mt_propedit
% MT_PROPEDIT enable/disable property editor by clicking on graphics objects
% function mt_propedit
%
%	Description
%		Activates the property editor for axes and children of axes in MT figures
%			(except for the organization figure)
%		This is intended to allow things like linestyles, axes grids etc. to be chosen by the user
%   Revision 5.04. New version of property editor seems to have undesired
%   side-effects. Try using plotedit instead
%   

figlist=mt_gfigd('figure_list');

nf=size(figlist,1);


for ii=1:nf figh(ii)=mt_gfigh(deblank(figlist(ii,:))); end;

plotedit(figh,'on');

dodo=input('When finished type <enter>');

plotedit(figh,'off');

set(0,'showhidden','on');
hh=findobj('type','figure','handlevisibility','off');
%assume this is the property editor
if ~isempty(hh)
    disp('Make sure the property editor is closed before continuing');
%actually you can ignore this
    dodo=input('When finished type <enter>');
end;

set(0,'showhidden','off');

return;

%=============
%original code with property editor



if myflag
   cbfunc='propedit(gcbo)';
else
   cbfunc='';
end;


for ii=1:nf
   figh=mt_gfigh(deblank(figlist(ii,:)));
   axlist=findobj(figh,'type','axes');
   nax=length(axlist);
   
   for jj=1:nax
      ha=axlist(jj);
      set(ha,'buttondownfcn',cbfunc);
      hc=get(ha,'children');
      nc=length(hc);
      for kk=1:nc
         set(hc(kk),'buttondownfcn',cbfunc);
      end;
   end;
end;
