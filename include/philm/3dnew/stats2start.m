%load statstmp
nsensor=size(stats,3);
nco=5;
grad2rad=pi/180;
startpos=ones(nsensor,nco);
for ii=1:nsensor 
x=stats(:,1:nco,ii);
%x(:,4:5)=normalizeangles(x(:,4:5));
%stats(:,1:nco,ii)=x;
xpos=x(:,1:3);
[orix,oriy,oriz]=sph2cart(x(:,4)*grad2rad,x(:,5)*grad2rad,1);
xquer=nanmean([xpos orix oriy oriz]);
[phi,theta,dodo]=cart2sph(xquer(4),xquer(5),xquer(6));
%    startpos(ii,:)=[xquer(1:3) normalizeangles([phi theta]/grad2rad)]; 
             startpos(ii,:)=[xquer(1:3) [phi theta]/grad2rad]; 
end;
disp(startpos);

