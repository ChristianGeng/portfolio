function mypos=subp_pos(nchan,xfac,yfac)
% SUBP_POS Calculate adjusted subplot positions
% function mypos=subp_pos(nchan,xfac,yfac)
% subp_pos: Version 18.2.99
%
%   Syntax
%       All args default to 1
%       nchan can have 1 or 2 elements
%       if 1, set up this many rows; if 2, use as rows/cols specification

if nargin<3 yfac=1;end;
if nargin<2 yfac=1;xfac=1;end;
if nargin<1 yfac=1;xfac=1;nchan=1;end;


nrow=nchan(1);
ncol=1;
if length(nchan)==2
    ncol=nchan(2);
end;
n=nrow*ncol;



mypos=zeros(n,4);
hdum=figure;
for ii=1:n
%the matlab7 version of subplot uses a new axes property called
%outerposition. This can result in the position extent being negative.
% But if you try to set position directly with a negative value, the
% program crashes!
%subplotv6 is simply a copy of the matlab 6 version of subplot
    subplotv6(nrow,ncol,ii);
    postmp=get(gca,'position');
    xladj=postmp(3)*xfac;
    xzadj=(xladj-postmp(3))./2;
    postmp(1)=postmp(1)-xzadj;
    postmp(3)=xladj;
    yladj=postmp(4)*yfac;
    yzadj=(yladj-postmp(4))./2;
    postmp(2)=postmp(2)-yzadj;
    postmp(4)=yladj;
%keyboard;
    set(gca,'position',postmp);
    mypos(ii,:)=get(gca,'position');
    
    
end;

delete(hdum);
