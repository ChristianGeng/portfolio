function mt_sigedit(mydef,mytime);
% MT_SIGEDIT Edit signals
% function mt_sigedit(mydef,mytime);
% mt_sigedit: Version 01.06.2004
%
%   Syntax
%       mydef is the calculation to be evaluated by MT_CALC
%       mytime ist the portion of the signal in the current trial to be
%       edited
%       The name of the signal to be edited must be set up with MT_SEDITD
%
%   See Also MT_CALC MT_SEDITD


sig2edit=mt_geditd('sig2edit');

if isempty(sig2edit)
    disp('mt_sigedit: No edit signal defined');
    return;
end;

try
    [tmpd,actualtime]=mt_gdata(sig2edit,mytime);
    newdata=mt_calc(mydef,actualtime);
    if length(newdata)~=length(tmpd)
        disp('mt_sigedit: Equation result has unexpected length');
        disp([length(newdata) length(tmpd)]);
    else
        mt_sdata(sig2edit,newdata,actualtime);
        mt_seditd('unsavededits',1);
        mt_shoft;           %also other displays to update?    
    end;
    
catch
    disp('mt_sigedit: Problem with equation execution?');
    disp(mydef);
    disp(lasterr);
end;
