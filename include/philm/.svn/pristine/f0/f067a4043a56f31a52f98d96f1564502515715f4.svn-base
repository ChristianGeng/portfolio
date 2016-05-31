function prompter_showg(mys);
% function prompter_showg(mys);

P=prompter_gmaind;

turnoff=P.hidemode;

hfsub=findobj('type','figure','name','Subject');
hfinv=findobj('type','figure','name','Investigator');

hi1=findobj(hfsub,'type','image','tag',P.imageprefix);
hi2=findobj(hfinv,'type','image','tag',P.imageprefix);
hi=[hi1;hi2];

ht=P.texthandle;

if ~isempty(hi) 
    set(hi,'visible','off'); 
hai1=findobj(hfsub,'type','axes','tag',P.imageprefix);
hai2=findobj(hfinv,'type','axes','tag',P.imageprefix);
hai=[hai1;hai2];
set(hai,'visible','off');
end;

set(ht,'visible','off');

mysc=char(mys);
if findstr(P.imageprefix,mysc(1,:))
    
    if ~isempty(hi)
        tmp=strrep(mysc(1,:),P.imageprefix,'');
        imnum=str2num(tmp);
        if ~isempty(imnum)
            if ~isempty(hai)
                imdata=get(hai(1),'userdata'); %in subject figure
                %                keyboard;
                if iscell(imdata)
                    imdata=imdata{imnum};
                    set(hi,'cdata',imdata);
                    
                    set(hi(2),'visible','on');      %investigator
                    set(get(hi(2),'parent'),'visible','on');
                    if ~turnoff
                        set(hi(1),'visible','on');
                        set(get(hi(1),'parent'),'visible','on');
                    end;
                    
                    
                    P.promptmode='image';
                    prompter_smaind(P);
                    drawnow;
                    prompter_updatefigs;
                    return;
                end;
            end;
        end;
    end;
    
end;

%if image display not possible, treat as normal text display

%normal text display


P.promptmode='text';
prompter_smaind(P);


tmpsize=get(ht(1),'userdata');
set(ht,'fontsize',tmpsize);
set(ht,'string',mys);
eee=get(ht(1),'extent');
ppp=get(ht(1),'position');

maxex=max(eee(3:4));
if maxex>1
    disp(['Reducing font to fit. Factor ' num2str(1/maxex)]);
    tmpsize=get(ht(1),'fontsize')*(1/maxex);
    set(ht,'fontsize',tmpsize);
    eee=get(ht(1),'extent');
end;




xe=eee(3);
%disp('extent');
%disp(eee);


halign=get(ht(1),'horizontalalignment');
if strcmp(halign,'left')
    ppp(1)=0.5-xe/2;
else
    ppp(1)=0.5;
end;


set(ht,'position',ppp);

%disp('position')
%disp(ppp);
%disp('axes x/y lim');
%disp([get(gca,'xlim') get(gca,'ylim')]);

%this assumes ht(1) is in the subject figure
set(ht(2),'visible','on');
if ~turnoff
    set(ht(1),'visible','on');
end;

drawnow;
prompter_updatefigs;

if P.compromptflag
    comprompt('prompt',mys);
end;
