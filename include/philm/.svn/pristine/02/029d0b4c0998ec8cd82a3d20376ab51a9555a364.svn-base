function prompter_sonixwrite
% PROMPTER_SONIXWRITE Prompter interface to sonix_ctrl('getframedata')
% function prompter_sonixwrite
% prompter_sonixwrite: Version 08.02.2013

U=sonix_getsettings;
P=prompter_gmaind;

ndig=4;     %configurable??

%must be called after prompter_nextstim
myname=[U.filenamebase '_' int2str0(P.irun-1,ndig)];
U.currentfile=myname;
U.item_id=P.logtext_trial;  %matches what is written in log file. This will be written in the mat info file that goes with the raw data
sonix_setsettings(U);
filelength=sonix_ctrl('getframedata',U.datatype,myname);

mymess=[myname ' : ' int2str(filelength) ' bytes'];
U=sonix_getsettings;
if filelength==0
    mymess=[mymess '. ' U.message];
    prompter_writelogfile(mymess);
else
    %may need additional formatting
    mymess=[mymess crlf U.message]; %may contain header if replaymode == header2message
    
end;
set(U.titlehandle,'string',mymess,'interpreter','none');
%maybe optionally read data, or just header ....
