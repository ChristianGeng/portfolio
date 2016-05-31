function prompter_updatefigs
%function prompter_updatefigs
%currently does nothing

return;	%disabled
hfi=findobj('type','figure','name','Investigator');

if isempty(hfi) return; end;        %assume separate figure not needed

hfs=findobj('type','figure','name','Subject');

ppps=get(hfs,'position');
pppi=get(hfi,'position');

set(hfs,'position',ppps);	%must have been a typo here
set(hfi,'position',pppi);

return;

figure(hf);

refresh(hf);
drawnow;

%ppos=get(0,'pointerlocation');
%fpos=get(hf,'position');
%newpos=ppos;
%newpos=[fpos(1)+fpos(3)/2 fpos(2)+fpos(4)/2];
%set(0,'pointerlocation',newpos);
hf=findobj('type','figure','name','Subject');
figure(hf);
refresh(hf);
drawnow;
%set(0,'pointerlocation',ppos);

