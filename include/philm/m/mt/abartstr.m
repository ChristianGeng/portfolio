function [strgsel,strgindex]=abartstr(prompt,mydefault,strglist,scalarflag,nowhite);
% ABARTSTR Version of abart. Select item(s) from string list
% function [strgsel,strgindex]=abartstr(prompt,mydefault,strglist,scalarflag,nowhite);
% abartstr: Version 26.08.02
%
%	Syntax
%
%		Input arguments
%
%			prompt
%				Self-explanatory. This is the only required input argument
%
%			strglist
%				If 'strglist' is absent, any string can be returned.
%				Otherwise, one or more items from 'strglist' can be chosen.
%				When multiple items are allowed
%				they can either be typed in literally as a blank-separated list
%				or chosen by their index in the list. In this case the string
%				input by the user must start with '[' and end with ']'.
%				(Strictly speaking the square brackets can enclose any expression
%				that will evaluate to a vector of legal line indices in 'strglist'.
%				The last item in the list can be referred to by 'list_end',
%				so '[1:list_end]' will choose all items in the list)
%				When choosing from 'strglist' the input items need not be complete,
%				they only have to at least partially match an item or items from the list.
%				When scalarflag is not TRUE multiple items can thus be chosen with one
%				partial specification.
%				'strglist' should be a string matrix (or cell array of strings)
%
%			mydefault
%				Can be a string matrix (or cell array), like 'strglist',
%				but it is converted to a blank-separated list for use in the prompt
%
%			scalarflag 
%				Allows only scalar data (one choice) to be returned. Defaults to on. 
%				Returning vector data when the program does not expect it may have unpredictable consequences
%
%			nowhite
%				Defaults to 0. If 1 (true), white space is eliminated from input string 
%				(only used when 'strglist' is empty or 'scalarflag' true)
%
%		Output arguments
%			strgsel: A string matrix of the selected items
%			strgindex: Optional. The indices of the selected items in strglist
%
%	See Also
%		PHILINP: handles the input; ABART: for numeric input; ABALL : Auxiliary function to select all items in list


%handle nargin
if nargin<4 scalarflag=1; end;
if nargin<5 nowhite=0; end;
if nargin<2
   defuse='';
else
   defuse=char(mydefault);		%in case cell array
   if size(defuse,1)>1
      defuse=strm2rv(defuse,' ');
   end;
   defuse=deblank(defuse);   
end;
if nargin<3 strglist='';end;
strglist=char(strglist);	%may be cell array of strings
nitem=size(strglist,1);
%check not zero????

%if strglist empty, simply return any input, using default if necessary
if nitem==0
   p=[prompt ' [' defuse ']  * '];
%    keyboard;
   instr=philinp(p);
   if nowhite instr(isspace(instr))=[];end;
   if isempty(instr) instr=defuse; end;
   strgsel=instr;
   if nargout>1 strgindex=0;end;
   return;
   
end;


