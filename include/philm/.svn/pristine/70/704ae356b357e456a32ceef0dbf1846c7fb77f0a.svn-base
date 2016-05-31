function [Amps, LocalPos, H] = SC_CalcLocalPos(GoListTapad, OrientVectors);

[NumPoints, dummy] = size(GoListTapad);

ODS2	= 1/sqrt(2);							% "OneDividedbySqrt2" equals cos(45)
Deg	= 180/pi; 	Rad = pi/180;			% express angles in [°] or [rad]
mm		= 1E-3; 		cm	 = 1E-2; 	


einsdw2  = 0.70710678118654752440084436210485;   %  1 / Wurzel(2) 
weindrt  = 0.577350269189625764509148780501957;  %  Wurzel(1/3)
wzweidr  = 0.816496580927726032732428024901964;  %  Wurzel(2/3)
weinsix  = 0.408248290463863016366214012450982;  %  Wurzel(1/6)


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
	
CoilTrans(:,:,1)=[0 0 -1; einsdw2 -einsdw2 0; -einsdw2 -einsdw2 0];
CoilTrans(:,:,2)=[weindrt weinsix einsdw2; -weindrt -weinsix einsdw2; weindrt -wzweidr 0];
CoilTrans(:,:,3)=[-einsdw2 -einsdw2 0; 0 0 1; -einsdw2 einsdw2 0];
CoilTrans(:,:,4)=[weindrt -wzweidr 0; -weindrt, -weinsix, -einsdw2; weindrt weinsix -einsdw2];
CoilTrans(:,:,5)=[-einsdw2 einsdw2 0; einsdw2 einsdw2 0; 0 0 -1];
CoilTrans(:,:,6)=[weindrt weinsix -einsdw2; -weindrt wzweidr 0; weindrt weinsix einsdw2];

												% local coordinate basis vector expressed in terms of the
for coil=1:6									% global (TAPAD) coordinate system!
	% Calc inverse matrix, which describes the global (TAPAD) coordinate basis vectors in terms of
	% each local coordinatesystem
	InvCoilTrans(:,:,coil) = inv(CoilTrans(:,:,coil));
end


% Entsprechend der Go-Liste werden lokale Positionen und resultierende Feldvektoren für die 6 Sender berechnet
LocalPos = zeros(NumPoints, 3, NumCoils); 
H = LocalPos;
LocalOrientVec = zeros(NumPoints, 3, NumCoils);			% Sensororientierung
Amps = zeros(NumPoints, NumCoils);

for Coil=1:NumCoils						
%	disp(Coil)
	% Translation in lokale Koordinaten
	LocalPos(:, :, Coil) = GoListTapad -  repmat(RK*CoilPos(Coil, :), NumPoints, 1); % translate
	% und Rotation in lokale Koordinaten
	for i=1:NumPoints
		LocalPos(i, :, Coil) = 	(InvCoilTrans(:,:,Coil) * LocalPos(i, :, Coil)')'; %rotate

		LocalOrientVec(i, :, Coil) = 	(InvCoilTrans(:,:,Coil) * OrientVectors(i,:)'); %local orientation
	end


    
%	disp('fieldvec start')
	H(:,:, Coil) = CalcFieldVec(LocalPos(:,:,Coil), Coil); 			% calculate magnetic field vectors
%	disp('fieldvec end')
	if Coil==1,
        H(:,:,Coil);
    end

	Amps(:, Coil) = sum(H(:,:,Coil) .* LocalOrientVec(:, :, Coil), 2);

end
%LocalPos;
