function[H, X2dot, Deltasquare, Avtaxdist]=rota_ini(X1,X2,methodSpec);
% ROTA_INI: Finds Rotation Matrix to superimpose X2 on X1. 
% function[H, X2dot, Deltasquare, Avtaxdist]=rota_ini(X1,X2,methodSpec)
% ROTA_INI: Version 28.03.2012
%
%   Input Arguments:
%       X1,X2: nx3 matrices of points, with X1 being the target of rotation 
%       methodSpec: Algorithm used to calculate the transformations,
%           + Procrustes: Use algortithm as desribed in Rohlff & Slice
%           + Horn:      Use the Algorithm as described in Horn (1987)
%
%   Output Arguments: 
%       H: 3x3 Matrix of Rotations
%       X2dot: Target-rotated version of input data X2
%       Deltasquare: Sum of squared Distances in x,y,z - Positions (summed
%           over all sensors
%       Avtaxdist: Average taxonomic distance
%            
%   Updates
%       3.2012 Choice of methods introduced.
%           Definition of Avtaxdist changed.
%           previously it was:
%               Avtaxdist=sqrt(Deltasquare/np); (where np equals number of
%               sensors)
%               Now it is:
%               Avtaxdist=nanmean(eucdistn(X1,X2dot)); (average over
%               sensors of euclidean distance between target location and
%               transformed input data)
%
%   Notes
%       [V,D] = eig(A) produces matrices of eigenvalues (D) and eigenvectors (V)
%       [U,S,V] = svd(X) produces a diagonal matrix S of the same dimension as X, with nonnegative diagonal elements in decreasing order, and unitary matrices U and V so that X = U*S*V'
%           , V, Sigma
%       The Horn method requires the SpinCalc function of John Fuller. The
%       subversions repository includes a version downloaded from the
%       mathworks website in March 2012
%
%   See Also REGE_H, RIGIDBODYANA, SPINCALC

method='Procrustes';
if (nargin>2)
    method=methodSpec;
end


M=X1'*X2; % Procrustes as well as Horn are beased on the Minor Product Moment
          % i.e. the sum of products of coordinates measured in each of the
          % coordinate systems. (see Horn, p. 635)

switch method
    case 'Procrustes'     
%         disp('really using Procrustes')
        %rrr=rank(M);
        %disp(['rota_ini rank : ' int2str(rrr)]);
        
        [U, Sigma, V]=svd(M);
        
        % reflection elimination makes this bit of code (Rohlf & Slice) superfluous: 
%         S=sign(diag(diag(Sigma)));
%         H=V*S*U';
%         
        H=V*U';
        ReflectionPresent = (det(H) < 0);
        if ReflectionPresent
            disp('rota_ini(Procrustes): fixing reflection');
           V(:,end) = -V(:,end);
            Sigma(end,end) = -Sigma(end,end);
        end
        
        H = V*U';
        
    case 'Horn'
%         disp('really using Horn')
        % Rewrite this matrix using single element indexing (also p.635)
        S_xx = M(1,1); S_xy = M(1,2); S_xz = M(1,3);
        S_yx = M(2,1); S_yy = M(2,2); S_yz = M(2,3);
        S_zx = M(3,1); S_zy = M(3,2); S_zz = M(3,3);
        
        
        % Properties of N: 
        N = [(S_xx+S_yy+S_zz)   S_yz-S_zy           S_zx-S_xz           S_xy-S_yx; ...
            S_yz-S_zy          (S_xx-S_yy-S_zz)     S_xy+S_yx           S_zx+S_xz; ...
            S_zx-S_xz           S_xy+S_yx           (-S_xx+S_yy-S_zz)   S_yz+S_zy; ...
            S_xy-S_yx           S_zx+S_xz           S_yz+S_zy           (-S_xx-S_yy+S_zz)];
        
        % find most positive eigenvalue of N, which corresponds to the unit quaternion
        % representing the rotation
        [e,d] = eig(N);
        d = diag(d);
        [v,k] = sort(d);
        % The quaternion are the eigenvectors corresponding to the sorted
        % eigenvalues: 
        quat = e(:,k(end));
        quat0 = quat(1); quatx = quat(2); quaty = quat(3); quatz = quat(4);
        
        % quaternion to rotation matrix conversion(p641). Requires SpinCalc
        H=SpinCalc('QtoDCM',[quatx quaty quatz quat0],1e-6,0);
        
        H=H';
        V=NaN;
        Sigma=NaN;
        
        
        
    case '3-point'
%         warning('3 point algorithm currently flawed')
%         disp('really using 3-point')
        [M_l]=getMadjoin(X1);
        [M_r]=getMadjoin(X2);
        
        R=M_r*M_l';
        H=R;
        V=NaN;
        Sigma=NaN;
        
        
        
    otherwise
        warning('ROTA_INI: Unknown method.');
end


X2dot=X2*H;
np=size(X1,1);
Deltasquare=trace((X1-X2dot)*(X1-X2dot)');
%changed, phil 9.02
%Avtaxdist=sqrt(Deltasquare/2);
%Avtaxdist=sqrt(Deltasquare/np);
%changed again, phil 03.2012
Avtaxdist=nanmean(eucdistn(X1,X2dot));

function [M]=getMadjoin(data);
% Calculation of adjoint matrix of vector compoenents
% used for the calculation of rotations based on
% triads,
%
% adopted from Horn, (Section 2A).
%
% Reference(s):
% Horn, Berthold(1987). Closed Form Solution of absolute orientation using unit
% quaternions. Journal of the Optical Society of America A, Vol. 4, page
% 629.
%

r_l1=(data(1,:));
r_l2=(data(2,:));
r_l3=(data(3,:));

% r_r1=(center(1,:));
% r_r2=(center(2,:));
% r_r3=(center(3,:));

% 1) x_l, xhat_l
x_l=r_l2-r_l1;
% This calculates a unit vector in the direction of the
% new x axis in the left-hand system:
xhat_l=x_l/norm(x_l);
% check that the result is a unit vector with this
% statement(resulting r=1):
%[theta,phi,r]=cart2sph(xhat_l(1),xhat_l(2),xhat_l(3))

% 2) y_l, yhat_l
% which is the component of
% (r_l3-r_l1) that is is perpendicular to xhat.
tmp=(r_l3-r_l1);
tmp2=dot(tmp,xhat_l);
y_l=tmp-(tmp2*xhat_l);
% bring to unit length vector again:
yhat_l=y_l/norm(y_l);
% The check that vector is of unit length:
%[theta,phi,r]=cart2sph(yhat_l(1),yhat_l(2),yhat_l(3))

% 3) z_l
zhat_l=cross(xhat_l,yhat_l);
% check that vector is of unit length:
%[theta,phi,r]=cart2sph(zhat_l(1),zhat_l(2),zhat_l(3))
M=[xhat_l;yhat_l;zhat_l];


