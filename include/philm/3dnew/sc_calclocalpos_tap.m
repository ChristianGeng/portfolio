function [Amps, LocalPos, H] = SC_CalcLocalPos_tap(GoListTapad, OrientVectors);
%function [Amps, LocalPos, H] = SC_CalcLocalPos_tap(GoListTapad, OrientVectors);
%   Phil: renamed with suffix tap to avoid collision with Carstens
%   alternative implementation

[NumPoints, dummy] = size(GoListTapad);

ODS2	= 1/sqrt(2);							% "OneDividedbySqrt2" equals cos(45)
Deg	= 180/pi; 	Rad = pi/180;			% express angles in [°] or [rad]
mm		= 1E-3; 		cm	 = 1E-2; 	
NumCoils = 6;		

% Local co-ordinates and transmitter alignment, does not consider negative 
% "Transmitter Polarity" settings, which results in negative CoilAlign! 
RK		= 0.3375;								% radius of the coil-mounting structure
CoilPos = [0 0 -1; 0 -1 0; -1 0 0;...	% Transmitter - coil positions (CoilPos*RK)
			  0 0 1;  0 1 0;   1 0 0]; 
CoilAlign= [1 0 0; ODS2    ODS2 0;...	% Transmitter - coil alignment
				0 1 0; 0       ODS2 ODS2;...
				0 0 1; ODS2    0    ODS2];
CoilTrans= zeros(3,3,6);					% 6 rotary matrices for local coordinate transformation
InvCoilTrans= zeros(3,3,6);				% each column contains the x-, y- and z-coordinate of the
													% local coordinate basis vector expressed in terms of the
for coil=1:6									% global (TAPAD) coordinate system!
	CoilTrans(:, 3, coil) = CoilAlign(coil, :)'; % local z = orientation of coil axis	
	% the local y axis is perpendicular to a line connecting the coil with TAPAD-Orign and local z
	CoilTrans(:, 2, coil) = cross(CoilPos(coil, :), CoilAlign(coil, :))';
	CoilTrans(:, 2, coil) = CoilTrans(:, 2, coil) ./ norm(CoilTrans(:, 2, coil));
	% local x is perpendicular to z and y (and equal -CoilAlign for T1,3,5) 
	CoilTrans(:, 1, coil) = cross(CoilTrans(:, 2, coil), CoilTrans(:, 3, coil)); 
	if norm(CoilTrans(:, 1, coil)) > 0;
		CoilTrans(:, 1, coil) = CoilTrans(:, 1, coil) ./ norm(CoilTrans(:, 1, coil));
	end
	% Calc inverse matrix, which describes the global (TAPAD) coordinate basis vectors in terms of
	% each local coordinatesystem
	InvCoilTrans(:,:,coil) = inv(CoilTrans(:,:,coil));
end


% Entsprechend der Go-Liste werden lokale Positionen und resultierende Feldvektoren für die 6 Sender berechnet
LocalPos = zeros(NumPoints, 3, NumCoils); H = LocalPos;
LocalOrientVec = zeros(NumPoints, 3, NumCoils);			% Sensororientierung
Amps = zeros(NumPoints, NumCoils);

for Coil=1:NumCoils						
	% Translation in lokale Koordinaten
	LocalPos(:, :, Coil) = GoListTapad -  repmat(RK*CoilPos(Coil, :), NumPoints, 1); % translate
	% und Rotation in lokale Koordinaten
	for i=1:NumPoints
		LocalPos(i, :, Coil) = 	(InvCoilTrans(:,:,Coil) * LocalPos(i, :, Coil)')'; %rotate

		LocalOrientVec(i, :, Coil) = 	(InvCoilTrans(:,:,Coil) * OrientVectors(i,:)'); %local orientation
	end

	H(:,:, Coil) = CalcFieldVec_tap(LocalPos(:,:,Coil)); 			% calculate magnetic field vectors
	H =   1 / exp(-3 * log(RK)) .* H;

	Amps(:, Coil) = sum(H(:,:,Coil) .* LocalOrientVec(:, :, Coil), 2);

end

