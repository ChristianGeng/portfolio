function indat=abart(prompt,mydefault,mymin,mymax,intflag,scalarflag);
% ABART Prompt for numeric input
% function indat=abart(prompt,mydefault,mymin,mymax,intflag,scalarflag)
% abart: Version 23.9.98
%
%   Syntax
%       intflag: (optional) force data to integer (default=on)
%       scalarflag: (optional) allows only scalar data to be returned (default=on)
%			returning vector data when the program does not expect it may have
%			unpredictable consequences
%       mydefault, mymax and mymin (compulsory) can be scalar or vector
%			but if they are vector then lengths must agree with input
%
%   Remarks
%       note: user input can be specified using mydefault, mymax and mymin
%       e.g mymax/2
%
%   See Also
%		PHILINP Collects the actual input from user or from command file
%       ABARTSTR For string input

if nargin<6
   scalarflag=1;
end;
if nargin<5
   intflag=1;
end;

defuse=mydefault;
if defuse>mymax
   disp (['Warning! Default ' num2str(defuse) ' > Max ' num2str(mymax)]);
   defuse=mymax;
end
if defuse<mymin
   disp (['Warning! Default ' num2str(defuse) ' < Min ' num2str(mymin)]);
   defuse=mymin;
end
%check max >= min????
defstr=num2str(defuse);
if intflag
   defuse=round(defuse);
   defstr=int2str(defuse);
end
badinp=1;
while badinp
   p=[prompt ' [' defstr ']  * '];
   instr=philinp(p);
   badinp=0;
   if isempty(instr) inuse=defuse;
   else
      try
         inuse=eval(instr);
      catch
         badinp=1;
         disp (lasterr);
         disp ('Unable to evaluate input');
      end
      
   end
   if ~badinp
      linp=length(inuse);
      if linp <= 0 
         disp('Input is empty');
         badinp=1;
      end
      if scalarflag
         if linp~=1
            badinp=1;
            disp ('Input must be scalar');
         end
      end
      if ~badinp
         if intflag inuse=round(inuse); end
         if any(inuse>mymax) badinp=1; end
         if any(inuse<mymin) badinp=1; end
      end;
      
   end
   if badinp disp('Bad input. Try again');end
end
indat=inuse;
