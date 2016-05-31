function parsemaus(splicefile,splicetype,mauspath,outfile)
% PARSEMAUS Parse PARtitur files, esp. from MAUS output, into MAT files
% function parsemaus(splicefile,splicetype,mauspath,outfile)
% parsemaus: Version 7.10.99
%
%	Syntax
%		splicefile
%			Name of cut file (MAT) that had been used for splicing out signals for processing by MAUS
%			needed for converting MAUS segments into offset from start of trial
%			(to avoid various kinds of rubbish it may often be better to have MAUS process spliced material
%			rather than complete trials)
%		splicetype
%			cut type of segment used to control splicing
%		mauspath
%			common part of MAUS PARtitur filenames. Assumes '.par' extension
%		outfile
%			output MAT file
%
%	See also
%		INSERT_T to merge results with existing segment file, CUTSORT to sort segments

functionname='Parsemaus: Version 7.10.99';
disp (functionname);
namestr=['<Start of Comment> ' functionname crlf];
namestr=[namestr datestr(now,0) crlf];

namestr=[namestr 'Splice file: ' splicefile crlf];
namestr=[namestr 'MAUS path: ' mauspath crlf];
namestr=[namestr 'Splice cut type: ' int2str(splicetype) crlf];







%partitur tier labels, (of segments to include in output file)

parlab=str2mat('KAN','ORT','MAU');

%cut type labels and values for these tiers in the output file

outlab=str2mat('SAMPA_canonical','orthography','MAUS_seg');
outval=[-1 -2 1];

namestr=[namestr 'Cut_type labels inserted : ' strm2rv(outlab,'/') crlf];
namestr=[namestr 'Cut_type values inserted : ' int2str(outval) crlf];




mausnolink=-1;	%value used by maus for segments with no symbolic link; will be changed to NaN

load(splicefile);

%not a very good solution
if exist('valuelabel','var')
    cut_type_value=valuelabel.cut_type.value;
    cut_type_label=valuelabel.cut_type.label;
end;



%copy splicefile to outfile
[status,msg]=copyfile([splicefile '.mat'],[outfile '.mat']);
if ~status
    disp(msg);
    return;
end;


D=desc2struct(descriptor);
vv=find(data(:,3)==splicetype);
splicecut=data(vv,:);
splicelabel=label(vv,:);

vv=find(cut_type_value==splicetype);
if length(vv)~=1
    disp('Parsemaus: Splice cut_type must have a label!');
    return;
end;
splicetypel=deblank(cut_type_label(vv(1),:));


ntrial=size(splicecut,1);
idigit=length(int2str(max(data(:,D.trial_number))));		%could be wrong sometimes!!

outpar=descriptor;
vi=strmatch('link',descriptor);
if isempty(vi)
    outpar=str2mat(descriptor,'link_1_cut_type_SAMPA_canonical','link_n_cut_type_SAMPA_canonical');
    unit=str2mat(unit,'word','word');
end;


O=desc2struct(outpar);
npout=size(outpar,1);
descriptor=outpar;


%sort out cut type labels and values

vv=find(outval==splicetype);
if ~isempty(vv)
    disp('Parsemaus: New cut types clash with cut type used for splicing!');
    return;
end;

oldtypesused=unique(data(:,D.cut_type));
for ii=1:length(outval)
    vi=find(cut_type_value==outval(ii));
    if ~isempty(vi)
        disp(['Parsemaus: Warning -- Cut_type value already coded in splice file: ' int2str(outval(ii))]);
    end;
    vi=find(oldtypesused==outval(ii));
    if ~isempty(vi)
        disp(['Parsemaus: Warning -- Cut_type value already used in splice file: ' int2str(outval(ii))]);
    end;
    vi=strmatch(deblank(outlab(ii,:)),cut_type_label);
    if ~isempty(vi)
        disp(['Parsemaus: Warning -- Cut_type label already present in splice file: ' outlab(ii,:)]);
    end;
    
end;

%make new value and label lists

