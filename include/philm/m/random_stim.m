function random_stim(listfile,ranfile,nrep,sameranflag,fixedcode,norestflag);
% RANDOM_STIM Randomize stimuli
% function random_stim(listfile,ranfile,nrep,sameranflag,fixedcode,norestflag);
% random_stim: Version ??
%
%	Description
%		Randomize stimuli
%		first line of listfile must be number of lines per stimulus prompt
%		Following each prompt there must be a stimulus code of one line
%
%	Syntax
%		sameranflag: Optional. Default to false. If true, use same randomization for every rep.
%		fixedcode: Optional code to add to every code line (before rep number)
%		norestflag: Optional. Default to false. If true, Suppress automatic insertion of "rest" at start of each block

sameran=0;
if nargin>3
   if ~isempty(sameranflag) sameran=sameranflag; end;
end;

fixedc='';
if nargin>4 fixedc=fixedcode; end;

reststr='"Rest"';

norest=0;
if nargin>5
   if ~isempty(norestflag) norest=norestflag; end;
end;


ls=file2str(listfile);

linstr=deblank(ls(1,:));
nline=str2num(ls(1,:));

ls=ls(2:end,:);

nstim=size(ls,1)/(nline+1);

if round(nstim)~=nstim
	disp('problem in file')
keyboard;
return;
end;


stimpos=1:(nline+1):size(ls,1);

rdig=length(int2str(nrep));

fid=fopen(ranfile,'w');
if fid<3 
   disp('unable to open output file');
   return;
end;

status=fwrite(fid,[linstr crlf],'uchar');

%keyboard;
restcell=(blanks(nline))';
restcell=cellstr(restcell);
restcell{1}=reststr;
restd=char(restcell);

restcode=['REST' fixedc];

myr=randperm(nstim);

for irep=1:nrep
   if ~sameran myr=randperm(nstim); end;
   
   if ~norest
      ss='';
      for ii=1:nline
         ts=deblank(restd(ii,:));
         ss=[ss ts crlf];
      end;
      ts=deblank(restcode);
      ts=[ts int2str0(irep,rdig)];
      
      ss=[ss ts crlf];
      status=fwrite(fid,ss,'uchar');
   end;
   
   
   for istim=1:nstim
      ipi=stimpos(myr(istim));
      ss='';
      for ii=1:nline
         ts=deblank(ls(ipi,:));
         ss=[ss ts crlf];
         ipi=ipi+1;
      end;
      ts=deblank(ls(ipi,:));
      ts=[ts fixedc int2str0(irep,rdig)];
      
      ss=[ss ts crlf];
      status=fwrite(fid,ss,'uchar');
      %write
      
   end;
end;


status=fclose(fid);
