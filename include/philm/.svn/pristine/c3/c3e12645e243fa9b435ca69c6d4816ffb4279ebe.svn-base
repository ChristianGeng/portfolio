function [itrial,wordpos]=mt_findwords(mystring,myrep,cuttype);
% MT_FINDWORDS Get trial and position of target word from MAUS segmentation
% function [itrial,wordpos]=mt_findwords(mystring,myrep,cuttype);
% mt_findwords: Version 12.10.2000
%
%   Syntax
%       Search for mystring in labels of segments of cuttype (usually orthography or SAMPA_canonical)
%       Return trial number and position of word, based on maussegments
%       (cuttype is optional; defaults to 'orthography')
%       Search is currently case sensitive. Looks for any match (i.e can't be restricted to full match)
%       If multiple tokens found, myrep determines which one is returned (default to first)
%
%   See Also CUTLINKS

%       In future allow for word segments directly????


itrial=0;
wordpos=[];

cutdata=mt_gcufd('data');
cutlabel=mt_gcufd('label');

cut_type_labels=mymatin(mt_gcufd('filename'),'cut_type_label');
cut_type_values=mymatin(mt_gcufd('filename'),'cut_type_value');


ctype='orthography';
if nargin>2 ctype=cuttype;
end;

stype='MAUS_seg';

cnum=strmatch(ctype,cut_type_labels);
if isempty(cnum) 
   disp('Bad cut type?');
   return;
end;

cnum=cut_type_values(cnum);


snum=strmatch(stype,cut_type_labels);
if isempty(snum) 
   disp('Bad cut type?');
   return;
end;

snum=cut_type_values(snum);

vv=find(cutdata(:,3)==cnum);

dattmp=cutdata(vv,:);
labtmp=cutlabel(vv,:);


nn=size(dattmp,1);

mylist=zeros(nn,2);		%store trial number and symbolic link

for ii=1:nn
%   ip=findstr(mystring,labtmp(ii,:));
   ip=strmatch(mystring,labtmp(ii,:),'exact');
   if ~isempty(ip)
      ipp=ip(1);
      mylist(ii,:)=dattmp(ii,[4 5]);	%should be done using labels
      if length(ip)>1
         disp(['Note: Multiple tokens of string in word ' labtmp(ii,:)]);
      end;
   end;
end;

vv=find(mylist(:,1)>0);
nv=length(vv);

if nv==0
   disp('No tokens found');
   return;
end;

mylist=mylist(vv,:);

iuse=1;
if nargin>1 iuse=myrep; end;

if iuse>nv iuse=nv; end;

if nv>1
   disp(['Using token ' int2str(iuse) ' of ' int2str(nv)]);
end;

%use directly if stype==ctype????

%find all segments for this symbolic link in this trial


b1=cutdata(:,4)==mylist(iuse,1);
b2=cutdata(:,5)==mylist(iuse,2);
b3=cutdata(:,3)==snum;

vv=find(b1&b2&b3);

if isempty(vv)
   disp('No segments found to matched word');
	return;   
end;

itrial=mylist(iuse,1);

%this is not quite correct if multiple symbolic links occur, cf. cutlinks

wordpos=[min(cutdata(vv,1)) max(cutdata(vv,2))];

wordlabel=strm2rv(cutlabel(vv,:),' ');	%separate segment labels by blanks

disp(['Segment labels of matched word: ' wordlabel]);
