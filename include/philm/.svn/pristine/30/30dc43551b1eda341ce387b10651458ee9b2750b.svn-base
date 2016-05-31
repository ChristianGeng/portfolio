function matmop(matname1,matname2,matout,colvec,insertp);
% MATMOP Merge main data matrix from 2 MAT files; store as new file
% function matmop(matname1,matname2,matout,colvec,insertp);
% matmop: Version 30.03.2010
%
%   Purpose
%       Merge data variables from 2 MAT files, adapting the descriptor, unit and comment variables accordingly
%
%   Syntax
%       colvec: specifies the columns in matname2 to place in matname1
%			(if argument is absent or empty: all columns)
%       insertp: specifies where 1st column from matname2 should be placed in new matrix
%           allowed range: 1 to columns in matname1 + 1;
%			Default is columns in matname1 + 1 (i.e simply appended across
%			the column dimension)
%       stores nothing if colvec or insertp are out of range
%		matout: name of merged mat file
%
%   Remarks
%       May allow choice by parameter name in future

functionname='matmop: Version 30.03.2010';
disp (functionname);
if nargin<4 help('matmop');return;end;



data=mymatin(matname1,'data');
descriptor=mymatin(matname1,'descriptor');
unit=mymatin(matname1,'unit');
comment=mymatin(matname1,'comment');
%temporary!!
%??comment=strm2rv(comment);

data2=mymatin(matname2,'data');
descriptor2=mymatin(matname2,'descriptor');
unit2=mymatin(matname2,'unit');
comment2=mymatin(matname2,'comment');

[m1,n1]=size(data);
[m2,n2]=size(data2);
if m1~=m2 error ('Data matrices different length'); end;

ip=n1+1;
if nargin>4 ip=insertp; end;
if isempty(ip) ip=n1+1; end;

if ((ip<1) | (ip>(n1+1))) error ('insertion point out of range');end;

clist=1:n2;
if nargin>3 clist=colvec; end;
if isempty(clist) clist=1:n2; end;

vv=find((clist<1) | (clist>n2));

%check descriptor and unit ok
md=size(descriptor,1);
mu=size(unit,1);
if md~=n1 error ('Bad descriptor, file 1');end;
%units may just be missing
badunit=0;
if mu~=n1
	disp('Bad unit, file 1');
	keyboard;
	badunit=1;
end;
md=size(descriptor2,1);
mu=size(unit2,1);
if md~=n2 error ('Bad descriptor, file 2');end;
if mu~=n2
	disp('Bad unit, file 2');
	keyboard;
	badunit=1;
end;

if badunit unit=''; unit2=''; end;


copyfile([matname1 '.mat'],[matout '.mat']);


disp (['Parameters available in secondary file' crlf '-------------']);
disp (descriptor2);
%        clist=abart ('Vector of parameters to move',1,1,n2,abint,abnoscalar);
descriptor2=descriptor2(clist,:);
if ~badunit unit2=unit2(clist,:);end;
data2=data2(:,clist);
disp (['------------------' crlf 'Parameters extracted' crlf '------------------']);
disp (descriptor2);


disp (['-------------' crlf 'Current parameter list in primary file' crlf '-------------']);
disp (descriptor);

%        ip=abart ('First column of secondary data in new data matrix',n1+1,1,n1+1,abint,abscalar);
idone=0;
if ip==n1+1
	data=[data data2];
	descriptor=str2mat(descriptor,descriptor2);
	unit=str2mat(unit,unit2);
	idone=1;
end;

if ip==1
	data=[data2 data];
	descriptor=str2mat(descriptor2,descriptor);
	unit=str2mat(unit2,unit);
	idone=1;
end;

if ~idone
	%split primary matrices
	x1=data(:,1:(ip-1));
	x2=data(:,ip:n1);
	data=[x1 data2 x2];
	x1=descriptor(1:(ip-1),:);
	x2=descriptor(ip:n1,:);
	descriptor=str2mat(x1,descriptor2,x2);
	if ~badunit
		x1=unit(1:(ip-1),:);
		x2=unit(ip:n1,:);
		unit=str2mat(x1,unit2,x2);
	end;

end;
%use short version of help text eventually
cx=['Matmop: Columns from ' matname2 ' inserted at ' int2str(ip) ' in ' matname1];
cx=[cx crlf strm2rv(descriptor2,'/')];
if badunit
	cx=[cx crlf 'Note: Bad units in one or both input files'];
end;

cx=[cx crlf 'Comment from ' matname1 crlf '=====================' crlf];
comment=[cx comment crlf 'Comment from ' matname2 crlf '=====================' comment2];
comment=framecomment(comment,functionname);

save(matout,'data','descriptor','comment','-append');
if ~badunit save(matout,'unit','-append'); end;

