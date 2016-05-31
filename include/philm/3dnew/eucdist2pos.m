function eucdist2pos(posdir1,posdir2,triallist,distfac)
% EUCDIST2POS Euclidean distance between 2 sets of AG500 position files
% function eucdist2pos(posdir1,posdir2,triallist,distfac)
% eucdistpos: Version 18.03.2008
%
%   Description
%       Inserts euclidean distance between pos files as parameter 7 in first pos
%       file
%       Position files assumed to be MAT files.
%       distfac: defaults to 1. Euclidean distance is multiplied by this
%       value

functionname='eucdist2pos: Version 18.03.08';

myversion=version;
versionstr='';
if myversion(1)>='7' versionstr='-v6'; end;

newcomment=['Inputs : ' posdir1 ' ' posdir2 crlf];

parametername='compdist';
outparrms=6;
outpardt=7;

distf=1;
if nargin>3 distf=distfac; end;


for iti=triallist
    disp(iti)
    mytrial=int2str0(iti,4);
    file1=[posdir1 pathchar mytrial];
    pp1=loadpos(file1);
    if ~isempty(pp1)
        comment=mymatin(file1,'comment');
        descriptor=mymatin(file1,'descriptor');
        unit=mymatin(file1,'unit');
        
        nsensor=size(pp1,3);
        pp2=loadpos([posdir2 pathchar mytrial]);



        for ii=1:nsensor 
            tmp=eucdistn(pp1(:,1:3,ii),pp2(:,1:3,ii));
            pp1(:,outpardt,ii)=tmp*distf;
        end;

        descriptor=cellstr(descriptor);
        descriptor{outpardt}=parametername;
        descriptor=char(descriptor);
        unit=cellstr(unit);
        tmpunit=unit{1};     %assume first parameter is position
        if distf~=1 tmpunit(1)='?'; end;    %needs sorting out
        unit{outpardt}=tmpunit;
        unit=char(unit);
        comment=[newcomment comment];
        comment=framecomment(comment,functionname);
        
        data=single(pp1);
        save(file1,'data','comment','descriptor','unit','-append',versionstr);
        
%        savepos([posdir1 '\' mytrial '.pos'],pp1);


    end;        %pp1 not empty
end;
