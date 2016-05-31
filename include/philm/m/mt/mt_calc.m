function y=mt_calc(calcstr,timspec);
% MT_CALC Arithmetic operations on MT signals
% function mt_calc(calcstr,timspec);
% MT_CALC: Version 30.05.2004
%
%	Syntax
%		calcstr: String defining the arithmetic operations. Refer to signals by their name
%		timspec:	Optional. Default to complete trial

siglist=mt_gsigv;
nsig=size(siglist,1);

%sort signal names in descending order of length
%to avoid problems where one signal name is a substring of another
namelen=zeros(1,nsig);
for ii=1:nsig namelen(ii)=length(deblank(siglist(ii,:))); end;

[dodo,sorti]=sort(namelen);
siglist=siglist(sorti,:);
siglist=flipud(siglist);

y=[];

for ii=1:nsig
   mysig=deblank(siglist(ii,:));
   repstr=['mt_gdata(' quote mysig quote];
   if nargin>1 repstr=[repstr ',timspec'];end;
   repstr=[repstr ')'];
    repstr=char(repstr+256);        %stop replacement of substrings in already replaced strings  
   calcstr=strrep(calcstr,mysig,repstr);
end;

calcstr=abs(calcstr);
vv=find(calcstr>256);
calcstr(vv)=calcstr(vv)-256;
calcstr=char(calcstr);


calcstr=['y=' calcstr ';'];

try
   eval(calcstr);
catch
   disp('mt_calc: Unable to perform calculation');
   disp(calcstr);
   disp(lasterr);
%   disp('Most likely reason:');
%   disp('The name of one signal is a sub-string of another signal');
%   disp('Adjust the signal names used in the calling program');
end;
