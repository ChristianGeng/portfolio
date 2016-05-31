function mt_movie(timspec)
% MT_MOVIE Do movie display of movement trajectories
% function mt_movie(timspec)
% mt_movie: Version 17.04.2009
%
%   Syntax
%       timspec (2-element vector) is time (in s) relative to current trial
%
%   Remarks
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
%
%	Updates
%		Treat all left/right contours as fixed during movie (i.e probably
%		less visible)
%
%   See also
%       MT_XYDIS for xy display. MT_SHOCO and MT_GXYCD for other contour oriented routines

global MT_XYDATA
global MT_XYVDATA

[abint,abnoint,abscalar,abnoscalar]=abartdef;

oldf=gcf;

hxyf=mt_gfigh('mt_xy');
if isempty(hxyf)
	disp ('mt_movie: xy display not initialized');
	return;
end;
%get movie cursor in main window
hmc=mt_gfigd('time_cursor_handles');
hmc=hmc(:,3);

delayfac=1;                       %could be loaded from mat file
delaylim=0.01;                    %1/delaylim is limit on speed up


%use this to get handle of left and right cursors so they can be made invisible
% (or less visible) during movie
[xyindex,sf,timestamp,xycontourh,xycontourhv]=mt_gxycd;


%get movie handles
[xyindex,sf,timestamp,hc,hcv]=mt_gxycd(1);

vactive=~isnan(hcv);

if isempty(xyindex)
	disp('mt_movie: No active axes');
	return;
end;
nax=length(xyindex);

if ((timspec(1)>=timestamp(2))|(timspec(2)<=timestamp(1)))
	disp ('mt_movie: Time spec completely outside xy timestamp');
	return;
end;





audiochan=mt_gcsid('audio_channel');
audiosf=mt_gsigv(audiochan,'samplerate');


[ndat,ntraj]=size(MT_XYDATA{xyindex(1),1});



sampinc=1./sf;

%determine start and end frame
framen=timspec-timestamp(1);
framen=round(framen*sf);
framen(1)=framen(1)+1;

framen(1)=max([framen(1) 1]);
framen(2)=min([framen(2) ndat]);

if diff(framen)<=0
	disp ('mt_movie: 0 frames');
	return
end;

xycs=mt_gfigd('xycursor_settings');
curfree=mt_gfigd('cursor_status');
freep=find(curfree);

%treat free cursors as fixed during movie (e.g no joined lines or vector)
%cf. mt_tcurs
set(xycontourh(:,freep),'linestyle',xycs{1,2},'marker',xycs{2,2});

if all(ishandle(xycontourhv(:)))
	set(xycontourhv(:,freep),'linestyle',xycs{3,2},'marker',xycs{4,2});
end;


tmptime=timestamp(1)+([(framen(1)-1) framen(2)]*sampinc);


figure(hxyf);                 %make sure figure visible

lastdelay=-1;

disp ('Movie delay factor: <1 to speed up, >1 to slow down, 0 to exit');
while delayfac>delaylim
	delayfac=abart('Delay factor',delayfac,0,1./delaylim,abnoint,abscalar);
	if delayfac>delaylim

		ticinterval=sampinc*delayfac;

		%                 set (hc,'linewidth',2);
		set(hc,'visible','on');
		set(hcv(vactive),'visible','on');
		set (hmc,'visible','on');
		lasttoc=-1;
		ifn=-1;

		if delayfac~=lastdelay
			adat=mt_gdata(audiochan,tmptime);
			delayuse=delayfac;
			[adat,delayuse]=mt_praatstretch(adat,delayfac,audiosf);

		end;        %delayfac~=lastdelay

		lastdelay=delayfac;
		mt_audio(adat,[],audiosf/delayuse);

		tic;

		while ifn<framen(2)
			itoc=toc;
			if itoc~=lasttoc
				ifn=framen(1)+round(itoc./ticinterval);

				if ifn<framen(2)
					cuttime=timestamp(1)+((ifn-1)*sampinc);

					for iax=1:nax
						axnum=xyindex(iax);
						set(hc(iax),'xdata',MT_XYDATA{axnum,1}(ifn,:),'ydata',MT_XYDATA{axnum,2}(ifn,:),'zdata',MT_XYDATA{axnum,3}(ifn,:));
						if vactive(iax)
							set(hcv(iax),'xdata',MT_XYVDATA{axnum,1}(ifn,:),'ydata',MT_XYVDATA{axnum,2}(ifn,:),'zdata',MT_XYVDATA{axnum,3}(ifn,:));
						end;

					end;

					%do movie cursor in main window
					set (hmc,'xdata',[cuttime cuttime]);
					drawnow;
					lasttoc=itoc;
				end;	%ifn<
			end; %itoc~=lasttoc
		end;%ifn<


	end;      %delayfac>delaylim
end;
%reset contour???
%        set (hs,'xdata',xbuf,'ydata',ybuf,'zdata',zbuf);
set (hmc,'visible','off');
set(hc,'visible','off');
set(hcv(vactive),'visible','off');

%restore active vector cursors
set(xycontourh(:,freep),'linestyle',xycs{1,1},'marker',xycs{2,1});

if all(ishandle(xycontourhv(:)))
	set(xycontourhv(:,freep),'linestyle',xycs{3,1},'marker',xycs{4,1});
end;




%restore. See note on mt_audio
%mt_scurp(oldcurp);

figure(oldf);
