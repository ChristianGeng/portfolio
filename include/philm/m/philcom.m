function philcom(ini);
% PHILCOM Handle command file status
% function philcom(ini);
% philcom: Version 5.10.2001
%
% Syntax
%   Any input argument initializes. If input arg is string, try and
%   open file of this name as command file. Otherwise prompt for command file name.
%   But if input argument is numeric and == 1, initialize and return without
%   prompting.
%   Without input arg toggles active state of command file input

%future possibilities?? chaining or calling other COM files
%globals for COM file control
global PHILCOMFLAG PHILCOMFID
%globals for special characters
global PHILCOMMCHAR PHILDEFCHAR PHILDELCHAR PHILEVALCHAR PHILQUOTECHAR PHILCBUFFER
%it may be necessary to allow different kinds of initialization
if nargin~=0
   PHILCOMFLAG=0;
   PHILCOMFID=0;
   %initialize to MATLAB comment character
   PHILCOMMCHAR='%';
   PHILDEFCHAR='*';
   PHILDELCHAR='#';
   PHILEVALCHAR='@';
   PHILQUOTECHAR=quote;
   PHILCBUFFER=[];
   
   if isstr(ini)
      comname=ini;
      [fidnamel,message]=fopen(comname,'r');
      if ~isempty(message)
         disp (message);
         disp ('No command file opened!');
         return;
      end;
      %save name as well
      PHILCOMFID=fidnamel;
      PHILCOMFLAG=1;
      return;
   else
        if ini==1 return; end;
       fidnamel=0;
      while fidnamel<=2
         comname=philinp ('COM file name (<CR> to ignore) : ');
         if isempty(comname) return;end;
         [fidnamel,message]=fopen(comname,'r');
         if ~isempty(message) disp (message); end;
      end;
      %save name as well
      PHILCOMFID=fidnamel;
      PHILCOMFLAG=1;
      return;
   end;
   
end;


if PHILCOMFLAG==1 & PHILCOMFID>0
   PHILCOMFLAG=0;
   disp ('COM file input suspended');
   return;
end;
if PHILCOMFLAG==0 & PHILCOMFID>0
   PHILCOMFLAG=1;
   disp ('COM file input resumed');
   return;
end;
if PHILCOMFLAG==1 & PHILCOMFID==0
   PHILCOMFLAG=0;
   disp ('Error in PHILCOM');
   return;
end;
