function mt_sclip(clist);
% MT_SCLIP Toggle osci clipping
% function mt_sclip(clist);
% mt_sclip: Version 26.8.02
%
%	Syntax
%		clist: String matrix of axes in mt_f(t)
%	Remarks
%		Clipping actually applies to the signals, but signal names are allowed
%		to occur multiple times, whereas axes names are unambiguous
%		So clipping will be toggled for all signals in the given axis


hfig=mt_gfigh('mt_f(t)');

ll=size(clist,1);
if (ll==0) return; end;



ibad=0;
for iclip=1:ll
   
   cl=deblank(clist(iclip,:));
   ho=findobj(hfig,'tag',cl,'type','axes');
   
   
   if ~isempty(ho)
      hol=findobj(ho,'type','line');
      if ~isempty(hol)
         lll=length(hol);
         for myline=1:lll
            clip=get(hol(myline),'clipping');
            chanstr=get(hol(myline),'tag');
            if strcmp(clip,'on')
               disp (['Clipping off. Signal ' chanstr ' Axes ' cl]);
               set (hol(myline),'clipping','off');
            else
               
               disp (['Clipping on. Signal ' chanstr ' Axes ' cl]);
               set (hol(myline),'clipping','on');
               
            end
         end;
      end;
      
   else
      disp (['mt_gextr: Bad axes name ' cl]);
      ibad=1;
   end;
   
end

if ibad
   myS=get(hfig,'userdata');
   axislist=myS.axis_name;
   disp('Valid axes are:');
   disp(axislist);
end;
