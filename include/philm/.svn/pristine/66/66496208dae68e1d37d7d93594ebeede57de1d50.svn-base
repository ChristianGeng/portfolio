function hmat=rege2hmat(T);
% REGE2HMAT Convert regejaw3 output to homogeneous matrix
% function hmat=rege2hmat(T);
% converts the structure returned by regejaw3 etc. containing the object centroids
%	and the rotation matrix to a single homogeneous matrix for use in the
%	form Mv, where v is a column vector of (homogeneous) coordinates ([x y z 1])'

rr=T.H_coll1;

rotmat=rr(:,:,2);

rotmat=rotmat';		%convert for use as Mv with v column vector of 

xx=T.xbars;

cent1=squeeze(xx(:,:,1));
cent2=squeeze(xx(:,:,2));

cent1=cent1';
cent2=cent2';

%rotate the centroid of the second object

cent2t=rotmat*cent2;

tt=cent1-cent2t;

hmat=[[rotmat tt];[0 0 0 1]];
