function stringm=file2str(filename,cellflag);
% FILE2STR read ascii file into string matrix
% function stringm=file2str(filename,cellflag);
% file2str: Version 19.6.2002
%
%	Description
%		New version based on textread
%		If an error is encountered the output argument is numeric and contains 0
%		Otherwise stringm contains the text of the file
%		If cellflag is present and true, the text is returned as a cell array of strings.
%		Otherwise (default) it is returned as a string matrix.
%		(cell array version will be faster, so use it if appropriate)
%
%	See Also
%		READTXTF: Reads into row vector
%		TEXTREAD: The underlying matlab function

dostrm=1;
if nargin>1
   if cellflag
      dostrm=0;
   end;
end;

try
   %when used this way textread returns a cell array of strings corresponding to 
   %the lines in the file
   stringm = textread(filename,'%s','delimiter','\n','whitespace','');
	if dostrm stringm=char(stringm); end;   
catch
   disp('Error in FILE2STR');
   disp(lasterr);
   stringm=0;
end;

