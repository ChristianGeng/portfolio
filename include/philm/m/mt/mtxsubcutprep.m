function [cutdata,cutlabel,nsubxy]=mtxsubcutprep(timspec,mymessage);
% MTXSUBCUTPREP prepare for subcut display
% function [cutdata,cutlabel,nsubxy]=mtxsubcutprep(timspec);
% mtxsubcutprep: Version 24.4.99
%
%	Notes
%		Only returns cutstart, end and type in cutdata
%
%	See Also
%		MT_XYDIS MT_SONADIS MT_NEXT

%find sub-cuts
%currently, this depends on whether mt_next has stored sub_cuts
%alternative would be to use mt_gtrid, which always stores sub_cuts of the current trial



cutdata=mt_gscud;
cutlabel='';
nsubxy=0;
if ~isempty(cutdata)
   
   vv=find((cutdata(:,1)>=timspec(1)) & (cutdata(:,2)<=timspec(2)) & ((cutdata(:,2)-cutdata(:,1))<diff(timspec(1:2))));
   
   nsubxy=length(vv);
   if ~isempty(mymessage)
   disp ([mymessage ': sub_cuts in frame ' int2str(nsubxy)]);
	end;   
   if nsubxy
      
      cutdata=cutdata(vv,1:3);
      cutlabel=mt_gscud('label');
      %deblank
      cutlabel=strmdebl(cutlabel(vv,:));
   end;
end;

