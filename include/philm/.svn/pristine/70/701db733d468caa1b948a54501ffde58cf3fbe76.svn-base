function prompter_evaluserfunc(myfunc,myname);
% PROMPTER_EVALUSERFUNC Evaluate user function
% function prompter_evaluserfunc(myfunc,myname);

if ~isempty(myfunc)
    try
        eval(myfunc);
    catch
        %possible problems parsing log file if it contains error message
        sss=lasterr;
        sss=strrep(sss,char(10),' ');
        sss=strrep(sss,char(13),' ');
        
        prompter_writelogfile(['<Error evaluating user ' myname ' function ' myfunc '>' crlf '<' sss '>' crlf]);
    end;
    
end;
