function lowerfile(myfile)
% LOWERFILE Convert file names to lowercase
% function lowerfile(myfile)
%
% myfile: filename; can include wildcards eg. '*.m'
% commands are stored in 'lowerfile.bat', but not executed!!

%myfile='*.m';
[s,w]=dos(['dir/b ' myfile]);
mylist=rv2strm(w);
mylist=rv2strm(w,crlf);
mylist(end,:)=[];
nf=size(mylist,1);
diary lowerfile.bat
for ii=1:nf
myname=deblank(mylist(ii,:));
mys=['rename ' myname ' ' lower(myname)];
disp(mys);
end;
diary off
