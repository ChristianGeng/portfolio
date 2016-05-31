function enscuttw(cutname,recpath,reftrial,reclist,reflabels,labelgrpl,outsuffix,timeshift,autoflag,chanlim,exportmode)
% ENSCUTTW Ensemble averages controlled by cut file with time warping
% function enscuttw(cutname,recpath,reftrial,reclist,reflabels,labelgrpl,outsuffix,timeshift,autoflag,chanlim,exportmode)
% enscuttw: Version 08.12.2011
%
%	Syntax
%       cutname:    Cutfile with same number of contiguous segments for
%          every trial. Signals are time-warped on a segment-by-segment basis
%          to have the same durations as the segments of the reference trial.
%          To do traditional ensemble averages about a line-up point with no
%          time-warping, set up a cut file with one equal-length segment per
%          trial (e.g 100ms before/after vowel onset).
%           Note: All cuts for each utterance must have same label
%		reflabels: List of labels to identify trial to use as reference for each ensemble
%		labelgrpl: vector of indices for selecting the part of the label to use when defining groups for the ensembles
%           Can also be a cell array with two entries: first one as just
%           described, second one a vector of indices for selecting the
%           part of the label to indentify individual items (may be useful
%           if segment labels for the same item differ slightly, but still
%           allow unambiguous identification of each item). If not present
%           the complete label is used
%		outsuffix: Added to cut name to form output filename
%		timeshift: Optional. If not present or empty default to zero. Amount in (s) by which to shift the signals
%			Use positive values for emg if the activity is assumed to occur before it
%			is reflected in the audio signal (and assuming the segmentation for the time-warping
%			is based on the audio signal). If present there must be one value for each signal
%		autoflag: Optional; if present and true skip interactive confirmation for adding tokens to the ensemble
%           If autoflag is a cell array of size ensembles*signals then each cell
%           element is treated as a list of trials to use. This allows
%           ensembles to be regenerated quickly with e.g different
%           time-shifts. The cell array can be taken from the enstrial variable
%           of the output file (i.e choose trials by hand first time
%           through)
%           Note: this may not work quite as expected if there can be more
%           than one item per trial
%       chanlim: Optional. Y axis scaling for each channel
%       exportmode: Optional, default to 1. If 1, the raw and timewarped
%           data of the individual trials is stored in addition to the
%           ensembles (set to 0 to turn this off, e.g. if the output files get too big, and one is not interested in the raw data)
%
%   Notes
%       A diary file named [cutname '_enscuttwdiary.txt'] is created.
%       This should be examined at the end for any warnings of unexpected
%       events, e.g segment types do not match for reference trial and
%       other trials in the ensemble. This diary file may get quite big if
%       a lot of signals are being processed. So it may be worth doing a
%       preliminary run with just one signal to check for problems (since
%       any warning messages will be repeated for every signal processed)
%
%	Updates
%		Add cutduration buffer (segment durations for all items analyzed
%		for first signal in list)
%       12.2011 store raw data for individual trials (plus time
%       specification). Storage of the raw data (and of the time-warped
%       data of individual trials) can be turned off using the new
%       exportmode input argument

functionname='enscuttw: Version 08.12.2011';

diaryname=[cutname '_enscuttwdiary.txt'];
diary(diaryname);


%warpexport set by input argument exportmode
warpexport=1;   %determines whether warped and raw data for individual trials is stored in addition to ensembles
domedian=0;     %should be input arg???
plotpath='ensplot';    %should be input arg??  if not empty used as path name to store figures
skiptypes=0;        %should also be input argument. Cut types that are eliminated before processing starts

	plotpathx=plotpath;
	
%uses cutname for plot output
vp=findstr(pathchar,cutname);
if ~isempty(vp)
	plotpathx=[plotpath pathchar cutname(1:(vp(end)-1))];
end;
mkdir(plotpathx);

ncut=mt_org(cutname,recpath,reftrial);
mt_ssig(reclist);

signal_list=mt_gcsid('signal_list');


nchan=size(signal_list,1);	%should be same as reclist
sigunit=cell(nchan,1);




for ii=1:nchan sigunit{ii}=mt_gsigv(deblank(signal_list(ii,:)),'unit'); end;

ne=size(reflabels,1);

tshift=zeros(nchan,1);
if nargin>7
    if length(timeshift)==nchan
        tshift=timeshift;
    end;
    
