function prompter_autonext(myarg)
% function prompter_autonext(myarg)
% If no input argument check for cancellation
% If any input argument start autonext mode

P=prompter_gmaind;
htinfo=P.infohandle;
hfinv=htinfo(2);

mymode='check';
if nargin mymode='start'; end;

if strcmp(mymode,'start')
    set(hfinv,'userdata',0);    %may have been an inadvertent click before    
    myrep=abartstr('Starting autonext mode. Continue?','n');
    myrep=lower(myrep);
    if ~(myrep=='y')
        disp('autonext mode not started');
        return;
    end;
    
    [abint,abnoint,abscalar,abnoscalar]=abartdef;
    
    P.autonext=1;
    set(hfinv,'backgroundcolor',P.autonextbackgroundcolor);    
    P.autodelay=abart('Inter-trial interval',P.autodelay,0,1000,abnoint,abscalar);
    P.logtext_sup=[P.logtext_sup '<Autonext mode started. Inter-trial interval ' num2str(P.autodelay) '>' crlf];
    disp('Click in highlighted code text in Investigator figure to exit from autonext mode');
    prompter_smaind(P);
    disp('Hit any key to continue');
    pause;
    
    return;
else
    %default is check, and cancel if necessary
%hfinv=findobj('type','figure','Name','Investigator');
    if P.autonext
        autochk=get(hfinv,'userdata');
        if autochk
            P.autonext=0;
            set(hfinv,'userdata',0);
    set(hfinv,'backgroundcolor','none');    
            P.logtext_sup=[P.logtext_sup '<Autonext mode stopped>' crlf];
            prompter_smaind(P);
        end;
    end;
end;
