function prompter_dotrafficlights(myfield);
% function prompter_dotrafficlights(myfield);
% myfield must be 'stop', 'go' or 'getready'

P=prompter_gmaind;
%disp(myfield);
%P.promptmode
TL=P.TL;
tlcol=TL.(myfield);
ht=P.texthandle;
if strcmp(P.promptmode,'text')
    oldcol=get(ht(1),'edgecolor');
    if any(oldcol~=tlcol) set(ht,'edgecolor',tlcol); end;
end;
if strcmp(P.promptmode,'image')
%    keyboard;
    hai=findobj('type','axes','tag',P.imageprefix);
    oldcol=get(hai(1),'color');
    if any(oldcol~=tlcol) set(hai,'color',tlcol); end;
    %    oldcol=get(figh(1),'color');
    %    if any(oldcol~=tlcol) set(figh,'color',tlcol); end;
end;
