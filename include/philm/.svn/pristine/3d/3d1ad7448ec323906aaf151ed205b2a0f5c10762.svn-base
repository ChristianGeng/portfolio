function TAPAD_Pos = Autokal2TAPAD(Autokal_Pos);
% AUTOKAL2TAPAD converts the Nx3 matrix with N XYZ-Positions
%           from the Autokal into the TAPAD co-ordinate system. 
%           Notice that the function implicit rescales the
%           positions (m <--> mm), so to transform orientation-vectors
%           use: TAPAD_OrientVec = 1000 * Autokal2TAPAD(Autokal_Orient);        
%
%           $Revision: 6.1 $

%---------------------------------------------------------------------
% Last Update at $Date: 2003/11/07 16:41:54 $	by	$Locker:  $	
% Copyright © 2003 by Andreas Zierdt, all rights reserved.
%---------------------------------------------------------------------

% Matrix for co-ordinate transformation Autokal -> TAPAD 
T = [-0.57735026874962  -0.70710678015087  -0.40824829055736;...
	   0.57735026874962  -0.70710678015087   0.40824829055736;...
  	  -0.57735026874962   0.00000000000000   0.81649658111471];

TAPAD_Pos = 1/1000 * (T * Autokal_Pos')';								
