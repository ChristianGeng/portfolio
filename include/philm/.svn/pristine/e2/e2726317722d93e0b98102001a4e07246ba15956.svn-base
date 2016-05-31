function [fbuf,abuf,fbufph,bwbufph,tbuf,mbuf,figh]=formant_ppph(sig_brut,fs,V,sujet,do_preemp)
% FORMANT_PP Pascal's formant extraction with modified i/o
% function [fbuf,abuf,fbufph,bwbufph,tbuf,mbuf,figh]=formant_pp(sig_brut,fs,V,sujet,do_preemp)
% formant_pp: Version 11.9.06
%
%   Syntax
%       Input:
%       sig_brut: signal data
%       fs: samplerate
%       V: currently 'i|e|a|u'
%           or 3*2 matrix containing min and max boundaries for F1/2/3 
%           which are then used instead of the built-in boundaries for the different vowel categories 
%           (in this case speaker sex (in sujet) is ignored)
%       sujet: currently 'm|f'
%       do_preemp: pre-emphasis flag
%       Output:
%       fbuf: 1st 3 Formants, abuf: relative amp F1 F2, and F1 F3, tbuf: time in s of each frame, mbuf: true for LPC, false for cepstrum
%           figh: handles of figures (lpc, cepstrum), so they can be
%           deleted by calling program
%
%   Description
%       PP Juillet 2006
%       Calcule les formants par LPC ou par cepstre
%       Phil: 10.06, i/o modified, pre-emphasis switchable, numeric search
%       boundaries

%[sig_brut, fs,n]=wavread(fichier_entree);
%nom_sortie=[fichier_sortie,'.txt'];
%fid=fopen(nom_sortie,'a');
%close all

tdeb=0;tfin=(length(sig_brut)-1)/fs;
%do_preemp=0;

dofig3=0;       %plots current frame
nocep=1;        %don't use cepstral method

lpcord=14;      %order is fixed, should be ok for 10kHz samplerate
nform=3;

flim=100;		%lower frequency limit for formants
blim=500;       %bandwidth limit for root solving method.

hf1=figure;
title('LPC-based');
figh=[hf1];

if ~nocep
    hf2=figure;
    title('Cepstrum-based');
    figh=[hf1 hf2];
end;

if dofig3
    hf3=figure;
    title('current frame');
    figh=[figh hf3];    
end;

if ~ischar(V)
    f1min=V(1,1);
    f1max=V(1,2);
    f2min=V(2,1);
    f2max=V(2,2);
    f3min=V(3,1);
    f3max=V(3,2);
else
    
    
    if V=='a'
        indV=1;
        if sujet=='m'
            f1min=400;
            f1max=900;
            f2min=1100;
            f2max=1700;
            f3min=1800;
            f3max=2600;
        else
            f1min=500;
            f1max=1000;
            f2min=1300;
            f2max=1900;
            %jb
            f3min=2500;
            f3max=3500;
            %        f3min=2000;
            %        f3max=2800;
        end
        
    end
    if V=='i'
        indV=2;
        if sujet=='m'
            f1min=200;
            f1max=500;
            f2min=1800;
            f2max=2400;
            f3min=2500;
            f3max=3000;
        else
            %jb
            f1min=200;
            %        f1min=300;
            f1max=600;
            
            %jb        
            f2min=2200;
            f2max=2900;
            %        f2min=2000;
            %        f2max=2500;
            %jb
            f3min=3000;
            f3max=3700;
            %        f3min=2600;
            %        f3max=3200;
        end
    end
    if V=='e'
        indV=2;
        if sujet=='m'
            f1min=200;
            f1max=600;
            f2min=1500;
            f2max=1950;
            f3min=2000;
            f3max=2500;
        else
            f1min=300;
            f1max=600;
            f2min=1600;
            f2max=2100;
            f3min=2150;
            f3max=2700;
        end
    end
    if V=='u'
        indV=3;
        if sujet=='m'
            f1min=200;
            f1max=450;
            f2min=500;
            f2max=1000;
            f3min=1500;
            f3max=2300;
        else
            %jb
            f1min=200;
            %        f1min=300;
            f1max=550;
            f2min=600;
            f2max=1200;
            %jb
            f3min=2400;
            f3max=3100;
            %        f3min=1800;
            %        f3max=2500;
        end
    end
    
