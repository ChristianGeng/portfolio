function mtkm
% MTKM mt user commands main
% function mtkm
% mtkm: Version 24.8.02

global MT_SESSION_NUMBER

persistent K

kname='m';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;

[abint,abnoint,abscalar,abnoscalar]=abartdef;

mysession=MT_SESSION_NUMBER;
myprompt=[upper(kname) '> '];
if mysession~=1 myprompt=[upper(kname) '_' int2str(mysession) '> '];end;

iquit=0;

while ~iquit
   drawnow;
%Note: command now a numeric variable
   command=-1;
   
%6.04
% newer version of property editor has some unpredictable effects
% so activate plotedit explicitly as a command in the display menu

%   propedit_on=0;
%   if philcomempty & ~philcomfileactive
%      propedit_on=1;
%      mt_propedit(propedit_on);
%   end;
   
   
   %replace with abartstr???
   mystring=philinp(myprompt);
   
 %  if propedit_on mt_propedit; end;
   
   mystring(isspace(mystring))=[];
   %9.99 no default command, (unless using uicommand dialog via mtkcomm)
   if ~isempty(mystring) command=abs(mystring(1));end;
   
   commandback=mtkcomm(command,K,'show');
   if commandback command=commandback; end;
   
   
   
   if command==K.i_o
      iquit=mtkmi;
   end;
   
   
   
   %next cut
   if ((command==K.next) | (mt_gccud('number')==0))
		ncut=mt_gcufd('n');
      
      mt_lmark;         %store any markers
      cutok=0;
      while ~cutok
         %needs upgrading for all NaN cuts
         cutnum=abart ('Cut number',mt_gccud('number')+1,1,ncut,abint,abscalar);
      	cutok=mt_next(cutnum);
      end;
      %read markers for new cut
      mt_rmark;
      %end of next cut
   end
   
   %time setting==================================
   
   if command==K.timeshift
      mtkmt;
   end;
   
   if command==K.show
      mtkms;
   end;
   
   
   
   %cursor section ==================================
   %block cursor commands if newdat??????
   if command==K.cursor
      mtkmc;
   end;
   
   %Display parameter settings --------------------------------------------------
   
   
   if command==K.display_settings
      
      mtkmd;   
      
      
   end;
   %end of display level commands
   if mt_newft mt_shoft;end;	%automatic update of time display
   
   %end of command loop; iquit is TRUE
end;
