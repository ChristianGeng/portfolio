function mt_shoft
% MT_SHOFT  Show f(t) display, i.e basic time-wave display routine
% function mt_shoft
% mt_shoft: Version 7.10.2001
%
%	Description
%		Must be called to actually generate a display after using routines
%		like mt_next and mt_sdtim to choose the segment of interest
%
%	See Also MT_SETFT, MT_SDTIM

%Note:
% It is essential that no input from ginput can come from an inactive
%	axis, as its time setting may not be uptodate.
%	If this turns out to be a problem, then is may be necessary to 
%	at least update the xlim setting of inactive axes

figmainh=mt_gfigh('mt_f(t)');
figure(figmainh);                     %ensure figure is visible
drawnow;
displaytime=mt_gdtim;


myS=get(figmainh,'userdata');

nchan=size(myS.signal_name,1);        

activeflag=myS.active_flag;

%set up time for data read

%clip time if  screen end is beyond end of cut
datatime=displaytime;
datatime(2)=min([datatime(2) mt_gccud('end')]);
displaylength=diff(displaytime);     
chanlist=myS.signal_name;
axislist=myS.axis_name;

%channel loop====================
for ichan=1:nchan
   if activeflag(ichan)
      channame=deblank(chanlist(ichan,:));
      axisname=deblank(axislist(ichan,:));
      
      [oscidata,oscitype]=mt_getmm(channame,datatime,displaylength);
      
      axish=findobj(figmainh,'tag',axisname,'type','axes');
      set (axish,'xlim',displaytime);
      osch=findobj(axish,'tag',channame,'type','line');
      set (osch,'userdata',oscitype);
      
      
      if ~isempty(oscidata)
         set (osch,'xdata',oscidata(:,1),'ydata',oscidata(:,2));
      else
         set (osch,'xdata',[],'ydata',[]);
      end;
      
      %end of loop thru channels
   end;		%active flag   
end;
drawnow;
mt_newft(0);		%reset new data flag