cut_type_value=[splicetype;outval'];
cut_type_label=str2mat(splicetypel,outlab);



alloutd=[];
alloutl=cell(0,0);

sfcheck=[];

%main loop
for ii=1:ntrial
    itrial=splicecut(ii,D.trial_number);
    disp(itrial);
    mausfilename=[mauspath int2str0(itrial,idigit) '.par'];
    if exist(mausfilename,'file')
        s_all=file2str(mausfilename);%or into cell array with textfile??
        
        
        vsf=strmatch('SAM:',s_all);
        if length(vsf)~=1
            disp('Parsemouse: Partitur file corrupt? (no sample rate) ');
            return;
        end;
        ss=s_all(vsf,:);
        
        [dodo,ss]=strtok(ss);
        sf=str2num(strtok(ss));

        if isempty(sfcheck) sfcheck=sf; end;
        
        if sf~=sfcheck
            disp(['Parsemouse: Partitur file corrupt? (inconsistent sample rates) : ' num2str([sf sfcheck])]);
            keyboard;
            return;
        end;
        
        %split up into subparts
        
        vv=strmatch('KAN:',s_all);
        canlist=s_all(vv,:);
        vv=strmatch('ORT:',s_all);
        ortlist=s_all(vv,:);
        vv=strmatch('MAU:',s_all);
        maulist=s_all(vv,:);
        nort=size(ortlist,1);
        ncan=size(canlist,1);
        nmau=size(maulist,1);
        
        ortd=repmat(NaN,[nort npout]);
        ortl=cell(nort,1);
        cand=repmat(NaN,[ncan npout]);
        canl=cell(ncan,1);
        maud=repmat(NaN,[nmau npout]);
        maul=cell(nmau,1);
        
        cand(:,O.trial_number)=itrial;
        ortd(:,O.trial_number)=itrial;
        maud(:,O.trial_number)=itrial;
        
        ipi=strmatch('SAMPA_canonical',outlab);
        cand(:,O.cut_type)=outval(ipi);
        ipi=strmatch('orthography',outlab);
        ortd(:,O.cut_type)=outval(ipi);
        ipi=strmatch('MAUS_seg',outlab);
        maud(:,O.cut_type)=outval(ipi);
        
        spliced=[splicecut(ii,:) 0 ncan-1];		%add on link parameters, set to first/last word
        splicel=cellstr(splicelabel(ii,:));
        
        
        
        
        for jj=1:ncan
            ss=canlist(jj,:);
            [dodo,ss]=strtok(ss);
            [symnum,ss]=strtok(ss);
            ss=strtok(ss);
            %symnum always from 0 to ncan-1 ??
            cand(jj,O.link_1_cut_type_SAMPA_canonical)=str2num(symnum);
            canl{jj}=ss;
        end;
        
        for jj=1:nort
            ss=ortlist(jj,:);
            [dodo,ss]=strtok(ss);
            [symnum,ss]=strtok(ss);
            ss=strtok(ss);
            ortd(jj,O.link_1_cut_type_SAMPA_canonical)=str2num(symnum);
            ortl{jj}=ss;
        end;
        
        for jj=1:nmau
            ss=maulist(jj,:);
            [dodo,ss]=strtok(ss);
            [cutpos,ss]=strtok(ss);
            [cutsamp,ss]=strtok(ss);
            [symnum,ss]=strtok(ss);
            ss=strtok(ss);
            mystart=str2num(cutpos);
            maud(jj,O.cut_start)=mystart;
            maud(jj,O.cut_end)=mystart+str2num(cutsamp)+1;	%+1 seems to be necessary for contiguous segments
            
            %parse for multiple links
            symnum=str2num(symnum);
            maud(jj,O.link_1_cut_type_SAMPA_canonical)=symnum(1);
            if length(symnum)>1
                maud(jj,O.link_n_cut_type_SAMPA_canonical)=symnum(end);
            end;
            
            
            
            maul{jj}=ss;
        end;
        
        %set symbolic link value of "none" to NaN 
        vv=find(maud(:,O.link_1_cut_type_SAMPA_canonical)==mausnolink);
        maud(vv,O.link_1_cut_type_SAMPA_canonical)=NaN;
        
        maud(:,[O.cut_start O.cut_end])=(maud(:,[O.cut_start O.cut_end])/sf)+splicecut(ii,D.cut_start);
        
        trialoutd=[ortd;cand;spliced;maud];
        trialoutl=[ortl;canl;splicel;maul];
        
        alloutd=[alloutd;trialoutd];
        alloutl=[alloutl;trialoutl];
        
    else
        disp('no partitur file?')
        
    end;
end;

%funnily enough the character array is generally much smaller than the cell array, despite padding with blanks
alloutl=char(alloutl);

data=alloutd;
label=alloutl;
namestr=[namestr comment crlf '<End of Comment> ' functionname crlf];
comment=namestr;



save(outfile,'data','label','descriptor','unit','comment','cut_type_value','cut_type_label','-append');

