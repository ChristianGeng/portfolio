function cutok=mt_next(icut);
% MT_NEXT Set up next cut
% function mt_next(icut);
% mt_next Version 7.10.99
%
%	Syntax
%		icut: Number of cut required
%
%	Remarks
%		This function does not actually redisplay signal data.
%		but loads the appropriate trial, if necessary
%		Routines like mt_shoft and mt_xydis must be called explicitly
%		However, subcut data is shown immediately, so there can be a mismatch
%		between the segments shown and the data visible on the screen!
%		9.98.  subcut display controlled by 'sub_cut_flag' in mt_f(t) figure userdata
%		If  ~= 0 all cuts within the new cut are retrieved and displayed.
%		Will be upgraded to allow only subcuts of a particular type
%		to be retrieved

        %retrieve cut data from cut_file axis
        %and place in current_cut axis
        %search for subsegments and place in current_cut
        %and cursor axes


        %tidy up handles.....
        %function to return cutdata and cutlabels


if nargout cutok=0;end;
figorgh=mt_gfigh('mt_organization');
figmainh=mt_gfigh('mt_f(t)');
%separate function?? Not yet an easy way of setting it
figdata=get(figmainh,'userdata');
subflag=figdata.sub_cut_flag;
hc=findobj(figorgh,'tag','cut_file_axis');
hca=findobj(figmainh,'tag','cursor_axis');
%        hct=get (hc,'title');
%        cutname=get(hct,'string');
cutdata=mt_gcufd;
ncut=size(cutdata,1);
if ((icut<0) | (icut>ncut))
   disp ('mt_next: ?cut number out of range?');
   return;
end;
labels=mt_gcufd('label');
curcut=cutdata(icut,:);
curlabel=deblank(labels(icut,:));

if any(isnan(curcut(1:2)))
   disp('mt_next: Requested cut incomplete');
   return;
end;



%load trial
mystatus=mt_loadt(curcut(4));



%find sub-cuts
%could also be done from trial axis....
nsub=0;
if subflag
   cutdata=mt_gtrid('cut_data');
   labels=mt_gtrid('cut_label');
   %4.99 cf mtxsubcutprep
   vv=find((cutdata(:,1)>=curcut(1)) & (cutdata(:,2)<=curcut(2)) & ((cutdata(:,2)-cutdata(:,1))<diff(curcut(1:2))));
   nsub=length(vv);
   disp(['mt_next: ' int2str(nsub) ' sub-cuts found']);
   %vector vv is needed below!!
end;
nsubold=mt_gscud('n');
hcc=findobj(figorgh,'tag','current_cut_axis');

%12.97 no longer include nsub in userdata

%        ccutS=struct('number',0,'data',[0 1 0 0],'label','','sub_cut_data',[],'sub_cut_label','');
myS=get(hcc,'userdata');
myS.number=icut;
myS.data=curcut;
myS.label=curlabel;

set (hcc,'userdata',myS);
set (hcc,'xlim',[curcut(1) curcut(2)]);

ht=get(hcc,'title');
set (ht,'string',curlabel);


%reset cursor axis to start of cut;
%reposition cursor
%(currently to default position, see mm_sdtim)
%mark all timewaves as invalid????

timdat=mt_gdtim;
timnew=[curcut(1) curcut(1)+diff(timdat)];
mt_sdtim(timnew);

%reset any sub-cut objects in the current_cut_axis
%and in the cursor axis
%must be done regardless of current state of subcut flag
innercuts=[];innerlabel='';
if nsubold
   %current cut axis
   hsu=findobj(hcc,'tag','sub_cut_start');
%   set(hsu,'xdata',0,'ydata',0);
   hl=findobj(hcc,'tag','sub_cut_end');
%   set(hl,'xdata',0,'ydata',1);
	set([hsu;hl],'visible','off');
%cursor axis
   hl(1)=findobj(hca,'tag','sub_cut_start');
   hl(2)=findobj(hca,'tag','sub_cut_end');
   hst=findobj(hca,'tag','sub_cut_label');
	set(hl,'visible','off');
   
   delete (hst);
end;

if subflag
   if nsub
      innercuts=cutdata(vv,:);
      %trim superfluous blanks??, note this removes ALL blanks
      innerlabel=strmdebl(labels(vv,:));
      tempt=innercuts(:,3);
      
      
      figcurh=gcf;
      %current_cut axis
      hsu=findobj(hcc,'tag','sub_cut_start');
      set(hsu,'xdata',innercuts(:,1),'ydata',tempt);
      hl=findobj(hcc,'tag','sub_cut_end');
      set(hl,'xdata',innercuts(:,2),'ydata',tempt);
      
      set([hsu;hl],'visible','on');
      
      %set cursor_axis
      figure(figmainh);
mtxsubcutdis(hca,figdata,innercuts,innerlabel,'mt_next');
      
   end; %nsub
end; %subcuts wanted


%position of cursor axis in current cut axis is done by mt_sdtim
%shoe position of current cut in trial axis

hpos=findobj(figorgh,'tag','current_cut_position');
set (hpos,'xdata',[curcut(1) curcut(2)]);


%set title as title in cursor axis, set visible to on

%adjust font size to title length???
typestr=[' (Type ' int2str(curcut(3)) ') '];

labelstr=curlabel;
labelstr=['"' labelstr '"'];
tlabelstr=mt_gtrid('label');
tlabelstr=[' "' tlabelstr '"'];
trialstr=[' Trial ' int2str(curcut(4))];
cutnumstr=[': Cut ' int2str(icut)];
totalstr=['/' int2str(ncut) '. '];
cutlengthstr=[num2str(diff(curcut(1:2))) ' s.'];

figtitle=[mt_gcufd('filename') cutnumstr totalstr labelstr typestr cutlengthstr trialstr];

disp (figtitle);
htit=get(hca,'title');
%vertical position??, fontsize??
set (htit,'string',figtitle,'visible','on');

%also trial label in fig. name
set (figmainh,'Name',[int2str(figmainh) ': ' get(figmainh,'tag') '. ' figtitle tlabelstr]);



myS.sub_cut_data=innercuts;
myS.sub_cut_label=innerlabel;

set (hcc,'userdata',myS);


%example of maxmin envelope
maxminsignal=mt_gccud('maxmin_signal');
mt_orgmm(hcc,maxminsignal);

if nargout cutok=1;end;

