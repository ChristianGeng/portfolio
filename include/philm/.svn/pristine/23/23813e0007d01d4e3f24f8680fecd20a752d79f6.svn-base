function adjlogfilev(logfile,agoffset,outoffset,fixlist)
% ADJLOGFILEV Adjust matlab log file of AG500 recordings
% function adjlogfilev(logfile,agoffset,outoffset,fixlist)
% adjlogfilev: Version 13.10.05
%
%   Description
%       New version, 8.05. uses vt numbers from log file as basis for
%       fixlist.
%       Should be used before parselogfile and addlabcmt2sync_f, and before converting ag data
%       to mt.
%       Originally needed to handle problems with trial numbers after
%       transmitter reset.
%       Can be used to handle any other discrepancies between trial
%       numbering in the log file, and actual trial number of corresponding
%       AG500 data files.
%       But should be used even if no problems.
%       Sets up an unambiguous relation between ag and mt trial numbers
%       and allows a record to be kept with the data of any discrepancies with
%       respect to the trial number inserted by the video timer.
%       Also trims off some automatic comments from the log file.
%       When setting up the basic cut file for an experiment it is
%       recommended to include the complete log file information as the
%       trial_number field in the valuelabel structure.
%       This is returned in the appropriate form by parselogfile.
%       If AG mat files need renumbering before being converted to the
%       final MT format (by rigidbodyana), then use renumber_trials with
%       the agtrialnum and mttrialnum output arguments from parselogfile
%
%   Syntax
%       logfile: name of raw log file (without extension; must be .txt)
%       agoffset: added to vtnum (leftmost column in raw log file) to get ag trial number
%       outoffset: mt trial number is then derived from ag trial number by subtracting outoffset
%       fixlist: Allows additional adjustment to trial numbers
%           set up [firsttrial lasttrial numberincrement]
%           here trial numbers refer to vtnum in the unadjusted log file
%       For simple cases agoffset=outoffset=0; and set fixlist to empty
%
%   See Also
%       ADDLABCMT2SYNC
%       PARSELOGFILE
%       RENUMBER_TRIALS


myfile=logfile;


outsuffix='_adj';

%this is the simple case
%agoffset=0;
%outoffset=agoffset;
%fixlist=[];

%myfile='french_s_all_ran_log_noel4';
%agoffset=0;
%outoffset=-217;     %ag numbered from 1, but final mt number continues from previous part of recording
%fixlist=[];

%myfile='french_s_all_ran_log_noel2_2';
%agoffset=0;
%outoffset=0;
%fixlist=[192 216 1];%ag trial 192 run without prompt. Insert dummy in log file afterwards


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

vv=strmatch(']',bigs);
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
%agnumx=agnum;
if nfix
    disp('fixing trial numbers');
    for ii=1:nfix
        disp(fixlist(ii,:));
        vv=find(vtnum>=fixlist(ii,1) & vtnum<=fixlist(ii,2));
        agnum(vv)=agnum(vv)+fixlist(ii,3);
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
