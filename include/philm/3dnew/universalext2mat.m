%for calcfieldvec
%read universal.ext and store as mat file
fid = fopen('Universal.ext','r'); % *.ext-File �ffnen
% Es ist auch vorgesehen unterschiedliche *.ext-Files f�r die verschiedenen
% Sendespulen zu verwenden. Dann m�sste hier anhand der Variable 'Coil' das
% entsprechende File gew�hlt werden. Zur Zeit wird aber nicht zwischen den
% Spulen unterschieden.
% (Die *.ext-Files enthalten eine Beschreibung des Magnetfeldes, das durch
% die Sendespule aufgebaut wird.)

status=fseek(fid,(8),'bof'); % Einen Double-Werte �berspringen (Versions-Information)
for k = 1:3
   for t = 1:20
      [spr(k,t,:),count]=fread(fid,20,'double');
   end;
end;

status=fclose(fid);

save universal_ext spr
