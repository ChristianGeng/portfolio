function commandout=mtkcomm(command,key,defcmd)
% MTKCOMM mt user commands, common
% function mtkcomm(command,key,defcmd)
% mtkcomm: Version 20.09.20101
%
%	Description
%		Handles mt common commands, i.e commands available at all levels of the programm
%		e.g help, keyboard, macro commands
%		Allows command input from uicontrol list box when the "what" command (usually the '?' key)
%		is used at an program prompt
%
%	Syntax
%		key: the structure giving the commands available to the calling function (see MT_SKEY)
%		defcmd: Optional. Default command to return when the "what" command is used to
%				trigger uicontrol list dialog input. Defaults to the first fieldname of "key".
%
%	Updates
%		3.2010 Indicate the location of the pdf manual as the browser does
%		not always seem to open it correctly
%		8.2010 Make sure user sees error message if eval command causes an
%		error
%       9.2011 make sure early versions don't refer to stack field of
%       lasterror

persistent K M k_names
kname='common';
if isempty(K)
    myS=load('mt_skey',['k_' kname]);
    K=getfield(myS,['k_' kname]);
    clear myS;
    k_names=mymatin('mt_skey','k_names');
    mlock;   
end;

if nargout commandout=0;end;

myver=version;


if command==K.global_help
    helpfile=which('mtnew_help.pdf');
    disp('mtnew documentation');
    disp('If the manual does not open automatically in the browser');
    disp('open this file by hand in the Acrobat reader: ');
    disp(helpfile);
    try
        %version 6 tries to open in help window if -browser switch is not used
        if myver(1)>'5'
            stat=web(['file:///' helpfile],'-browser');
            if stat disp('Problem opening browser for PDF documentation?'); end;    
        else
            stat=web(['file:///' helpfile]);
        end;
        %      help mtnew;
        %      type mt_skey;
        %         type mt_help;
    catch
        
        disp('Sorry! Full documentation not accessible via browser');
        disp('Try opening this file by hand directly in the Acrobat reader:');
        disp(helpfile);
        disp(lasterr);
    end;
    return;   
end

if command==K.local_help
    ktmp=kname;
    if nargin>1
        ktmp=evalin('caller','kname','kname');
    end;
    
    try
        mytrace=getfield(k_names,ktmp);
        mytrace=cellstr(rv2strm(mytrace));
        helpme('mtcmdhlp',mytrace{:});
    catch
        disp('Unable to provide local help for');
        disp(mytrace);
        disp(lasterr);   
    end;
    
    
end;


if command==K.what
    if nargin<2 key=K; end;
    %9.99 "what" command triggers uicontrol list dialog input
    
    
    %   disp(key);
    c=struct2cell(key);
    lc=size(c,1);
    clist=c;		%the commands are actually the numeric equivalent of the key pressed
    
    myfields=fieldnames(key);
    for ii=1:lc c(ii)={setstr(c{ii})}; end;
    %   cstr=[char(myfields) (blanks(lc))' char(c)];
    cstr=[char(c) (blanks(lc))' char(myfields)];
    
    setchoice=1;
    
    if nargin>2
        ipick=strmatch(defcmd,myfields);
        if ~isempty(ipick) setchoice=ipick(1);end;
    end;
    
    [myselection,selectok]=listdlg('liststring',cstr,'selectionmode','single','initialvalue',setchoice,'promptstring','Command list');
    
    if nargout
        if selectok commandout=clist{myselection};end;
    end;
    
    return;
    
end;


%keyboard=======================
if command==K.keyboard
    disp ('Keyboard mode: type <RETURN> to return');
    dummy;
    return;   
end

%pass command to evaluate function
if command==K.eval_command
    evalstr=philinp('Command for eval: ');
    try   
        eval(evalstr);
    catch
        disp('Problem with evaluation in mt common command?')
        lasterrorstruct=lasterror;
        disp(lasterrorstruct.message);
        disp(lasterrorstruct.identifier);
        %not available in older versions
        if isfield(lasterrorstruct,'stack')
            mystack=lasterrorstruct.stack;
            nstack=length(mystack);
            for istack=1:nstack
                disp([mystack(istack).file ' ' mystack(istack).name ', line ' int2str(mystack(istack).line)]);
            end;
        end;
        
        disp('Execution will continue after typing ''return''');
        disp('but this is not recommended.');
        disp('Type ''dbquit'' to exit here');
        disp('close all figures before restarting mtnew');
        keyboard;
        return;   
    end
end;

%12.2000
%evaluate variable now simply adds string to command buffer
%i.e acts like a kind of keyboard macro
%avoid having to use add2philb in the string itself
%macro variables can be defined using the v command
%e.g M.m1='help'

if command==K.eval_variable
    %use abartstr and fieldnames
    if isstruct(M)
        fieldlist=fieldnames(M);
        abscalar=1;nowhite=1;
        myfield=abartstr('Macro command name',fieldlist{1},fieldlist,abscalar,nowhite);
        tmp=getfield(M,myfield);
        if isstr(tmp)
            if size(tmp,1)==1
                try
                    add2philb(tmp);
                catch
                    disp('Problem passing macro to command buffer')
                    disp(lasterr);
                    
                end;
                
            end;	%size
        end;	%string
    end;	%isstruct
    return;
    
end;


