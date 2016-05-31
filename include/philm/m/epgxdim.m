function epgxdim(epgfile)
% EPGXDIM Add external dimension specification to epg file
% function epgxdim(epgfile)
% epgxdim: Version 12.2.08
%
%   Description
%       Ensures that descriptor and unit variables are in the EPG mat file
%       Also includes internal and external dimension specification, which
%       is needed for full compatibility with mtnew display functions.
%       This version provides the specification for the traditional
%       arrangement of the Reading-style EPG in rows and columns, but it
%       could be used as a guide for including electrode locations based on
%       anatomical measurements if desired

functionname='EPGXDIM: Version 12.2.08';

ndim=2;
nrow=8;
ncol=8;

%newepg=0;
unused_electrodes=[1 8];

externalcomment=['Row numbers increase from front to back.' crlf 'Column numbers increase from left to right'];

comment=mymatin(epgfile,'comment','<No comment in input EPG file>');

% no longer necessary: epg_rt stores compatible with older data
%myprivate=mymatin(epgfile,'private');
%if isfield(myprivate,'epgrt')
%    unused_electrodes=[57 64];
%externalcomment='Row numbers increase from back to front.';
%end;

externalcomment=[externalcomment crlf 'Unused electrodes are ' int2str(unused_electrodes) '.'];

myD.descriptor=str2mat('electrode','time');
myD.unit=str2mat(' ',' ');

axc=cell(1,2);

axc{1}=(1:64)';
axc{2}=[];
myD.axis=axc;



myD.external.descriptor=str2mat('column','row');
myD.external.unit=str2mat(' ',' ');
myD.external.comment=externalcomment;

ax1=repmat((1:8)',[1 nrow]);
ax1=ax1(:);

ax2=repmat((1:8),[ncol 1]);
ax2=ax2(:);

ax1(unused_electrodes)=NaN;
ax2(unused_electrodes)=NaN;

ax=cell(ndim,1);
ax{1}=ax1;
ax{2}=ax2;


myD.external.axis=ax;

dimension=myD;

descriptor='EPG';
unit='contact';

comment=framecomment(comment,functionname);
save(epgfile,'dimension','descriptor','unit','comment','-append');

