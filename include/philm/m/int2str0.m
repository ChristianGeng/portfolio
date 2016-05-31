function numstr=int2str0(num,numlength);
% INT2STR0 Version of INT2STR adding leading zeros to give desired length,
% function numstr=int2str0(num,numlength);
% int2str0: Version 6.8.2010
%
%	Syntax
%		num: scalar, or column vector of integers
%		numlength: desired length; optional, defaults to 3
%
%	Update
%		8.2010 Allow num to be a column vector. No longer a warning if
%			result without padding is already longer than numlength

numstr='';
if nargin < 2 numlength=3; end;
[nrow,ncol]=size(num);
if ncol>1
	disp('int2str0: Input data cannot have more than one column');
	return;
end;

numstr=int2str(num);
%replace any blanks with 0
numstr=char(strrep(cellstr(numstr),' ','0'));

ncolx=size(numstr,2);

if numlength>ncolx
	npad=numlength-ncolx;
	pp=repmat('0',[nrow npad]);
	numstr=[pp numstr];
end;

