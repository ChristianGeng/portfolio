function mtnew(cutfile,recpath,reftrial,signalspec,cmdfile,mysession)
% MTNEW Multichannel display for data in MAT files
% function mtnew (cutfile,recpath,reftrial,signallist,cmdfile,mysession)
% mtnew: Version 23.08.02
%
%	Syntax
%		cutfile: MAT segmentation file containing (at least) variables data and label
%		recpath: common part of signal filename
%		reftrial: number (as string; e.g.'001') of reference (or typical trial); 
%			main use is currently just to know how many digits are used to code trial number in the file names
%		signalspec: string matrix to associate internal signal names with parameters in MAT files
%			see MT_SSIG for syntax
%		cmdfile: Optional: Command file name. See PHILINP and PHILCOM
%		mysession: Optional. Use to distinguish sessions when multiple copies of mtnew are run simultaneously
%
%	See also
%		PHILINP for details of how command line or command file input is parsed

global MT_SESSION_NUMBER
MT_SESSION_NUMBER=1;

if nargin>5 MT_SESSION_NUMBER=mysession;end;

helpme('mtcmdhlp','Quickstart');

%initialize command file control
cmdarg=0;
if nargin>4 cmdarg=cmdfile;end;
philcom(cmdarg);


%==============================================
%end of general initialization
%==============================================

mt_org(cutfile,recpath,reftrial);
fighorg=mt_gfigh('mt_organization');

%key assignments, 5.99, must be after mt_org
mt_skey;				%new version 9.98


ncut=mt_gcufd('n');
if ~ncut return; end;

mt_ssig(signalspec);
signallist=mt_gcsid('signal_list');

%turn off all organization axes except current_cut
mt_toav(str2mat('signal_axis','cut_file_axis','trial_axis'));

%if audio obviously present, show in current_cut axis of organization figure

iaudp=strmatch('audio',lower(signallist),'exact');
if ~isempty(iaudp) 
   audname=deblank(signallist(iaudp(1),:));
   myh=findobj(fighorg,'type','axes','tag','current_cut_axis');
	myS=get(myh,'userdata');
	myS.maxmin_signal=audname;
      set(myh,'userdata',myS);
   end;
   

%set up default time display
mt_setft(mt_gcsid('signal_list'));    

fighmain=mt_gfigh('mt_f(t)');		%no longer a very good name

%audio initialization
if ~isempty(iaudp)
   audiochan=audname;
else
   
	audiochan=deblank(signallist(1,:));
end;
mt_scsid('audio_channel',audiochan);

%=======================================================================
% Enter main command loop
%=======================================================================

mtkm;

%Tidy up to finish

%store analysis data as mat file
%removed !!
mt_lmark;         %store any markers


%store last session.......

%ensure all figs deleted!
figlist=mt_gfigd('figure_list');
figlist=str2mat(figlist,'mt_organization');
nf=size(figlist,1);
figpos=zeros(nf,4);
for ii=1:nf
   htmp=mt_gfigh(deblank(figlist(ii,:)));
    figpos(ii,:)=get(htmp,'position');
   delete(htmp);
   
end;

save mtxfigpos figlist figpos

fclose ('all');

colordef white
