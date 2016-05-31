function mylist=makesiglist(descrip,filesuffix,sensorin,sensorout,dimtran);
% MAKESIGLIST Make signal lists for mtnew
% function mylist=makesiglist(descrip,filesuffix,sensorin,sensorout,dimtran);

mylist=[];
vs=strmatch(sensorin,descrip);

ns=length(vs);
dname=descrip(vs,:);	%signal name as used in descriptor
iname=[];				%internal name

%keyboard

fs=repmat([filesuffix '.'],[ns 1]);

if nargin>3
   
   iname=[repmat('.',[ns 1]) dname];
   
   iname=cellstr(iname);
   if ~isempty(sensorout)
      iname=strrep(iname,sensorin,sensorout);
   end;
   
   if nargin>4
      nd=size(dimtran,1);
      for ii=1:nd
         iname=strrep(iname,dimtran{ii,1},dimtran{ii,2});
      end;
   end;
end;


mylist=[fs dname char(iname)];
mylist=strmdebl(mylist);
