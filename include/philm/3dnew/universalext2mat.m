%for calcfieldvec
%read universal.ext and store as mat file
fid = fopen('Universal.ext','r'); % *.ext-File öffnen
% Es ist auch vorgesehen unterschiedliche *.ext-Files für die verschiedenen
% Sendespulen zu verwenden. Dann müsste hier anhand der Variable 'Coil' das
% entsprechende File gewählt werden. Zur Zeit wird aber nicht zwischen den
% Spulen unterschieden.
% (Die *.ext-Files enthalten eine Beschreibung des Magnetfeldes, das durch
% die Sendespule aufgebaut wird.)

status=fseek(fid,(8),'bof'); % Einen Double-Werte überspringen (Versions-Information)
for k = 1:3
   for t = 1:20
      [spr(k,t,:),count]=fread(fid,20,'double');
   end;
end;

status=fclose(fid);

save universal_ext spr
