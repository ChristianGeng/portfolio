function S=showcaltxt(calfile)
% SHOWCALTXT Get calibration data, phases, sinofs from text file of AG500 calibration results
% function showcaltxt(calfile)
% showcaltxt: Version 14.12.07
%
%   Description
%       Returns results in a structure with fields
%       'phase','sinofs','calibration_factors','calibration_a0_r_z_phi_theta_rms'
%       Also plots the data

fieldlist=str2mat('phase','sinofs','calibration_factors','calibration_a0_r_z_phi_theta_rms');

nfield=size(fieldlist,1);

ss=file2str(calfile);
maxchan=12;
ntrans=6;

for ifield=1:nfield
    myfield=deblank(fieldlist(ifield,:));



    mydata=ones(maxchan,ntrans)*NaN;
    for ii=1:maxchan
        ipi=strmatch(['__channel' int2str(ii) '_' myfield '='],ss);
        if length(ipi)==1
            tmps=ss(ipi,:);
            ipi2=findstr('=',tmps);
            tmps(1:ipi2)=[];
            mydata(ii,:)=str2num(tmps);
        end;

    end;

    S.(myfield)=mydata;

    plotdata=mydata;
    if strcmp(myfield,'phase')
        vv=find(plotdata<0);
        plotdata(vv)=180+plotdata(vv);
    end;

    figure;
    plot(plotdata)
    title(myfield,'interpreter','none');

end;
