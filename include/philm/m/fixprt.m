function fixprt(prtfile)
% FIXPRT Extract labels from ag100 prt file
% function fixprt(prtfile)
% Version 15.2.99
%
%   Handle repeats
%   This version designed for dfgsp
%   Each label (code) must start with '<CODE>'
%   Specify prt file without extension
%   New file .lab is generated

codeit='<CODE>';
lcode=length(codeit);
repeatit='!!REPEAT!!';
lrep=length(repeatit);
codrep=repeatit;
codrep(1:lcode)=codeit;

ss=file2str([prtfile '.prt']);
vr=strmatch(repeatit,ss);
lr=length(vr);
disp(['No. of repeats ' int2str(lr)]);
disp(ss(vr,:));
if lr
   ss(vr,1:length(codeit))=rpts([lr 1],codeit);
end;

vv=strmatch(codeit,ss);
sc=cellstr(ss(vv,:));

if lr
   vr=strmatch(codrep,sc);
   for ii=1:lr
      tmps=sc{vr(ii)};
      tmps=tmps((lrep+1):end);
      sc{vr(ii)}=tmps;
      tmps=sc{vr(ii)-1};
      tmps=[tmps ' ' repeatit];
      sc{vr(ii)-1}=tmps;
   end;
end;

ss=char(sc);
ss=strm2rv(ss);
fid=fopen([prtfile '.lab'],'w');
ff=fwrite(fid,ss,'uchar');
fclose(fid);

