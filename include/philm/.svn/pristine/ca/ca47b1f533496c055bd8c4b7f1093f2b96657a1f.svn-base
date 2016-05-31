function cutlinks(cutfile,target_type,seg_type)
% CUTLINKS Link segment information via symbolic links

load(cutfile)

D=desc2struct(descriptor);

C.in=cut_type_value;
C.out=cut_type_label;

target_name=mtxcode(C,target_type,'decode');
seg_name=mtxcode(C,seg_type,'decode');

newtype=10;	%?????

disp(['Cutlinks : Linking ' deblank(seg_name) ' to ' deblank(target_name)]);

vl=strmatch('link',descriptor);
disp('Link parameters:');
disp(descriptor(vl,:));
disp('----------------');
lp1=deblank(descriptor(vl(1),:));
lp2=deblank(descriptor(vl(2),:));

lp1=getfield(D,lp1);
lp2=getfield(D,lp2);



tlist=unique(data(:,D.trial_number));
ntrial=length(tlist);

%if 2nd link not filled in, set equal to first one
vd=find(isnan(data(:,lp2)));
data(vd,lp2)=data(vd,lp1);

for ii=1:ntrial
   itrial=tlist(ii);
   vv=find(data(:,D.trial_number)==itrial);
   if ~isempty(vv)
      tdata=data(vv,:);
      tlabel=label(vv,:);
      
      vv=find(tdata(:,D.cut_type)==target_type);
      if ~isempty(vv)
         targlist=tdata(vv,:);		%target type has unique values??
         targlabel=tlabel(vv,:);
         ntarg=length(vv);
         
         bignn=[int2str(itrial) '  '];
         bigtl=[int2str(itrial) '  '];
         bigll=[int2str(itrial) '  '];
         bigmm=[int2str(itrial) '  '];
         
         
            vv=find(tdata(:,D.cut_type)==seg_type);
            segdata=tdata(vv,:);
            seglabel=tlabel(vv,:);
            nseg=size(segdata,1);
            
            %fix segments within the utterance with no symbolic link (i.e NaN for first link), 
            %e.g pauses, so they won't be ignored completely
            %first link will be set to earliest link of preceeding segment and second link set to latest link of following sentence
            %both  * -1 to keep them identifiable
            v0=find(isnan(segdata(:,lp1)));
            if ~isempty(v0)
               nv0=length(v0);
               for i0=1:nv0
                  ipi=v0(i0);
                  
                  %this means e.g pause at beginning and end of utterance will be left unchanged
                  if ipi>1 & ipi<nseg
                     segdata(ipi,lp1)=-min(segdata(ipi-1,[lp1 lp2]));
                     segdata(ipi,lp2)=-max(segdata(ipi+1,[lp1 lp2]));
                  end;
               end;
            end;
            
                  
            
            for jj=1:ntarg
            ctargdata=targlist(jj,:);
            ctarglabel=deblank(targlabel(jj,:));
            
            tlink=ctargdata(lp1);
            
            
            
            vv=find((abs(segdata(:,lp1))<=tlink) & (abs(segdata(:,lp2))>=tlink));
            
            linklabel=' ';
            multilabel=' ';
            if ~isempty(vv)
               multilabel='';
               linkseg=[min(segdata(vv,1)) max(segdata(vv,2)) newtype itrial tlink NaN];
               tmplabel=seglabel(vv,:);
               linklabel=strm2rv(tmplabel,'');
            %mark segments with multiple links
            
            %segments without a symbolic link, e.g. pauses within the utterance, will be marked by '!'
            %if between segments with same link
            % and will be marked like multiple links if between segments with different links
            
            nv=length(vv);
            for mm=1:nv
               ml=length(deblank(seglabel(vv(mm),:)));
               tmpb=blanks(ml);
               if segdata(vv(mm),lp1)<0 tmpb=rpts([1 ml],'!'); end;
               if segdata(vv(mm),lp1)~=segdata(vv(mm),lp2)
                  tmpb=rpts([1 ml],'_');
               end;
               multilabel=[multilabel tmpb];
            end;
            
            
            
         end;		%segments found for this target
            
            
            
            nspace=max([length(ctarglabel) length(linklabel)]);
            nspace=nspace+1;
            mybl=blanks(nspace);
            tmpm=str2mat(int2str(tlink),ctarglabel,linklabel,multilabel,mybl);
            bignn=[bignn tmpm(1,:)];
            bigtl=[bigtl tmpm(2,:)];
            bigll=[bigll tmpm(3,:)];
            bigmm=[bigmm tmpm(4,:)];
            
            
            %   disp([int2str([ii jj]) ' ' ctarglabel]);
            %      disp([int2str([ii jj]) ' ' linklabel]);
            
         end;
         disp(' ');
         disp(bignn);
         disp(bigtl);
         disp(bigll);
         disp(bigmm);
         
      end;		%target type not empty, shouldn't really happen   
   end;		%trial data not empty   
end;



