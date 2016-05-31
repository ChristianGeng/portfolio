function hearreps(trans)
% HEARREPS Audio output of segments labelled trans
% function hearreps(trans)
%
% auxiliary routine for mmnew. Needs rewriting for MT!!!
% Note. Generates one big buffer of all segments found

%had problems with calling mm_audio in a loop "sound device busy"

%this could be second arg
cuttype=6;
%this could be a third arg.
maxrep=5;
%pause length could also be arg

cutlabel=mm_gcbud('label');
cutdata=mm_gcbud;
vv=find(cutdata(:,3)==cuttype);
cutdata=cutdata(vv,:);
cutlabel=cutlabel(vv,:);
ipause=zeros(2000,1);
bigdat=[];

for ii=1:maxrep
   ss=[trans int2str(ii)];
   vv=strmatch(ss,cutlabel);
   if ~isempty(vv)
      for jj=1:length(vv);
         disp([int2str(jj) ' ' ss]);
         bigdat=[bigdat;mm_gdata(1,[cutdata(vv(jj),1) cutdata(vv(jj),2)]);ipause];
         
      end;
   end;
end;
if ~isempty(bigdat)
	mm_audio(bigdat);
end;
   