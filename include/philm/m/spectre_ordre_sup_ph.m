function [dataout,descriptorout,unitout,samplerateout,t0out]=spectre_ordre_sup_ph(Tf, Fmin, Fmax, rec, N3, fenetre_pond, sondata,sonsf);
% SPECTRE_ORDRE_SUP_PH Calculate centre of gravity, dispersion, skewness, kurtosis of spectrum
% function [moment_lin,moment_db,slopeab_lin,slopeab_db]=spectre_ordre_sup_ph(Tf, Fmin, Fmax, rec, N3, fenetre_pond, sondata,sonsf);
% spectre_ordre_sup_ph: Version 8.3.07
%
%   Description
%       Original ICP function modified by Phil for matlab input and output
% Programme pour le calcul probabliliste de la valeur moyenne du signal,
% de skewness et de kurtosis. 
% 1er partie crée différentes fenetres à partir du signal analysé. 
% 
%
% Paramètres à introduire sont les suivants (par ordre d'écriture): 
% 1. Longueur de la fenetre (5 ms par défaut). 
% 2. Recouvrement des fenetres en pourcents est de 1 à 99 % (par defaut égal à 40%).
% 3. Nombre de points de la TF (1024 par défaut). Il doit etre paire.
% 4. Fenetre de ponderation utilisée (hanning par défaut). 
% Toutes les fenetres doivent etre ecrites entre les apostrophes.
% Pour les fenetres avec un paramètre supplémentaire (Gaussienne, de Kaiser, de
% Chebyshev) - il sera demandé dans la suite. Les fenetres utilisables sont les suivantes : 
% rectangulaire, triangulaire, de Hanning, de Hamming, de Blackman, gaussienne, de Kaiser, de Chebychev. 
% 5. Nom du fichier son à traiter. Il faut l'écrire entre les apostrophes.
%
% N.B. Sachez que quelle que soit la fenetre utilisée, vous restez toujours limité(e) au
% principe de Heisenberg : variance(t)*variance(w) > ou = à 0.5 (Egalité pour la fenetre gaussienne pure). 
% En d'autres termes il s'agit du delemme résolution spectrale versus temporelle. 
% Il existe un autre aspect important - celui de la conservation d'énergie en
% frequence, c'est-à-dire si la largeur du 1er lobe principale diminue
% (resolution augmente) le niveau des lobes secondaires augmente et vice et versa.
%
% Remarque : vaux mieux utiliser "help" depuis le "Documentation CD" de
% Matlab que celui de la fenetre de commandes (surtout pour la question des
% fenetres de ponderation).
% 
% Deuxième partie est pour le calcul probabliliste de la valeur moyenne du signal,
% de skewness et de kurtosis (ainsi que des moments d'ordre 5 et 6).
% Cette partie lit les valeurs fournies par la première partie, notamment
% ceux concernant les fenetres du signal. Elle normalise les spectre de
% chaque fenetre, d'abord en passant en décibels, ensuite de façon à ce que
% le spectre puisse etre assimilé à une distribution de probabilite, c'est-à-dire 
% la somme de tous les élements du spectre est égal à un. 
% Ensuite, on calcule une seule valeur de skewness, de kurtosis, de moment d'ordre 5 et 6 sur chaque fenetre.
% 
% N.B. Les valeurs de skewness et de kurtosis ont été calculées comme les
% moments d'ordre 3, 4, 5 et 6 (ésperences mathématiques) respectivement normalisées par (divisées par)
% écart-type ^ 3, 4, 5, 6 respectivement. Une autre méthode de
% normalisation a été aussi utilisée : normalisation par extraction de la
% racine de dégrée 3, 4, 5 et 6 respectivement.
%
% Auteur : Iaroslav Blagouchine, l'ICP de l'INPG et de l'Université de
% Stendhal, le 12 juin 2003.
% Corrigé et modifié : Mai 04 PP
%               Adaptation à une entrée automatique des instants entre
%               lesquels on étudie le spectre (tdeb et tmin). Sauvegarde
%               des résultats dans une fichier excel. Correction de quels
%               bugs dont en particulier la mise à zéro des échantillons
%               spectraux entre 0 et Fmin. Désormais on ne prend tout
%               simplement plus en compte ces échantillons. Mise en
%               commentaires des calculs des ordres supérieurs à 4. Ajout de
%               l'approximation linéaire du spectre entre Fmin et Famx puis
%               entre Fmax et 8000 Hz (paramètre A et B). (PP Mai 04)

% Description des variables utilisées :
% x - signal que l'on traite. Une colonne en fait.
% Nbits - numéro de bits sur lequel le signal est quantifié.
% Fe - fréquence d'échantillonnage du signal en Hz.
% Te - période d'échantillonnage du signal en s.
% Tf - longueur de la fenetre de ponderation en s.(PP Mai 04)
% Fmin = frequence minimale prise en compte dans le spectre (700 Hz par défaut)
% Fmax = fréquence max de la première partie linéaire (3500 Hz conseillé) 
% T0 - longueur totale du signal en s.
% t - vecteur du temps. 
% rec - coefficient de recouvrement des fenetres en pourcents de 1 à 99%.
% tdeb : instant de début de calcul des spectres(PP Mai 04)
% tfin : instant de fin de calcul des spectres (PP Mai 04)
% label : étiquette du son étudié
% fichier_sortie : nom du fichier Excel de sortie
% k2 - coefficient compris entre 0.99 et 0.01 qui montre en partie de la
% longueur de la fenetre où commence la fenetre suivante.
% N0 - longueur totale du signal en échantillons.
% N1 - longueur de la fenetre de ponderation en échantillons.
% N3 - nombre des points de la TF.
% n - nombres des fenetres ponderation total.
% N4 - premier échantillon de chaque fenetre. C'est un vecteur de dimension
% n.
% N5 - dernier échantillon de chaque fenetre. C'est un vecteur de dimension
% n.
% matsignal - matrice qui contient tout le signal x découpé en tranche dont
% chaque est une fenetre. Il a "n" lignes et "N1" colonnes.
% matTFsignal - matrice qui contient toute la TF du signal x, chaque ligne
% est la TF de la ligne correspondante de la "matsignal" calculé sur N3
% points. Sa taille est donc "n" lignes et "N3" colonnes.
% matTFsignal_pond_compl - la meme chose qu'avant, mais le signal est ponderé,
% elle est donc la TF du signal ponderé par la fenetre ponderation.
% fenetre - type de fenetre de pondération utilisé pour la fft.
% ponderation - vecteur de longueur N1 qui defini la fenetre d'pondération.


%function spectre_ordre_sup(Tf, Fmin, Fmax, rec, N3, fenetre_pond, son, tdeb, tfin, label, fichier_sortie);
close all
% Si les 5 variables d'entrée ne sont pas définies on les fixe par les
% valeurs par défaut.

if exist('Tf') == 0,
    Tf = 0.005;  % en secondes
end

if exist('Fmin') == 0,
    Fmin = 700; 
end

if exist('rec') == 0,
    rec = 60;
end

if exist('N3') == 0,
    N3 = 1024; 
end

if exist('fenetre_pond') == 0,
    fenetre_pond = 'han'; 
end
fenetre=fenetre_pond;

%if exist('son') == 0,
%    son = 'essai_0.wav'; 
%end
% - Lecture du son -
%[sig,Fs,Nbits] = wavread(son);

sig=double(sondata);
Fs=sonsf;


duree_signal=(length(sig)-1)/Fs;
%if exist('tdeb') == 0,
    tdeb = 0; 
    %end
%if exist('tfin') == 0,
    tfin = duree_signal; 
    %end

% --- fin de remise par défaut.

% --- Protections contre oublies et indéterminités. 

if length(fenetre) < 3,
    error('Le nom de la fenetre utilisée doit comporter au moins 3 lettres. Reesayez!');
end

if rec > 99 | rec < 1,
    error('Le recouvrement permis est compris entre 1 et 99 % .');
end

if (N3/2) ~= fix(N3/2),  
    error('Le nombre des points de la Transformée de Fourier Discrète doit etre paire.');
end
% ------ Fin de protection.

%Tf
%rec
%N3
%fenetre

% - Prise en compte de la bonne partie du son et sous-echantillonnage à 16 kHz-
%keyboard;
N_deb=fix(tdeb*Fs)+1;
N_fin=fix(tfin*Fs);
y=sig(N_deb:N_fin);
Fe=16000;
x=resample(y,Fe,Fs);
tdeb=fix(tdeb*Fe)/Fe; % on ajuste précisément tdeb a l'echantillon
tfin=tdeb+(length(x)-1)/Fe; % on ajuste précisément tfin a l'echantillon
N0 = length(x);
Te = (1/Fe);
T0 = (N0-1)*Te;
t = linspace(tdeb,tfin,length(x));

if Tf > T0, 
    error('La longueur de la fenetre d''analyse ne doit pas depasser la longueur totale du signal.');
end

if Tf < Te,
    error('La longueur du signal doit etre supérieure à la période d''échantillonnage. ');
end

% Pour le plot on se laisse 8% de marge libre pour l'amlpitude et toute la
% longueur pour le signal temporel.


k2 = (100-rec)/100;

N1 = fix(Tf*Fe)+1;

n = fix(((N0-N1)/(N1*k2)) + 1); % D'après mes calculs c'est le nombre des fenetres...
%sprintf('Nombre de fenetres : %i',n)

%if n > 30,
 %   question_1 = input(['Vous aurez ', num2str(n), ' fenetres affichées sur la figure 1. Voulez-vous les visualiser toutes? (Y/N) '], 's');
 %else
    question_1 = 'N';
    %end
%if n > 50,
%    n=50;
%end
N4(1) = 1;

for k=1:n-1,
    N4(k+1) = (1 + k*fix(N1*k2)); %  Indice de début pour chaque fenetre
end

clear k;

%N4
N5 = (N4 + (N1-1)*ones(1,n)); % Indice de fin pour chaque fenetre

% Definition du vecteur de la fenetre de ponderation
if fenetre(1:3)=='rec' | fenetre(1:3)=='tri' | fenetre(1:3)=='han' | fenetre(1:3)=='ham' | fenetre(1:3)=='bla' | fenetre(1:3)=='gau' | fenetre(1:3)=='kai' | fenetre(1:3)=='che' 
    
     if fenetre(1:3) == 'rec',
        ponderation = ones(1,N1);
        annonce_1 = ['Fenetre rectangulaire de durée ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end
    
     if fenetre(1:3) == 'tri',
        ponderation = (triang(N1))';
        annonce_1 = ['Fenetre triangulaire de durée ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end
    
    if fenetre(1:3) == 'han',
        ponderation = (hann(N1))';
        annonce_1 = ['Fenetre de Hanning de durée ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end

    if fenetre(1:3) == 'ham',
        ponderation = (hamming(N1))';
        annonce_1 = ['Fenetre de Hamming de durée ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end

    if fenetre(1:3) == 'bla',
        ponderation = (blackman(N1))';
        annonce_1 = ['Fenetre de Blackman de durée ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end
    
    if fenetre(1:3) == 'gau',
        par_a = input('Introduisez le paramètre alfa de la fenetre (voir "help" pour l''aide) : ');
        ponderation = (gausswin(N1,par_a))';
        annonce_1 = ['Fenetre gaussienne avec alfa égal à ',num2str(par_a), '. Sa durée est de ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end
   
    if fenetre(1:3) == 'kai',
        par_b = input('Introduisez le paramètre beta de la fenetre (voir "help" pour l''aide) : ');
        ponderation = (kaiser(N1,par_b))';
        annonce_1 = ['Fenetre de Kaiser avec beta égal à ',num2str(par_b), '. Sa durée est de ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end
    
    if fenetre(1:3) == 'che',
        par_r = input('Introduisez l''attenuation R du 1er lobe secondaire de la fenetre (voir "help" pour l''aide) : ');
        ponderation = (chebwin(N1,par_r))';
        annonce_1 = ['Fenetre de Chebyshev utilisée avec R égal à ',num2str(par_r),' dB.', ' Sa durée est de ', num2str(Tf), ' s (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz. La TF est sur ', num2str(N3), ' points. '];
    end
    
else
    error('La fenetre d''analyse que vous avez prise n''est pas connue. Vraiment désolé...');
end

%N1
%plot(ponderation), grid
%size(ponderation)
if question_1(1) == 'Y',
    figure('name','Signal (colonne 1) et son spectre sans (colonne 2) et avec pondération (colonne 3)'); 
end

for k=1:n,
    matsignal(k,1:N1) = (x((N4(k)):(N5(k))))';
   
    if question_1(1) == 'Y',
        subplot(n+1,3,3*k-2)
        plot(t(N4(k):N5(k)),matsignal(k,1:N1),'b')
        grid
        axis ([t(N4(k)), t(N5(k)), -1.08*max(abs(x)), 1.08*max(abs(x))]);
    end
    
    matTFsignal(k,1:N3) = (abs(fft( matsignal(k,1:N1),N3) )); % Spectre du
   % signal non pondéré.
   
    matTFsignal_pond_compl(k,1:N3) = (abs(fft( (ponderation.*matsignal(k,1:N1)),N3) ));
    frequence_plot=linspace(0,Fe/2,N3/2+1);
    if question_1(1) == 'Y',
        subplot(n+1,3,3*k-1), plot(frequence_plot, matTFsignal(k,1:N3/2+1),'b'), grid, axis ([0, Fe/2, 0, 1.14*max(matTFsignal(k,1:N3/2))]);
      
    
        if k==1,
            title(annonce_1); % On le met au centre.
        end
    
  
        subplot(n+1,3,3*k), plot(frequence_plot, matTFsignal_pond_compl(k,1:N3/2+1),'r'), grid, axis ([0, Fe/2, 0, 1.14*max(matTFsignal_pond_compl(k,1:N3/2))]);
    end

end
if question_1(1) == 'Y',
    subplot(n+1,3,3*n+1), plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); xlabel('Temps en ms')
    xlabel('Temps en s');
end

spectre = abs(fft(x,N3));
if question_1(1) == 'Y',
    subplot(n+1,3,3*n+2), plot(frequence_plot, spectre(1:fix(N3/2)+1),'b'), grid, xlabel('Fréquence en Hz'), axis ([0, Fe/2, 0, 1.14*max(spectre(1:N3/2))]);
    subplot(n+1,3,3*n+3), plot(ponderation,'g'), grid, xlabel('Fréquence en Hz'); 
end

% Si il y a trop de fenetres on ne veut pas les voir, on fait voir juste le signal et la fenetre de pondération.
%if question_1(1) == 'N',
%    figure('name','Signal analysé et la fenetre de pondération employée.');
%    subplot(2,1,1), plot(t,x), grid, xlabel('Temps en ms'), ylabel('Amplitude du signal'), axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]);
%    title(annonce_1);
%    subplot(2,1,2), plot(ponderation,'g'), grid, xlabel('Temps en échantillons'), ylabel('Amplitude de la fenetre');
%end

%%% ----------- FIN  DE  LA  PREMIERE PARTIE --------------------------

% Programme (deuxième partie) pour le calcul probabliliste de la valeur moyenne du signal,
% de skewness et de kurtosis, et pour l'approximation linéaire du spectre
% en basse fréquence et en haute fréquence (PP - Mai 04)


% Description des variables :
% somme_nor - vecteur dont les éléments sont les sommes de chaque ligne de
% la matrice du spectre matTFsignal_pond_compl.
% On pondere matTFsignal_pond_compl par une fonction pour limiter le
% doamine spectral considéré --> matTFsignal_pond
% somme_nor - idem qu'avant, sauf que l'échelle est en dB.
% mats1 - matrice du spectre normalisé et linéaire, assimilé à une distribution de probabilité (ddp).
% mats2 - matrice de longeur N3*n, dont les lignes sont les lignes k de
% la differences entre valeurs en dB du spectre matTFsignal_pond et sa
% valeur minmale (une valeur minimale pour chaque ligne). mats2 est donc
% toute positive ou =0, elle peut etre vue comme une matrice du spectre en décibels normalisé sur 0 dB (amplitude minimale).
% Elémént qui est égal à 0 c'est l'élément munimal de la matrice
% matTFsignal_pond.
% mats3 - matrice du spectre en décibels normalisé sur 0 dB (amplitude
% minimale), assimilée à une ddp.
% vecteur - vecteur de dimension N3/2 dont les éléments sont les numéros
% des échantillons moins 1 (car k=1 corréspond à la composante constante f=0) : [0, 1, 2, ... , N2/3 - 1].
% vectfk - vecteur dont les composants sont les fréquences discrètes de la TFD.
% moyenne_nor - vecteur de dimension "n" dont les éléments sont les valeurs
% moeynnes E[fk] = fm pour chaque fenetre de pondération en échelle normale pour le spectre.
% moyenne_dB = E[fk] = fm en échelle dB pour le spectre.
% variance_nor = E[(f-fm)^2] en échelle normale.
% variance_dB idem en échelle dB.
% %variance_ - variable provisoire, égale à la variance calculé par la
% méthode  var(x) = E[f^2] - (E[f])^2 .
% ecarttp_nor - racine carré de la variance du spectre normal.
% ecarttp_dB - idem du spectre en dB.
% skewn_nor - skewness du spectre normale.
% skewn_dB - skewness du spectre en dB.
% kurtos_nor - kurtosis du spectre normale.
% kurtos_dB - kurtosis du spectre en dB.
% stat5_nor - statistique d'ordre 5 du spectre normale.
% stat5_dB - statistique d'ordre 5 du spectre en dB.
% stat6_nor - statistique d'ordre 6 du spectre normale.
% stat6_dB - statistique d'ordre 6 du spectre dB.
% N6 - vecteur de dimension "n" dont les éléments sont les moments où les
% moments d'ordre supériers sqont calculés. Par défaut, on les défini au
% milieu de la fenetre de ponderation.
% A_skewn_nor (et bien d'autres) - les memes que sans "A" sauf que ces moments sont calulés un
% peu différements : ils sont normalisés par l'extraction de la racine de
% meme degrée que le moment meme. 
% alfa - la taille de la nouvelle fenetre de matlab pour la visualisation
% (rapport de la taille ancienne à la taille nouvelle). 
% N8 - nombre d'échantillons du signal corréspondant à 5 ms - durée de la
% fenetre d'analyse du spectrogramme. La fenetre étant la fenetre de Kaiser
% avec beta égal à 6.

N_min=fix((Fmin/Fe)*N3)+1;
matTFsignal_pond=matTFsignal_pond_compl(:,N_min:N3/2+1);

vectfk = frequence_plot(N_min:N3/2+1);

if question_1(1) == 'Y',
    figure('name', 'Spectre, assimilé à une ddp, pondéré par la fenetre en amplitude linéaire (à gauche) et en dB (à droite)');
    h_ordre_sup=gcf;
    figure('name', 'Spectres et leur approximation linéaire en amplitude linéaire (à gauche) et en dB (à droite)');
    h_approx_lin=gcf;
end

for k=1:n,
    somme_nor(k) = sum(matTFsignal_pond(k,:));
    min_TF=min(matTFsignal_pond(k,:));
    mats1(k,:) = (matTFsignal_pond(k,:))/somme_nor(k);
    mats2(k,:) =  20*log10(matTFsignal_pond(k,:)/min_TF);  % Ref = Min pour respecter l'allure de la fonction après normalisation
    somme_dB(k) = sum(mats2(k,:));
    mats3(k,:) = mats2(k,:)/somme_dB(k);
    
    df = vectfk;
    if question_1(1) == 'Y',
        figure(h_ordre_sup)
        subplot(n,2,2*k-1), plot(df,mats1(k,:),'b'), grid; axis([Fmin Fe/2 0 1.1*max(mats1(k,:))]);
        hold on
        ylabel('ddp');
        if k==n
            xlabel('Fréquence en Hz');  
        end
        if k==1,
            %title(['                                                                                                  ',annonce_1]); % On le met au centre.
        end
        subplot(n,2,2*k), plot(df,mats3(k,:),'r'); grid ;axis([Fmin Fe/2 0 1.1*max(mats3(k,:))]);
        hold on
        ylabel('ddp');
        if k==n
            xlabel('Fréquence en Hz');
        end
    end
    % Calculs des espérences mathématiques d'ordre 1, 2, 3 et 4.

    moyenne_nor(k) = sum(vectfk.*mats1(k,:));
    moyenne_dB(k) = sum(vectfk.*mats3(k,:));
    
    variance_nor(k) = sum(((vectfk - moyenne_nor(k)).^2).*mats1(k,:));
    variance_dB(k) = sum(((vectfk - moyenne_dB(k)).^2).*mats3(k,:));
    %variance_(k) = ((Fe/N3)^2)*sum((vecteur.^2).*mats3(k,1:((N3/2) + 1))) - (moyenne_dB(k)).^2 ; % Autre méthode pour calculer la variance.
    
    ecarttp_nor(k) = sqrt(variance_nor(k));
    ecarttp_dB(k) = sqrt(variance_dB(k));
    
    skewn_nor(k) = sum(((vectfk - moyenne_nor(k)).^3).*mats1(k,:))/((ecarttp_nor(k))^3);
    skewn_dB(k) = sum(((vectfk - moyenne_dB(k)).^3).*mats3(k,:))/((ecarttp_dB(k))^3);
    
    A_skewn_nor(k) = sum(((vectfk - moyenne_nor(k)).^3).*mats1(k,:));
    A_skewn_dB(k) = sum(((vectfk - moyenne_dB(k)).^3).*mats3(k,:));
    Askewn_nor(k) = (abs(A_skewn_nor(k))^(1/3))*sign(A_skewn_nor(k));
    Askewn_dB(k) =  (abs(A_skewn_dB(k))^(1/3))*sign(A_skewn_dB(k));
    
    kurtos_nor(k) = sum(((vectfk - moyenne_nor(k)).^4).*mats1(k,:))/(ecarttp_nor(k)^4);
    kurtos_dB(k) = sum (((vectfk - moyenne_dB(k)).^4).*mats3(k,:))/(ecarttp_dB(k)^4);
    
    Akurtos_nor(k) = sum(((vectfk - moyenne_nor(k)).^4).*mats1(k,:))^0.25;
    Akurtos_dB(k) = sum(((vectfk - moyenne_dB(k)).^4).*mats3(k,:))^0.25;
    
%     % On n'en a pas besoin aparremment, mais ça ne coute rien les calculer,
%     % donc...
%     stat5_nor(k) = (sum (((vectfk - ((moyenne_nor(k)).*(ones(1,((N3/2) + 1))))).^5).*(mats1(k,1:((N3/2) + 1)))))/((ecarttp_nor(k))^5);
%     %stat5_dB(k) = (sum (((vectfk - ((moyenne_dB(k)).*(ones(1,((N3/2) + 1))))).^5).*(mats3(k,1:((N3/2) + 1)))))/((ecarttp_dB(k))^5);
%     
%     A_stat5_nor(k) = (sum (((vectfk - ((moyenne_nor(k)).*(ones(1,((N3/2) + 1))))).^5).*(mats1(k,1:((N3/2) + 1)))));
%     %A_stat5_dB(k) = (sum (((vectfk - ((moyenne_dB(k)).*(ones(1,((N3/2) + 1))))).^5).*(mats3(k,1:((N3/2) + 1)))));
%     Astat5_nor(k) = ((abs(A_stat5_nor(k)))^(0.2))*sign(A_stat5_nor(k));
%     %Astat5_dB(k) = ((abs(A_stat5_dB(k)))^(0.2))*sign(A_stat5_dB(k));
%     
%     stat6_nor(k) = (sum (((vectfk - ((moyenne_nor(k)).*(ones(1,((N3/2) + 1))))).^6).*(mats1(k,1:((N3/2) + 1)))))/((ecarttp_nor(k))^6);
%     %stat6_dB(k) = (sum (((vectfk - ((moyenne_dB(k)).*(ones(1,((N3/2) + 1))))).^6).*(mats3(k,1:((N3/2) + 1)))))/((ecarttp_dB(k))^6);
%     
%     Astat6_nor(k) = ((sum (((vectfk - ((moyenne_nor(k)).*(ones(1,((N3/2) + 1))))).^6).*(mats1(k,1:((N3/2) + 1)))))^(1/6));
%     %Astat6_dB(k) = ((sum (((vectfk - ((moyenne_dB(k)).*(ones(1,((N3/2) + 1))))).^6).*(mats3(k,1:((N3/2) + 1)))))^(1/6));


% Calcul des approximations linéaires entre Fmin et Fmax d'une part et Fmax et 8000 Hz
% d'autre part. On considère à la fois le spectre en échelle d'amplitude
% linéaire et le spectre en dB.
% Parties du spectre linéaire considérées
N_max=fix((Fmax/Fe)*N3)+1;
matTFsignal_pond_BF=matTFsignal_pond_compl(k,N_min:N_max); % Spectre entre Fmin et Fmax
vectfk_BF = frequence_plot(N_min:N_max); % Fréquences correspondantes
matTFsignal_pond_HF=matTFsignal_pond_compl(k,N_max+1:N3/2+1); % Spectre entre Fmax et 8000 Hz
vectfk_HF = frequence_plot(N_max+1:N3/2+1); % Fréquences correspondantes
% Approximation linéaire du spectre en amplitude linéaire
% 
spectre_BF= matTFsignal_pond_BF-matTFsignal_pond_BF(1); % On part de zéro pour un fit du type Y=Xb
spectre_HF=matTFsignal_pond_HF-matTFsignal_pond_HF(1); % Meme chose
A_lin(k)=regress(spectre_BF', vectfk_BF'/1000); % Echelle fréquentielle en kHz
B_lin(k)=regress(spectre_HF', vectfk_HF'/1000); % Echelle fréquentielle en kHz
approx_lin_spec_lin_BF=A_lin(k)*vectfk_BF/1000+matTFsignal_pond_BF(1);
approx_lin_spec_lin_HF=B_lin(k)*vectfk_HF/1000+matTFsignal_pond_HF(1);

% Parties du spectre en dB considérées
max_TF_compl=max(matTFsignal_pond_compl(k,:));
matTFsignal_pond_dB_BF=20*log10(matTFsignal_pond_compl(k,N_min:N_max)/max_TF_compl); % Spectre entre Fmin et Fmax
matTFsignal_pond_dB_HF=20*log10(matTFsignal_pond_compl(k,N_max+1:N3/2+1)/max_TF_compl); % Spectre entre Fmin et Fmax
% Approximation linéaire du spectre en dB
% 
spectre_dB_BF= matTFsignal_pond_dB_BF-matTFsignal_pond_dB_BF(1); % On part de zéro pour un fit du type Y=Xb
spectre_dB_HF=matTFsignal_pond_dB_HF-matTFsignal_pond_dB_HF(1); % Meme chose
A_dB(k)=regress(spectre_dB_BF', vectfk_BF'/1000);% Echelle fréquentielle en kHz
B_dB(k)=regress(spectre_dB_HF', vectfk_HF'/1000);% Echelle fréquentielle en kHz
approx_lin_spec_dB_BF=A_dB(k)*vectfk_BF/1000+matTFsignal_pond_dB_BF(1);
approx_lin_spec_dB_HF=B_dB(k)*vectfk_HF/1000+matTFsignal_pond_dB_HF(1);

% Superposition des spectres et de leurs approximations linéaires.
    if question_1(1) == 'Y',
        figure(h_approx_lin)
        subplot(n,2,2*k-1), plot(frequence_plot,matTFsignal_pond_compl(k,1:N3/2+1),'b');
        grid; axis([0 Fe/2 0 1.1*max(matTFsignal_pond_compl(k,1:N3/2+1))]);
        hold on
        plot(vectfk_BF,approx_lin_spec_lin_BF,':r','LineWidth', 2);
        plot(vectfk_HF,approx_lin_spec_lin_HF,':g','LineWidth', 2);
        ylabel('Amplitude');
        if k==n
            xlabel('Fréquence en Hz');  
        end
        if k==1,
            %title(['                                                                                                  ',annonce_1]); % On le met au centre.
        end
        spectre_dB_compl=20*log10(matTFsignal_pond_compl(k,1:N3/2+1)/max_TF_compl);
        subplot(n,2,2*k), plot(frequence_plot,spectre_dB_compl,'b');
        grid; axis([0 Fe/2 -80  10]);
        hold on
        plot(vectfk_BF,approx_lin_spec_dB_BF,':r','LineWidth', 2);
        plot(vectfk_HF,approx_lin_spec_dB_HF,':g','LineWidth', 2);
        ylabel('dB');
        if k==n
            xlabel('Fréquence en Hz');  
        end
    end

end


% La création de dependances temporelles des spectres successifs.

N6 = N4 + fix(N1/2);
%disp('before return');
%keyboard;
moment_db=[moyenne_dB' ecarttp_dB' skewn_dB' kurtos_dB'];
moment_lin=[moyenne_nor' ecarttp_nor' skewn_nor' kurtos_nor'];
slopeab_db=[A_dB' B_dB'];
slopeab_lin=[A_lin' B_lin'];
dataout=[moment_db slopeab_db moment_lin slopeab_lin];
descriptorout=str2mat('COG_db','dispersion_db','skewness_db','kurtosis_db','slopea_db','slopeb_db','COG_lin','dispersion_lin','skewness_lin','kurtosis_lin','slopea_lin','slopeb_lin');
unitout=str2mat('Hz','Hz',' ',' ',' ',' ','Hz','Hz',' ',' ',' ',' ');

samplerateout=1/mean(diff(N6*Te));
t0out=t(1)*Te + N6(1)*Te;




return;


% --- Création des figures -----------------
% Statistique d'ordre supérieur
N8 = fix(0.005*Fe); % On fixe la durée de la fenetre d'analyse égale à 5 ms uniquement pour le spectrogramme.
figure('name','Signal, spectrogramme et évolution du centre de gravité du spectre linéaire.');
subplot(3,1,1),plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre linéaire. ',num2str(n), ' fenetres de ',num2str(Tf),' ms (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Fech = ', num2str(Fe/1000), ' kHz.']);
subplot(3,1,2);
%[spectro, F, T] = specgram(x, 1024, Fe, kaiser(N8,6), fix(0.98*N8));
[spectro, F, T] = specgram(x, 1024, Fe, hanning(N8), fix(0.98*N8));
colormap(gray)
map=colormap;
[l_map, col]=size(map);
for i=1:l_map
   inv_gray(i,:)=map(l_map-i+1,:);
end
colormap(inv_gray)
spectro_db=20*log10(abs(spectro));
dyn=50;
max_clip=max(max(spectro_db));
min_clip=max_clip-dyn;
[npoints, ntrame]=size(spectro_db);
for i=1:npoints
   for j=1:ntrame
      value=spectro_db(i,j);
      spectro_db_clip(i,j)=max(value,min_clip);
   end
end
imagesc(t(1)+0.005/2+T,F,spectro_db_clip);
axis xy
grid, axis ([t(1) t(length(t)), 0, Fe/2]); 
ylabel('Fréquence (Hz)')
subplot(3,1,3),plot(t(1)+Te*(N6-1),(moyenne_nor),'+m'), grid, xlabel('Temps en s'), ylabel('COG (Hz)'),axis ([t(1), t(length(t)), 0, Fe/2]); 

figure('name','Evolution des statistiques d''ordre 2, 3 et 4 pour le spectre linéaire.');
subplot(4,1,1),plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre linéaire. ',num2str(n), ' fenetres de ',num2str(Tf),' ms (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Fech = ', num2str(Fe/1000), ' kHz.']);
subplot(4,1,2),plot(t(1)+Te*(N6-1),ecarttp_nor,'+m'), grid, ylabel('Ecart-type Hz'); axis ([t(1), t(length(t)), 0 , 3000]);
subplot(4,1,3),plot(t(1)+Te*(N6-1),skewn_nor,'+m'), grid, ylabel('Skewness'), axis ([t(1), t(length(t)), (1-sign(min(skewn_nor))*0.1)*min(skewn_nor), (1+sign(max(skewn_nor))*0.1)*max(skewn_nor)]);
subplot(4,1,4),plot(t(1)+Te*(N6-1),kurtos_nor,'+m'), grid, xlabel('Temps en s'), ylabel('Kurtosis'), axis ([t(1), t(length(t)), (1-sign(min(kurtos_nor))*0.1)*min(kurtos_nor), (1+sign(max(kurtos_nor))*0.1)*max(kurtos_nor)]);

figure('name','Signal, spectrogramme et évolution du centre de gravité du spectre en dB.');
subplot(3,1,1),plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre en dB. ',num2str(n), ' fenetres de ',num2str(Tf),' ms (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Fech = ', num2str(Fe/1000), ' kHz.']);
subplot(3,1,2)
colormap(inv_gray)
imagesc(t(1)+0.005/2+T,F,spectro_db_clip);
axis xy
grid, axis ([t(1) t(length(t)), 0, Fe/2]); 
ylabel('Fréquence (Hz)')
subplot(3,1,3),plot(t(1)+Te*(N6-1),(moyenne_dB),'*r'), grid, xlabel('Temps en s'), ylabel('COG (Hz)'), axis ([t(1), t(length(t)), 0, Fe/2]); 

figure('name','Evolution des statistiques d''ordre 2, 3 et 4 pour le spectre en dB.');
subplot(4,1,1),plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre en dB. ',num2str(n), ' fenetres de ',num2str(Tf),' ms (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Fech = ', num2str(Fe/1000), ' kHz.']);
subplot(4,1,2),plot(t(1)+Te*(N6-1),ecarttp_dB,'*r'), grid, ylabel('Ecart-type Hz'); axis ([t(1), t(length(t)), 0, 3000]); 
subplot(4,1,3),plot(t(1)+Te*(N6-1),skewn_dB,'*r'), grid, ylabel('Skewness');axis ([t(1), t(length(t)), (1-sign(min(skewn_dB))*0.1)*min(skewn_dB), (1+sign(max(skewn_dB))*0.1)*max(skewn_dB)]);
subplot(4,1,4),plot(t(1)+Te*(N6-1),kurtos_dB,'*r'), grid, xlabel('Temps en s'), ylabel('Kurtosis'); axis ([t(1), t(length(t)), (1-sign(min(kurtos_dB))*0.1)*min(kurtos_dB), (1+sign(max(kurtos_dB))*0.1)*max(kurtos_dB)]);


% question_2 = input('Désirez-vous voir d''autres statistiques d''ordre supérieur pour ce signal? (Y/N) ','s');
% if question_2(1) == 'N'
%     return
% end
% 
% % Partie optionnelle qui visualise le signal avec les statistiques d'ordre
% % 2, 5 et 6 qui ne sont aparremment pas très exploitables....
% figure('name','Evolution des moments d''ordre 2, 5 et 6 (5 et 6) normalisées sur l''écart-type. La ddp est assimilée au spectre en échelle linéaire.');
% subplot(3,1,1),plot(t,x,'b'), grid, axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre linéaire. ',num2str(n), ' fenetres analysées de ',num2str(Tf),' ms chacune (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz.']);
% subplot(3,1,2),plot(1000*Te*(N6-1),stat5_nor), grid, ylabel('Moment d''ordre 5'); axis ([0, max(t), koef1*min(stat5_nor) - koef2*max(stat5_nor), koef1*max(stat5_nor) - koef2*min(stat5_nor)]);
% subplot(3,1,3),plot(1000*Te*(N6-1),stat6_nor), grid, xlabel('Temps en ms'), ylabel('Moment d''ordre 6'); axis ([0, max(t), koef1*min(stat6_nor) - koef2*max(stat6_nor), koef1*max(stat6_nor) - koef2*min(stat6_nor)]);
% 
% figure('name','Evolution des moments d''ordre 2, 5 et 6 (5 et 6) normalisées sur l''écart-type. La ddp est assimilée au spectre en échelle logarithmique.');
% subplot(4,1,1),plot(t,x,'r'), grid, axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre logarithmique. ',num2str(n), ' fenetres analysées de ',num2str(Tf),' ms chacune (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz.']);
% subplot(4,1,2),plot(1000*Te*(N6-1),(ecarttp_dB/1000),'r'), grid, ylabel('Ecart-type kHz'); axis ([0, max(t), koef1*min(ecarttp_dB/1000) - koef2*max(ecarttp_dB/1000), koef1*max(ecarttp_dB/1000) - koef2*min(ecarttp_dB/1000)]); 
% subplot(4,1,3),plot(1000*Te*(N6-1),stat5_dB,'r'), grid, ylabel('Moment d''ordre 5'); axis ([0, max(t), koef1*min(stat5_dB) - koef2*max(stat5_dB), koef1*max(stat5_dB) - koef2*min(stat5_dB)]);
% subplot(4,1,4),plot(1000*Te*(N6-1),stat6_dB,'r'), grid, xlabel('Temps en ms'), ylabel('Moment d''ordre 6'); axis ([0, max(t), koef1*min(stat6_dB) - koef2*max(stat6_dB), koef1*max(stat6_dB) - koef2*min(stat6_dB)]);
% 
% % - Statistiques d'ordre supérieur calculées comme les ésperences
% % mathématiques pures, sans division par écart-type pour le moment d'ordre
% % 3 et plus élevés. Pour les normaliser on extrait la racine de meme degrée
% % que l'ordre du moment. Dans ce cas toutes ces valeurs seront mésurées en
% % Hz, comme la fréquence - ce que a un sens physique car c'est la
% % distribution de fréquence que nous exploitons.
% 
% figure('name','Evolution des statistiques d''ordre 3 et 4 normalisées par extraction de la racine de dégrée 3 et 4 respectivement. La ddp est assimilée au spectre en échelle linéaire.');
% subplot(3,1,1),plot(t,x,'b'), grid, axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre linéaire. ',num2str(n), ' fenetres analysées de ',num2str(Tf),' ms chacune (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz.']);
% subplot(3,1,2),plot(1000*Te*(N6-1),Askewn_nor/1000), grid, ylabel('Moment d''ordre 3 en kHz'); axis ([0, max(t), koef1*min(Askewn_nor/1000) - koef2*max(Askewn_nor/1000), koef1*max(Askewn_nor/1000) - koef2*min(Askewn_nor/1000)]);
% subplot(3,1,3),plot(1000*Te*(N6-1), Akurtos_nor/1000), grid, xlabel('Temps en ms'), ylabel('Moment d''ordre 4 en kHz'); axis ([0, max(t), koef1*min(Akurtos_nor/1000) - koef2*max(Akurtos_nor/1000), koef1*max(Akurtos_nor/1000) - koef2*min(Akurtos_nor/1000)]);
% 
% figure('name','Evolution des statistiques d''ordre 5 et 6 normalisées par extraction de la racine de dégrée 5 et 6 respectivement. La ddp est assimilée au spectre en échelle linéaire.');
% subplot(3,1,1),plot(t,x,'b'), grid, axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre linéaire. ',num2str(n), ' fenetres analysées de ',num2str(Tf),' ms chacune (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz.']);
% subplot(3,1,2),plot(1000*Te*(N6-1),Astat5_nor/1000), grid, ylabel('Moment d''ordre 5 en kHz'); axis ([0, max(t), koef1*min(Astat5_nor/1000) - koef2*max(Astat5_nor/1000), koef1*max(Astat5_nor/1000) - koef2*min(Astat5_nor/1000)]);
% subplot(3,1,3),plot(1000*Te*(N6-1), Astat6_nor/1000), grid, xlabel('Temps en ms'), ylabel('Moment d''ordre 6 en kHz'); axis ([0, max(t), koef1*min(Astat6_nor/1000) - koef2*max(Astat6_nor/1000), koef1*max(Astat6_nor/1000) - koef2*min(Astat6_nor/1000)]);
% 
%  
% figure('name','Evolution des statistiques d''ordre 3 et 4 normalisées par extraction de la racine de dégrée 3 et 4 respectivement. La ddp est assimilée au spectre en échelle logarithmique.');
% subplot(3,1,1),plot(t,x,'r'), grid, axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre logarithmique. ',num2str(n), ' fenetres analysées de ',num2str(Tf),' ms chacune (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz.']);
% subplot(3,1,2),plot(1000*Te*(N6-1),Askewn_dB/1000,'r'), grid, ylabel('Moment d''ordre 3 en kHz'); axis ([0, max(t), koef1*min(Askewn_dB/1000) - koef2*max(Askewn_dB/1000), koef1*max(Askewn_dB/1000) - koef2*min(Askewn_dB/1000)]);
% subplot(3,1,3),plot(1000*Te*(N6-1), Akurtos_dB/1000,'r'), grid, xlabel('Temps en ms'), ylabel('Moment d''ordre 4 en kHz'); axis ([0, max(t), koef1*min(Akurtos_dB/1000) - koef2*max(Akurtos_dB/1000), koef1*max(Akurtos_dB/1000) - koef2*min(Akurtos_dB/1000)]);
% 
% figure('name','Evolution des statistiques d''ordre 5 et 6 normalisées par extraction de la racine de dégrée 5 et 6 respectivement. La ddp est assimilée au spectre en échelle logarithmique.');
% subplot(3,1,1),plot(t,x,'r'), grid, axis ([0, max(t), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre logarithmique. ',num2str(n), ' fenetres analysées de ',num2str(Tf),' ms chacune (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Signal échantillonné à ', num2str(Fe/1000), ' kHz.']);
% subplot(3,1,2),plot(1000*Te*(N6-1),Astat5_dB/1000,'r'), grid, ylabel('Moment d''ordre 5 en kHz'); axis ([0, max(t), koef1*min(Astat5_dB/1000) - koef2*max(Astat5_dB/1000), koef1*max(Astat5_dB/1000) - koef2*min(Astat5_dB/1000)]);
% subplot(3,1,3),plot(1000*Te*(N6-1), Astat6_dB/1000,'r'), grid, xlabel('Temps en ms'), ylabel('Moment d''ordre 6 en kHz'); axis ([0, max(t), koef1*min(Astat6_dB/1000) - koef2*max(Astat6_dB/1000), koef1*max(Astat6_dB/1000) - koef2*min(Astat6_dB/1000)]);
% 


% --- Création des figures -----------------
% Approximation linéaire
figure('name','Signal, Spectrogramme et Evolution des coefficients A et B pour le spectre linéaire.');
subplot(4,1,1),plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre linéaire. ',num2str(n), ' fenetres de ',num2str(Tf),' ms (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Fech = ', num2str(Fe/1000), ' kHz.']);
subplot(4,1,2)
colormap(inv_gray)
imagesc(t(1)+0.005/2+T,F,spectro_db_clip);
axis xy
grid, axis ([t(1) t(length(t)), 0, Fe/2]); 
ylabel('Fréquence (Hz)')
subplot(4,1,3),plot(t(1)+Te*(N6-1),A_lin,'+m'), grid, ylabel('A'), axis ([t(1), t(length(t)), (1-sign(min(A_lin))*0.1)*min(A_lin), (1+sign(max(A_lin))*0.1)*max(A_lin)]);
subplot(4,1,4),plot(t(1)+Te*(N6-1),B_lin,'+m'), grid, xlabel('Temps en s'), ylabel('B'), axis ([t(1), t(length(t)), (1-sign(min(B_lin))*0.1)*min(B_lin), (1+sign(max(B_lin))*0.1)*max(B_lin)]);

figure('name','Signal, Spectrogramme et Evolution des coefficients A et B pour le spectre en dB.');
subplot(4,1,1),plot(t,x,'b'), grid, axis ([t(1), t(length(t)), -1.08*max(abs(x)), 1.08*max(abs(x))]); title(['Spectre en dB. ',num2str(n), ' fenetres de ',num2str(Tf),' ms (soit ', num2str(N1), ' échantillons) avec recouvrement de ', num2str(rec), '%. Fech = ', num2str(Fe/1000), ' kHz.']);
subplot(4,1,2)
colormap(inv_gray)
imagesc(t(1)+0.005/2+T,F,spectro_db_clip);
axis xy
grid, axis ([t(1) t(length(t)), 0, Fe/2]); 
ylabel('Fréquence (Hz)')
subplot(4,1,3),plot(t(1)+Te*(N6-1),A_dB,'+m'), grid, ylabel('A'), axis ([t(1), t(length(t)), (1-sign(min(A_dB))*0.1)*min(A_dB), (1+sign(max(A_dB))*0.1)*max(A_dB)]);
subplot(4,1,4),plot(t(1)+Te*(N6-1),B_dB,'+m'), grid, xlabel('Temps en s'), ylabel('B'), axis ([t(1), t(length(t)), (1-sign(min(B_dB))*0.1)*min(B_dB), (1+sign(max(B_dB))*0.1)*max(B_dB)]);


%%% ----------- FIN DE LA DEUXIEME PARTIE --------------------------
%%% ----------------------------------------------------------------
%%% ----------------------------------------------------------------
% Ecriture des résultats dans un fichier Excel


nom_fic_sortie=[fichier_sortie,'.xls'];
fid2 = fopen(nom_fic_sortie, 'a');
fprintf(fid2,'\n');
fprintf(fid2,'%s \n', ['Fichier : ', son]);
fprintf(fid2,'%s \n', ['Séquence : ', label]);
fprintf(fid2,'%s \t', 'Skewness_Lin ');
for k=1:n
    fprintf(fid2,'%3.5f \t', skewn_nor(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'Kurtosis_lin ');
for k=1:n
    fprintf(fid2,'%3.5f \t', kurtos_nor(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'A_lin ');
for k=1:n
    fprintf(fid2,'%3.5f \t', A_lin(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'B_lin ');
for k=1:n
    fprintf(fid2,'%3.5f \t', B_lin(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'Skewness_dB ');
for k=1:n
    fprintf(fid2,'%3.5f \t', skewn_dB(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'Kurtosis_dB ');
for k=1:n
    fprintf(fid2,'%3.5f \t', kurtos_dB(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'A_dB ');
for k=1:n
    fprintf(fid2,'%3.5f \t', A_dB(k));
end
fprintf(fid2,'\n');
fprintf(fid2,'%s \t', 'B_dB ');
for k=1:n
    fprintf(fid2,'%3.5f \t', B_dB(k));
end
fprintf(fid2,'\n');
fclose(fid2);
clear all







