function setcontextmenu(handlelist,parentfig);
nl=length(handlelist);
hf=parentfig;
for ii=1:nl
    hll=handlelist(ii);

    cmenu=uicontextmenu('parent',hf,'userdata',hll);
set(hll,'uicontextmenu',cmenu);
hitem=uimenu(cmenu,'label',get(hll,'tag'),'callback','inspect(get(get(gcbo,''parent''),''userdata''))');
%hitem=uimenu(cmenu,'label',get(hll,'tag'),'callback',{@setcontextmenucb,hll});
end;

function setcontextmenucb(cbobj,cbdata,hll)
disp('in context callback')
keyboard;
inspect(hll);
%set(hll,'linewidth',2);
