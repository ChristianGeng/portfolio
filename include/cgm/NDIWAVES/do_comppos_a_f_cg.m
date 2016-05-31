function do_comppos_a_f_cg(basepath,altpath,triallist,kanallist,comp_sensor,auto_flag,diaryfile)
% function do_comppos_a_f(basepath,altpath,triallist,kanallist,comp_sensor,auto_flag,diaryfile)
% DO_COMPPOS_A_F Auxiliary function to run comppos_fm_cg and plot statistics
% do_comppos_a_f: Version 31.3.09
%
%   Syntax
%       First 4 arguments are compulsory
%           basepath: Path (with backslash) with main position data
%           altpath: Alternative path, to allow comparison of two sets of
%				data processed in different ways. If not required set to empty
%           trialllist, kanallist: Row vectors, list of trials and sensors
%				to show
%           comp_sensor: Comparison sensor. Will be displayed with each
%				sensor in kanallist, and euclidean distance between the two
%				will also be displayed. Set to empty if not required and if
%				auto_flag etc. need to be specified
%           auto_flag: If present and true, pause after each trial. Otherwise, only
%				pause between sensors (==1), and not at all (==2)
%           diaryfile: Name of text file to store the calculated
%           statistics. Mainly for use by AMPVSPOSAMPA. See also PARSESTATS
%
%   Notes
%       Some overlap in functionality with SHOW_TRIALOX. But show_trialox does
%       not allow use of alternative path or comparison sensor. Note also
%       that the statistics calculated are not quite the same!
%       Possible extensions: choice of coordinates to show; choice of
%       statistics
%
%   See Also
%       comppos_fm_cg The function that actually does most of the work
%       SHOW_TRIALOX, PARSESTATS
%
%   Updates
%       5.08 Plot of total and valid data per trial
%		3.09 no stopping at all in keyboard mode if autorun==2
%		3. 09 diary  output modified for easier parsing by parsestats
%			If diary in use, then figures also stored

functionname='do_comppos_a_f_cg: Version 31.3.09';


compsensor=[];
if nargin>4 compsensor=comp_sensor; end;

autoflag=1;
if nargin>5 autoflag=auto_flag; end;

dodiary=0;
if nargin>6
    if ~isempty(diaryfile)
        try
            diary(diaryfile);
            diary off;
            dodiary=1;
			figbase=strrep(diaryfile,'.txt','');
			figbase=strrep(figbase,pathchar,'_');	%should nor normally be needed
			figdir='figs';
			if ~exist(figdir,'dir') mkdir(figdir); end;

		
		catch
            disp('Unable to open diary file');
        end;
    end;
end;


statpic=[1 5 6];        %mean, 2.5 and 97.5%ile

hfstats=figure;
hrpos=get(0,'screensize');
%keyboard;
statspos=get(hfstats,'position');
statspos(1)=hrpos(3)/2;
statspos(2)=hrpos(4)*0.05;
set(hfstats,'position',statspos);

%commpos_fm expects column vector (as additional columns can be used to
%subdivide trial
if size(triallist,2)>size(triallist,1) triallist=triallist'; end;




%colist=[1 2 3];
%standard
colist=[1 2 3 6];       %pos x/y/z and ori z
colist2=[7 8];          %rms/parameter 7

for kanallistb=kanallist
    
    %    [rmsstat,tangstat,eucstat,dtstat,trialn,posstat,oristat]=comppos_f(basepath,altpath,triallist,kanallistb,autoflag,colist);
    %with comparison
    [rmsstat,tangstat,eucstat,dtstat,trialn,costat]=comppos_fm_cg(basepath,altpath,triallist,[kanallistb compsensor],autoflag,colist,colist2);
     
    %pause;
    close all
    if length(triallist)>1
        if dodiary, diary on; end;
        disp('=========');
        disp(['Sensor ' int2str(kanallistb)])
        disp('=========');
        disp(['Total data per trial (max/min/mean): ' int2str([max(trialn(:,1)) min(trialn(:,1))]) ' ' num2str(mean(trialn(:,1)))]);
        disp(['Valid data per trial (max/min/mean): ' int2str([max(trialn(:,2)) min(trialn(:,2))]) ' ' num2str(mean(trialn(:,2)))]);
        titstring=['Sensor ' int2str(kanallistb)];

        hftrialn=figure('position',statspos);
        plot(triallist(:),trialn,'linestyle','-','marker','.')

        title('Total and valid data per trial');
        xlabel('Trial no.');
        set(hftrialn,'name',titstring);
        %pause
        hfstats=figure('position',statspos);
        showstat(rmsstat,triallist,statpic,'rms',1,kanallistb);
        %pause
        showstat(tangstat,triallist,statpic,'tangential velocity',2,kanallistb);
        %pause
        showstat(eucstat,triallist,statpic,'euclidean distance',3,kanallistb);
        showstat(dtstat,triallist,statpic,'parameter 7',4,kanallistb);
        
	if ~isempty(compsensor)
            titstring=[titstring ' (Comp. Sensor ' int2str(compsensor) ')'];
        end;
        set(hfstats,'name',titstring);
        disp('do_comppos_a_f: See behind stats fig for trial n. Type ''return'' to continue');
        if autoflag<2 keyboard; end;
        %pause
        %close all
        if dodiary 
		
			figname=[figdir pathchar figbase '_trialstats_' int2str(kanallistb) '.fig'];
			saveas(hfstats,figname,'fig');
			figname=[figdir pathchar figbase '_trialn_' int2str(kanallistb) '.fig'];
			saveas(hftrialn,figname,'fig');
			
			
			diary off; 
		
		
		end;
    end;
end;

function showstat(x,triallist,statpic,mytitle,isubp,kanalnum);
sdfac=2;
%myprctile=[2.5 97.5];
myprctile=[5 95];
%prctile(eucbuf(:,1),myprctile)

disp(mytitle);

nstat=length(statpic);

tt=triallist(:);
tt=repmat(tt,[1 nstat]);

xx=x(:,statpic);
%figure;
subplot(2,2,isubp)
%plot(tt,xx);
%hold on;
plot(tt,xx,'linestyle','-','marker','.');

title(mytitle);
xlabel('Trial no.');
%should get y units from somewhere

xq=nanmean(xx);
if any(isnan(xq)) return; end;
%sd=nanstd(xx)*sdfac;
%lolim=xq-sd;
%hilim=xq+sd;

try,  xprct=prctile(xx,myprctile);
catch, disp('alarm');keyboard;  end

lolim=xprct(1,:);
hilim=xprct(2,:);
disp(['lolim mean hilim (columns) of stats ' int2str(statpic) ' (rows)']);
allvals=([lolim;xq;hilim])';
disp(allvals);
disp(['Suggested range |' mytitle '(' int2str(kanalnum) ') : ' num2str([min(allvals(:,1)) max(allvals(:,3))])]);
%keyboard;
xsd=nanmean(x(:,2));
sdprct=prctile(x(:,2),myprctile);
disp('lolim mean hilim of trial sds');
disp([sdprct(1) xsd sdprct(2)]);
