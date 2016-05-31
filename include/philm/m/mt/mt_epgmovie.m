function mt_epgmovie(timspec)
% mt_epgmovie Do epg movie display
% function mt_epgmovie(timspec)
% mt_epgmovie: Version 13.10.2002
%
%	Syntax
%		timspec (2-element vector) is time (in s) relative to current trial
%
%	Remarks
%       Prompts for factor by which to speed up or slow down.
%       User must enter a factor of 0 to exit from the movie function.
%       factor > 1 to slow down; 0 < factor < 1 to speed up (i.e 0.5 means
%       double speed)
%       If the factor is a power of 2 and >=2 then the program tries to use
%       praat to stretch the audio signal.
%       MT_PRAATSTRETCH may require editing before first use to indicate the correct
%       location of the praat program.
%       (A small praat script called praatstretch.txt is generated in the
%       working directory. This can be edited by the user, if desired. e.g
%       to change default f0 analysis settings for praats PSOLA algorithm)
%		Temporary version, pending merge of mt_video, mt_movie and mt_epgmovie
%
%	See also
%		MT_MOVIE for movie in xy display
%		mt_xydis for xy display. mt_shoco and mt_gxycd for other contour oriented routines


[abint,abnoint,abscalar,abnoscalar]=abartdef;
oldfigh=gcf;

hfepg=mt_gfigh('mt_epg');
if isempty(hfepg)
   disp ('mt_epgmovie: epg display not initialized');
   return;
end;
%get movie cursor in main window
hmc=mt_gfigd('time_cursor_handles');
hmc=hmc(:,3);

delayfac=1;                       %could be loaded from mat file
delaylim=0.01;                    %1/delaylim is limit on speed up


%currently only works for single axes in epg figure
haepg=findobj(hfepg,'type','axes');
epgS=get(haepg,'userdata');
epgsigname=epgS.signal_name;
epgpos=epgS.sensor_position;
hlepg=findobj(haepg,'tag',[epgsigname '_data']);


sf=mt_gsigv(epgsigname,'samplerate');

[epgdata,actualtime]=mt_gdata(epgsigname,timspec);

if isempty(epgdata)
   disp('No epg data for requested time');
   return
end;

nframe=size(epgdata,2);


disp('Time requested and used:');
disp([timspec;actualtime]);



audiochan=mt_gcsid('audio_channel');
audiosf=mt_gsigv(audiochan,'samplerate');

sampinc=1./sf;



figure(hfepg);                 %make sure figure visible


tmptime=actualtime;

lastdelay=-1;


disp ('Movie delay factor: <1 to speed up, >1 to slow down, 0 to exit');
delayfac=abart('Delay factor',delayfac,0,1./delaylim,abnoint,abscalar);

while delayfac>delaylim
   
   %do sound???
   ticinterval=sampinc*delayfac;
   
   totaltime=diff(tmptime)*delayfac;

   
   set (hmc,'visible','on');
   
   
   
   lasttoc=-1;
   lastframe=0;

        if delayfac~=lastdelay
            adat=mt_gdata(audiochan,tmptime);
            delayuse=delayfac;
            [adat,delayuse]=mt_praatstretch(adat,delayfac,audiosf);
            
        end;        %delayfac~=lastdelay
        
        lastdelay=delayfac;
        mt_audio(adat,[],audiosf/delayuse);
   
   
   tic;
   
   itoc=0;
   while itoc<totaltime
      itoc=toc;
      if itoc~=lasttoc
         ifn=round(itoc./ticinterval)+1;
         
         ifn=min([ifn nframe]);
         ifn=max([ifn 1]);		%can't happen here, but maybe in merged function
         
         if ifn~=lastframe
            cuttime=tmptime(1)+((ifn-1)*sampinc);
            
            mt_epgdis(epgdata(:,ifn),epgpos,hlepg)
            
            %do movie cursor in main window
            set (hmc,'xdata',[cuttime cuttime]);
            drawnow;
            lastframe=ifn;
         end;	%ifn ne lastframe
         
         lasttoc=itoc;
      end; %itoc~=lasttoc
   end;%ifn<
   
   delayfac=abart('Delay factor',delayfac,0,1./delaylim,abnoint,abscalar);
   
   
end;

set (hmc,'visible','off');

figure(oldfigh);
