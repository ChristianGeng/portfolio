P.figurebasecolor=get(hfsub,'color');
P.promptmode='text';
figh=[hfsub hfinv];
set(figh,'userdata',P);

tlcolor.stop=[1 0 0];
tlcolor.go=[0 1 0];
tlcolor.getready[1 1 0];

function dotrafficlights(tlcol,ht,figh);
P=get(figh(1),'userdata');
if strcmp(P.promptmode,'text')
    oldcol=get(ht(1),'edgecolor');
    if any(oldcol~=tlcol) set(ht,'edgecolor',tlcol); end;
end;
if strcmp(P.promptmode,'image')
    oldcol=get(figh(1),'color');
    if any(oldcol~=tlcol) set(figh,'color',tlcol); end;
end;

in showg
if previous mode image and new mode text, set fig colors to figure base color
    