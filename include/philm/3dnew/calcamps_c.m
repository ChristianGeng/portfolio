function CAmps = CalcAmps(P, O, x) 
% P = Positionen im Cube-System (Autokal)
%       n*3-Matrix (in millimeter (converted to metres by autokal2tapad))
%
% O = Orientierungen im Cube-System (Autokal)
%       n*2-Matrix (Phi, Theta) in Grad
%

% Achtung!
% --------
% Das Autokal-Koordinatensystem heiﬂt jetzt auch Cube-System.
% Das TAPAD-Koordinatensystem heiﬂt jetzt auch Logic-System 
%
% In diesen Skripten stehen noch die alten Bezeichnungen....

O=O.*pi/180;

if nargin == 2,
    PT = Autokal2TAPAD(P); 						% transform to TAPAD co-ordinates
    OT = 1000*Autokal2TAPAD(AngleToVec(O(:,1), O(:,2))); 
else,
    PT = P;
    OT = AngleToVec(O(:,1), O(:,2));
end;

%disp('in calcamps')
%pause;
[CAmps, LocalPos, H] = SC_CalcLocalPos(PT, OT); % calculate Signals

unorm=2.53362555799256;
CAmps=CAmps.*unorm;
