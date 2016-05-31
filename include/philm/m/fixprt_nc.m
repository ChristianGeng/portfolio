function fixprt_nc(prtfile)
% FIXPRT_NC Extract labels from ag100 prt file (no CODE string required)
% function fixprt_nc(prtfile)
% Version 26.11.10
%
%   Handle repeats
%   This version derived from dfgsp version
%   but codes need not start with "<CODE>"
%   Specify prt file without extension
%   New file .lab is generated

codeit='Coils  :';
codeoff=4;		%line offset from "code" string to actual code line
repeatit='!!REPEAT!!';
lrep=length(repeatit);

ss=file2str([prtfile '.prt']);

vc=strmatch(codeit,ss);
vc=vc+codeoff;
ss=ss(vc,:);

ntrial=size(ss,1);

disp(['Total trials : ' int2str(ntrial)]);




vr=strmatch(repeatit,ss);
lr=length(vr);
disp(['No. of repeats ' int2str(lr)]);
disp(ss(vr,:));

sc=cellstr(ss);

if lr
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

