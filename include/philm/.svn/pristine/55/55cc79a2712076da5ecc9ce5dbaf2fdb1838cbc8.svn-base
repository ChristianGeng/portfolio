function iquit=mtkmi
% MTKMI mt user commands main_i_o
% function iquit=mtkmi
% mtkmi: Version 30.9.99

persistent K
persistent plotcount
persistent plotit

kname='mi';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;
iquit=0;

while command~=K.return
   mystring=philinp([kname '> ']);
   if isempty(mystring)
      command=K.return;
   else
      command=abs(mystring(1));
   end;
   commandback=mtkcomm(command,K,'return');
   if commandback command=commandback; end;
   
   %audio channel setting, use as sonachannel too?
   if command==K.audiochannel
      
      audiochan=abartstr('Audio Channel',mt_gcsid('audio_channel'),mt_gcsid('signal_list'),abscalar);
      mt_scsid('audio_channel',audiochan);
   end;
   %end of audio settings
   
   %plot. Note: Desired figure must be current figure
   if command==K.plot
      plotmax=999;	%abitrary
plotnumchar=length(int2str(plotmax));
      if isempty(plotcount)
         %note: no checks, and only really applies to DOS anyhow
         %maybe prompt for plot device etc. too
         plotprefix=philinp('Plot file path and name  * ');
         plotdevice=philinp('Plot device  [epsc2]  * ');
         if isempty(plotdevice) plotdevice='epsc2';end;
         plotit.prefix=plotprefix;
         plotit.device=plotdevice;
         plotcount=0;   
      end;
      plotcount=plotcount+1;
      if plotcount<=plotmax
         plotname=[plotit.prefix int2str0(plotcount,plotnumchar)];
         try
         eval(['print '  '-d' plot.device ' ' plotname]);
         disp(['Figure ' num2str(gcf) ' printed to ' plotname]);
      catch
         disp('Plot failed!');
         disp(lasterr);
         plotcount=[];
      end;
      
      else
         disp ('Sorry! No more plots possible');
      	plotcount=[];   
      end;
   end;
   
   if command==K.quit
      mys=philinp('Quit: Are you sure [n] ? ');
      if strcmp(mys,'y')
	iquit=1;
        command=K.return;
      end;



   end;
   
   
end;		%while not return
