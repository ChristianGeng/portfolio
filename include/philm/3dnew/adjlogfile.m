% adjlogfile Old script version, use adjlogfilev function instead
%should be used before addlabcmt2sync, and before converting ag data to mt
%originally needed to handle problems with trial numbers after transmitter reset in MCA1
%but should be used even if no problems.
%Sets up an unambiguous relation between ag and mt trial numbers
% and allows a record to be kept with the data of any discrepancies with
% respect to the trial number inserted by the video timer
% also trims off some automatic comments from the log file
%The adjusted version of the log file is used by tapad2mat_new2_log
% to set up trial numbering, and in effect includes the complete log file
% in the trialnumber_label/value structure in the cut file

outsuffix='_adj';

myfile='aix_fre_all_ran_log_noel1';
%this is the simple case
agoffset=0;
outoffset=agoffset;
fixlist=[];

%=================================================
%examples of set up for various more problematic cases

%=========
%myfile='arabiclong_ran_log_cz';
%agoffset=0;
%outoffset=agoffset;

%fixlist=[21 121 3;122 123 4;124 124 5;125 197 6;198 378 7;379 398 8;399 415 9;416 421 10];
%============
%myfile='arabic_codefast_ran_log_czfast';

%first ag trial is 432

%agoffset=431;
%outoffset=agoffset;     %outoffset normally same as agoffset, if mt trials are to be numbered from 1

%445 and 517 zero length file with timeout
%setting up this list is tricky!!!
%180 not accurate (just needs to be big enough to cover all remaining trials in this part of recording
%fixlist=[445 515 1;516 516+180 2];

%====================
%=========================================================================

nfix=size(fixlist,1);

outheader='% MT, AG, VT, Stim, Time of day, Duration, Code and Comment';
bigs=file2str([myfile '.txt']);

vv=strmatch('<',bigs);
if ~isempty(vv)
    disp('Deleting comments');
    disp(bigs(vv,:));
    bigs(vv,:)=[];
end;
vv=strmatch('%',bigs);
if ~isempty(vv)
    disp('Deleting comments');
    disp(bigs(vv,:));
    bigs(vv,:)=[];
end;
vv=strmatch('!',bigs);
if ~isempty(vv)
    disp('Deleting comments');
    disp(bigs(vv,:));
    bigs(vv,:)=[];
end;


nrec=size(bigs,1);
vtnum=zeros(nrec,1);
for ii=1:nrec
    tmps=strtok(bigs(ii,:));
    vtnum(ii)=str2num(tmps);
end;

agnum=vtnum+agoffset;
agnumx=agnum;
if nfix
    disp('fixing trial numbers');
    for ii=1:nfix
        disp(fixlist(ii,:));
        vv=find(agnumx>=fixlist(ii,1) & agnumx<=fixlist(ii,2));
        agnum(vv)=agnumx(vv)+fixlist(ii,3);
    end;
end;

outnum=agnum-outoffset;

fid=fopen([myfile outsuffix '.txt'],'w');
status=fwrite(fid,[outheader crlf],'uchar');
for ii=1:nrec
    tmps=deblank(bigs(ii,:));
    tmps=[int2str(outnum(ii)) ' ' int2str(agnum(ii)) ' ' tmps crlf];
    status=fwrite(fid,tmps,'uchar');
end;
fclose(fid);
