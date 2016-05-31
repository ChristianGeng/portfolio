function outstring=rpts(irep,mystring)
% RPTS Repeat string
% function outstring=rpts(irep,mystring)
% rpts: Version 8.9.98
%
% Syntax
%    irep: number of repeats
%	if irep is scalar outstring is a row vector formed from concatenating the input string
%	if irep is a two element vector irep(2) determines the number of concatenations of the input string
%		This row is then duplicated irep(1) times
%    mystring: Input string; must be simple row vector
%
% Description
%    Main use is to input repetitive command strings
%
% See Also
%    philinp

if nargin~=2
	help rpts
	outstring='';
	return
end;

if length(irep)==1
	outstring=strrep(blanks(irep),' ',mystring);
	return
end;
if length(irep)==2
	outstring=strrep(blanks(irep(2)),' ',mystring);
	if isempty(outstring)
		outstring=setstr(ones(irep(1),0));
	else
		outstring=setstr(ones(irep(1),1)*outstring);
	end;
	return
end;
disp('rpts: Unexpected irep argument');
help rpts
outstring='';
