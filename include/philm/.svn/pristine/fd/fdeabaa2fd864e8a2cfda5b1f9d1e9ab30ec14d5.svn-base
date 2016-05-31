function storev6
% STOREV6 Load all mat files in working dir and store as v6

ss=dir('*.mat');
nf=length(ss);

for ii=1:nf
    disp(ss(ii).name);
    S=load(ss(ii).name);
    save(ss(ii).name,'-struct','S','-v6')
end;