end;

disp('Timeshifts')
disp(tshift);
keyboard;

autotrial=[];
autoflaguse=0;
if nargin>8
    autoflaguse=autoflag;
    if iscell(autoflaguse)
        if all(size(autoflaguse)==[ne nchan])
            autotrial=autoflaguse;
            autoflaguse=1;
        end;
    end;
    
end;

doyscale=0;
if nargin>9
    if ~isempty(chanlim) doyscale=1; end;
end;

if nargin>10
    if ~isempty(exportmode) warpexport=exportmode; end;
end;



%initialize 1 panel for each signal and 3 lines in each panel for ref, ensemble and current signal

hf=figure;

collist='rgb';

for ii=1:nchan
    hax(ii)=subplot(nchan,1,ii);
    mysig=deblank(signal_list(ii,:));
    set(hax(ii),'tag',mysig);
    ylabel([mysig '(' sigunit{ii} ')'],'interpreter','none','fontweight','bold')
    hl(ii,1)=line([0;1],[0;1],'tag',[mysig '_ref'],'color',collist(1));
    hl(ii,2)=line([0;1],[0;1],'tag',[mysig '_ens'],'color',collist(2));
    hl(ii,3)=line([0;1],[0;1],'tag',[mysig '_cur'],'color',collist(3));
end;

set(hl,'clipping','off');


cutdata=mt_gcufd('data');
cutlabel=mt_gcufd('label');

vv=find(ismember(cutdata(:,3),skiptypes));		%eliminate e.g. trial and grouping segments
if ~isempty(vv)
    cutdata(vv,:)=[];
    cutlabel(vv,:)=[];
end;

maxtype=max(cutdata(:,3));		%for setting up cut duration buffer

%make it possible to eliminate extraneous parts of the full label
labeliteml=1:size(cutlabel,2);
if iscell(labelgrpl)
    labeliteml=labelgrpl{2};
    labelgrpl=labelgrpl{1};
end;


%initialize ensemble buffers???

%use cell array as signals may have different samplerates
%store the ensemble data itself, its time axis (from the reference trial) and its standard deviation

ensdatab=cell(ne,nchan);
enstimeb=cell(ne,nchan);
ensvarb=cell(ne,nchan);

%these variables will only contain data if exportmode is 1 (default)
%(otherwise they are still stored, but will be empty)
warpxb=cell(ne,nchan);      %for storage of all warped data
rawdata2warp=cell(ne,nchan);    %note: unlike warpxb each element will in turn be a cell array, because the raw unwarped data will have different lengths
rawdatatime=cell(ne,1);         %time vectors for raw data. Assume same time for each signal. Mainly to check data has been assembled correctly if multiple segments

cutdurationb=cell(ne,1);

%store trials used in ensembles
%and labels. Could be useful e.g with warped data for e.g subsequent
%normalization by repetition

enstrial=cell(ne,nchan);
ensitemlabel=cell(ne,nchan);

%store segment data for each ensemble
%will be needed later in order to line up different ensembles

enscutb=cell(ne,1);

for ie=1:ne
    reflabel=deblank(reflabels(ie,:));
    disp([int2str(ie) ' ' reflabel]);
    
    vv=strmatch(reflabel,cutlabel,'exact');
    
    if isempty(vv)
        disp('reflabel not found?');
        return
    end;
    
    
    
    rd=cutdata(vv,:);
    disp('cuts in reference trial');
    disp(rd);
    
    cl=rd(:,2)-rd(:,1);
    if any(cl<=0)
        disp('segmentation error? bad cut length');
        disp(cl);
        keyboard;
        return;
    end;
    
    %normally cuts should be contiguous. Certainly should not overlap
    if size(rd,1)>1
        gapl=rd(2:end,1)-rd(1:(end-1),2);
        
        if any(gapl~=0)
            disp('Warning: cuts not contiguous (ref trial)?');
            disp('gaps')
            disp(gapl);
            disp('cut data');
            disp(rd);
            if any(gapl<0)
                disp('segmentation error? overlapping cuts');
                keyboard;
                return;
            end;
            keyboard;
        end;
    end;
    
