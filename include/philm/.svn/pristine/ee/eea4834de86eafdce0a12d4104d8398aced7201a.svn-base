function prompter_writelogfile(mystring);
% function prompter_writelogfile(mystring);

P=prompter_gmaind;
%disp('--------- log message --------');
disp(['Log: ' mystring]);
%disp('------------------------------');
status=fwrite(P.logfilefid,mystring,'uchar');
ht=P.infohandle;
set(ht(3),'string',['Log: ' mystring]);

    %check status??
    