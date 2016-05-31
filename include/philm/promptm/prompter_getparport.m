function parport=prompter_getparport;
% function parport=prompter_getparport;

P=prompter_gmaind;
daqok=1;
myaddress=P.lptaddress;
if isempty(myaddress) myaddress='LPT1'; end;
if strcmp(P.paralleloutmode,'porttalk')
    if ischar(myaddress)
        disp('Address must be numeric in porttalk mode');
        parport=[];
        daqok=0;
        return;
    end;
    
    try
        lptwrite(myaddress,0); %reset all lines as test for accessibility
    catch
        daqok=0;
        disp(['Parallel port not accessible at ' num2str(myaddress) ' with lptwrite/porttalk']);
        parport=[];
    end;
    if daqok parport=myaddress; end;
else
    if ~ischar(myaddress)
        disp('LPT address must be string in simple mode');
        parport=[];
        daqok=0;
        return;
    end;
        
    try
        parport = digitalio('parallel',myaddress);
    catch
        daqok=0;
        parport=[];
        disp(['Parallel port not available at ' myaddress]);
        disp('Check you have administrator privileges');
    end;
end;

P.daqok=daqok;
prompter_smaind(P);
