% ERRORANA script to analyze magnetometer error maps
% errorana: Version 6.7.97
%
% Description
%   Display errormaps and set up coordinate coorection based on predicted error
%   designed to be called from emmaproc/emmaproa
%   but could be turned into a stand alone routine fairly easily
%   (see notes in emmaproc)
%
% See also
%   ag100cal: Gets autokal results into MAT file as required by errorana

disp ('=====================================');
disp ('Analysis of error map');
disp ('Preparation of coordinate corrections');
disp ('=====================================');
%error is defined as true minus measured
errorxy=[errormap(:,2)-errormap(:,4) errormap(:,3)-errormap(:,5)];
truexy=errormap(:,2:3);
errorsens=errormap(:,1);

sdfac=3;	%show +/- sdfac range around mean
minvectorsneeded=3;	%otherwise no vector analysis/correction perfomred

%x and y errors will be predicted individually from the x and y coordinates
%i.e e.g x_error=a*x+b*y+c;


for ii=1:nsensor
    isensor=sensorlist(ii);
    sensorlabel=deblank(sensorstrm(ii,:));
    disp (['Processing sensor ' int2str(isensor) ' ' sensorlabel]);
    %allow sensor to be skipped immediately
    tempstr=upper(abartstr('Continue processing?','Y'));
    if tempstr ~='N'
        nvfound=0;
        %extract current sensor data from complete error map
        vv=find(errorsens==isensor);
        
        if isempty(vv)
            disp ('No error vector information available for this sensor');
        end;
        
        if ~isempty(vv)
            
            euse=errorxy(vv,:);
            tuse=truexy(vv,:);
            
            hq=figure;
            [maxmag,maxmagind]=max(abs(euse(:,1)+i*euse(:,2)));
            quiver (tuse(:,1),tuse(:,2),euse(:,1),euse(:,2),'g');
            axis ([-10 10 -10 10]);
            axis ('square');
            set (gca,'xgrid','on','ygrid','on');
            hold on;
            quiver (tuse(maxmagind,1),tuse(maxmagind,2),euse(maxmagind,1),euse(maxmagind,2),'r*');
            title (['Sensor ' int2str(ii) ' ' sensorlabel '. Max. error ' num2str(maxmag*10) ' mm']);
            %note : transx defined in emmaproa
            %so will not work if errorana turned into a function!
            line ([transx';transx(1)],[transy';transy(1)])
            %note: size of error vectors in fig. not scaled
            %
            %this could be upgraded to show 2sig ellipse
            disp (['Cross shows data range +/- ' num2str(sdfac) ' sds around mean']);
            %skip sensor if meanall is NaN
            datamx=meanall(x_col(isensor));
            datamy=meanall(y_col(isensor));
            datasdx=stdall(x_col(isensor));
            datasdy=stdall(y_col(isensor));
            realdata=max([datasdx datasdy]);
            line ([datamx-sdfac*datasdx datamx+sdfac*datasdx],[datamy datamy]);
            line ([datamx datamx],[datamy-sdfac*datasdy datamy+sdfac*datasdy]);
            line('xdata',datamx,'ydata',datamy,'linestyle','o','color','y');
            lookradius=(max([datasdx datasdy]))*sdfac;
            if lookradius==0 lookradius=r_cen./2; end;
            vectorschosen='N';
            
            while vectorschosen~='Y'
                %ask for choice of vector range around mean
                %then compute current error
                %and estimated error after error correction
                %correction method either mean or regression
                
                lookradius=abart ('Error vector search radius',lookradius,0,r_cen,abnoint,abscalar);
                %draw a circle at this radius
                if ~realdata
                    datamx=abart ('X-coordinate of search region centre',datamx,-r_cen,r_cen,abnoint,abscalar);
                    datamy=abart ('Y-coordinate of search region centre',datamy,-r_cen,r_cen,abnoint,abscalar);
                end;
                hc=plot((lookradius*exp(i*(0:0.1:2*pi)))+(datamx+i*datamy),'-r');
                
                vv=find(abs((tuse(:,1)-datamx)+i*(tuse(:,2)-datamy))<lookradius);
                
                if length(vv)<minvectorsneeded
                    disp ('Not enough vectors for further analysis');
                end;
                
                if length(vv)>=minvectorsneeded
                    nvfound=length(vv);
                    disp (['Error vectors found : ' int2str(nvfound)]);
                    
                    echosen=euse(vv,:);
                    tchosen=tuse(vv,:);
                    dodos=philinp('zoom after CR');
                    delete (hq);
                    hq=figure;
                    [maxmag,maxmagind]=max(abs(echosen(:,1)+i*echosen(:,2)));
                    quiver (tchosen(:,1),tchosen(:,2),echosen(:,1),echosen(:,2),'g');
                    lookx=lookradius*1.1;
                    axis ([datamx-lookx datamx+lookx datamy-lookx datamy+lookx]);
                    axis ('square');
                    set (gca,'xgrid','on','ygrid','on');
                    hold on;
                    quiver (tchosen(maxmagind,1),tchosen(maxmagind,2),echosen(maxmagind,1),echosen(maxmagind,2),'r*');
                    title (['Sensor ' int2str(ii) ' ' sensorlabel '. Max. error ' num2str(maxmag*10) ' mm']);
                    %note : transx defined in emmaproa
                    %so will not work if errorana turned into a function!
                    line ([transx';transx(1)],[transy';transy(1)])
                    hc=plot((lookradius*exp(i*(0:0.1:2*pi)))+(datamx+i*datamy),'-r');
                    line ([datamx-sdfac*datasdx datamx+sdfac*datasdx],[datamy datamy]);
                    line ([datamx datamx],[datamy-sdfac*datasdy datamy+sdfac*datasdy]);
                    line('xdata',datamx,'ydata',datamy,'linestyle','o','color','y');
                    %note: size of error vectors in fig. not scaled
                    disp ('Error stats (in mm) before correction')
                    disp ('=====================================');
                    errprint=echosen*10;
                    eucerr=abs(errprint(:,1)+i*errprint(:,2));
                    disp ('mean(x), mean(y), mean(abs(x)), mean(abs(y)), mean(magnitude)');
                    disp ([mean(errprint) mean(abs(errprint)) mean(eucerr)]);
                    disp ('sd(x), sd(y), sd(magnitude), max(abs(x)),max(abs(y)), max(magnitude)');
                    disp ([std(errprint) std(eucerr) max(abs(errprint)) max(eucerr)]);
                    
                    correctionmethod=upper(abartstr('Chose correction method : M=Mean, R=Regression','R'));
                    
                    if correctionmethod=='M' myA=[zeros(nvfound,2) ones(nvfound,1)]; end;
                    if correctionmethod~='M' myA=[tchosen ones(nvfound,1)];end;
                    
                    %do regression analysis......
                    ptemp=myA\echosen;
                    disp ('Correction coefficients');
                    disp ('Columns: xerror, yerror; Rows: xcof, ycof, const.');
                    disp (ptemp*10);
                    %compute predicted error and subtract from current error
                    prederr=myA*ptemp;
                    residerr=echosen-prederr;
                    
                    %show stats on residual error
                    disp ('Predicted error (in mm) after correction')
                    disp ('========================================');
                    %sort out units for mit vs. ag100
                    errprint=residerr*10;
                    
                    eucerr=abs(errprint(:,1)+i*errprint(:,2));
                    disp ('mean(x), mean(y), mean(abs(x)), mean(abs(y)), mean(magnitude)');
                    disp ([mean(errprint) mean(abs(errprint)) mean(eucerr)]);
                    disp ('sd(x), sd(y), sd(magnitude), max(abs(x)),max(abs(y)), max(magnitude)');
                    disp ([std(errprint) std(eucerr) max(abs(errprint)) max(eucerr)]);
                    
                end;	%minvectors
                
                
                disp (str2mat('================','N=New Correction','D=Discard and continue','R=Retain and continue'));
                corrcommand=upper(abartstr('Enter command','N'));
                if corrcommand=='D'
                    vectorschosen='Y';
                    nvfound=0;
                end;
                if corrcommand=='R' & nvfound>=minvectorsneeded
                    vectorschosen='Y';
                    perrx(:,isensor)=ptemp(:,1);
                    perry(:,isensor)=ptemp(:,2);
                end;
                
                delete (hc);	%delete the circle
            end;	%vectorschosen
            keyboard;
            delete (hq);
        end;	%vectors found
        
        %summarize results for this sensor
        if nvfound > 0
            disp ('=================================');
            disp (['Correction summary for sensor ' int2str(isensor) ' ' sensorlabel]);
            disp (['Vectors used : ' int2str(nvfound)]);
            disp (['Radius of vector search region : ' num2str(lookradius)]);
            disp (['Correction method : ' correctionmethod]);
            disp ('=================================');
            %Note: This won't work if errorana is turned into a function
            namestr=[namestr 'Correction summary for sensor ' int2str(isensor) ' ' sensorlabel crlf];
            namestr=[namestr 'n_vectors/radius of search region(cm)/correction method : ' int2str(nvfound) ' / ' num2str(lookradius) ' / ' correctionmethod crlf];
        end;
        
    end;    %process sensor ?
    
end;	%loop thru sensors;

%====================================================
%end of error analysis, correction set up
%===================================================
%
disp('Final x correction coefficients');
disp(perrx);
disp('Final y correction coefficients');
disp(perry);
