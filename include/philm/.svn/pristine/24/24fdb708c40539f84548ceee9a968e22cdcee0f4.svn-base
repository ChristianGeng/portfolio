function mtkmt
% MTKMT mt user commands main_timeshift
% function mtkmt
% mtkmt: Version 13.12.2000

persistent K
kname='mt';
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
   
   timdat=mt_gdtim;
   dttmp=diff(timdat);
   oldtim=timdat;
   curdat=mt_gcurp;
   sampincmax=mt_gcsid('max_sample_inc');   
   
   if command==K.t0
      timdat(1)=abart ('T0 in s.',timdat(1),mt_gccud('start'),mt_gccud('end')-sampincmax,abnoint,abscalar);
      timdat(2)=timdat(1)+dttmp;           
   end;
   
   if command==K.duration
      dttmp=abart ('Time in s.',dttmp,sampincmax*3,realmax,abnoint,abscalar);
      %max should be set to length of cut??
      timdat(2)=timdat(1)+dttmp;            
   end;
   
   %skip ===================================
   %lower case forwards, upper case backwards
   
   
   if command==K.skipforwards
      timdat(1)=timdat(2);
      timdat(2)=timdat(1)+dttmp;
   end;
   if command==K.skipbackwards
      timdat(2)=timdat(1);
      timdat(1)=timdat(2)-dttmp;
   end;
   if command==K.start2left
      timdat(1)=curdat(1);
      timdat(2)=timdat(1)+dttmp;
   end;
   if command==K.end2left
      timdat(2)=curdat(1);
      timdat(1)=timdat(2)-dttmp;
   end;
   if command==K.start2right
      timdat(1)=curdat(2);
      timdat(2)=timdat(1)+dttmp;
   end;
   if command==K.end2right
      timdat(2)=curdat(2);
      timdat(1)=timdat(2)-dttmp;
   end;
   if command==K.start2start
      timdat(1)=mt_gccud('start');
      timdat(2)=timdat(1)+dttmp;
   end;
   if command==K.end2end
      timdat(2)=mt_gccud('end');
      timdat(1)=timdat(2)-dttmp;
   end;
   
   if command==K.zoomin2cursor
   	timdat=curdat;   
   end;
   
   if command==K.zoomout2cut
   	timdat=[mt_gccud('start') mt_gccud('end')];   
   end;
   
   %12.2000, position defined in current_cut_a
   if ((command==K.centre2cutpos) | (command==K.startend2cutpos))
      
      oldfh=gcf;
      oldxh=gca;
      figh=mt_gfigh('mt_organization');
      axh=findobj(figh,'type','axes','tag','current_cut_axis');
      
      
      %save mouse position
      %This is important for unix systems, should be irrelevant but harmless for Windows
      %mouse is moved into target figure
      %after choosing points mouse will be restored to old location
      %assumed this was in the command window
      oldmousep=get(0,'pointerlocation');
      figurepos=get(figh,'position');
      %set mouse to middle of figure
      figurepos(1:2)=figurepos(1:2)+(figurepos(3:4)./2);
      set(0,'pointerlocation',figurepos(1:2));
      
      
      if command==K.centre2cutpos
         disp('Choose centre of new screen position by clicking in current cut display of mt_organization figure');
         figure(figh);
         axes(axh);
         [gx,gy,gb]=ginput(1);
         if length(gx)==1
         	tmp=gx-dttmp/2;
            timdat=[tmp tmp+dttmp];
         else
            disp('Wrong number of mouse clicks?');
         end;
         
      end;
      
      if command==K.startend2cutpos
         disp('Choose start and end of new screen position by clicking twice in current cut display of mt_organization figure');
         figure(figh);
         axes(axh);
         [gx,gy,gb]=ginput(2);
         if length(gx)==2
            timdat=[min(gx) max(gx)];
         else
            disp('Wrong number of mouse clicks?');
         end;
         
      end;
      
      %restore current figure, and previous pointer position
      figure(oldfh);
      axes(oldxh);
      set(0,'pointerlocation',oldmousep);
   end;
   
   
   
   
   
   if command==K.start2mstart
      tmp=mt_gmark('start');
      if ~isempty(tmp)
         if ~isnan(tmp)
            timdat(1)=tmp;
            timdat(2)=timdat(1)+dttmp;
         end;
      end;
   end;
   if command==K.start2mend
      tmp=mt_gmark('end');
      if ~isempty(tmp)
         if ~isnan(tmp)
            timdat(1)=tmp;
            timdat(2)=timdat(1)+dttmp;
         end;
      end;
   end;
   if command==K.end2mstart
      tmp=mt_gmark('start');
      if ~isempty(tmp)
         if ~isnan(tmp)
            timdat(2)=tmp;
            timdat(1)=timdat(2)-dttmp;
         end;
      end;
   end;
   if command==K.end2mend
      tmp=mt_gmark('end');
      if ~isempty(tmp)
         if ~isnan(tmp)
            timdat(2)=tmp;
            timdat(1)=timdat(2)-dttmp;
         end;
      end;
   end;
   
   if command==K.bookmark
      tmp=mt_getft('bookmark');
      if ~isempty(tmp)
         if ~isnan(tmp)
            timdat(2)=tmp+(dttmp/2);	%i.e centre at bookmark
            timdat(1)=timdat(2)-dttmp;
         end;
      end;
   end;
   
   
   timdat=sampincmax*round(timdat./sampincmax);
   if timdat(1) < mt_gccud('start')
      timdat(1)=mt_gccud('start');
      timdat(2)=timdat(1)+dttmp;
   end;
   if timdat(1) < (mt_gccud('end')-sampincmax)
      if any(timdat~=oldtim)
         mt_sdtim(timdat);
      end;
      
      
   else
      disp ('No more data in cut!');
   end;
   
   
end;		%while not return
