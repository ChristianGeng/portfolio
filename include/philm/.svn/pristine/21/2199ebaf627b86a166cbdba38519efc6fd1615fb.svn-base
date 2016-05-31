function [posamprms,posampdt]=posampana(amps,posamps,rmsfac);
% POSAMPANA rms error and dt difference from amps and posamps
% function [posamprms,posampdt]=posampana(amps,posamps,rmsfac);
% posampana: Version 17.9.05
%
%   Description
%       Compute rms and difference between first difference! for a set of
%       amp and posamp data (sensors as 3rd dimension)

aa=amps;
pa=posamps;
[ndat,ntrans,nsensor]=size(aa);

eucpa=zeros(ndat-1,nsensor);
eucaa=zeros(ndat-1,nsensor);
myrms=zeros(ndat,nsensor);
leavesquare=1;
for ii=1:nsensor 
    eucaa(:,ii)=eucdistn(aa(1:end-1,:,ii),aa(2:end,:,ii),leavesquare);
    eucpa(:,ii)=eucdistn(pa(1:end-1,:,ii),pa(2:end,:,ii),leavesquare);
    myrms(:,ii)=eucdistn(pa(:,:,ii),aa(:,:,ii),leavesquare);
end;


eucaa=(sqrt(eucaa/ntrans))*rmsfac;
eucpa=(sqrt(eucpa/ntrans))*rmsfac;
myrms=(sqrt(myrms/ntrans))*rmsfac;
%keyboard;
posampdt=abs(eucpa-eucaa);
posampdt=[posampdt;posampdt(end,:)];        %ensure same length as original data

posamprms=myrms;
