function timeout=prompter_getemaall(quietflag)
% prompter_getemaall Get AG tcpip data stream
% function timeout=prompter_getemaall(quietflag)
% prompter_getemaall Version 11.11.2012
%
%   Syntax
%       quietflag: optional. if true, suppress text output to command window

timeout=0;
bequiet=0;
if nargin bequiet=quietflag; end;

AG=prompter_gagd;

if strcmp(AG.agtriggermode,'manual')
    return;
end;



s=AG.socket;

s=[];       %temporary: also need to incorporate togglestatus
if ~isempty(s)
    sockok=1;
    try
        [active,sample,sweep,dataS,dataC,pos] = getemaall (s,agname);
    catch
        sockok=0;
    end;
else
    sockok=0;
end;

if ~sockok
    
    lidatimeout=200;
    readok=0;
    retry = 0;
    while ~readok
        try
            %timeout variable??
            %       maybe also set to quiet mode, as data will be displayed from
            %       getemaall anyway
            [s,agname] = lida_connect(lidatimeout,1);
            pause(0.02);
            %some way to avoid double read??
            %		[active,sample,sweep,dataS,dataC,pos] = getEmaAll (s);
            %changed to all lower-case names
            [active,sample,sweep,dataS,dataC,pos] = getemaall (s,agname);
            readok=1;
    %not sure this should really ok, if getemaall detects error correctly
            if ((sample==0) & (sweep==0))
                readok=0;
                pause(0.02);
                close(s);
                pause(0.1);
            end;

        catch
            %disp(lasterr);
            retry=retry+1;
            pause(0.02)
            close(s);
            pause(0.02)
            if (retry >9)
                disp(lasterr);
                disp(['prompter_getemaall: No connection??' crlf 'Type return to exit to calling function']);
                disp('If possible, first make sure cs5recorder is running');
                prompter_writelogfile(['!!Timeout on TCPIP connection !!' crlf]);
                
                keyboard;
                timeout=1;
                AG.socket=[];
                prompter_sagd(AG);
                return;
                %original version carried on retrying indefinitely
                %            retry=0;
                
            end
        end
    end
end;

AG.active=active;
AG.sample=sample;
AG.sweep=sweep;
AG.dataS=dataS;
AG.dataC=dataC;
AG.pos=pos;
AG.agname=agname;
AG.socket=s;
if ~bequiet
    pegel=round(eucdistn(dataS*1000,zeros(size(dataS))));
    
    
    disp([agname ': x y z phi theta rms(resid) spare rms(amp)*1000']);
    disp(round([(1:size(pos,1))' pos pegel]));
end;
disp([agname ': Active, samplenum, trialnum : ' int2str([active sample sweep])]);

prompter_sagd(AG);
