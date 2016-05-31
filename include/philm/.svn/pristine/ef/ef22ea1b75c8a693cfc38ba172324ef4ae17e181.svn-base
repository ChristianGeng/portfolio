function mtxmenucb
% MTXMENUCB Call back from menus
%	See also MT_INIMENU MT_SKEY

%in practice it can't be as simple as this
mychar=get(gcbo,'userdata');
mylabel=get(gcbo,'tag');
%add2philb([mychar '#']);
%keyboard;
%dummy
%disp(['menu callback: ' mychar]);

mytrace{1,1}=mylabel;

finished=0;
myobj=gcbo;
ipi=1;
while ~finished
   myparent=get(myobj,'parent');
   if strcmp(get(myparent,'type'),'uimenu')
      ipi=ipi+1;
      mytrace{ipi,1}=get(myparent,'tag');
      myobj=myparent;
   else
      finished=1;
   end;
end;

mytrace=flipud(mytrace);

try
helpme('mtcmdhlp',mytrace{:});
%disp(mytrace);
catch
   disp('unable to do help for ');
   disp(mytrace);
end;

        