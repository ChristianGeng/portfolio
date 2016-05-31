function rotmat=plane_rot(myangle,myplane);
% function rotmat=plane_rot(myangle,myplane);
% return 3D rotation matrix for simple rotations in single planes
% matrix should be used as M*v where v is a column vector of coordinates
% myangle is in radians
% plane must by xy, yz or xz

alpha=myangle;
rotmat=[];

if strcmp(myplane,'xy');
   hx =[cos(alpha) -sin(alpha) 0];
   hy =[sin(alpha) cos(alpha) 0];
   hz =[0 0 1];
   rotmat = [hx; hy; hz];
   
end;
if strcmp(myplane,'yz');
   hx =[1 0 0];
   hy =[0 cos(alpha) -sin(alpha)];
   hz =[0 sin(alpha) cos(alpha)];
   rotmat = [hx; hy; hz];						% final (global) rotation
   
end;

if strcmp(myplane,'xz');
   hx =[cos(alpha) 0 -sin(alpha)];
   hy =[0 1 0];
   hz =[sin(alpha) 0 cos(alpha)];
   rotmat = [hx; hy; hz];						% final (global) rotation
   
end;

if isempty(rotmat)
   disp('plane must by xy, yz or xz');
end;