%also check each cut type only occurs once
    
    enscutb{ie}=rd;
    
    
    reftrial=rd(1,4);
    
    loadresult=mt_loadt(reftrial);
    if ~loadresult
        disp(['No signal data for reference trial ' int2str(reftrial) '; unable to continue']);
        keyboard;
        return;
    end;
    
    
    
    reftime=[min(rd(:,1)) max(rd(:,2))];
    %round the times to samplepositions
    mysig=deblank(signal_list(1,:));
    sfx=mt_gsigv(mysig,'samplerate');
    reftime=round(reftime*sfx)./sfx;
    
    %loop thru signals to display ref data
    
    for ichan=1:nchan
        mysig=deblank(signal_list(ichan,:));
        sfx=mt_gsigv(mysig,'samplerate');
        
        %round the times to samplepositions
        %superfluous if tshift a multiple of sample increment and all
        %signals have same samplerate
        reftx=round((reftime-tshift(ichan))*sfx)./sfx;
        
        %      keyboard;
        
        %oscitype must be timewave!!!
        [refdata,oscitype]=mt_getmm(mysig,reftx,diff(reftx));
        
        %there's a problem if reference data not available for complete
        %segment, so use interpolation
        
        
        refdata(:,1)=refdata(:,1)+tshift(ichan);		%need to add timeshfit back on, after using with mt_getmm
        enstime=(reftime(1):(1./sfx):reftime(2))';
        try
            refi=interp1(refdata(:,1),refdata(:,2),enstime);
        catch
            disp('Problem interpolating reference trial');
            disp(lasterr);
            keyboard;
            return;
        end;
        
        enstimeb{ie,ichan}=enstime;
        ensdata=refi;
        
        %display ref
        set(hl(ichan,1),'xdata',enstime,'ydata',ensdata);
        
        tmpdata=ensdata*NaN;
        %display ensemble
        set(hl(ichan,2),'xdata',enstime,'ydata',tmpdata);
        
        %also initialize as current signal
        set(hl(ichan,3),'xdata',enstime,'ydata',tmpdata);
        
        
        ymin=min(ensdata);
        ymax=max(ensdata);
        if ymin==ymax
%note: unusual signal only checked for in ref segment
            disp(['Unexpected values in ' mysig]);
            disp([ymin ymax]);
