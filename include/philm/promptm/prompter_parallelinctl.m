function nargout=prompter_parallelinctl(mycmd,arg2)
% prompter_parallelinctl Control input lines of parallel port
% function nargout=prompter_parallelinctl(mycmd,parportin)
%
%   Syntax
%       When command is 'ini' arg2 should be parport object obtained with
%           prompter_getparport
%       parallelinmode must be set in main data structure
%       currently only 'AG500' is supported
%
%   Notes
%       Settings cannot be changed without re-initializing
%           i.e. even if they are changed in the main prompter data structure
%           (currently only parallelinmode) 
%           these settings remain fixed until the next call with command
%           'ini'

persistent parport parallelinmode lines_IN_1 ag500names statuslines


if strcmp(mycmd,'readlines')
nargout=[];
    if ~isempty(parallelinmode)
    nargout=getvalue(lines_IN_1);
end;

end;

if strcmp(mycmd,'getlinenames')
nargout=[];
    if ~isempty(parallelinmode)
    nargout=ag500names;
end;

end;




if strcmp(mycmd,'ini')
    
    P=prompter_gmaind;
    if ~P.daqok
        parallelinmode=''; %prevent any further attempt to access port
        disp('prompter_parallelinctl: Unable to initialize input from parallel port');
        keyboard;
    else    
        parallelinmode=P.parallelinmode;
        parport=arg2;
        if strcmp(parallelinmode,'AG500')
            
            %make this a function like prompter_paralleloutctl???
            lines_IN_1 = addline(parport,[0:3],1,'in');     %input lines on port1; need 4 for ag500 monitoring
            
            
            statnames=char(get(lines_IN_1,'LineName'));
            statnames=strm2rv(statnames,' ');
            
            statuslines=get(lines_IN_1,'Index');
            
            %must match the pin assignment for input lines from port 1
            %the five lines (0:4) of port 1 correspond to pins
            %15 13 12 10 11
            
            %thus Pin 11 is still free for other purposes (according to matlab help Pin
            %11 is hardware inverted)
            
            ag500names=str2mat('psr','attn','sweep','trans');
            A=desc2struct(ag500names);
            nstat=size(ag500names,1);
            
            for ii=1:nstat set(lines_IN_1(ii),'LineName',deblank(ag500names(ii,:))); end;
            
            agstat=getvalue(lines_IN_1);
            
            %binary vector has first element on left, so names should match values
            disp('Parallel in initialized for AG500');
            disp('Current line status');
            disp(statnames);
            disp(strm2rv(ag500names,' '));
            disp(agstat);
        end;
        
        
    end;        %daqok
end;               %ini


