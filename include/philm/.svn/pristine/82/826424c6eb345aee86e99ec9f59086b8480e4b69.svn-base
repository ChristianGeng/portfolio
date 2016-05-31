function H = CalcFieldVec_tap(LocalPos, PowVal);
% CALCFIELDVEC calculates the magnetic field vector H for the given
%           (local) coordinates. (The same way TAPAD would do it)  
%				PowVal is 3 by default. If size(LocalPos) = Nx3,
%           the result will be a a Nx3 matrix, containing the local 
%           x-,y- and z-component of the magnetic field-vectors.
%     
%           H = CalcFieldVec(phi, theta, r, PowVal);
%
%           Use Amp = FC .* sum(H .* LocalOrientVec, 2); to calculate
%           signal-amplitudes. FC is the normalize factor:             
%           FC = (CalFac / exp(-PowVal * log(RK))); % CalAmp / (CalDistance^PowVal)
%           $Revision: 6.0 $
%   Phil: renamed with suffix tap to avoid collision with Carstens
%   alternative implemenatation

%---------------------------------------------------------------------
% Last Update at $Date: 2003/11/07 16:41:58 $	by	$Locker:  $	
% Copyright © 2003 by Andreas Zierdt, all rights reserved.
%---------------------------------------------------------------------
if (nargin < 4)								% default arguments
	PowVal = 3;
end

[phi, theta, r] = Cart2Sph(LocalPos(:,1), LocalPos(:,2), LocalPos(:,3));

%phil; use version that does not require transposition
Er = AngleToVec(phi, theta);			% radial unit vector (in cartesian coordinates)
%Er = Angles2Vec(phi', theta');			% radial unit vector (in cartesian coordinates)

thetat = abs(theta) - pi/2;
idx = find(theta<0);
thetat(idx) = -thetat(idx);
Et = AngleToVec(phi, thetat);			% tangential unit vector
%Et = Angles2Vec(phi', thetat');			% tangential unit vector
Et(idx, :) = -Et(idx, :);

Fr = 1./r.^PowVal;								% f(r) 

Hr = repmat((2 .* sin(theta)), 1, 3) .* Er;			% radial field component	
Ht = repmat(cos(theta), 1, 3) .* Et;					% tangential

H = repmat(Fr, 1, 3) .* (Hr + Ht);
