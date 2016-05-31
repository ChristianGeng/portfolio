function prompter_makepromptvisible
% function prompter_makepromptvisible

P=prompter_gmaind;

if strcmp(P.promptmode,'text') 
    ht=P.texthandle;
    set(ht(1),'visible','on'); 
end;

if strcmp(P.promptmode,'image')
hfsub=findobj('type','figure','name','Subject');
    hi=findobj(hfsub,'type','image','tag',P.imageprefix);
    if ~isempty(hi)
        set(hi,'visible','on');
        set(get(hi,'parent'),'visible','on');
    end;
end;


drawnow;
