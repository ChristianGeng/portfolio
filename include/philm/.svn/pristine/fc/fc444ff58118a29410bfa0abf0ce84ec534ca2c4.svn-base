function rotmat=euler2mat(eule)
% EULER2MAT Convert euler angles to rotation matrix
% function rotmat=euler2mat(eule)
%
%	Syntax
%		Input is a 1*3 vector, arranged as in optotrak rigid body format
%			i.e rotation about z, y and x axes respectively
%		Output is a 3*3 transformation matrix
%
%	Algorithm
%		Uses formula in Price, Pose Estimation
%
%	See Also MAT2EULER

%input follows optotrak euler angle rigid body format
%optotrak dimensions are (assuming upright position facing camera):
% x = vertical (longitudinal)
% y = lateral (what is left and right???)
% z = a_p (towards/away from camera) larger values = greater distance from camera???
%
% the angles are then defined as (following Price, Pose Estimation: An Introduction):
% eule(1) = psi = rotation about z axis, (positive rotation is from x to y), aka "roll"
% eule(2) = phi = rotation about y axis, (positive rotation is from z to x), aka "pitch"
% eule(3) = the = rotation about x axis, (positive rotation is from y to z), aka "yaw"

%rotation appears to be defined in the order the, phi, psi


cosall=cos(eule);
sinall=sin(eule);
cospsi=cosall(:,1);
cosphi=cosall(:,2);
costhe=cosall(:,3);

sinpsi=sinall(:,1);
sinphi=sinall(:,2);
sinthe=sinall(:,3);


rotmat=[...
       (cosphi.*cospsi)  ((sinthe.*sinphi.*cospsi) - (costhe.*sinpsi))  ((costhe.*sinphi.*cospsi) + (sinthe.*sinpsi));...
       (cosphi.*sinpsi)  ((sinthe.*sinphi.*sinpsi) + (costhe.*cospsi))  ((costhe.*sinphi.*sinpsi) - (sinthe.*cospsi));...
             -sinphi                        sinthe.*cosphi                                 costhe.*cosphi        ];
           
       return;
       

%

%matlab quatdemo refers to the euler angles as follows
%and gets the rotation matrix by simply multiplying the three simple rotation
% x * y * z
% This is almost certainly equivalent to the above, but I haven't checked it yet
% Note, however, the different assignment of angle letters to rotation axes.
%
% x : phi   : roll
% y : theta : pitch
% z : psi   : yaw

% The angle names make sense in the standard matlab arrangement of 3d axes used for the
% aeroplane in the example, i.e 
% x = a-p
% y = lateral
% z = up down


cosphi=cosall(:,3);
costhe=cosall(:,2);
cospsi=cosall(:,1);

sinphi=sinall(:,3);
sinthe=sinall(:,2);
sinpsi=sinall(:,1);


%multiplication of the elementary 2D rotations, about x, y and z axis, in that order

rotmat=     [1           0         0 
             0           cosphi  sinphi
             0          -sinphi  cosphi]  ...
            * ...
            [costhe      0        -sinthe 
             0           1         0
             sinthe      0         costhe] ...
            * ...
            [cospsi      sinpsi    0
            -sinpsi      cospsi    0
             0           0         1         ];


return;

% this is taken from the German edition of Goldstein, Klassische Mechanik, Chap. 4 p. 120


rotmat=[...
       (cospsi.*cosphi)-(costhe.*sinphi.*sinpsi)  (cospsi.*sinphi)+(costhe.*cosphi.*sinpsi) sinpsi.*sinthe;...
      (-sinpsi.*cosphi)-(costhe.*sinphi.*cospsi) (-sinpsi.*sinphi)+(costhe.*cosphi.*cospsi) cospsi.*sinthe;...
                 sinthe.*sinphi                            -sinthe.*cosphi                       costhe        ];
           

