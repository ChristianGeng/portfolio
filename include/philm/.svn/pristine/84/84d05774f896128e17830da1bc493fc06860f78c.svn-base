function random_stim_blocked(listfile,ranfile,nrep,sameranflag,fixedcode,restinterval,blockspec,dummyfile);
% RANDOM_STIM_BLOCKED Randomize stimuli, optionally blockwise
% function random_stim_blocked(listfile,ranfile,nrep,sameranflag,fixedcode,restinterval,blockspec,dummyfile);
% random_stim_blocked: Version 8.9.06
%
%	Description
%		Randomize stimuli
%		first line of listfile must be number of lines per stimulus prompt
%		Following each prompt there must be a stimulus code of one line
%           Block number and repetition number are added to code (if total
%           blocks or total reps > 1, respectively)
%
%	Syntax
%		sameranflag: Optional. Default to false. If true, use same randomization for every rep.
%		fixedcode: Optional code to add to every code line (before rep number)
%		restinterval: Optional. Default to 1. A rest position will be
%		    inserted after every restinterval blocks of repetitions. i.e set to
%		    0 to suppress rest positions.
%       blockspec: Optional. If present must be vector [blockstart
%           blockstep blockn startinc]
%       dummyfile: Optional. Can specify a file containing dummy stimuli to
%           insert after every rest position. Must have same arrangement as
%           main list file (main listfile can also be used as the source of
%           dummies, if desired). The order of items in the dummy file is
%           randomized before use.
%           If more dummies are required than are in the file then file is
%           cycle through as often as necessary.
%           The string !!DUUMY!! is inserted at the beginning of the code
%           line of each dummy stimulus

sameran=0;
if nargin>3
    if ~isempty(sameranflag) sameran=sameranflag; end;
end;

%this makes sure a different random sequence is generated each time the
%program is run (should also be an option??)
rand('state',sum(100*clock));


fixedc='';
if nargin>4 fixedc=fixedcode; end;

reststr='"Rest"';

restcnt=1;
if nargin>5
    if ~isempty(restinterval) restcnt=restinterval; end;
end;

restcntx=restcnt;


blockflag=0;
if nargin>6
    if length(blockspec)==4
        blockflag=1;
        blockstart=blockspec(1);
        blockstep=blockspec(2);
        blockn=blockspec(3);
        startinc=blockspec(4);
    end;
end;


[nline,bigstim,bigcode]=getlistfile(listfile);

nstimall=length(bigcode);

if nstimall==0
    disp('Unable to proceed');
    return;
end;


dodummy=0;
if nargin>7
    [nlined,dummystim,dummycode]=getlistfile(dummyfile);
    nstimd=length(dummycode);
    if nstimd>0 & nlined==nline 
        dummyp=1;
        tmpran=randperm(nstimd);
        dummystim=dummystim(tmpran,:);
        dummycode=dummycode(tmpran);
        dummycode=strcat('!!DUMMY!!',dummycode);
        dodummy=1;
    else
        disp('Unable to use dummy file');
        keyboard;
    end;
end;

%sort out blocks
if blockflag
    blockbuf=(blockstart:blockstep:nstimall)';
    blockbuf=blockbuf(1:blockn);
    blocklength=length(blockbuf);
    bdone=0;
    while ~bdone
        blockstart=blockstart+startinc;
        tmpbuf=(blockstart:blockstep:nstimall)';
        if length(tmpbuf)>=blocklength
            blockbuf=[blockbuf tmpbuf(1:blockn)];
        else
            bdone=1;
        end;
    end;
    
else
    blockbuf=(1:nstimall)';
    blocklength=nstimall;
end;

nblock=size(blockbuf,2);

nstim=blocklength;

%keyboard;


rdig=length(int2str(nrep));
bdig=length(int2str(nblock));

fid=fopen(ranfile,'w');
if fid<3 
    disp('unable to open output file');
    return;
end;

status=fwrite(fid,[int2str(nline) crlf],'uchar');

%keyboard;
restcell=(blanks(nline))';
restcell=cellstr(restcell);
restcell{1}=reststr;
restd=restcell;
%restd=char(restcell);

restcode=['REST' fixedc];


myr=randperm(nstim);

for iblock=1:nblock
    xcode=bigcode(blockbuf(:,iblock));
    xstim=bigstim(blockbuf(:,iblock),:);
    
    blockstr='';
    if nblock>1 blockstr=['_b' int2str0(iblock,bdig)]; end;
    
    
    for irep=1:nrep
        if ~sameran myr=randperm(nstim); end;
        
        repstr='';
        if nrep>1 repstr=['_' int2str0(irep,rdig)]; end;
        
        if restcnt>0
            restcntx=restcntx+1;
            if restcntx>=restcnt
                restcntx=0;
                writestim(restd,restcode,blockstr,repstr,fixedc,fid);
                
                
                if dodummy
%keyboard;
                    writestim(dummystim(dummyp,:),dummycode{dummyp},blockstr,repstr,fixedc,fid);
                    dummyp=dummyp+1;
                    if dummyp>nstimd dummyp=1; end;
                end;
                
                
            end;
        end;
        
        
        for istim=1:nstim
            ipi=myr(istim);
            writestim(xstim(ipi,:),xcode{ipi},blockstr,repstr,fixedc,fid);
            
        end;
    end;
    
end;            %block loop



status=fclose(fid);

function [nline,bigstim,bigcode]=getlistfile(listfile);

ls=file2str(listfile);

linstr=deblank(ls(1,:));
nline=str2num(ls(1,:));

ls=ls(2:end,:);

%divide into codes and stimuli

bigcode=cellstr(ls((nline+1):(nline+1):end,:));

bigstim=ls;
bigstim((nline+1):(nline+1):end,:)=[];      %remove code lines
bigstim=cellstr(bigstim);
try
    bigstim=reshape(bigstim,nline,[]);
catch
    disp('error in file (stim reshape) ??');
    disp(listfile);
    keyboard;
    bigcode=[];
    return;
end;

bigstim=bigstim';

nstimall=length(bigcode);
if nstimall~=size(bigstim,1)
    disp('error in file (stim vs code length) ??');
    disp(listfile);
    keyboard;
    bigcode=[];
    return;
end;

function writestim(mystim,mycode,blockstr,repstr,fixedc,fid);

nline=length(mystim);
ss='';
for ii=1:nline
    ts=mystim{ii};
    ss=[ss ts crlf];
end;
ts=mycode;
ts=[ts fixedc blockstr repstr];

ss=[ss ts crlf];
status=fwrite(fid,ss,'uchar');
