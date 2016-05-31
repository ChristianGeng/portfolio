function mtkmd
% MTKMD mt user commands main_display
% function mtkmd
% mtkmd: Version 01.06.04

%update 6.04. plotedit command moved here as explicit command
%   (previously automatically activated in main menu)

persistent K
kname='md';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;


while command~=K.return
   mystring=philinp([kname '> ']);
   if isempty(mystring)
      command=K.return;
   else
      command=abs(mystring(1));
   end;
   commandback=mtkcomm(command,K,'return');
   if commandback command=commandback; end;
   
   
   if command==K.foreground
      forename=abartstr('Foreground figure',mt_gfigd('foreground'),mt_gfigd('figure_list'),abscalar);
   	mt_sfigd('foreground',forename);   
   end;
   
   if command==K.plotedit
      mt_propedit;
   end;
   
   if command==K.setxy
      mtkmdx;
   end;
   
      
   if command==K.settime
      mtkmdt;
   end;
   
      
   if command==K.setorganization
      mtkmdo;
   end;
   
   
end;		%while not return
