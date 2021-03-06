function myresult=showstats(mymode,triallist,channellist)
% SHOWSTATS Grand means of stats from show_trialox
% function myresult=showstats(mymode,triallist,channellist)
% showstats: Version 15.11.2012
%
%   Description
%       For this function to work the figures created by show_trialox must be
%           present.
%       mymode: Optional. Default to 1. If an unavailable mode is specified
%           this help text will be shown
%       triallist: Optional. Default (also if empty) to all trials currently shown in the figure
%       channellist: Optional. Default to all channels
%       Currently available modes are:
%       1: show sensor coordinates (orientation as phi/theta)
%       2: store sensor coordinates (as mode 1) for use by rtmon_cfg
%       3: Load current start positions in rtmon_cfg and show for selected channels
%       4: Show all show_trialo stats (orientation as unit vector), plus rms and tangential velocity
%       5: Grand total of missing data
%       6: Mean of trial standard deviations (arrangement like mode 4)
%       7: As mode 1 except any channel list is ignored. Store (e.g for use as start positions) with prompting for filename
%		8: Standard deviation of trial means (arrangement like mode 4)
%       myresult: Optional.
%
%
%   Updates
%       10.08 Output argument included. Storage of start positions not
%			restricted to rtmon_cfg (mode 7)
%		2.10 Output to file (mode 7) uses standard file names
%		9.10 Use descriptor (and unit) from user data (to take into account
%			change of show_trialox to give choice of tangential velocity or
%			original parameter 7
%			Added mode 8
%       11.12 Adapt to new version of show_trialox (stats bufs may reserve
%       space for more sensors than are actually in the system)
%
%   See Also SHOW_TRIALOX MAKESTART4RTMON

functionname='SHOWSTATS: Version 15.11.2012';


philcom(1);		%abartstr used in mode 7 (should really initialize at startup)

maxmode=8;

xstats=[];

hf=findobj('type','fig','tag','showtrial_statsfig');
if length(hf)~=1
	disp('Make sure show_trialox figures are present');
	return;
end;


imode=1;
if nargin imode=mymode; end;

if imode<1 | imode>maxmode
	help showstats;
	return;
end;


userdata=get(hf,'userdata');

statxb=userdata.statxb;
statsdb=userdata.statsdb;
nancntb=userdata.nancntb;

%nsensorbuf is here the size of the input buffers
%the actual number of sensors in the system is determined by the length of
%userdata.sensorlist
[ntrial,nsensorbuf]=size(nancntb);

datacols='posx posy posz orix oriy oriz rms tangvel';
dataunits='mm mm mm norm norm norm AD_units mm/s';
if isfield(userdata,'descriptor')
	datacols=strm2rv(userdata.descriptor,' ');
	dataunits=strm2rv(userdata.unit,' ');
end;



trials=1:ntrial;
if nargin>1
	if ~isempty(triallist)
		trials=triallist;
	end;
end;


%check trials and channels in range

%Note: This is the only variable reduced to the channel selection
% REason for not doing this for the other variables is that storage of
% start positions needs all channels

sensorlist=userdata.sensorlist;
%number of sensors in the system
nsensors=size(sensorlist,1);

statxb=statxb(:,:,1:nsensors);
statsdb=statsdb(:,:,1:nsensors);
nancntb=nancntb(:,1:nsensors);


channels=1:nsensors;
if nargin>2 channels=channellist; end;
nsensor=length(channels);
sensorlist=sensorlist(channels,:);

myblanks=(blanks(nsensor))';

maxtrial=userdata.maxtrial;
rowlabels=strcat(int2str(channels'),' : ',sensorlist);
if imode==1
	disp('Means of trial means');
	startpos_sph=stats2start_cartf(statxb(trials,:,channels));
	columnlabels='posx posy posz phi theta';
	disp(columnlabels);
	disp([rowlabels myblanks num2str(startpos_sph)]);
	xstats=startpos_sph;

end;

if imode==7
	disp('Storage of trial means to file (e.g for use as start positions)');
	%note: Like mode 2, ignores channel selection
	startpos=stats2start_cartf(statxb(trials,:,:));
	descriptor=str2mat('posx','posy','posz','phi','theta');
	unit=str2mat('mm','mm','mm','deg','deg');	%should retrieve this from somewhere??
	%    disp(columnlabels);
	%    disp([rowlabels myblanks num2str(startpos_sph)]);
	%    xstats=startpos_sph;
	label=userdata.sensorlist;
	comment=abartstr('Comment to store in file : ');
	comment=['User comment:' crlf comment crlf 'Mean coordinates calculated from first/last/n trials : ' int2str([trials(1) trials(end) length(trials)])];
	comment=framecomment(comment,functionname);
	data=startpos;
	outfile=abartstr('Output file name : ');
	try
		save(outfile,'data','label','descriptor','unit','comment');
	catch
		disp('Unable to store');
		disp(lasterr);
		keyboard;
	end;


end;

%Note that this ignores the channel selection
if imode==2
	disp('Calculation of start positions');
	disp('Type return to continue');
	keyboard;
	makestart4rtmon(statxb(trials,:,:));
end;

if imode==3
	if exist('rtmon_cfg.mat')
		startposin=mymatin('rtmon_cfg','startpos');
		if ~isempty(startposin)
			startposin=startposin(channels,:);
			disp('Current start positions');
			columnlabels='posx posy posz phi theta';
			disp(columnlabels);
			disp([rowlabels myblanks num2str(startposin)]);
		end;
	end;
	xstats=startposin;


end;

if imode==4
	disp('Means of trial means');
	columnlabels=datacols;
	columnunits=dataunits;
	disp(['Cols.: ' columnlabels]);
	disp(['Units: ' columnunits]);
	xstats=ones(nsensor,size(statxb,2))*NaN;
	for ii=1:nsensor
		isensor=channels(ii);
		tmp=statxb(trials,:,isensor);
		xstats(ii,:)=mynanmean(tmp);
	end;

	disp([rowlabels myblanks num2str(xstats)]);
end;
if imode==8
	disp('Standard deviation of trial means');
	if length(trials)>1
		columnlabels=datacols;
		columnunits=dataunits;
		disp(['Cols.: ' columnlabels]);
		disp(['Units: ' columnunits]);
		xstats=ones(nsensor,size(statxb,2))*NaN;
		for ii=1:nsensor
			isensor=channels(ii);
			tmp=statxb(trials,:,isensor);
			xstats(ii,:)=nanstd(tmp);
		end;

		disp([rowlabels myblanks num2str(xstats)]);
	else
		disp('Only available if more than one trial in list');
	end;

end;

if imode==5
	tmp=nancntb(:,channels);
	if size(tmp,1)>1
		xstats=nansum(tmp);
	end;

	xstats=xstats';
	columnlabels='Total NaN count over all selected trials';
	disp(columnlabels);
	disp([rowlabels myblanks num2str(xstats)]);
end;

if imode==6
	disp('Means of trial standard deviations');

	columnlabels=datacols;
	columnunits=dataunits;
	disp(['Cols.: ' columnlabels]);
	disp(['Units: ' columnunits]);

	xstats=ones(nsensor,size(statxb,2))*NaN;
	for ii=1:nsensor
		isensor=channels(ii);
		tmp=statsdb(trials,:,isensor);
		xstats(ii,:)=mynanmean(tmp);
	end;

	disp([rowlabels myblanks num2str(xstats)]);
end;

if nargout myresult=xstats; end;



function xquer=mynanmean(x);
%2nd input arg not available in version 6
%    xquer=nanmean(x,1);

if size(x,1)>1
	xquer=nanmean(x);
else
	xquer=x;
end;

