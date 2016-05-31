function eule=mat2euler(tmat)
% MAT2EULER Rotation matrix to Euler angles
% function eule=mat2euler(tmat)
% mat2euler: Version ???
%
%	Syntax
%		Input is a 3*3 transformation matrix
%		Output is a 1*3 vector
%			rotation about z, y, x axis respectively (corresponds to 
%			arrangement in optotrak rigid body data
%
%	Algorithm
%		Uses formulae in Price, Pose Estimation
%
%	See Also EULER2MAT

% eule([1 2 3]) corresponds to psi, phi and theta in Price, Pose estimation

eule(1)=atan(tmat(2,1)./tmat(1,1));
eule(2)=asin(-tmat(3,1));
eule(3)=atan(tmat(3,2)./tmat(3,3));
