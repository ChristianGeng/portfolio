function vec = AngleToVec(phi, theta);
% ANGLETOVEC converts the two angles into a 3-dimensional  
%           orientation-vector. (The same way TAPAD would do it)        
%           vec = AngleToVec(phi, theta);
%           Phi is the azimuth or horizontal rotation and theta is the 
%           vertical elevation (both in radians). Azimuth revolves about 
%           the z-axis, with positive values indicating counter-clockwise 
%           rotation of the vector. Positive values of elevation correspond 
%           to moving above the 'equator'; negative values move below.
%           Ranges: phi (-pi .. +pi), theta (-pi/4 .. +pi/4)
%
%           If phi and theta are vectors with length N, the result will be a
%           a Nx3 matrix. 
%           $Revision: 5.3 $

%---------------------------------------------------------------------
% Last Update at $Date: 2001/08/16 18:45:09 $	by	$Locker:  $	
% Copyright © 2001 by Andreas Zierdt, all rights reserved.
%---------------------------------------------------------------------

vec = zeros(length(phi), 3);
vec(:, 1) = cos(theta).*cos(phi);
vec(:, 2) = cos(theta).*sin(phi);
vec(:, 3) = sin(theta);

