function mt_smark(iwant,mvec,arg3);
% MT_SMARK Set markers
% function mt_smark(iwant,mvec,arg3);
% mt_smark: Version 16.3.2009
%
%	Syntax
%
%		iwant
%			'start','end','cut','label','type','status','source_cut'
%
%		mvec 
%			List of markers. If absent or empty defaults to current marker.
%
%		arg3 
%			For 'start', 'end' and 'cut': optional explicit list of times.
%				Defaults to current active cursor position ('start' and 'end') or both cursors ('cut')
%			For 'label', string matrix of labels
%			For 'status' and 'source_cut' vector of editflag and cutnumber settings
%				defaults to all zeros
%
%	Examples
%		mt_smark({'start'|'end'|'cut'})
%		mt_smark({'start'|'end'|'cut'},markerlist)
%		mt_smark({'start'|'end'|'cut'},markerlist,markertimes)
%		mt_smark('type',markertype) to set current marker
%		mt_smark('label',[],markerlabel) to label current marker
%		mt_smark('label',markerlist,labellist)
%
%	See also
%		MT_IMARK: initialize markers; MT_SMARK: Set markers; MT_CMARK: clear markers;
%		MT_LMARK: log markers to disk; MT_GMARK: get markers
%		MT_SMARX: Sets complete fields in userdata (and doesn't do any graphics)
%
%	Notes
%		'cut' mode not yet implemented
%
%	Graphics
%
%		1. Cursor axis of the main time figure, and other time figures
%			line 'markerstart'
%				userdata markertype (1..nmark)
%			line 'markerend'
%				userdata markertype (1..nmark)
%				linetype '--'
%			text 'markerlabel'
%				position(1) follows xdata of markerstart
%
%		2. Current cut axis of the organization figure
%			text 'marker_org'
%				position [0 currentmarker]
%				string filename of output cut file
%				userdata [nmarker currentmarker]
%
%	Updates
%		3.09 yticklabel for cut type taken from cut type labels in new
%		field type_labels_use

orgdat=mt_gmarx;
if isempty(orgdat) return; end;
maxmark=orgdat.n_markers;
curmark=orgdat.current_marker;
hac=orgdat.marker_axes_handles;
hacc=findobj(mt_gfigh('mt_organization'),'tag','current_cut_axis');


if nargin<2 mvec=curmark; end;
if isempty(mvec) mvec=curmark; end;



%special case iwant==label

if strcmp(iwant,'label')
   %shouldn't really happen
   if nargin<3
      mystring='';
   else
      %check this is a string
      mystring=arg3;
   end;
   %allow same string for multiple markers
   if isempty(mystring) mystring=' ';end;
   ns=size(mystring,1);
   nv=length(mvec);
   
   if nv>ns mystring=rpts([nv 1],mystring); end;
end;


%check marker list in range
if any(mvec<1)|any(mvec>maxmark)
   disp('mt_smark: markers out of range');
   return
end;

lm=length(mvec);
ln=size(mvec,2);
mlist=mvec;
if lm~=ln mlist=mlist';end;


if strcmp(iwant,'status')
   if nargin<3
      newstatus=zeros(lm,1);
      disp('mt_smark: Resetting status');
   else
      newstatus=arg3;
   end;
   if length(newstatus)~=lm
      disp('mt_smark: Status vector wrong length');
      return;
   end;
   
   orgdat.status(mvec)=newstatus;
   mt_smarx('status',orgdat.status);
   disp(['mt_smark: Status set ' int2str(mlist')]);
 %  disp(mlist);
   return;
end;



if strcmp(iwant,'source_cut')
   if nargin<3
      newstatus=zeros(lm,1);
      disp('mt_smark: Resetting source_cut');
   else
      newstatus=arg3;
   end;
   if length(newstatus)~=lm
      disp('mt_smark: Source_cut vector wrong length');
      return;
   end;
   
   orgdat.source_cut(mvec)=newstatus;
   mt_smarx('source_cut',orgdat.source_cut);
   disp(['mt_smark: Source_cut set' int2str(mlist')]);
%   disp(mlist);
   return;
end;



if strcmp(iwant,'type')
   
   oldmark=curmark;
   %warning if mvec not scalar???
   curmark=mvec(1);
if curmark<1 | curmark>maxmark
	disp('MT_SMARK: cut type out of range');
	return;
end;

   if isfield(orgdat,'type_labels_use')
	   tmplab=orgdat.type_labels_use;
	   ticklab=deblank(tmplab(curmark,:));
	   set(hac,'yticklabel',ticklab);
	   set(hacc,'yticklabel',ticklab);
   end;
   
	   
   
   %   ticklab=get(hac,'yticklabels');
%   ticklab(oldmark,1)=' ';
%   ticklab(curmark,1)='>';
%   set(hac,'yticklabels',ticklab);
%set(hac,'ytick',0.5+(curmark/(maxmark*2)));   
set(hac,'ytick',curmark);   
 set(hacc,'ytick',curmark);  
   mt_smarx('current_marker',curmark);
%   hmo=findobj(hacc,'tag','marker_org');
%   set(hmo,'position',[0 curmark]);
   disp(['mt_smark: marker type set to ' int2str(curmark)]);
   return;
end;



%sort out time spec
if ~strcmp(iwant,'label')
   
   
   %needs sorting out for cut mode
   
   
   if nargin<3
		curh=mt_gcurh;curh=curh(1,:);
      tt=mt_gcurp(curh);
      mtime=NaN;
      curfree=mt_tcurs(curh,1);
      ifree=find(curfree==1);
      if ~isempty(ifree) mtime=tt(ifree(1));end;
   else
      mtime=arg3;
   end;
   
   
   %possible combinations of mvec and mtime length
   % 1. simple case, both 1
   % 2. mvec >1 and mtime 1, set all to this time
   % 3. mvec and mtime same length but both >1
   
   lm=length(mvec);
   if lm>1 & length(mtime)==1 mtime=ones(lm,1).*mtime;end;
   if lm~=length(mtime)
      disp('mt_smark: marker and time lists do not match');
      return;
   end;
end;        %not label

lm=length(mvec);

startorg=orgdat.start;
endorg=orgdat.end;
labelorg=orgdat.label;
mstatus=orgdat.status;






if strcmp(iwant,'start')
   if any(mtime>=endorg(mvec))
      disp('mt_smark: Bad start mark position');
      return;
   end;
   startorg(mvec)=mtime;
   hso=findobj(hacc,'tag','marker_start');
   set(hso,'xdata',startorg);	%current cut axis
   
   mt_smarx('start',startorg);
   for ii=1:lm
      mytime=mtime(ii);
      mymark=mvec(ii);
      hlx=findobj(hac,'tag','marker_start','userdata',mymark);
      htx=findobj(hac,'tag','marker_label','userdata',mymark);
      
      set(hlx,'xdata',[mytime;mytime]);
      pp=get(htx(1),'position');
      txttime=mytime;if isnan(mytime) txttime=0;end;
      pp(1)=txttime;
      set(htx,'position',pp);
      if ~isnan(mytime)
%      disp(['mt_smark: Start marker set ' int2str(mymark)]);
      else
%      disp(['mt_smark: Start marker cleared ' int2str(mymark)]);
		end;      
   end;
   
end;   %start


if strcmp(iwant,'end')
   if any(mtime<=startorg(mvec))
      disp('mt_smark: Bad end mark position');
      return;
   end;
   endorg(mvec)=mtime;
   hso=findobj(hacc,'tag','marker_end');
   set(hso,'xdata',endorg);	%current cut axis
   
   mt_smarx('end',endorg);
   for ii=1:lm
      mytime=mtime(ii);
      mymark=mvec(ii);
      hlx=findobj(hac,'tag','marker_end','userdata',mymark);
      
      set(hlx,'xdata',[mytime;mytime]);
      if ~isnan(mytime)
%      disp(['mt_smark: End marker set ' int2str(mymark)]);
      else
 %     disp(['mt_smark: End marker cleared ' int2str(mymark)]);
		end;      
      
   end;
   
end;   %end



if strcmp(iwant,'label')
   for ii=1:lm
      mymark=mvec(ii);
      htx=findobj(hac,'tag','marker_label','userdata',mymark);
      tstr=deblank(mystring(ii,:));
      set(htx,'string',tstr);
      labelorg{mymark}=tstr;
   end;
   
mt_smarx('label',labelorg);end;   %label



mstatus(mvec)=1;


mt_smarx('status',mstatus);
