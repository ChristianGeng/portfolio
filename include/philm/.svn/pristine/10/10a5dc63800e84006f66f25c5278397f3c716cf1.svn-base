function matout=mymatin(matname,varname,mydefault);
% MYMATIN Retrieve single arbitrary variable from MAT file
% function matout=mymatin(matname,varname,mydefault);
% mymatin: Version 13.7.2001
%
%	Description
%		enables calling program to retrieve variable from mat file
%		and use with an arbitrary name
%       Returns with error and empty matrix if mat file not found
%       Return optional default value if variable not found;
%       otherwise return empty matrix
%			If variable is not found a warning is given (superfluous warnings can
%			be turned on and off by the calling program: 'warning off', 'warning on')
%

matout=[];


varlist=who('-file',matname);

if isempty(varlist)
   error (['mymatin: MAT file not found; ' matname]);
end;

varexist=strmatch(varname,varlist,'exact');

if length(varexist)==1
   
   matout=load(matname,varname);%matout is a struct, with field varname
   matout=getfield(matout,varname);
   
else
   if nargin>2
      warning(['mymatin: Variable not found; ' varname '. Returning default']);
      matout=mydefault;
   else
      warning(['mymatin: Variable not found; ' varname '. Returning empty matrix']);
   end;
   
end;

