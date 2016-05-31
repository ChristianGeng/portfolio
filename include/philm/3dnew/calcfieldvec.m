function H = CalcFieldVec(LocalPos,Coil);
% LocalPos = Mx3 - Matrix, M = size(alphas,1)
%            (Positionen im Spulenkoordinatensystem)
% Coil = Integer, number of Coil (1-6)
% 
% returns Mx3 - Matrix H containing the local 
% x-,y- and z-component of the magnetic field-vectors.
%
% Eine Vektorkomponente wird folgendermaßen berechnet:
% 
% Sum[t=0:19] (Sum[r=0:19] (spr(k,t,r)*(1/(RO^r)))*(th^t))
%
% spr ist ein 3x20x20-Array mit Koeffizienten
% k=1 ist x, k=2 ist y, k=3 ist z
%
% Abschließend wird das Feld noch um die X-Achse gedreht
% 
% Übertragen in Mathlab am 5.4.2004 von Nico Schug

%disp('in calcfieldvec');
%pause;

Positions = size(LocalPos,1); % Anzahl der zu berechnenden Vektoren (entspricht M)


Rxy = sqrt(LocalPos(:,1).^2 + LocalPos(:,2).^2); % Radien der Projektion in XY-Ebene

RO = sqrt(LocalPos(:,1).^2 + LocalPos(:,2).^2 + LocalPos(:,3).^2); % Radien der Orte


NichtNull = (Rxy < -eps) | (Rxy > eps);			% cs enthält:
cs = [ones(Positions,1) zeros(Positions,1)];		% 
cs(NichtNull,1) = LocalPos(:,1)./Rxy;				% Richtungscosinus gegen x-Achse und
cs(NichtNull,2) = LocalPos(:,2)./Rxy;				% Richtungssinus gegen y-Achse       für jede Position
% Im Fall: Rxy nahe Null wird cs(1) auf eins und cs(2) auf null gesetzt.

th = asin(LocalPos(:,3)./RO);	% Berechnung der Winkel Theta.
th = (th./pi)*180;

% Einlesen von spr[k, t, r] aus Datei 'SpKo3D.ext' im Ordner Cirkal:

%pre-stored as mat file. See universalext2mat.m

load universal_ext

%fid = fopen('Universal.ext','r'); % *.ext-File öffnen
% Es ist auch vorgesehen unterschiedliche *.ext-Files für die verschiedenen
% Sendespulen zu verwenden. Dann müsste hier anhand der Variable 'Coil' das
% entsprechende File gewählt werden. Zur Zeit wird aber nicht zwischen den
% Spulen unterschieden.
% (Die *.ext-Files enthalten eine Beschreibung des Magnetfeldes, das durch
% die Sendespule aufgebaut wird.)

%status=fseek(fid,(8),'bof'); % Einen Double-Werte überspringen (Versions-Information)
%for k = 1:3
%   for t = 1:20
%      [spr(k,t,:),count]=fread(fid,20,'double');
%   end;
%end;

%status=fclose(fid);

%don't do allocation procedure, takes ages
doalloc=0;

if doalloc

spr2=spr;
disp('allocating')
tic;
a=1;

while a < (Positions)
      a=a+1;
      spr2=cat(4,spr2,spr); % ... Anfügen einer weiteren Zeile für jede Position...
end;								  % -> vorerst in der 4. Dimension
disp('end allocating')
toc;

spr2=permute(spr2,[4 1 2 3]); % Hier werden die angefügten Zeilen tatsächlich zu Zeilen gemacht (Umsortierung der Dimensionen)
end;		%doalloc


H = zeros(Positions,3);	%Initialisierung einer Mx3-Matrix für die Feldvektoren.
ko = zeros(Positions,20);
rp = ones(Positions,1);

% Man möge die for-next-Struktur verzeihen.
% Ich habe es auch mal vektorisiert versucht - das war langsamer....

%disp('loop start')
%tic;
for k=1:3
   for t=1:20
      ko(:,t)=zeros(Positions,1);
%      rp=ones(Positions,1);
      rp=1;
      for r=1:20
%         ko(:,t)=ko(:,t)+spr2(:,k,t,r).*rp;
         ko(:,t)=ko(:,t)+spr(k,t,r).*rp;
         rp=rp./RO;
      end;
   end;
   
   thp=ones(Positions,1);
   for t=1:20
      H(:,k)=H(:,k)+ko(:,t).*thp;
      thp=thp.*th;
   end;
end;

%disp('loop end')
%toc;





Rp = H(:,1).*cs(:,1)-H(:,2).*cs(:,2);		% Feld um Z-Achse drehen.
H(:,2) = H(:,1).*cs(:,2)+H(:,2).*cs(:,1);
H(:,1) = Rp;


