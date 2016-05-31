function [descrip,units]=getdesuni(instring);
% GETDESUNI Parse a string matrix into parameter descriptor and units
% function [descrip,units]=getdesuni(instring);
% getdesuni: Version ??
%
%   Notes
%       separator can be blank or comma

nrow=size(instring,2);
sep=' ,';
descrip='';units='';
if nrow>0
    for ii=1:nrow
        [dt,rest]=strtok(instring(ii,:),sep);
        ut=strtok(rest,sep);
        descrip=str2mat(descrip,dt);
        units=str2mat(units,ut);
    end;
    %eliminate first row
    descrip(1,:)=[];
    units(1,:)=[];
end;
