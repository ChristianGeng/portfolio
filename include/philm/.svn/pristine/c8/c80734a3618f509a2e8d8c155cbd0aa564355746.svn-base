function epgwav2mat(inname,outname,codefile,ntrial,usercomment,trialdig,epgsamplerate);
% EPGWAV2MAT Quick conversion EPG and WAV file to MAT file
% function epgwav2mat(inname,outname,codefile,ntrial,usercomment,trialdig,epgsamplerate);
% epgwav2mat: Version 18.05.07
%
%   Description
%       inname: common part of name, without trial number
%       outname: common part of name. _aud_ and _epg_ inserted before trial number
%       codefile: text file of stimulus codes
%       ntrial: number of trials to process
%       usercomment: Free comment
%       trialdig. Optional. Number of digits in trial number. Default to 3
%       epgsamplerate. Optional. Default to 100;
%       Also generates a cut file
%       EPG data is stored as uint8 (i.e 1 byte per electrode)

functionname='EPGWAV2MAT: Version 18.05.07';

addcomment=['Input name : ' inname crlf 'Code file : ' codefile crlf];


bitsperframe=64;
samplerate_epg=100;
if nargin>6 samplerate_epg=epgsamplerate; end;

ndig=3;
if nargin>5 ndig=trialdig; end;

cutlabel=file2str(codefile);
if size(cutlabel,1)<ntrial
    disp('not enough entries in code file');
    return;
end;
cutlabel=cutlabel(1:ntrial,:);

cutdata=zeros(ntrial,4);

for ii=1:ntrial
    item_id=deblank(cutlabel(ii,:));

    trials=int2str0(ii,ndig);

    disp([trials ' ' item_id]);

    comment=[addcomment usercomment];
    comment=framecomment(comment,functionname);

    wavname=[inname trials '.wav'];
    if exist(wavname,'file')
        [y,sf]=wavread(wavname);
        cutdata(ii,4)=ii;
        cutdata(ii,2)=length(y)/sf;

        descriptor='AUDIO';
        unit='au';
        samplerate=sf;
        data=y;

        save([outname '_aud_' trials],'data','descriptor','unit','samplerate','comment','item_id');



        fid=fopen([inname trials '.EPG'],'r');
        if fid<3
            disp('EPG File not found?');
            return;
        end;

        data=fread(fid,[bitsperframe, Inf],'ubit1');
        fclose(fid);

        data=flipud(data);

        %may be better to change to something like uint8 rather than sparse
        %uint8 and logical both use 1 byte per electrode
        %sparse MAY use less storage space, but this cannot be guaranteed
        %(in some situations it may even use more than a standard double
        %format)
        
        %        data=sparse(data);
        data=uint8(data);
        
        samplerate=samplerate_epg;

        epgoutname=[outname '_epg_' trials];
        save(epgoutname,'data','samplerate','comment','item_id');

        %add phil's standard variables
        epgxdim(epgoutname);
    else
        disp('no WAV file');
        keyboard;
    end;


end;

data=cutdata;
label=cutlabel;
[descriptor,unit,cut_type_value,cut_type_label]=cutstruc;

save([outname '_cut'],'data','label','descriptor','unit','cut_type_value','cut_type_label','comment');

