function [fbuf,abuf,tbuf,figh]=formant_ph(sig_brut,fs,lpcord,do_preemp)
% FORMANT_PP Pascal's formant extraction with modified i/o
% function [fbuf,abuf,tbuf,mbuf,figh]=formant_pp(sig_brut,fs,V,sujet,do_preemp)
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


tdeb=0;tfin=(length(sig_brut)-1)/fs;
%do_preemp=0;


hf1=figure;
title('LPC-based');

figh=[hf1];

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
    return;
end;


%reserve storage for results (only very rough calculation of size required;
%trim at end
ntmp=ceil((tfin/decal))+2;

ipi=1;
fbuf=ones(ntmp,3)*NaN;
abuf=ones(ntmp,3)*NaN;
tbuf=ones(ntmp,1)*NaN;

n1=ndeb;
n2=n1+nfen-1;
%disp('formant_ph, before loop')
while n2<=nfin
    % Fenêtrage et pondération
    x=sig(n1:n2);
    x_pond=x.*W;
    % Formants par LCP
    a=lpc(x_pond,lpcord);
    [h,w]=freqz(1,a,4096);
    modh=20*log10(abs(h));
    f=w/pi*Fe/2;%f(1)=0
    figure(hf1)
    plot(f,modh,'r');
    hax=gca;
hold on
    a2=lpc(x_pond,lpcord*2);
    [h2,w]=freqz(1,a2,4096);
    modh2=20*log10(abs(h2));
    plot(f,modh2,'g:')

    myroots=roots(a);
   
   myf=angle(myroots)*(Fe/(2*pi));
   mybw=-log(abs(myroots))*(Fe/pi);
   
   
   
   %rough elimination of useless data
   %Also eliminates the complex conjugate versions of the poles (they have negative frequencies)
   flim=100;		%lower frequency limit
   blim=500;		%upper limit on bandwidth
   vv=find((myf<flim)|(mybw>blim));
   myf(vv)=NaN;
   mybw(vv)=NaN;
   
   %sort by bandwidth
   
   [mybw,sortindex]=sort(mybw);
   myf=myf(sortindex);
   %keep resonances with smallest bandwidths
   %may need to be more sophisticated
%   myf=myf(1:fuse);
%   mybw=mybw(1:fuse);
   
   %then sort by frequency
   [myf,sortindex]=sort(myf);
   
   mybw=mybw(sortindex);
   
mycolf='cmyb';  
   mylim=get(hax,'ylim');
   for ifi=1:length(myf)
      colp=ifi; if colp>4 colp=4; end;
      plot([myf(ifi);myf(ifi)],mylim','color',mycolf(colp));
      plot([myf(ifi)-mybw(ifi);myf(ifi)+mybw(ifi)],[mean(mylim);mean(mylim)],mycolf(colp));
   end;
   drawnow;

 disp('formant_ph, in loop');
 keyboard;
    fbuf(ipi,:)=myf(1:3)';
    abuf(ipi,:)=mybw(1:3)';
    tbuf(ipi)=n1/Fe;
    ipi=ipi+1;
    
    n1=n1+ndecal-1;
    n2=n1+nfen-1;
end

fbuf(ipi:end,:)=[];
abuf(ipi:end,:)=[];
tbuf(ipi:end)=[];

figure(hf1);
title('LPC with root solving');
grid on