%    keyboard;
    ymax=ymin+1;
        end;
        
        if doyscale
            ymin=chanlim(ichan,1);
            ymax=chanlim(ichan,2);
        end;
        
        set(hax(ichan),'xlim',[reftime(1) reftime(2)],'ylim',[ymin ymax]);
        
        
        %display cut boundaries here, or specific to each trial
        axes(hax(ichan));
        htmp=findobj(gca,'tag','cutstart','type','line');
        if ~isempty(htmp) delete(htmp); end;
        htmp=findobj(gca,'tag','cutend','type','line');
        if ~isempty(htmp) delete(htmp); end;
        
        
        nrseg=size(rd,1);
        hlseg1=line([rd(:,1)';rd(:,1)'],repmat([ymin;ymax],[1 nrseg]),'tag','cutstart');
        hlseg2=line([rd(:,2)';rd(:,2)'],repmat([ymin;ymax],[1 nrseg]),'tag','cutend');
        
        
        
    end;
    
    
    
    enslabel=reflabel(labelgrpl);
    
    axes(hax(1));
    title([enslabel '. (r=ref, g=ens, b=cur)'],'fontweight','bold','fontsize',12,'interpreter','none');
    
    
    
    %get unique list of item labels that match enslabel
    
    
    vv=strmatch(enslabel,cutlabel(:,labelgrpl));
    tmpl=cutlabel(vv,:);

    ulabellist=unique(tmpl(:,labeliteml),'rows');
    ntrial=size(ulabellist,1);      %not strictly speaking trials
    
    
    disp([int2str(ntrial) ' trials for ensemble ' enslabel]);
    disp(ulabellist);
    
    %loop thru all trials for each signal
    
    for ichan=1:nchan
        
        mysig=deblank(signal_list(ichan,:));
        disp(mysig);
        sfx=mt_gsigv(mysig,'samplerate');
        sampinc=1./sfx;
        
        ensdata=ensdatab{ie,ichan};
        
        %enstime is not changed; identical to the vector of samplepositions of the ref trial for this signal
        enstime=enstimeb{ie,ichan};
        
        itemsdone=[];
        trialsdone=[];
        rawb=cell(ntrial,1);    %store data (and times) before warping
        rawt=cell(ntrial,1);
		if ichan==1
			cutduration=ones(ntrial,maxtype)*NaN;
		end;
		
        for idodo=1:ntrial

            vvl=strmatch(ulabellist(idodo,:),cutlabel(:,labeliteml));
            
            %         keyboard;
            curd=cutdata(vvl,:);
            curl=cutlabel(vvl,:);
            
            itrial=unique(curd(:,4));
            disp(itrial);
            if length(itrial)~=1
                disp('Trial not unique for this label');
                disp(ulabellist(idodo,:));
                disp(curd);
                keyboard;
                return;
            end;
            
            if length(curd(:,3)) ~= length(unique(curd(:,3)))
                disp('Cut types not unique; unable to continue');
                disp([curl num2str(curd)]);
                keyboard;
                return;
            end;

            %timewarping is based on cut types present for both current data and warped data
            if size(curd,1)~=size(rd,1)
                disp('Different numbers of segments in reference trial and current trial');
                disp('Only the intersection of cut types will be used');
                disp('Check for possible inconsistencies in use of label');
                disp('Ref. trial:')
                disp(rd);
                disp('Current trial (segments with matching label):');
                disp([curl num2str(curd)]);
            end;
            
                
            
            [ct,icp,irp]=intersect(curd(:,3),rd(:,3));
            curduse=curd(icp,:);
            rduse=rd(irp,:);
            
            %make sure still sorted by time (intersect may have changed this)
            
            [dodo,isp]=sort(rduse(:,1));
            rduse=rduse(isp,:);
            curduse=curduse(isp,:);
            
            %check segments for current data
            cl=curduse(:,2)-curduse(:,1);
            if any(cl<=0)
                disp('segmentation error? bad cut length');
                disp(cl);
                disp('cut data')
                disp(curduse);
                keyboard;
                return;
            end;
            
            %normally cuts should be contiguous. Certainly should not overlap
            if size(curduse,1)>1
                gapl=curduse(2:end,1)-curduse(1:(end-1),2);
                
                if any(gapl~=0)
                    disp('Warning: cuts not contiguous?');
                    disp(gapl);
                    disp('cut data');
                    disp(curduse);
                    if any(gapl<0)
                        disp('segmentation error? overlapping cuts');
                        keyboard;
                        return;
                    end;
                    keyboard;
                end;
                
            end;
            
            
            
            %round the times to samplepositions
            rduse(:,1:2)=round(rduse(:,1:2)*sfx)./sfx;
            
            %allow for timeshift in signal here
            curduse(:,1:2)=round((curduse(:,1:2)-tshift(ichan))*sfx)./sfx;
            
            %display the cut boundaries in rduse????
            
            ncut=size(rduse,1);
            
            
            
            
            
            warptime=[];
            warpdata=[];
            
diary off
            loadresult=mt_loadt(itrial);
 diary on
            if loadresult
                %loop thru cuts
                for icut=1:ncut
diary off;      
                    disp(curduse(icut,:));
diary on;
                    sampincwarp=sampinc*(diff(rduse(icut,1:2))./diff(curduse(icut,1:2)));
                    
                    %allow for emg delay????
                    
                    cutit=curduse(icut,1:2);
					if ichan==1
