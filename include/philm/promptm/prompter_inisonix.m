function iniok=prompter_inisonix

iniok=1;
sonix_ctrl('ini');
U=sonix_getsettings;
if isempty(U)
    iniok=0;
end;
%more checks? specific fields?

if ~iniok return; end;

%get base file name from main prompter data structure
U.filenamebase=prompter_gmaind('sonixfilename');
sonix_setsettings(U);

myfunc=prompter_gmaind('usersonixsetfunc');
prompter_evaluserfunc(myfunc,'sonixset');

fignames=prompter_gmaind('figure_names');
fignames=str2mat(fignames,U.figurename);
prompter_smaind('figure_names',fignames);
