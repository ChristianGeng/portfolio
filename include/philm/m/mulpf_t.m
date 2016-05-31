function [data,label,comment,descriptor,unit,private]=mulpf_t(cutname,recpath,reftrial,reclist,cuttypebase,calcspec,cuttypespec,matchmode);
% MULPF_T Get values for multiple signals at desired timepoints, or calculate functions of signal values
% function [data,label,comment,descriptor,unit,private]=mulpf_t(cutname,recpath,reftrial,reclist,cuttypebase,calcspec,cuttypespec,matchmode);
% mulpf_t: Version 27.10.2011
%
%	Purpose
%		Extract data at specific time points, or calculate functions of signals
%			Functions will usually be simple statistic functions like mean, max, min etc.
%			i.e should normally return a scalar value when applied to the signal portions defined in the cut file
%           (or a vector the same length as the input vector for the special case
%           when the only input signal is a vector (see reclist below))
%
%	Syntax
%
%		Input arguments:
%			Currently all compulsory except cuttypespec
%
%			cutname
%				Name of cut file containing the cuts that define at what time instants, or over what
%				portion of the signal the analyses are performed
%
%			recpath
%				actually the common part of the REC file names
%
%			reclist
%				string matrix specifying mat files, descriptors, and (optionally) internal names of signals to be processed.
%				Same usage as when calling MTNEW.
%				See mt_ssig for syntax
%					Note that the use of the optional internal names for the signals can be handy for
%					exercising some control over what the output parameters are called.
%					Use of an internal name will be essential if the same descriptor occurs in different series of mat files
%                   If only one signal is specified, and only one analysis
%                   in calcspec, then this signal can be a vector, e.g 64
%                   EPG electrodes, or spectral data (the elements of the
%                   vector must form the first dimension of the data
%                   variable (and time is the second dimension). See below
%                   on output argument descriptor for arrangement of output
%                   data.
%
%			cuttypebase
%				Works in two ways depending on whether optional input argument cuttypespec is present.
%				(1) cuttypespec not present: This is the simple case.
%					Only cuts in file cutname whose type corresponds to cuttypebase are analyzed
%				(2) cuttypespec present: cuttypebase is used to group the individual analyses with different cuttypes
%					specified in cuttypespec into records for storage. It must be a cuttype that encloses the cuts specified
%					in cuttypespec. The simplest (and probably most frequent) case is to use the cuttype corresponding to
%					the complete trial. But with appropriate choice of cuttypebase it is possible to perform multiple
%					sets of analyses per trial, with the results unambiguously organized for output.
%                   Update 10.2011: when cuttypespec is present,
%                   cuttypebase can be a vector, i.e more than one segment
%                   type can act as a grouping segment, e.g when analyzing
%                   multiple words within a trial, where each word has as
%                   separate cut type
%                   See also matchmode
%
%			calcspec
%				Has two different forms depending on whether 'magic moment' extraction of signal values
%				is to be performed, or functions of the signal data are to be evaluated.
%				1. magic moment analysis
%					calcspec is an m*2 matrix, where m is the number of analyses to be performed
%					For analyis i, the timepoint where analysis is performed is determined from
%					calcspec(i,1)*cutstart + calcspec(i,2)*cutend
%					i.e [1 0] and [0 1] give analysis at cutstart and cutend respectively, [0.5 0.5] give midpoint.
%						For relative positions in the segment the formula in general is:
%							(1-rel_pos)*cutstart + rel_pos*cutend (with rel_pos = 0 .... 1)
%				2. Function evaluation
%					calcspec is a string matrix. Each row should be the name of a function e.g 'mean', 'max'
%					The number of analyses, i.e the number of different functions applied is given by the number of rows
%
%			cuttypespec
%				Optional. See above cuttypebase. If present, must be a vector of same length as calcspec, i.e it
%				determines the cuttype to use for each analysis. However, only cuts enclosed by a cut of type cuttypebase
%				will be used (and only 1 cut of the types given in cuttypespec can be within the cuttypebase segment).
%				Another way of looking at this is that the number of segments of type cuttypebase determines the number
%				of records in the output.
%           matchmode
%               Optional. Only relevant when cuttypespec is also specified
%                   Defaults to 'none'
%                   Other possible values: 'label' and 'link'
%                   Gives more control over how segments in cuttypespec are
%                   matched to grouping segments.
%                   If matchmode is 'none' then the program only looks for
%                   segments enclosed by the grouping segment. If there are
%                   multiple grouping segments per trial this may give
%                   ambiguous results.
%                   'label' mode means that labels must agree (up to the
%                   end of the cuttypebase label)
%                   'link' means that link type of the cuttypespec segment
%                   must agree with the cut type of the cuttypebase
%                   segment.
%                   Not yet implemented: 'linkid' means that in addition the link_target of the
%                   cuttypespec segment must agree with the link_id of the
%                   cuttypebase segment.
%                   (see cutstrucn for information on these new parameters
%                   in segment files. It is probably worth making use of
%                   these whenever possible, but currently not many segment
%                   files have been set up to make them consistently
%                   available.)
%
%		Output arguments:
%
%			data
%					analysis data (rows correspond to analyses grouped by cutbasetype (very often this will simply be one row per trial),
%										columns correspond to signals)
%             It contains (from left to right): signal data, all cut data
%             (start, end, type, as well as trial_number and possibly additional columns for newer recordings),
%             cut number (of each cuttypebase segment in the cutfile).
%						For magic moment analyses the analysis positions
%					For function analyses the start and end of the analysis frame if the optional cuttypespec input argument has been used
%             Total columns is thus:
%					(1) for magic moment analyses:
%					((number of signals)*(number of analyses)) size(cutdata,2) + 1 + (number of analyses)
%					(2) for function analyses without cuttypespec:
%					((number of signals)*(number of analyses)) size(cutdata,2) + 1
%					(3) for function analyses with cuttypespec:
%					((number of signals)*(number of analyses)) size(cutdata,2) + 1 + (2*(number of analyses))
%                   For the special case of a single vector input signal
%                   then the first n columns in data correspond to the elements of the vector. 
%
%			label
%				simply the transcription field of the cuts analyzed
%
%			comment
%				string variable (row vector with embedded CRLF).
%				Intended to be used as the comment variable, perhaps with additions
%				from the calling program, in the MAT file used to store the analysis results.
%         It consists of:
%         functionname, analysis operation (calcspec) cutname, recpath, recnames, comment from cut file.
%
%			descriptor and unit
%				Set up from signal descriptor and unit.
%				In both modes the cut_type label (if available) is appended to the signal descriptor
%				In function evaluation mode, the name of the function is then appended, e.g 'dorsum' ---> 'dorsum_vowel' ----> 'dorsum_vowel_mean'
%				In magic moment mode, a meaningful designation of the timepoint like 'onset', 'offset', 'midpoint'
%				is used if possible. Otherwise an indication of the relative position (in %) in the segment
%               For a single vector input signal with n elements in the
%               vector then the first n elements of descriptor will be e.g
%               EPG01, EPG02 ... EPG64 (with timepoint information
%               appended). The first n elements of unit will be identical.
%
%           private
%               Optional, but recommended when using a single vector input
%               signal. It returns the dimension structure of this signal
%               (in private.mulpf_t.dimension), which may be necessary to
%               have access to a physical interpretation of the elements of
%               the vector (since this is not included in the descriptor
%               variable).
%
%	Remarks
%           (1) The program stores messages in a diary file called
%           [cutname 'mulpftdiary.txt']. This is appended to rather than overwritten
%           each time the program is run with the same cutfile. So it may
%           end up containing a lot of rubbish from preliminary runs of the
%           program. Ought to be checked after running the program for
%           evidence of unusual situations. If everything is OK it can then
%           normally be deleted.
%			(2) Stored time positions have been rounded to a multiple of the sample interval
%
%	Updates
%			2.98. Output comment variable standardized. descriptor and unit variables generated and returned as output variables
%			10.98 New version for mt functions. Splice functions removed
%			3.99. New specification of analysis position, with calcspec argument
%			3.00 This version (position only, no filtering) split off from mulpva_t
%			2.01 mulpf_t from mulp_t: Allow choice of multiple magic moments, multiple function evaluation
%           2.07 handling of cut_type_label improved (use of valuelabel
%           structure is possible)
%           5.07 Name of diary file based on cutfile name
%           8.07 Skip missing trials
%           11.08 Correct handling of cut data where one boundary is NaN
%           12.08 Start implementing vector data, further correction to NaN
%               boundary handling
%			03.10 Change checking for non-matching labels
%           07.11 catch problems when unit variable is empty; correct
%           function evaluation for vector data
%           10.11 cuttypebase can be vector if cuttypespec is present
%                   matchmode input argument added
%
%	See Also
%		FEVAL

data=[];
label=[];
comment=[];
descriptor=[];
unit=[];
if nargout>5
    private.mulpf_t.dimension=[];
end;


myversion=version;

diaryname=[cutname '_mulpftdiary.txt'];

diary(diaryname);
functionname='MULPF_T: Version 26.11.2011';
disp (functionname);
if nargin<6
    help mulpf_t;
    return;
end;

namestr=['Magic moment and function analysis of signals' crlf];
diary off;

vecok=1;        %analysis of vector data only possible with one signal and one analysis
veclen=0;       %will flag whether vector mode is actually to be used
cuttype=cuttypebase;		%original name

[ncut]=mt_org(cutname,recpath,reftrial);
mt_ssig(reclist);
siglist=mt_gcsid('signal_list');
nchan=size(siglist,1);
if nchan>1 vecok=0; end;
sampincmax=mt_gcsid('max_sample_inc');
diary on;


C=mymatin(cutname,'descriptor');
C=desc2struct(C);       %will be used to access supplementary cut file parameters, if necessary


posfac=calcspec;


posmode=1;
if ischar(posfac) posmode=0;end;

if posmode
    if size(posfac,2)~=2
        disp('calcspec must be m*2 matrix');
        return;
    end;
end;

nana=size(posfac,1);

if nana>1 vecok=0; end;

veccomment=0;
if vecok
    mat_column=mt_gsigv(siglist,'mat_column');
    if mat_column==0
        datasize=mt_gsigv(siglist,'data_size');
        %   make sure data has maximum of 2 dimensions, i.e image etc. data is not
        %   supported
        veclen=datasize(1);
        veccomment=['Analysis in vector mode for ' siglist '; vector length = ' int2str(veclen)];
        disp(veccomment);
        if nargout>5
            private.mulpf_t.dimension=mt_gsigv(siglist,'dimension');
        end;
        
    end;
end;




typeissimple=1;

spectype=ones(nana,1)*cuttype(1);	%default case, no additional cuttypespec
if nargin>6
    spectype=cuttypespec;
    if length(spectype)~=nana
        disp('cuttypespec must be same length as calcspec');
        return;
    end;
    typeissimple=0;
end;

if typeissimple
    if length(cuttype)>1
        disp('Cuttypebase must be scalar');
        return;
    end;
end;

mymatch='none';
if nargin>7 mymatch=matchmode; end;

linkok=0;
if strcmp(mymatch,'link')
    if isfield(C,'link_type') 
        linkok=1; 
    else
        disp('The segment file does not support use of link as matchmode');
        disp('Restart using a different setting for matchmode');
        return;
    end;
    
end;


nrec=nchan;
nrec3=nrec*nana;   %total signal parameters
if veclen>0 nrec3=veclen; end;



cutdata=mt_gcufd;
cutlabel=mt_gcufd('label');
sf=mt_gsigv(siglist,'samplerate');
sampinc=1./sf(1);


%cut file must have at least 3 parameters
%watch out for possible future updates to cutfiles

%10.2011 expand to multiple values
cutlist=find(ismember(cutdata(:,3),cuttype));
cutdatabase=cutdata(cutlist,:);
%no idea why older version had strmdebl (causes problems if label has
%internal blanks)
%cutlabelbase=strmdebl(cutlabel(cutlist,:));
cutlabelbase=deblank(cutlabel(cutlist,:));


ncut=length(cutlist);	%nparc should be 3 or 4
nparc=size(cutdata,2);

%include cuttype label if possible

valuelabel=mymatin(cutname,'valuelabel');
if isfield(valuelabel,'cut_type')
    cut_type_value=valuelabel.cut_type.value;
    cut_type_label=valuelabel.cut_type.label;
else
    cut_type_value=mymatin(cutname,'cut_type_value');
    cut_type_label=mymatin(cutname,'cut_type_label');
end;

%currently this label is only used for documentation in the output file
%comment
cutlabeld='';
for ici=1:length(cuttype)
    cutlabeld=[cutlabeld gettypelabel(cuttype(ici),cut_type_value,cut_type_label)];
end;

cuttype=(cuttype(:))';  %make sure row vector


if posmode
    npar=nrec3+nparc+1+nana;		%i.e cutnumber and analysis position(s)
else
    npar=nrec3+nparc+1;
    if ~typeissimple
        npar=npar+nana*2;		%analysis start and end positons
    end;
    
end;


%11.97 initialize to NaN
anabuf=ones(ncut,nrec3)*NaN;

anabuf=[anabuf cutdatabase cutlist];

%3.99. New way of specifying analysis position
%2.2001 Rewritten to allow for cuttypespec
% for both magic moment and function mode, analysis positions are prepared completely here (and checked)

anarecpos=ones(ncut,nana)*NaN;
anarecposend=ones(ncut,nana)*NaN;	%only needed in function mode
anaposstr='';

for jj=1:ncut
    baselabel=deblank(cutlabelbase(jj,:));
    disp(['Preparing ' baselabel]);
    cutbstart=cutdatabase(jj,1);
    cutbend=cutdatabase(jj,2);
    cutbtype=cutdatabase(jj,3);
    cutbtrial=cutdatabase(jj,4);
    if isnan(cutbend) cutbend=cutbstart; end;
    if isnan(cutbstart) cutbstart=cutbend; end;
    
    
    vv=find(cutdata(:,4)==cutbtrial);
    nosegs=0;
    if isempty(vv)
        nosegs=1;
    else
        cutd=cutdata(vv,:);
        cutl=cutlabel(vv,:);
        if strcmp(mymatch,'label')
            vv=strmatch(baselabel,cutl);
            if isempty(vv)
                nosegs=1;
            else
                cutd=cutd(vv,:);
                cutl=cutl(vv,:);
                
            end;
        end;
        %maybe eventually allow label AND link, so check segs still present        
        if ~nosegs
            if linkok
                
                vv=find(cutbtype==cutd(:,C.link_type));
                
                if isempty(vv)
                    nosegs=1;
                else
                    cutd=cutd(vv,:);
                    cutl=cutl(vv,:);
                    
                end;
                
                
            end;
        end;
        
        
    end;
    
    if nosegs
        disp('No segments');
        
        
    else
        
        for ii=1:nana
            
            idone=0;
            
            
            % the complication in magic moment mode is to allow one segment bounday to be NaN when analyzing at precisely the
            %opposite one
            
            if posmode
                %only consider cutstart
                if posfac(ii,1)==1 & posfac(ii,2)==0
                    vv=find(cutd(:,3)==spectype(ii) & cutd(:,1)>=cutbstart & cutd(:,1)<=cutbend);
                    idone=1;
                end;
                %only consider cutend
                if posfac(ii,1)==0 & posfac(ii,2)==1
                    vv=find(cutd(:,3)==spectype(ii) & cutd(:,2)>=cutbstart & cutd(:,2)<=cutbend);
                    idone=1;
                end;
            end;
            if ~idone
                vv=find(cutd(:,3)==spectype(ii) & cutd(:,1)>=cutbstart & cutd(:,2)<=cutbend);
            end;
            
            
            
            
            if length(vv)~=1
                if isempty(vv)
                    disp(['Note: Missing cut, type = ' int2str(spectype(ii))]);
                end;
                
                %ambiguous is more serious
                if length(vv)>1
                    disp('Ambiguous segments!');
                    disp('Data for ambiguous segments');
                    disp(cutd(vv,:));
                    disp('Labels for ambiguous segments');
                    disp(cutl(vv,:));
                    disp('mulpf_t: Unable to continue. type return to exit from keyboard mode');
                    
                    keyboard;
                    return;
                end;
            else
                %expect labels of base cut to at least be same as start of target segment label
                checklabel=deblank(cutl(vv,:));
                nbtmp=length(baselabel);
                ixxx=[];
                if length(checklabel)>=nbtmp 
                    ixxx=strmatch(baselabel,checklabel(1:nbtmp));
                end;
                
                if isempty(ixxx) ixxx=2; end;			%why this??
                if ixxx~=1
                    disp('Warning: Labels do not match');
                    disp(baselabel);
                    disp(checklabel);
                end;
                
                
                
                if posmode
                    %again, this allows for NaNs at uncrucial segment positions
                    %corrected (probably) 11.08
                    mypos=0;
                    if ~isnan(cutd(vv,1)) mypos=mypos+(cutd(vv,1)*posfac(ii,1)); end;
                    if ~isnan(cutd(vv,2)) mypos=mypos+(cutd(vv,2)*posfac(ii,2)); end;
                    anarecpos(jj,ii)=mypos;
                else
                    
                    anarecpos(jj,ii)=cutd(vv,1);
                    anarecposend(jj,ii)=cutd(vv,2);
                end;					%posmode
                
            end;				%length(vv)
            
            
            
            
        end;		%nana loop
    end;		%skip if no segs
end;			%cut loop

disp('Checking of segment data finished');
disp('Signal values will now be extracted');
disp('Type ''return'' to continue');


keyboard;
%do this in a separate loop
for ii=1:nana
    %extend for function mode?????, include cut type label????
    anaposstr=[anaposstr 'Analysis ' int2str(ii) '. Cut type: ' gettypelabel(spectype(ii),cut_type_value,cut_type_label)];
    if posmode
        anaposstr=[anaposstr '. Cut start factor : ' num2str(posfac(ii,1)) '. Cut end factor : ' num2str(posfac(ii,2)) crlf];	%for comment
    else
        anaposstr=[anaposstr '. Function: ' calcspec(ii,:) crlf];	%for comment
    end;
    
end;


%now round the position data
anarecpos=round(anarecpos*sf(1))./sf(1);
if posmode
    dummyinc=2/sf(1);		%mini segment length for mt_gdata
    
    anarecposend=anarecpos+dummyinc;
end;

anarecposend=round(anarecposend*sf(1))./sf(1);


%cf. below for descriptors
%in function mode analysis position only needs to be stored if cuttypespec is being used

if posmode
    anabuf=[anabuf anarecpos];
else
    if ~typeissimple
        anabuf=[anabuf anarecpos anarecposend];
    end;
end;




namestr=[namestr 'Cut file name: ' cutname crlf];


namestr=[namestr 'Base cut type used: ' int2str(cuttype) ' ' cutlabeld crlf];

if posmode
    namestr=[namestr 'Analysis position specification: ' crlf];
else
    namestr=[namestr 'Function specification: ' crlf];
end;
namestr=[namestr anaposstr crlf];


namestr=[namestr 'Signal file path: ' recpath crlf];

namestr=[namestr 'Signal files: ' strm2rv(reclist,' ') crlf];
if ~isempty(veccomment) namestr=[namestr veccomment crlf]; end;



%3.98
%get comment from cut file

reccomment=mymatin(cutname,'comment');

reccomment=framecomment(reccomment,'Comment from cut file');
namestr=[namestr crlf reccomment];

comment=framecomment(namestr,functionname);


%set up complete descriptors and units

%changed 2.2001. Use internal signal names rather than descriptor in mat file
%alldescrip=mt_gsigv(siglist,'descriptor');
alldescrip=mt_gsigv;
allunit=mt_gsigv(siglist,'unit');

%need to watch out for cases where units are empty
if isempty(allunit) allunit=' '; end;
if size(allunit,1)~=size(alldescrip,1)
    disp('mulpf_t: size of descriptor and unit does not match (empty units?');
    disp('setting all units to single blank');
    
    keyboard;
    allunit=repmat(' ',[size(alldescrip,1) 1]);
    
end;

sufdig=length(int2str(nana));


if ~veclen>0
    descbase=alldescrip;
    unitbase=allunit;
    unit=repmat(unitbase,[nana 1]);
else
    unit=repmat(allunit,[veclen 1]);
    descbase=repmat(alldescrip,[veclen 1]);
    tmpd=int2str((1:veclen)');
    tmpd=char(strrep(cellstr(tmpd),' ','0'));
    descbase=[descbase tmpd];
end;

descriptor='';
posdesc='';
posdescend='';		%needed when function mode and cuttypespec combined


%try and use cut type label and posfac intelligently
for ii=1:nana
    dtmp=descbase;
    if posmode
        mysuff='';
        
        %if possible use a meaningful description of the magic movement
        %or at least an indication of relative position in the segment
        if ((posfac(ii,1)==1) & (posfac(ii,2)==0)) mysuff='onset'; end;
        if ((posfac(ii,1)==0) & (posfac(ii,2)==1)) mysuff='offset'; end;
        
        if ((posfac(ii,1)==0.5) & (posfac(ii,2)==0.5)) mysuff='midpoint'; end;
        
        if isempty(mysuff)
            
            if (posfac(ii,1)+posfac(ii,2))==1
                
                mysuff=int2str(round(posfac(ii,2)*100));
                
                if mysuff(1)=='-' mysuff(1)='m'; end;		%avoid arithmetic symbols in descriptors
                
            else
                
                
                mysuff=int2str0(ii,sufdig);
                
            end;
        end;
        
        
    else
        mysuff=deblank(calcspec(ii,:));
    end;
    mysuff=['_' gettypelabel(spectype(ii),cut_type_value,cut_type_label) '_' mysuff];
    dtmp=[dtmp rpts([size(dtmp,1) 1],mysuff)];
    descriptor=strvcat(descriptor,dtmp);
    postmp=['ana_pos' mysuff];
    if ~posmode
        posdescend=strvcat(posdescend,[postmp '_end']);
        posdesc=strvcat(posdesc,[postmp '_start']);
    else
        posdesc=strvcat(posdesc,postmp);
    end;
    
    
    
end;


descriptor=strmdebl(descriptor);


%add in descriptor and unit for cut file variables

cutdescriptor=mymatin(cutname,'descriptor');
if isempty(cutdescriptor)
    [cutdescriptor,cutunit,dodo1,dodo2]=cutstruc;
else
    cutunit=mymatin(cutname,'unit');
end;
if size(cutdescriptor,1)<nparc
    error('Unable to generate cut parameter descriptors');
end;
cutdescriptor=cutdescriptor(1:nparc,:);
cutunit=cutunit(1:nparc,:);

descriptor=str2mat(descriptor,cutdescriptor);
unit=str2mat(unit,cutunit);





%add in descriptor and unit for remaining variables
%in magic moment the analysis position information is always included
% in function mode this is only included if cuttypespec has been used
% In this case both start and end of analysis must be given
% If cuttypespec has not been used the analysis position simply corresponds to the basic
%	segment information and doesn't need to be repeated

descriptor=str2mat(descriptor,'cutnumber');
unit=str2mat(unit,' ');
if posmode
    descriptor=str2mat(descriptor,posdesc);
    unit=str2mat(unit,rpts([nana 1],'s'));
else
    if ~typeissimple
        descriptor=str2mat(descriptor,posdesc,posdescend);
        unit=str2mat(unit,rpts([nana*2 1],'s'));
    end;
    
end;





diary off;




%main loop, thru cuts
for icut=1:ncut
    itrial=cutdatabase(icut,4);
    disp(cutlabelbase(icut,:));
    disp ([icut cutdatabase(icut,:)])
    
    %could also use mt_next???
    myresult=mt_loadt(itrial);
    
    if myresult
        posbuf=ones(nchan,nana)*NaN;
        
        for jj=1:nana
            timspec=[anarecpos(icut,jj) anarecposend(icut,jj)];
            
            
            if isnan(timspec(1))
                disp('Skipping unsegmented item');
            else
                
                if ~posmode myfunc=deblank(calcspec(jj,:)); end;
                %Data all channels
                for jd=1:nchan
                    [xx,actualtime]=mt_gdata(deblank(siglist(jd,:)),timspec);
                    if ~veclen>0
                        if posmode
                            posbuf(jd,jj)=xx(1);
                        else
                            posbuf(jd,jj)=feval(myfunc,xx);
                        end;
                    else
                        
                        
                        if posmode
                            posbuf(jd,1:veclen)=(xx(:,1))';
                        else
                            posbuf(jd,1:veclen)=feval(myfunc,xx');
                        end;
                        
                    end;
                    
                    
                end;		%channel loop
            end;		%skip unsegmented trial
            
            
        end;		%analysis loop
        
        anabuf(icut,1:nrec3)=(posbuf(:))';
        
    else
        
        disp(['No data for trial ' int2str(itrial)]);
    end;
    
    
    
end;    %cut loop
data=anabuf;
label=cutlabelbase;
close(mt_gfigh('mt_f(t)'));
close(mt_gfigh('mt_organization'));
colordef white;


function mylabel=gettypelabel(myvalue,cut_type_value,cut_type_label)

mylabel=int2str(myvalue);
if isempty(cut_type_value) | isempty(cut_type_label)
    return;
end;

vvl=find(myvalue==cut_type_value);
if isempty(vvl) return; end;
mylabel=deblank(cut_type_label(vvl(1),:));