%		keyboard;
                        cutduration(idodo,curduse(icut,3))=diff(cutit);
					end;
					
					%make sure no extrapolation needed in interp1 for the last
                    %point
                    if icut==ncut cutit(2)=cutit(2)+(2*sampinc); end;
                    tmpd=mt_gdata(mysig,cutit);
                    nd=length(tmpd);
                    wtmp=(rduse(icut,1)+(0:(nd-1))*sampincwarp)';
                    warptime=[warptime;wtmp];
                    warpdata=[warpdata;tmpd];
                end;
                
                %now generate data for current trial at sample positions in reference trial
                
                %most likely problems for interpolation would result from segmentation errors
                %they should have been taken care of above
                %Also seems to happen if the signal file is missing for a trial
                %for which there is a segmentation. Would be better to catch
                %this above after mt_loadt
                try
                    
                    warped=interp1(warptime,warpdata,enstime);
                    
                catch
                    disp('Problem during interpolation');
                    disp(lasterr);
                    keyboard;
                    warped=ones(length(enstime),1)*NaN;
                    %                return;
                end;
                
                %display the warped data
                set(hl(ichan,3),'ydata',warped);
                drawnow;
                
                %shouldn't normally happen in e.g EMG, but normal in F0
                if any(isnan(warped))
                    disp('nans in warped data');
                    %keyboard;
                end;
                
                %add to ensemble after prompt, or control by list for regeneration
                
                myans='n';
                if autoflaguse
                    if ~isempty(autotrial)
                        trialcheck=autotrial{ie,ichan};
                        if any(itrial==trialcheck) myans='y'; end;
                    else
                        myans='y';
                    end;
                    
                    
                else
                    
                    myans=lower(abartstr('Add to ensemble ','y'));
                end;
                
                if strcmp(myans,'y')
                    
                    %disp('adding warped to ensemble')
                    %                keyboard;
                    ensdata=[ensdata warped];
                    if size(ensdata,2)>1
                        if domedian
                            enssig=(nanmedian(ensdata'))';
                        else
                            enssig=(nanmean(ensdata'))';
                        end;
                        
                    else
                        enssig=ensdata;
                    end;
                    oldens=get(hl(ichan,2),'ydata');
                    set(hl(ichan,2),'ydata',enssig);
                    drawnow;
                    trialsdone=[trialsdone itrial];
                    itemsdone=[itemsdone idodo];
                    %if in non-auto mode allow for second thoughts
                    if ~autoflaguse
                        myans=lower(abartstr('ok ','y'));
                        if strcmp(myans,'n')
                            
                            ensdata(:,end)=[];	%remove last token
                            trialsdone(end)=[];
                            itemsdone(end)=[];
                            
                            %restore display of old ensemble
                            set(hl(ichan,2),'ydata',oldens);
                            drawnow;
                        end;
                    end;
                end;
                
                rawb{idodo}=warpdata;
                rawt{idodo}=warptime;
                
                drawnow;
            else
                disp(['No signal data for trial ' int2str(itrial)]);
            end;
            
            
        end;		%trial loop
        
        if warpexport
            warpxb{ie,ichan}=ensdata;
            rawdata2warp{ie,ichan}=rawb;
            rawdatatime{ie}=rawt;       %actually only retain for last signal
        end;
        
        
        disp('end of trial loop')
        %        keyboard;
        
        
        %maybe also store n for each sample point
        
        if domedian
            ensdatab{ie,ichan}=(nanmedian(ensdata'))';
        else
            ensdatab{ie,ichan}=(nanmean(ensdata'))';
        end;
        
        %disp('computing variance')
        %        keyboard;
        ensvarb{ie,ichan}=(nanstd(ensdata'))';
        enstrial{ie,ichan}=trialsdone;
        
        ensitemlabel{ie,ichan}=ulabellist(itemsdone,:);
        
		if ichan==1
		cutdurationb{ie}=cutduration(itemsdone,:);
		end;
		
        
    end;			%signal loop
    %disp('end of signal loop')
    
    
    %store each time through in case of disasters
    save([cutname outsuffix],'ensdatab','ensvarb','enstrial','enstimeb','enscutb','signal_list','reflabels','labelgrpl','timeshift','warpxb','cutdurationb','rawdata2warp','rawdatatime');
    
    set(hl(:,[1 3]),'visible','off');
    set(hl,'clipping','off','linewidth',2);
    
    
    if ~isempty(plotpath)
        saveas(hf,[plotpath pathchar cutname outsuffix '_' int2str(ie)],'fig');
    end;
    
    set(hl(:,[1 3]),'visible','on');
    
    %   keyboard;
    
end;					%ensemble loop


%store ensembles
%keyboard;


%units

unit=char(sigunit);
comment=mymatin(cutname,'comment','<No comment in cut file>');

[cut_type_label,cut_type_value]=getvaluelabel(cutname,'cut_type');
%cut_type_label=mymatin(cutname,'cut_type_label');
%cut_type_value=mymatin(cutname,'cut_type_value');

%should include explanation of variables here
comment=framecomment(comment,functionname);


save([cutname outsuffix],'ensdatab','ensvarb','enstrial','enstimeb','enscutb','signal_list','reflabels','labelgrpl','timeshift','comment','unit','warpxb','ensitemlabel','cutdurationb','rawdata2warp','rawdatatime');

%try and include cut type labels

if exist('cut_type_label','var')
    if ~isempty(cut_type_label)
        save([cutname outsuffix],'cut_type_label','cut_type_value','-append');
    end;
end;

colordef white
diary off
