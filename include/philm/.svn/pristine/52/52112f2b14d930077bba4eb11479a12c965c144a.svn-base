function newmap=stretchmap(nsize,istretch);
% STRETCHMAP Stretched version of HSV colormap
% function newmap=stretchmap(nsize,istretch);
% stretchmap: Version ???
%
%   See Also MYHSV2RGB

intrate=100;
ia=istretch:-(istretch/nsize):0;
ia=ia(1:nsize)+1;
ia=cumsum(ia);

ia=ia*intrate;
ia=round(ia-ia(1)+1);
nbig=ia(end);
bigmap=myhsv2rgb(nbig);
newmap=bigmap(ia,:);
