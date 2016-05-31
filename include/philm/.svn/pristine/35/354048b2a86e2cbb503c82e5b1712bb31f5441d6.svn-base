function comprompt(mycmd,arg2,arg3);
% COMPROMPT Definitions for controlling VT220 serial terminal  (on COM1)
% function comprompt(mycmd,arg2,arg3);
% COMPROMPT: Version 5.10.03
%
%   Syntax
%       mycmd: 'ini', 'message','prompt','reset','keyboard'
%           ini: needs number of lines per prompt, and maximum number of
%           columns in prompt line as 2nd and 3rd arguments, respectively
%           message: Displays message on top line of screen. Default is '
%           !!RECORDING!!
%           Use the second input argument for alternative message (main
%           use: use an empty string to clear the message line)
%           prompt: display the prompt given in the second input argument
%           keyboard: Enter keyboard mode. Can be used for customizing the
%           display by hand, or by calling an m-file
%               The most important settings are stored as persistent
%               variables in the structures Screen, Message and Prompt

persistent comport Message Prompt Screen

myport='COM1';
if nargin<1 mycmd='keyboard'; end;

esc=char(27);

bold=[esc '[1m'];

%other attributes
% 0 = all off
% 4 = underline
% 5 = blinking
% 7 reverse

%double width (single height) : esc # 6
%single width (single height) : esc # 5


defaultmessage='!! R E C O R D I N G !!';


switch lower(mycmd)
    case 'ini'
        if nargin<3
            disp('Need line and column arguments');
            keyboard;
        end;
        
        
        %Currently, the line and column at which display of the prompt text
        %will start is calculated here during initialization, and not
        %changed afterwards
        %However, it would be easy enough to change so that each individual
        %prompt is centered on the screen
        
        nline=arg2;     %number of lines per prompt
        maxcolumns=arg3; %maximum number of columns in the prompt lines
        Screen.lines=24;         %currently fixed; just possibly other screen modes could be useful
        %assume 1 normal height line for start message
        %each prompt text line consists of 1 double height (and double width) line followed by 1 blank
        %single line
        maxlines=floor((Screen.lines-1)/3);
        
        if nline>maxlines
            disp('Too many lines in prompt');
            keyboard;
        end;
        
        Screen.baseline=3;     %start display from line 3 (allow top line for message, and 1 blank)
        %work out line to start display, so it is centered on screen
        Screen.startline=Screen.baseline+floor((maxlines-nline)/2)*3;
        Prompt.line=Screen.startline;
        Prompt.screenlines=Screen.lines;    %last line allowed for use by prompt text; must prevent scrolling!!        
        %set column mode (72 or 130) appropriately, and center text on screen
        %based on longest line in prompt file
        maxcol2=maxcolumns*2;       %using double width characters
        Screen.columns=80;
        setcols=[esc '[?3l'];
        if maxcol2>80 
            Screen.columns=132; 
            setcols=[esc '[?3h'];
        end;
        if maxcol2>Screen.columns
            disp('Prompt lines are too long for screen');
            keyboard;
        end;
        
        
        Screen.startcolumn=floor(Screen.columns/4-maxcolumns/2)+1;  %calculated for doublewidth lines
        Prompt.column=Screen.startcolumn;
        
        
        Prompt.text='';
        Prompt.attribute=bold;
        
        
        %basic settings for the message line (column position is worked out on the
        %fly at each call)
        Message.line=1; %fixed to line 1
        Message.defaultmessage=defaultmessage;
        Message.text=defaultmessage;
        Message.attribute=bold;
        Message.nbell=1;        %number of times to sound bell
        
        %allow for double width message??? in attribute and column?
        
        %actually superfluous
        tmpl=length(Message.text);
        tmpl=floor(Screen.columns/2-tmpl/2)+1;
        Message.column=tmpl;        
        
        
        ss=instrfind('Port',myport);
        if ~isempty(ss)
            disp('Delete existing serial object');
            keyboard;
            fclose(ss);
            delete(ss);
        end;
        
        
        try
            comport=serial('COM1');
            set(comport,'term','CR/LF');
            set(comport,'outputbuffersize',4096);       %should be larg enough for just about any case (the default of 512 is definitely too small!!
            fopen(comport);
        catch
            disp('Unable to open COM port');
            disp(lasterr);
        end;
        
        fprintf(comport,setcols);       %set columns per line; do this even if no change from default as it clears the screen
        %lock m file to protect persistent variables
        mlock;
        
        
        
    case 'message'
        if nargin<2 
            Message.text=Message.defaultmessage;
            
        else
            %check appropriate
            Message.text=arg2;
        end;
        tmpl=length(Message.text);
        tmpl=floor(Screen.columns/2-tmpl/2)+1;
        Message.column=tmpl;        
        
        showmessage(comport,Message);
        
    case 'prompt'
        
        if nargin>1
            Prompt.text=arg2;
        else
            %could be used to clear the screen
            Prompt.text='';
        end;
        
        showprompt(comport,Prompt)
        
    case 'reset'
        fclose(comport);
        delete(comport);
        clear comport;
        
        munlock
        
    otherwise
        keyboard
        %e.g to customize settings (could also take m-file as argument)
        
end;

function showmessage(comport,Message);
esc=char(27);
dellin=[esc '[2K'];
nbell=Message.nbell;

%treat this as a special case; clears message line without ringing bell
if isempty(Message.text) nbell=0; end;
sout='';
if nbell

bell=char(7);
sout=repmat(bell,[1 nbell]);
end;

curpos=makecurpos(Message.line,Message.column);
sout=[sout curpos dellin Message.attribute Message.text];

%important to write the start message asynchronously, as it can be quite
%slow
while ~strcmp(get(comport,'transferstatus'),'idle')
    x=1;
end;


fwrite(comport,sout,'uchar','async');

function showprompt(comport,Prompt);
esc=char(27);

delscreen=[esc '[J'];   %erases from current cursor position
%dellin=[esc '[2K'];

top=[esc '#3'];
bot=[esc '#4'];

pstring=Prompt.text;
nline=size(pstring,1);
%possibly delete screen from line 2 rather than prompt start line?
myline=Prompt.line;
sout=[esc '[' int2str(myline) 'H' delscreen];

%could allow an option to centre promptwise, rather than set once for whole
%prompt file

mycol=Prompt.column;
limline=Prompt.screenlines;
%may need to increase serial output buffer size???
if nline>0
    for ii=1:nline
        if myline<limline
            mystring=deblank(pstring(ii,:));    
            
            curpos=makecurpos(myline,mycol);
            s1=[curpos top Prompt.attribute mystring];
            
            myline=myline+1;
            curpos=makecurpos(myline,mycol);
            s2=[curpos bot Prompt.attribute mystring];
            
            sout=[sout s1 s2];
            myline=myline+2;                %single height line between double-height text lines
        else
            disp('Too many lines in prompt??');
        end;
        
    end;
    
    
end;

%asynchronous??
%should really check string is not too big for output buffer

while ~strcmp(get(comport,'transferstatus'),'idle')
    x=1;
end;


fwrite(comport,sout,'uchar');

function curpos=makecurpos(myline,mycol)    
esc=char(27);
curpos=[esc '[' int2str(myline) ';' int2str(mycol) 'H'];
