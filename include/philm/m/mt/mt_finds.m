function cd=mt_finds(indexop,dataout,cutfield,myop,myvalue,cutbuf,cutlabel);
% MT_FINDS Find selection of cuts
% function cd=mt_finds(indexop,dataout,cutfield,myop,myvalue,cutbuf,cutlabel);
% mt_finds: Version 16.3.99
%
%	Syntax
%		Order of input args is meant to be easy to remember,
%			e.g find ('first','data','start','>',1)
%		indexop: 'first', 'last', 'all'
%		dataout: 'data','label','index' (i.e latter returns indices, not actual data)
%		cutfield: 'start', 'end', 'length', 'type', 'trial','number'
%		myop: string specifying comparison operator, e.g >,== etc.
%		myvalue: scalar with which cutfield is compared
%		cutbuf (optional): m*3 matrix of cut data. If not present, mt_gcufd is used to retrieve the data
%			thus, this is a way of speeding up frequent searches, and
%			also makes it possible to use the function independently of the mm setup
%		cutlabel: (ditto) for label data
%
% See also
%		MT_GSCUD to get the sub-cut data buffer
%		SELECTRO for use with any matrix and multiple conditions

cd=[];
if nargin<5
   disp('mt_finds: Not enough input args.');
   return;
end;

if nargin<6
   cutbuf=mt_gcufd;
end;
   if ((strcmp(dataout,'label'))& (nargin<7)) cutlabel=mt_gcufd('label');end;


if isempty(cutbuf) return;end;

cc=[];
if strcmp(cutfield,'start') cc=cutbuf(:,1);end;
if strcmp(cutfield,'end') cc=cutbuf(:,2);end;
if strcmp(cutfield,'length') cc=cutbuf(:,2)-cutbuf(:,1);end;
if strcmp(cutfield,'type') cc=cutbuf(:,3);end;
if strcmp(cutfield,'trial') cc=cutbuf(:,4);end;
if strcmp(cutfield,'number') cc=(1:size(cutbuf,1))';end;



ss=['vv=find(cc' myop 'myvalue);'];
%        disp (ss);


try
   eval (ss);
catch
   vv=[];
end;


if isempty(vv) return; end;


%default is all

if strcmp(indexop,'last')
   ll=length(vv);
   vv=vv(ll);
end;
if strcmp(indexop,'first')
   vv=vv(1);
end;


if strcmp(dataout,'data')
   cd=cutbuf(vv,:);
end;
if strcmp(dataout,'label')
   cd=cutlabel(vv,:);
end;
if strcmp(dataout,'index')
   cd=vv;
end;
