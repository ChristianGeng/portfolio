function makexcut(markfile,outsuff,typenames,boundinc,boundind,frametype,frameinc)
% MAKEXCUT Extend cut boundaries (selecting cuts by type)
% function makexcut(markfile,outsuff,typenames,boundinc,boundind,frametype,frameinc)
% makexcut: Version 06.10.2006
%
%   Description
%       extend cuts (separate specs for each cut type possible)
%       and add a cut framing the other cuts (for use by mulpf_t)
%       boundinc and boundind together determine the onset and offet off the new
%       segments
%       First column for onset, second column for offset
%       boundind:
%           boundary index determining the existing segment boundary
%           to which the corresponding increment in boundinc is ADDED
%           1 = onset, 2 = offset
%           Using the same value in both columns of boundind allows a fixed length segment
%           around onset or offset to be defined
%		frametype: Optional. If present (and the specified cut type is not
%			in use), then a framing cut is set up for each trial based on the
%			minimum and maximum time point found for any cut in the trial.
%			Label for the framing cut is simply taken from the first cut
%			found for the trial.
%		frameinc: 2-element vector. Increments to add to beginning and end
%			of new framing cut
%
%	Notes
%		Note that only cuts selected for extending are included in the output
%		file.

%markfile=['cgl2_emg_2_mark'];
%outsuff='_ext';
%typenames=str2mat('C1','V','C2');
%boundinc=[0 0;0 0;0 0];
%boundind=[1 2;1 2;1 2];
%frametype=15;
%frameinc=[0.2 0.2];

functionname='MAKEXCUT: Version 06.10.2006';

load(markfile);

ntype=size(typenames,1);
typelist=zeros(ntype,1);

if exist('valuelabel','var')
    cut_type_label=valuelabel.cut_type.label;
    cut_type_value=valuelabel.cut_type.value;
end;

    

for ii=1:ntype
    vv=strmatch(deblank(typenames(ii,:)),cut_type_label,'exact');
    typelist(ii)=cut_type_value(vv);
end;



dataout=[];
labelout='';

for itype=1:ntype
    vv=find(data(:,3)==typelist(itype));
    tmpdatax=data(vv,:);
    tmplabel=label(vv,:);
    tmpdata=tmpdatax;
    tmpdata(:,1)=tmpdatax(:,boundind(itype,1))+boundinc(itype,1);
    tmpdata(:,2)=tmpdatax(:,boundind(itype,2))+boundinc(itype,2);
    
    dataout=[dataout;tmpdata];
    labelout=strvcat(labelout,tmplabel);
end;

%add frame segment

framename='';
if nargin>5
    if ~isempty(frametype)
        
        %check that the frame type not in use in any cut type (not just those selected for
        %the output file)
        
        if any(cut_type_value==frametype)
            disp('Inappropriate cut type for frame segment');
            return;
        end;
        
        framename='frameseg';
        
        triallist=unique(dataout(:,4));
        ntrial=length(triallist);
        framebuf=zeros(ntrial,4);
        framelabelc=cell(ntrial,1);
        for ipi=1:ntrial
            itrial=triallist(ipi);
            vv=find(dataout(:,4)==itrial);
            frameon=min(dataout(vv,1))+frameinc(1);
            frameoff=max(dataout(vv,2))+frameinc(2);
            
            frameon=max([frameon 0]);
            %triallength to clip frameoff???
            frameseg=[frameon frameoff frametype itrial];
            framelabel=labelout(vv(1),:);
            framebuf(ipi,:)=frameseg;
            framelabelc{ipi}=framelabel;
        end;
        dataout=[dataout;framebuf];
        labelout=str2mat(labelout,char(framelabelc));
    end;    %frame not empty
    
else
    frametype=[];
    
end;        %frame argin



[data,label]=sortcut(dataout,labelout);



comment=['From main mark file : ' markfile crlf 'Cut types, Boundary increments and Boundary indices' crlf];
tmp=strm2rv(num2str([typelist boundinc boundind]));
comment=[comment tmp];

comment=framecomment(comment,functionname);


cut_type_value=[typelist;frametype];
cut_type_label=char(strcat(cellstr(typenames),'_x'));
cut_type_label=strvcat(cut_type_label,framename);
valuelabel.cut_type.value=cut_type_value;
valuelabel.cut_type.label=cut_type_label;

save([markfile outsuff],'data','label','descriptor','unit','comment','valuelabel');