numlen=length(int2str(nitem));
numlist=setstr(zeros(nitem,numlen));
for ii=1:nitem numlist(ii,:)=int2str0(ii,numlen);end;
numlist=[numlist blanks(nitem)'];

%help character
helpchar=sethelp(strglist);

%do scalar data separately. Much less complicated as eval not required

if scalarflag
   %		evaluate default
   videf=strmatch(defuse,strglist);
   vile=length(videf);
   if vile~=1
      disp(['abartstr: Default not in list of possible choices > ' defuse]);
      disp('Using first item');
      defuse=deblank(strglist(1,:));
      videf=1;
   end;
   
   badinp=1;
   while badinp
      p=[prompt ' (' quote helpchar quote ' for choices) [' defuse ']  * '];
      instr=philinp(p);
      if nowhite instr(isspace(instr))=[];end;
      %check default ok????
      if ~strcmp(instr,helpchar)
         if isempty(instr)
            vi=videf;
            badinp=0;
         else
            %try exact match first, otherwise there is no way of getting a string that is a substring of another string
            
            
            vi=strmatch(instr,strglist,'exact');
            vile=length(vi);
            if vile==1
               badinp=0;
            else   
               vi=strmatch(instr,strglist);
               vile=length(vi);
               if vile==1
                  badinp=0;
               end;
               
               
            end;
         end;
      else
         %typing help character allows selection via uicontrol list dialog
         [vi,selectok]=listdlg('liststring',strglist,'selectionmode','single','initialvalue',videf,'promptstring','Choose 1 item');
         if selectok badinp=0;end;
         
      end;
      
      if badinp          
         disp('=========================================================');            
         disp(['Choose one item from the following list']);
         disp(['(Or type ' helpchar ' for mouse-aided selection)' crlf]);
         disp(strglist)
         disp('=========================================================');            
      end;
   end;
   strgsel=deblank(strglist(vi,:));
   if nargout>1 strgindex=vi; end;
   
   
   return;
end;			%scalarflag


%		evaluate default
videf=abarteva(defuse,strglist);
if isempty(videf)
   disp(['abartstr: Unable to evaluate default > ' defuse]);
   disp('Using first entry in item list');
   defuse=deblank(strglist(1,:));
   videf=1;
end;


badinp=1;
while badinp
   p=[prompt ' (' quote helpchar quote ' for help) [' defuse ']  * '];
   instr=philinp(p);
   if ~strcmp(instr,helpchar)
      if isempty(instr)
         vi=videf;
         badinp=0;
      else
         vi=abarteva(instr,strglist);
         if ~isempty(vi) badinp=0; end;
      end;
   else
      %typing help character allows selection via uicontrol list dialog
      [vi,selectok]=listdlg('liststring',strglist,'selectionmode','multiple','initialvalue',videf,'promptstring','Choose 1 or more items');
      if selectok badinp=0;end;
      
      
   end;
   
   if badinp          
      %include numbers
      disp('=========================================================');            
      disp('Choose items from the following list');
      disp('Either: Enter a blank-separated list of choices')
      disp('Or:     Enter a vector of indices enclosed in [...]') 
      disp(['Or:     Type ' helpchar ' for mouse-aided selection)' crlf]);
      
      disp([numlist strglist])
      disp('=========================================================');            
   end;
end;

strgsel=strglist(vi,:);
if nargout>1 strgindex=vi; end;


function  vi=abarteva(instr,strglist);
list_end=size(strglist,1);		       

badinp=0;

if strcmp(instr(1),'[') & strcmp(instr(end),']')
   try
      vi=eval(instr);
      if isempty(vi)
         badinp=1;
      else
         badinp=(any(vi<1)|any(vi>list_end));
      end;
   catch
      badinp=1;
   end;
   
else
   
   try
      inlist=rv2strm(instr);
      
      if isempty(inlist)
         disp('empty list?');
         badinp=1;
      else
         vi=[];
         ll=size(inlist,1);
         for ii=1:ll
            %exact match takes precedence. If no match allow multiple partial matches
            vix=strmatch(deblank(inlist(ii,:)),strglist,'exact');
            if length(vix)==1
               vi=[vi;vix];
            else
               
               vix=strmatch(deblank(inlist(ii,:)),strglist);
               
               if length(vix)>=1
                  vi=[vi;vix];
               else
                  
                  badinp=1; 
               end;
               
            end;
         end;
      end;	%inlist not empty
   catch
      badinp=1;
   end;
   
end;	%literal or eval

%keyboard;
if badinp vi=[];end;


function helpchar=sethelp(strglist);
myc='?';
vi=strmatch(myc,strglist);
if isempty(vi)
   helpchar=myc;
   return;
end;


myc='help';
vi=strmatch(myc,strglist);
if isempty(vi)
   helpchar=myc;
   return;
end;

myc='helpme';
vi=strmatch(myc,strglist);
if isempty(vi)
   helpchar=myc;
   return;
end;

disp('abartstr: Run out of choices for help');
helpchar='999';

