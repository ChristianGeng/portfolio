function [data,label,comment,descriptor,unit]=mulpva_t(cutname,recpath,reftrial,reclist,cuttype,posfac);
% MULPVA_T Get position, velocity and acceleration for multiple signals at desired timepoint
% function [data,label,comment,descriptor,unit]=mulpva_t(cutname,recpath,reftrial,reclist,cuttype);
% mulpva_t: Version 8.3.99
%
% Purpose
%   Extract data at specific time point 
%   This version assumes input is position data
%   and also determines velocity and acceleration
%
% Syntax
%   Input arguments:
%	Currently all compulsory
%        recpath: actually the common part of the REC file names
%        reclist: string matrix
%        cuttype: currently must be explicitly provided. Only cuts in file cutname with specified cuttype are analyzed
%	 posfac: 2-element vector. Analysis position is determined from posfac(1)*cutstart + posfac(2)*cutend
%			i.e [1 0] and [0 1] give analysis at cutstart and cutend respectively, [0.5 0.5] give midpoint, etc.
%   Output arguments:
%        data: analysis data (rows correspond to trials, columns to signals)
%             It contains (from left to right): signal data, all cut data
%             (start, end, type, as well as trial_number and possibly additional columns for newer recordings),
%             rec position, cut position, cut number
%             Total columns is thus: (3*number of REC files) size(cutdata,2) + 3
%        label: simply the transcription field of the cuts analyzed
%        comment: string variable (row vector with embedded CRLF).
%                 Intended to be used as the comment variable, perhaps with additions
%                 from the calling program, in the MAT file used to store the analysis results.
%                 It consists of:
%                 functionname, analysis operation (anaposstr) cutname, recpath
%                 recnames
%                 comment from cut file.
%                 comments from the three filter files used
%        descriptor and unit: Set up from signal file descriptor and unit. Suffixes for velocity and acceleration parameters. Also cut data parameter descriptors etc.
%
% Remarks
%   Stored time positions have been rounded to a multiple of the sample interval
%   Calling program should delete all figures after termination
%
% Updates
%   4.97. version to use with mm_org setting up access to signal files
%   Raw integer output temporarily disabled
%   10.87 --re-enabled
%   2.98. Output comment variable standardized. descriptor and unit variables
%         generated and returned as output variables
%		10.98 New version for mt functions. Splice functions removed
%	3.99. New specification of analysis position, with posfac argument
%
% Algorithm
%   Filters for position, velocity and acceleration are currently fixed
%   Velocity and acceleration filters assumed designed as lowpass filters
%   They are convolved with [0.5 0 -0.5] to get a differentiation filter
%   (with a small amount of additional smoothing)

myversion=version;
diary on;
functionname='Mulpva_t: Version 8.3.99';
disp (functionname);
if nargin~=6
	help mulpva_t;
	return;
end;

namestr=['<Start of Comment> ' functionname crlf];
if strcmp(myversion(1),'5')
   namestr=[namestr datestr(now,0) crlf];
end;
%identifier?????
%       load the filter files and comments
posfilter='mf3535';
velfilter='mf2010';
accfilter='fir3';

bp=mymatin(posfilter,'data');
bv=mymatin(velfilter,'data');
ba=mymatin(accfilter,'data');
bpcom=mymatin(posfilter,'comment','No comment: Position filter');
bvcom=mymatin(velfilter,'comment','No comment: Velocity filter');
bacom=mymatin(accfilter,'comment','No comment: Acceleration filter');


filtercomment=['============' crlf];
filtercomment=[filtercomment 'Filter files' crlf];
filtercomment=[filtercomment '============' crlf];
filtercomment=[filtercomment '1. Position filter: ' posfilter '. Ncof ' int2str(length(bp)) crlf];
filtercomment=[filtercomment bpcom crlf];
filtercomment=[filtercomment '============' crlf];
filtercomment=[filtercomment '2. Velocity filter: ' velfilter '. Ncof ' int2str(length(bv)) crlf];
filtercomment=[filtercomment bvcom crlf];
filtercomment=[filtercomment '============' crlf];
filtercomment=[filtercomment '3. Acceleration filter: ' accfilter '. Ncof ' int2str(length(ba)) crlf];
filtercomment=[filtercomment bacom crlf];
filtercomment=[filtercomment '============' crlf];

%set up the filters
bd=[0.5 0 -0.5];
bv=conv(bd,bv);
ba=conv(bd,ba);
bbb=conv(bp,bv);
bbb=conv(bbb,ba);
nfilt=length(bbb);

diary off;
%        [nchan,ncut,sampincmax]=mm_org(cutname,recpath,reclist);
[ncut]=mt_org(cutname,recpath,reftrial);
mt_ssig(reclist);
siglist=mt_gcsid('signal_list');
nchan=size(siglist,1);
sampincmax=mt_gcsid('max_sample_inc');
diary on;
nrec=nchan;
nrec3=nrec*3;   %total signal parameters for pos, vel and acc



databufsize=200000;   %really needed??

cutdata=mt_gcufd;
cutlabel=mt_gcufd('label');
sf=mt_gsigv(siglist,'samplerate');
sampinc=1./sf(1);

%filter time
filtertime=sampinc*nfilt;
disp (['Total filter length in samples: ' int2str(nfilt)]);