end;

fbound=[f1min f1max;f2min f2max;f3min f3max];

cepk=0;
fen_dur=0.02; % durée de la fenêtre d'analyse en s
decal=0.005; % décalage de la fenêtre d'analyse à chaque pas.
Fe=10000; % On rééchantillonne à 10 Khz, car seul F1, F2, F3 nous intéresse
sig_10=resample(sig_brut,Fe,fs);
if do_preemp
    sig=filter([1 -0.96], 1, sig_10); % préemphase à +6 dB/oct
else
    sig=sig_10;
end;

%Début de la fenêtre d'analyse
ndeb=fix(tdeb*Fe)+1;
%Fin de la fenêtre d'analyse
nfin=fix(tfin*Fe);
%Nombre d'échantillons de la fénêtre d'analyse
nfen=fix(fen_dur*Fe);
W=hanning(nfen);
%nombre d'échantillons de décalage
ndecal=fix(decal*Fe);
%

if length(sig)<nfen
    disp(['Signal too short; must be at least ' num2str(fen_dur) ' s long']);
    fbuf=[];
    abuf=[];
    tbuf=[];
    mbuf=[];
    return;
end;


%reserve storage for results (only very rough calculation of size required;
%trim at end
ntmp=ceil((tfin/decal))+2;

ipi=1;
fbuf=ones(ntmp,nform)*NaN;
abuf=ones(ntmp,nform-1)*NaN;
tbuf=ones(ntmp,1)*NaN;
mbuf=ones(ntmp,1)*NaN;

%results for root solving method
fbufph=ones(ntmp,nform)*NaN;
bwbufph=ones(ntmp,nform)*NaN;


mycolspec=hsv(ntmp);


n1=ndeb;
n2=n1+nfen-1;
while n2<=nfin
disp(['Frame ' int2str(ipi)]);
disp('========');
    cepk=0;
    method='LPC';
    % Fenêtrage et pondération
    x=sig(n1:n2);
    x_pond=x.*W;
    % Formants par LCP
    a=lpc(x_pond,lpcord);
    [h,w]=freqz(1,a,4096);
    modh=20*log10(abs(h));
    f=w/pi*Fe/2;%f(1)=0


    %formants by root solving
        myroots=roots(a);
   
   myf=angle(myroots)*(Fe/(2*pi));
   mybw=-log(abs(myroots))*(Fe/pi);
   
   
   %rough elimination of useless data
   %Also eliminates the complex conjugate versions of the poles (they have negative frequencies)
   vv=find((myf<flim)|(mybw>blim));
   myf(vv)=[];
   mybw(vv)=[];
   
%within each set of boundaries use the resonance with the lowest bandwidth
%as the formant candidate
ftmp=ones(1,nform)*NaN;
bwtmp=ones(1,nform)*NaN;

for iri=1:nform

vp=find(myf>fbound(iri,1) & myf<fbound(iri,2));

if length(vp)==0
    disp(['No root in F' int2str(iri) ' region']);
else
    tmpf=myf(vp);
    tmpbw=mybw(vp);
    [dodo,vb]=min(tmpbw);
    ftmp(iri)=tmpf(vb);
    bwtmp(iri)=tmpbw(vb);
    if length(vp)>1
        disp(['Multiple roots in F' int2str(iri) ' region. Frequencies and bandwidths:'])
        disp(round([tmpf tmpbw]));
    
    end;
end;

end;

fbufph(ipi,:)=ftmp;
bwbufph(ipi,:)=bwtmp;

    
    i1min=0;
    i1max=0;
    i2min=0;
    i2max=0;
    i3min=0;
    i3max=0;
    plot(f,modh,'color',mycolspec(ipi,:))
    hold on

    %plot results of root-solving method
    formcol='brm';
    
    for iri=1:nform
        fxxx=ftmp(iri);
        if ~isnan(fxxx)
        [dodo,vr]=min(abs(f-fxxx));    %could also use interp1
        ytmp=modh(vr)-6;
        plot(fxxx,ytmp,['x' formcol(iri)]);
        plot([fxxx-bwtmp(iri)/sqrt(2) fxxx+bwtmp(iri)/sqrt(2)]',[ytmp ytmp]','linestyle',':','color',mycolspec(ipi,:));
    end;
    
    end;
    
    
    
    
    % On repère les indices spectraux correspondants aux différentes
    % limites des intervalles de recherche pour F1, F2, F3.
    for ii=1:4096
        if (f(ii)>=f1min)&(i1min==0)
            i1min=ii;
        end
        if (f(ii)>=f1max)&(i1max==0)
            i1max=ii-1;
        end
        if (f(ii)>=f2min)&(i2min==0)
            i2min=ii;
        end
        if (f(ii)>=f2max)&(i2max==0)
            i2max=ii-1;
        end
        if (f(ii)>=f3min)&(i3min==0)
            i3min=ii;
        end
        if (f(ii)>=f3max)&(i3max==0)
            i3max=ii-1;
        end
    end
    % Recherche des maximas dans les zones spectrales définies.
    [ampF1,ind]=max(modh(i1min:i1max));
    ind_F1=ind+i1min-1;
    F1=f(ind_F1);
    
    [ampF2,ind]=max(modh(i2min:i2max));
    ind_F2=ind+i2min-1;
    F2=f(ind_F2);
    
    [ampF3,ind]=max(modh(i3min:i3max));
    ind_F3=ind+i3min-1;
    F3=f(ind_F3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %On regarde si les valeurs maximales sont sur les bords des intervalles
    % ce qui reviendrait à dire qu'on a pas trouvé de vrais maximas dans
    % les zones définies
    %
    pastrouve_F1=0;
    pastrouve_F2=0;
    pastrouve_F3=0;
    
    if F1<=f1min+10*(Fe/(2*4096))|F1>=f1max-10*(Fe/(2*4096))
        pastrouve_F1=1;
    end
    if F2<=f2min+10*(Fe/(2*4096))|F2>=f2max-10*(Fe/(2*4096))
        pastrouve_F2=1;
    end
    if F3<=f3min+10*(Fe/(2*4096))|F3>=f3max-10*(Fe/(2*4096))
        pastrouve_F3=1;
    end
    % Si on ne trouve pas de max dans les zones définies, pour l'un des formants,alors
    % on recherhe si il existe un épaulement net en passant par la dérivée du spectre
    deriv_modh=zeros(4096,1);
    for jj=2:4096
        deriv_modh(jj)=modh(jj)-modh(jj-1);
    end
    
    %calcul F2 par épaulement,
    if pastrouve_F2
        disp('Recherche d''epaulement pour F2')
        [ampF2,ind]=min(abs(deriv_modh(i2min:i2max)));%abs
        ind_F2_d=ind+i2min-1; % Recherche d'un minimum local de la dérivée
        if (f(ind_F2_d)>=f2min+10*(Fe/(2*4096)))||(f(ind_F2_d)<=f2max-10*(Fe/(2*4096))) %pour /u/ la courbe touts desende pendent la periode de F2. le derive cherche peut etre le band 1200. calcul Cepstre
            if ((deriv_modh(ind_F2_d-10)*deriv_modh(ind_F2_d+10))<0)&&(deriv_modh(ind_F2_d-10)>0)% % Petit maximum local
                % Changement de signe de la dérivée de part et
                % d'autre du point dérivée croissante à gauche du
                % point
                pastrouve_F2=0;
                %            figure(hf1)
                %            plot(f,modh,'b')
                %            hold on
                %            plot(f(ind_F2_d),modh(ind_F2_d),'*r')
            elseif ((deriv_modh(ind_F2_d-10)*deriv_modh(ind_F2_d+10))>0)&&(deriv_modh(ind_F2_d-10)<0&&(abs(deriv_modh(ind_F2_d-10))<10*abs(deriv_modh(ind_F2_d+10))))||(deriv_modh(ind_F2_d-10)>0&&(abs(deriv_modh(ind_F2_d-10))>10*abs(deriv_modh(ind_F2_d+10))))&&(modh(ind_F1_d)-modh(ind_F2_d)<30)
                % Cas d'un épaulement
                pastrouve_F2=0;
                %                figure(hf1)
                %                plot(f,modh,'b')
                %                hold on
                %                plot(f(ind_F2_d),modh(ind_F2_d),'*r')
            else
                cepk=1; % si on n'a pas trouvé d'épaulement clair on calculera le cesptre pour calculer tous les formants
            end
        else
            cepk=1; % Il n' y a pas de minimum local de la dérivée. On passera par le cepstre
        end
    else
        ind_F2_d=ind_F2;
        %       figure(hf1)
        %       plot(f(ind_F2_d),modh(ind_F2_d),'*r')
        %       hold on
        %       plot(f,modh,'b')
    end
    figure(hf1)
    plot([f1min f1min],[-20 20],':y')
    plot([f1max f1max],[-20 20],':c')
    plot([f2min f2min],[-20 20],':y')
    plot([f2max f2max],[-20 20],':c')
    plot([f3min f3min],[-20 20],':y')
    plot([f3max f3max],[-20 20],':c')
    
    F2_d=NaN;
    if ~pastrouve_F2 
        F2_d=f(ind_F2_d); % si cette fréquence est à l'intérieur de l'intervalle de recherche de F2 alors on a trouvé F2, sinon...
    end;
    %disable cepstrum
    cepk=0;
    if cepk==0%dans le cas ou la LPC a marché pour F2, on continue avec la LPC pour F1 et F3
        if pastrouve_F1
            [ampF1,ind]=min(abs(deriv_modh(i1min:i1max)));%abs
            ind_F1_d=ind+i1min-1; % Recherche d'un minimum de la dérivée pour F1 ;
            % Par de rechereche plus complexe
            if (f(ind_F1_d)>=f1min+10*(Fe/(2*4096)))||(f(ind_F1_d)<=f1max-10*(Fe/(2*4096)))
                if ((deriv_modh(ind_F1_d-10)*deriv_modh(ind_F1_d+10))<0)&&(deriv_modh(ind_F1_d-10)>0)%max
                    pastrouve_F1=0;
                    %                    figure(hf1)
                    %                    plot(f,modh,'b')
                    %                    hold on
                    %                    plot(f(ind_F1_d),modh(ind_F1_d),'*r')
                elseif ((deriv_modh(ind_F1_d-10)*deriv_modh(ind_F1_d+10))>0)&&(deriv_modh(ind_F1_d-10)<0&&(abs(deriv_modh(ind_F1_d-10))<10*abs(deriv_modh(ind_F1_d+10))))||(deriv_modh(ind_F1_d-10)>0&&(abs(deriv_modh(ind_F1_d-10))>10*abs(deriv_modh(ind_F1_d+10))))&&(modh(ind_F1_d)-modh(ind_F1_d)<30)
                    pastrouve_F1=0;
                    %                    figure(hf1)
                    %                    plot(f,modh,'b')
                    %                    hold on
                    %                    plot(f(ind_F1_d),modh(ind_F1_d),'*r')
                else
                    cepk=1;
                    %cepstre
                end
            else
                cepk=1;
            end
        else
            ind_F1_d=ind_F1;
            %           figure(hf1)
            %           plot(f(ind_F1_d),modh(ind_F1_d),'*b')
            %           hold on
            %           plot(f,modh,'b')
        end
        F1_d=NaN;
        if ~pastrouve_F1 
            
            
            F1_d=f(ind_F1_d);% si cette fréquence est à l'intérieur de l'intervalle de recherche de F1 alors on a trouvé F1, sinon..
        end;    
    end;
    %disable cepstrum
    cepk=0;
    if cepk==0%dans le cas ou la LPC a marché pour F1 et F2, on continue avec la LPC pour F3
        
        if pastrouve_F3
            disp('calcul d''epaulement pour F3')
            [ampF3,ind]=min(abs(deriv_modh(i3min:i3max)));%abs
            ind_F3_d=ind+i3min-1;
            if ((deriv_modh(ind_F3_d-10)*deriv_modh(ind_F3_d+10))<0)&&(deriv_modh(ind_F3_d-10)>0)%max
                pastrouve_F3=0;
                %               figure(hf1)
                %               plot(f,modh,'b')
                %               hold on
                %               plot(f(ind_F3_d),modh(ind_F3_d),'*m')
            elseif ((deriv_modh(ind_F3_d-10)*deriv_modh(ind_F3_d+10))>0)&&(deriv_modh(ind_F3_d-10)<0&&(abs(deriv_modh(ind_F3_d-10))<10*abs(deriv_modh(ind_F3_d+10))))||(deriv_modh(ind_F3_d-10)>0&&(abs(deriv_modh(ind_F3_d-10))>10*abs(deriv_modh(ind_F3_d+10))))
                pastrouve_F3=0;
                %                figure(hf1)
                %                plot(f,modh,'b')
                %                hold on
                %                plot(f(ind_F3_d),modh(ind_F3_d),'*m')
            else
                cepk=1;
                %cepstre
            end
        else
            ind_F3_d=ind_F3;
            %           figure(hf1)
            %           plot(f,modh,'b')
            %           hold on
            %           plot(f(ind_F3_d),modh(ind_F3_d),'*m')
        end
        F3_d=NaN;
        if ~pastrouve_F3 
            F3_d=f(ind_F3_d);
        end;
        
    end;
    
    plot(F1_d,modh(ind_F1_d),'*b')
    
    plot(F2_d,modh(ind_F2_d),'*r')
    plot(F3_d,modh(ind_F3_d),'*m')
    
    
    %disable cepstrum
    cepk=0;
    
    %%%%%Cepstre au cas où la LPC n'a pas fonctionné%%%%%
    if cepk==1%dans les cas ou on ne peut pas utiliser la LPC pour F1 ou pour F2 ou pour F3 on utilise le Cepstre pour les formants F1 F2 F3
        disp('calcul par le cesptre')
        method='CEP'
        i1min=0;
        i1max=0;
        i2min=0;
        i2max=0;
        i3min=0;
        i3max=0;
        
        %calcul Cepstre  un programme calcul_Cepstre.m
        cepstre_reel=(rceps(x))';
        l_cep=length(cepstre_reel);
        quef_max=(l_cep-1)/Fe;
        cep_max=max(abs(cepstre_reel(2:l_cep/2)));%max
        quef=linspace(0,quef_max,l_cep);% point
        if sujet=='m'
            quef_coup=0.003;%femme 0.0023 ou 0.003 pour homme
        else
            quef_coup=0.0023;
        end
        ncoup_b=fix(quef_coup*Fe+0.5)+1;
        ncoup_h=l_cep-ncoup_b+1;
        val_b=1;
        val_h=0;
        liftr=ones(1,l_cep);
        liftr(1:ncoup_b)=val_b;
        liftr((ncoup_b+1):(ncoup_h-1))=val_h;
        liftr(ncoup_h:l_cep)=val_b;
        cep_liftr=cepstre_reel.*liftr;
        puis_filtr=var(liftr);
        
        % TFD cepstre
        TFD_cepstre=fft(cep_liftr);
        N_FFT=length(TFD_cepstre);
        TFD_reduite=TFD_cepstre(1:N_FFT/2);
        modh=20*(abs(TFD_reduite+10000)-10000)*log10(exp(1));
        f=linspace(0,Fe/2-Fe/N_FFT,N_FFT/2);
        
        for ii=1:N_FFT/2
            if (f(ii)>=f1min)&(i1min==0)
                i1min=ii;
            end
            if (f(ii)>=f1max)&(i1max==0)
                i1max=ii-1;
            end
            if (f(ii)>=f2min)&(i2min==0)
                i2min=ii;
            end
            if (f(ii)>=f2max)&(i2max==0)
                i2max=ii-1;
            end
            
            if (f(ii)>=f3min)&(i3min==0)
                i3min=ii;
            end
            if (f(ii)>=f3max)&(i3max==0)
                i3max=ii-1;
            end
        end
        [ampF1,ind]=max(modh(i1min:i1max));
        ind_F1=ind+i1min-1;
        F1=f(ind_F1);
        
        [ampF2,ind]=max(modh(i2min:i2max));
        ind_F2=ind+i2min-1;
        F2=f(ind_F2);
        
        [ampF3,ind]=max(modh(i3min:i3max));
        ind_F3=ind+i3min-1;
        F3=f(ind_F3);
        %calcul derive F2
        %calcul derive F2
        pastrouve_F1=0;
        pastrouve_F2=0;
        pastrouve_F3=0;
        if F1<=f1min+(Fe/(2*N_FFT/2))|F1>=f1max-(Fe/(2*N_FFT/2))
            pastrouve_F1=1;
        end
        if F2<=f2min+(Fe/(2*N_FFT/2))|F2>=f2max-(Fe/(2*N_FFT/2))
            pastrouve_F2=1;
        end
        if F3<=f3min+(Fe/(2*N_FFT/2))|F3>=f3max-(Fe/(2*N_FFT/2))
            pastrouve_F3=1;
        end
        figure(hf2)
        plot([f1min f1min],[-20 20],':y')
        hold on
        plot([f1max f1max],[-20 20],':c')
        plot([f2min f2min],[-20 20],':y')
        plot([f2max f2max],[-20 20],':c')
        plot([f3min f3min],[-20 20],':y')
        plot([f3max f3max],[-20 20],':c')
        
        % calcul en passant par la dérivée du spectre
        deriv_modh=zeros(N_FFT/2,1);
        for jj=2:N_FFT/2
            %deriv_modh(jj)=abs(modh(jj)-modh(jj-1));
            deriv_modh(jj)=modh(jj)-modh(jj-1);%19/07/2005
        end
        
        if pastrouve_F1
            [ampF1,ind]=min(abs(deriv_modh(i1min:i1max)));%abs
            ind_F1_d=ind+i1min-1;
        else
            ind_F1_d=ind_F1;
        end
        F1_d=f(ind_F1_d);
        figure(hf2)
        plot(f(ind_F1_d),modh(ind_F1_d),'*b')
        hold on
        plot(f,modh,'b')
        
        if pastrouve_F2
            [ampF2,ind]=min(abs(deriv_modh(i2min:i2max)));%abs
            ind_F2_d=ind+i2min-1;
            if ((deriv_modh(ind_F2_d-1)*deriv_modh(ind_F2_d+1))<0)&&(deriv_modh(ind_F2_d-1)>0)%max
                figure(hf2)
                plot(f,modh,'b')
                hold on
                plot(f(ind_F2_d),modh(ind_F2_d),'*r')
            elseif ((deriv_modh(ind_F2_d-10)*deriv_modh(ind_F2_d+10))>0)&&(deriv_modh(ind_F2_d-10)<0&&(abs(deriv_modh(ind_F2_d-10))<10*abs(deriv_modh(ind_F2_d+10))))||(deriv_modh(ind_F2_d-10)>0&&(abs(deriv_modh(ind_F2_d-10))>10*abs(deriv_modh(ind_F2_d+10))))
                figure(hf2)
                plot(f,modh,'b')
                hold on
                plot(f(ind_F2_d),modh(ind_F2_d),'*r')
            else
                figure(hf2)
                plot(f,modh,'b')
                hold on
                plot(f(ind_F2_d),modh(ind_F2_d),'*g')
                f(ind_F2_d)=0;
            end
        else
            ind_F2_d=ind_F2;
            figure(hf2)
            plot(f(ind_F2_d),modh(ind_F2_d),'*r')
            hold on
            plot(f,modh,'b')
        end
        F2_d=f(ind_F2_d);
        
        if pastrouve_F3
            [ampF3,ind]=min(abs(deriv_modh(i3min:i3max)));%abs
            ind_F3_d=ind+i3min-1;
            if ((deriv_modh(ind_F3_d-1)*deriv_modh(ind_F3_d+1))<0)&&(deriv_modh(ind_F3_d-1)>0)%max
                figure(hf2)
                plot(f,modh,'b')
                hold on
                plot(f(ind_F3_d),modh(ind_F3_d),'*m')
            elseif ((deriv_modh(ind_F2_d-10)*deriv_modh(ind_F2_d+10))>0)&&(deriv_modh(ind_F2_d-10)<0&&(abs(deriv_modh(ind_F2_d-10))<10*abs(deriv_modh(ind_F2_d+10))))||(deriv_modh(ind_F2_d-10)>0&&(abs(deriv_modh(ind_F2_d-10))>10*abs(deriv_modh(ind_F2_d+10))))
                figure(hf2)
                plot(f,modh,'b')
                hold on
                plot(f(ind_F3_d),modh(ind_F3_d),'*m')
            else
                figure(hf2)
                plot(f,modh,'b')
                hold on
                plot(f(ind_F3_d),modh(ind_F3_d),'*g')
                f(ind_F3_d)=0;
            end
        else
            ind_F3_d=ind_F3;
            figure(hf2)
            plot(f(ind_F3_d),modh(ind_F3_d),'*m')
            hold on
            plot(f,modh,'b')
        end
        F3_d=f(ind_F3_d);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    AmpF1F2=NaN;
    AmpF1F3=NaN;
    
    if ~isnan(F1_d)
        if ~isnan(F2_d)
            AmpF1F2=20*log10(modh(ind_F1_d)/modh(ind_F2_d));
        end;
        if ~isnan(F3_d)
            AmpF1F3=20*log10(modh(ind_F1_d)/modh(ind_F3_d));
        end;
        
        
    end;
    
    
    
    if dofig3
        figure(hf3)
        subplot(2,1,1)
        plot(f,modh,'b')
        hold on
        plot([f1min f1min],[-20 20],':y')
        plot([f1max f1max],[-20 20],':c')
        plot([f2min f2min],[-20 20],':y')
        plot([f2max f2max],[-20 20],':c')
        plot([f3min f3min],[-20 20],':y')
        plot([f3max f3max],[-20 20],':c')
        subplot(2,1,2)
        plot(x)
        
    end;
    %    fprintf(fid,'%s\t%s\t%s\t%i4\t%6.1f\t%6.1f\t%6.1f\t%6.2f\t%6.2f\n', fichier_entree,V, method, n1, F1_d, F2_d, F3_d, AmpF1F2, AmpF1F3);
    
    fbuf(ipi,:)=[F1_d F2_d F3_d];
    abuf(ipi,:)=[AmpF1F2 AmpF1F3];
    tbuf(ipi)=n1/Fe;
    lpcflag=1;
    if strcmp(method,'CEP') lpcflag=0; end;
    mbuf(ipi)=lpcflag;
    ipi=ipi+1;
    
    n1=n1+ndecal-1;
    n2=n1+nfen-1;
end

fbuf(ipi:end,:)=[];
abuf(ipi:end,:)=[];
tbuf(ipi:end)=[];
mbuf(ipi:end)=[];
fbufph(ipi:end,:)=[];
bwbufph(ipi:end,:)=[];

figure(hf1);
title('LPC-based');
grid on
if ~nocep
    figure(hf2);
    title('Cepstrum-based');
    grid on;
end;

if dofig3
    figure(hf3);
    title('current frame');
end;
figure(hf1);

%disp('type return to return');
%keyboard;
%close([hf1 hf2]);
%if dofig3 close(hf3); end;
%fclose(fid);

