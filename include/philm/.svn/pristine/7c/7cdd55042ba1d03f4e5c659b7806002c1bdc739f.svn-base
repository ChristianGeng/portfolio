function xcol(infile,outfile,desclist);
% XCOL Extract columns from MAT file using descriptor variable
% function xcol(infile,outfile,desclist);
% xcol: Version 10.8.2001
%
%	Syntax
%		desclist: all columns whose label in descriptor of infile matches one of the entries
%			in desclist are extracted. Note: Entries in desclist can be incomplete
%			This allows them to match multiple entries in descriptor.
%			e.g 'tip' matches 'tipx' and 'tipy'

functionname='XCOL: Version 10.8.2001';

descin=mymatin(infile,'descriptor');

nold=size(descin,1);

%compile a list of columns to extract
mycol=[];

n1=size(desclist,1);

for ii=1:n1
   mydesc=deblank(desclist(ii,:));
   vv=strmatch(mydesc,descin);
   mycol=[mycol;vv];
   if isempty(vv)
      disp(['xcol: No match for ' mydesc]);
   end;
end;

n0=length(mycol);

if isempty(mycol)
   disp('xcol: No matches with input file');
   return;
end;

%eliminate any duplicates

ntmp=length(unique(mycol));
if ntmp~=n0
   disp('xcol: Eliminating duplicate columns');
   
	mycol=unique(mycol);		%this may rearrange the order
end;

ncol=length(mycol);

[status,msg]=copyfile([infile '.mat'],[outfile '.mat']);
if ~status
   disp('xcol: Unable to copy file');
   error(msg);
end;


data=mymatin(infile,'data');
data=data(:,mycol);
descriptor=descin(mycol,:);

unit=mymatin(infile,'unit');
unit=unit(mycol,:);

comment=mymatin(infile,'comment','[No comment in input file]');

%very very temporary!!!!

%sss=rv2strm(comment,crlf);
%vx=strmatch('REMARKS',sss);
%if ~isempty(vx)
%   sss(vx,:)=[];
%   comment=strm2rv(sss,crlf);
%end;

   



comment=['Data extracted from ' infile crlf comment];
comment=framecomment(comment,functionname);

V={'data','descriptor','unit','comment'};
nv=length(V);


scalefactor=mymatin(infile,'scalefactor');
doscale=0;
if length(scalefactor)==nold
   scalefactor=scalefactor(mycol);
   nv=nv+1;
   V{nv}='scalefactor';
end;

signalzero=mymatin(infile,'signalzero');
dozero=0;
if length(signalzero)==nold
   signalzero=signalzero(mycol);
   nv=nv+1;
   V{nv}='signalzero';
end;


nv=nv+1;
V{nv}='-append';


save(outfile,V{:});





disp(['xcol: ' int2str(ncol) ' columns extracted using ' int2str(n1) ' specifications']);

