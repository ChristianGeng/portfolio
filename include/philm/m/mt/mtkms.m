function mtkms
% MTKMS mt user commands main_show
% function mtkms
% mtkms: Version 22.08.2013

persistent K
kname='ms';
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
   
   
   if command==K.timedisplay
      
      %if new data is required all channels must be redisplayed
      if mt_newft
         mt_shoft;
         drawnow;
      end
      %end of display (default command)
   end
   
   
   %xy display 1. between cursors
   if command==K.xycursor
      mt_xydis(mt_gcurp);
   end;
   
   %xy display 2. on screen data
   if command==K.xyscreen
      mt_xydis(mt_gdtim);
   end;
   
   %sona display 1. between cursors
   if command==K.sonacursor
      mt_sonadis(mt_gcurp);
   end;
   
   %sona display 2. on screen data
   if command==K.sonascreen
      mt_sonadis(mt_gdtim);
   end;
   
   if command==K.moviecursor
      mt_movie(mt_gcurp);
      
   end;
   
   if command==K.moviescreen
      mt_movie(mt_gdtim);
      
   end;
   
   if command==K.videocursor
      mt_video(mt_gcurp);
      
   end;
   
   if command==K.videoscreen
      mt_video(mt_gdtim);
      
   end;
   if command==K.surfcursor
      mt_surf(mt_gcurp);
      
   end;
   
   if command==K.surfscreen
      mt_surf(mt_gdtim);
      
   end;
   if command==K.epgcursor
      mt_epgmovie(mt_gcurp);
      
   end;
   
   if command==K.epgscreen
      mt_epgmovie(mt_gdtim);
      
   end;
   
   
end;		%while not return
