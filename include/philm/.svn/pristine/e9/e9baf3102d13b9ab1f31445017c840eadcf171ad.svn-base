function startpos_sph=stats2start_cartf(stats_cart)
% STATS2START_CARTF: Mean coordinates. Orientation: Input as unit vector; output as spherical
% function startpos_sph=stats2start_cartf(stats_cart)
% stats2start_cartf: Version 18.12.07
%
%   Description
%       Computes mean of an m x 6 list of input coordinates (with sensors
%       as 3rd dimension)
%           Positions in cols. 1-3, orientations in cols. 4-6
%               (additional columns may be present; they are simply
%               ignored)
%           Orientations in the input data must be in cartesian (unit vector) form;
%               they are returned in the output as spherical coordinates (in degrees)
%       Output data is arranged sensors*coordinates (the latter as posx,
%       posy, posz, phi, theta)
%       Typical use: Get a set of start positions for use with tapad

stats=stats_cart;

nsensor=size(stats,3);
nco=5;
grad2rad=pi/180;
startpos=ones(nsensor,nco)*NaN;
for ii=1:nsensor
    x=stats(:,1:(nco+1),ii);

    %2nd input arg not available in version 6
    %    xquer=nanmean(x,1);

    if size(x,1)>1
    xquer=nanmean(x);
    else
        xquer=x;
    end;
    


    [phi,theta,dodo]=cart2sph(xquer(4),xquer(5),xquer(6));
    startpos(ii,:)=[xquer(1:3) [phi theta]/grad2rad];
end;

startpos_sph=startpos;
