function tapadold2autokal(posdir,outdir,triallist);
% TAPADOLD2AUTOKAL convert old recordings to autokal coordinates
% function tapadold2autokal(posdir,outdir,triallist);
% convert position data calculated with old C version of tapad to autokal
% based coordinate system (with scaling in mm and deg.)

m2mm=1000;
rad2grad=180/pi;

%triallist=1:431;

%posdir='..\tappos_m\rawpos\';
%outdir='..\tap2auto_m\rawpos\';

for ii=triallist
    pp=loadpos([posdir int2str0(ii,4) '.pos']);
    if ~isempty(pp)
    disp(ii);
        nchan=size(pp,3);
    

    for jj=1:nchan
        tmp=pp(:,1:3,jj);
        tmp=m2mm*tapadold2autokal_rotta(tmp);
        pp(:,1:3,jj)=tmp;

        tmp=pp(:,4:5,jj);
        [x,y,z]=sph2cart(tmp(:,1),tmp(:,2),1);
        tmp=m2mm*tapadold2autokal_rotta([x y z]);
        [w1,w2,dodo]=cart2sph(tmp(:,1),tmp(:,2),tmp(:,3));
        
        pp(:,4:5,jj)=[w1 w2]*rad2grad;
    end;
    
    savepos([outdir int2str0(ii,4) '.pos'],pp);
end;

end;
