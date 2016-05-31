function rigout=showth(T,mymessage)
% SHOWTH convert 4*4 homogeneous matrix to list of translational components and euler angles
% function rigout=showth(T,mymessage)
% showth: Version 10.9.02
%
%	Syntax
%		T can be a stack of matrices, i.e sized 4*4*n
%		If no output args simply display on terminal
%		rigout is sized 6*n, each row being arranged tx, ty, tz, rz, ry, rx
%			rz means rotation about the z axis (i.e in the xy plane); ceteris paribus for ry and rx
%		mymessage is an optional message for display on the terminal
%
%	See Also MAT2EULER SHOWT

mys='';
if nargin>1 mys=mymessage; end;

nm=1;
if ndims(T)>2 nm=size(T,3); end;

if nargout rigout=ones(nm,6)*NaN; end;

for ii=1:nm
   hmat=T(:,:,ii);
   t=(hmat(1:3,4))';
   r=mat2euler(hmat(1:3,1:3));
   
   if nargout
      rigout(ii,:)=[t r];
   else
      
      
      
      if ~isempty(mys) disp(mys); end;
      disp(['Translation: ' num2str(t) ' Rotation (deg.): ' num2str(r*180/pi)]);
      
   end;
end;
