function colnum=coloursigs(siglist,suffmode,sufflen,spacefac,minstem);
% COLOURSIGS Choose oscillogram colours maximizing contrast between either signal names stems or suffixes
% function colnum=coloursigs(siglist,suffmode,sufflen,spacefac,minstem);

colnum=[];

nsig=size(siglist,1);

if ~nsig
   disp('no signals to colour?');
   return
end;

colnum=(1:nsig)';

mymode='suffix';
if nargin>1
   mymode=lower(suffmode);
   if ~strcmp(mymode,'stem') mymode='suffix'; end;
end;




suffl=1;
if nargin>2
   if ~isempty(sufflen)
      suffl=sufflen;
   end;
end;



spacef=2;
if nargin>3
   if ~isempty(spacefac)
      spacef=spacefac;
   end;
end;

minst=1;
if nargin>4
   if ~isempty(minstem)
      minst=minstem;
   end;
end;

if spacef==0 return; end;%simple case, no special spacing
if suffl==0 return; end;%simple case, no special spacing
if minst<1 return; end;	%actually doesnt seem to matter

%determine number of suffixes

suffla=abs(suffl);

cc=cellstr(siglist);
for ii=1:nsig
   tmps=cc{ii};
   lt=length(tmps);
   if lt>=(suffla+minst)
      if strcmp(mymode,'suffix')
         if suffl>0
            myp=(suffla+1):lt;
         else
            myp=(lt-suffla+1):lt;
         end;
         
      else
         if suffl>0
            myp=1:suffla;
         else
            myp=1:(lt-suffla);
         end;
         
      end;
      
         cc{ii}=tmps(myp);
      
   else
      cc{ii}=tmps;%ensure signal is treated as separate category if not made up of stem plus suffix
   end;
end;

cu=unique(cc);

nsuff=size(cu,1);

grpspace=round(spacef*(nsig/nsuff))+1;

icol=1;
for ii=1:nsuff
   vv=strmatch(cu{ii},cc);
   for jj=1:length(vv)
      colnum(vv(jj))=icol;
      icol=icol+1;
   end;
   icol=icol+grpspace;
end;
