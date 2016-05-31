function [ps,cs,s1line,nstim,nline,imageflag,maxcol]=parsestimfile(stimfile,myprefix);
% PARSESTIMFILE Extract codes and prompts from stimulus file
% function [ps,cs,s1line,nstim,nline,imageflag,maxcol]=parsestimfile(stimfile,myprefix);
% parsestimfile: Version 19.03.07

baseprefix='<IMAGE>';
imageflag=0;

if nargin>1 baseprefix=myprefix; end;

ls=file2str(stimfile);

nline=str2num(ls(1,:));

ls=ls(2:end,:);

nstim=size(ls,1)/(nline+1);

stimpos=1:(nline+1):size(ls,1);

if round(nstim)~=nstim
    disp('Probably wrong number of lines somewhere in prompt file');
    keyboard;
    %    return;
end;

nstim=floor(nstim);
ndig=length(int2str(nstim));

%sort into prompts and codes
%also one-line version of code and prompt
ps=cell(nstim,1);
cs=cell(nstim,1);
s1line=cell(nstim,1);

maxcol=1;      %maximum number of columns in prompts; only needed for vt100 output


lsc=cellstr(ls);
try
    for ii=1:nstim
        ptmp=char(lsc(stimpos(ii):(stimpos(ii)+nline-1)));
        maxcol=max([maxcol size(ptmp,2)]);
        
        %strip trailing blank lines
        if nline>1
            ok2del=1;
            for ild=nline:-1:2
                ptmp2=deblank(ptmp(ild,:));
                if isempty(ptmp2)
                    if ok2del ptmp(ild,:)=[]; end;
                else
                    ok2del=0;
                end;
            end;
        end;
        
        %disp(ii);
        
        if ~isempty(findstr(baseprefix,ptmp(1,:))) imageflag=1; end;
        
        
        %each stimulus text is itself stored as a cellstring within the cell array
        ps{ii}=cellstr(ptmp);
        
        cs{ii}=deblank(ls(stimpos(ii)+nline,:));
        %disp(ps{ii});
        %   disp(cs{ii});
        tmp1=[int2str0(ii,ndig) '<' cs{ii} '>' strm2rv(ptmp,' ')];
        s1line{ii}=tmp1;
        
    end;
catch
    disp('problem with stimulus file');
    keyboard;
end;

if ~nargout helpwin(s1line,stimfile); end;
