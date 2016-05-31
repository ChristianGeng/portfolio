function samplo=cut2samp(cutin,sf,samplim)
% CUT2SAMP Convert cut boundaries in seconds to length and offset in samples
% function samplo=cut2samp(cutin,sf,samplim)
% cut2samp: Version ???
%
%   Syntax
%       samplo is a 2-element vector: [length offset]
%       3rd ar. samplim is optional; can be used to clip cut length
%
%   See Also CUTCHECK

anasamp=round(cutin*sf);
%use cutcheck, probably redundant
%to check for negative start or negative length
[anasamp,cutflag]=cutcheck(anasamp,0,realmax);
samoff=anasamp(1);
samlen=anasamp(2)-anasamp(1);
if nargin==3
    if samlen > samplim
        disp ('Cut2samp: Cut length clipped');
        disp ([samlen samplim]);
        samlen=samplim;
    end
end
if (samlen==0) disp ('Cut2samp: Note - Zero cut');end
samplo=[samlen samoff];
