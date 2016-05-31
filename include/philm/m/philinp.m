function mystr=philinp(prompt)
% philinp Input routine, similar to input(..,'s') but allows use of command file and special characters
% function mystr=philinp(prompt)
% philinp: Version 7.3.2002
%
% Description
%    Collects a string from keyboard or command file
%		Some characters have special functions. These are initialized as follows, but can be changed by accessing
%		the appropriate global variables:
%			% (as first character in string, in command file). Treat line as comment, i.e skip
%			# Multiple strings can be entered on one line,if delimited by this character (can make command files much more readable, and speeds up repetitive input at the keyboard)
%        * When using delimiters this is needed to get default input, i.e ## would be skipped completely, but #*# returns an empty string
%        @ (as first character in line) evaluate string. Result should also be a string.
%
% See Also
%     philcom (Initializes global variables for special characters, and activates command file input)

%globals for COM file control
global PHILCOMFLAG PHILCOMFID
%globals for special characters
%must be initialized by philcom(0)
global PHILCOMMCHAR PHILDEFCHAR PHILDELCHAR PHILEVALCHAR PHILQUOTECHAR PHILCBUFFER
%low level input function
%handle command file control, log file and string parsing
%globals etc.
%write prompt to log file as comment


cbuffer=PHILCBUFFER;
%disp(cbuffer);

%helps if diary being used to set up command file

diaryon=strcmp(get(0,'diary'),'on');
if diaryon prompt=['% ' prompt];end;

if isempty (cbuffer)
   %get next command line from com file or terminal
   
   
   
   if PHILCOMFLAG==1 & PHILCOMFID>0
      %input from command file
      disp (prompt);
      ierror=0;
      char1=PHILCOMMCHAR;
      mycommchar=PHILCOMMCHAR;
      while ((ierror==0) & strcmp(char1,mycommchar))
         instr=fgetl(PHILCOMFID);
         if ~isstr(instr) 
            ierror=1;
            fidnamel=PHILCOMFID;
            PHILCOMFLAG=0;
            PHILCOMFID=0;
            disp ('COM file closed');
            status=fclose (fidnamel);
            
         else
            %instr to log file
            char1='';
            if (length(instr)>0) char1=instr(1);end;
%            disp (instr);           
         end;
      end;
   end;
   %
   if PHILCOMFLAG==0
 %       disp(prompt);
 %       disp(size(prompt));
       instr=input(prompt,'s');
      %instr to log file
   end;
   
   %if quoted command line, no more parsing
   % return immediately with string (stripped of quotes) leaving command buffer empty
   if length(instr)>2
      myquote=PHILQUOTECHAR;
   if strcmp(instr([1 end]),[myquote myquote])
		if diaryon disp(instr); end;		%echo on new line to diary/command file      
      mystr=instr(2:(end-1));
%      keyboard;
      return;
   end;
   
end;

   
   cbuffer=instr;
   %evaluate input
   if length(cbuffer)>1
      evalchar=PHILEVALCHAR;
      if strcmp(cbuffer(1),evalchar)
         tempstr=cbuffer(2:end);
         
         %If problems occur, the function will return an empty string. May not be best solution
         
         try
            newstr=eval(tempstr);
         catch
            disp('philinp: Unable to evaluate input string')
            disp(tempstr);
            disp(lasterr);
            newstr='';
         end;
         if ~ischar(newstr)|size(newstr,1)~=1
            disp('philinp: Unexpected result of eval');
            disp(tempstr);
            newstr='';
         end;
         cbuffer=newstr;
      end;
   end;
   
end; %end of get next string
deluse=PHILDELCHAR;
[tmpstr,cbuffer]=strtok(cbuffer,deluse);
mydefchar=PHILDEFCHAR;
if strcmp(tmpstr,mydefchar) tmpstr=[]; end;
%update global buffer
PHILCBUFFER=cbuffer;
mystr=tmpstr;
if diaryon disp(mystr); end;		%echo on new line to diary/command file      

%check buffer only consists of delimiters????

%currently if input line is terminated with delimiter character (any number)
%one additional default value will be returned