%cut file must have at least 3 parameters
%watch out for possible future updates to cutfiles

vv=find (cutdata(:,3)==cuttype);
cutdata=cutdata(vv,:);
cutlabel=cutlabel(vv,:);

%removed!! note, will be NaN if one segment boundary is NaN
%cutlength=cutdata(:,2)-cutdata(:,1);

[ncut,nparc]=size(cutdata);	%nparc should be 3 or 4
%make space for 3 additional parameters,
%i.e cutnum, anarecpos, anacutpos
npar=nrec3+nparc+3;
%11.97 initialize to NaN
anabuf=ones(ncut,nrec3)*NaN;


%3.99. New way of specifying analysis position

anarecpos=zeros(ncut,1);
%this allows e.g NaNs for cutend if analyzing at cutstart

if posfac(1)~=0 anarecpos=anarecpos+(cutdata(:,1)*posfac(1)); end;
if posfac(2)~=0 anarecpos=anarecpos+(cutdata(:,2)*posfac(2)); end;

anaposstr=['Cut start factor : ' num2str(posfac(1)) '. Cut end factor : ' num2str(posfac(2))];	%for comment

%now round all the cut data
anarecpos=round(anarecpos*sf(1))./sf(1);
cutdata(:,1:2)=round(cutdata(:,1:2)*sf(1))./sf(1);

anacutpos=anarecpos-cutdata(:,1);
%11.97 cutlabel removed from anabuf
anabuf=[anabuf cutdata anarecpos anacutpos (1:ncut)'];
%main loops thru rec files and cuts
namestr=[namestr 'Cut file name: ' cutname crlf];

%include cuttype label if possible?????
cut_type_label='';
cut_type_value=mymatin(cutname,'cut_type_value');
if ~isempty(cut_type_value)
   vvl=find(cut_type_value==cuttype);
   if ~isempty(vvl)
      cut_type_label=mymatin(cutname,'cut_type_label');
      cut_type_label=cut_type_label(vvl,:);
   end;
end;

namestr=[namestr 'Cut type used: ' int2str(cuttype) ' ' cut_type_label crlf];

namestr=[namestr 'Analysis position specification: ' anaposstr crlf];

namestr=[namestr 'Signal file path: ' recpath crlf];

namestr=[namestr 'Signal files: ' strm2rv(reclist,' ') crlf];



%3.98
%get comment from cut file

reccomment=mymatin(cutname,'comment');

namestr=[namestr '==============================' crlf];
namestr=[namestr 'Comment from cut file' crlf];
namestr=[namestr '==============================' crlf];
namestr=[namestr reccomment crlf];

namestr=[namestr filtercomment crlf];

namestr=[namestr '<End of Comment> ' functionname crlf];

comment=namestr;


%set up complete descriptors and units

alldescrip=mt_gsigv(siglist,'descriptor');
allunit=mt_gsigv(siglist,'unit');

%complete unit/descriptors for vel. and acc.
ts=setstr(ones(nchan,1)*'_V');
descv=[alldescrip ts];
ts=setstr(ones(nchan,1)*'_A');
desca=[alldescrip ts];

descriptor=str2mat(alldescrip,descv,desca);
descriptor=strmdebl(descriptor);
ts=setstr(ones(nchan,1)*'/s');
unitv=[allunit ts];
ts=setstr(ones(nchan,1)*'/s2');
unita=[allunit ts];
unit=str2mat(allunit,unitv,unita);
unit=strmdebl(unit);

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





%add in descriptor and unit for last 3 variables
descriptor=str2mat(descriptor,'ana_recposition','ana_cutposition','cutnumber');
unit=str2mat(unit,'s','s',' ');



diary off;

%main loop, thru cuts
for icut=1:ncut
   itrial=cutdata(icut,4);
   mt_loadt(itrial);
   timspec=cutdata(icut,1:2);
   timspec(1)=timspec(1)-filtertime;
   timspec(2)=timspec(2)+filtertime;
	%workaround if cut end is NaN
	if isnan(timspec(2)) timspec(2)=timspec(1)+2*filtertime; end;


   
   indi1=round((anarecpos(icut)-timspec(1))*sf(1))+1;
   %read data
   
   [xx,actualtime]=mt_gdata(siglist(1,:),timspec);
   nx=size(xx,1);
   
   posbuf=zeros(nx,nchan);
   velbuf=zeros(nx,nchan);
   accbuf=zeros(nx,nchan);
   
   %filtering
   for jd=1:nchan
      [xx,actualtime]=mt_gdata(siglist(jd,:),timspec);
      posbuf(:,jd)=decifir(bp,xx);
      velbuf(:,jd)=decifir(bv,posbuf(:,jd))*sf(1);
      accbuf(:,jd)=decifir(ba,velbuf(:,jd))*sf(1);
   end;
   
   
   
   %mulana style analysis
   posbuf=posbuf(indi1,:);
   velbuf=velbuf(indi1,:);
   accbuf=accbuf(indi1,:);
   
   anabuf(icut,1:nrec3)=[posbuf velbuf accbuf];
   disp(cutlabel(icut,:));
   disp ([icut anacutpos(icut) indi1 indi1-nfilt])
   %            disp (databuf(indi1,:));
   
   
   
end;    %cut loop
data=anabuf;
label=cutlabel;

