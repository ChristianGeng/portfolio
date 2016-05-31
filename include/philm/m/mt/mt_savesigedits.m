function mt_savesigedits(confirmflag)
% MT_SAVESIGEDITS Save edited signal
% function mt_savesigedits(confirmflag)
% mt_savesigedits: Version 10.8.04
%
%   Syntax
%       confirmflag: If no input arg, or if present and true, prompt for
%       confirmation

functionname='MT edit signal. Version 10.08.2004';

iconfirm=1;
if nargin iconfirm=confirmflag; end;

editS=mt_geditd;

sig2edit=editS.sig2edit;
if isempty(sig2edit)
    disp('No data to save as no edit signal chosen');
else
    if iconfirm
        oks=abartstr('OK to store edited signal to file?','n');
    else
        oks='y';
    end;
    if strcmp(lower(oks),'y')
        outdata=mt_gdata(sig2edit);     %whole trial
        MyS=mt_gsigv(sig2edit);
        MyC=mt_gcsid;
        %recpath, current trial
        ndig=length(MyC.ref_trial);
        
        sigfile=[MyC.signalpath MyS.mat_name int2str0(mt_gccud('trial_number'),ndig)];
        data=mymatin(sigfile,'data');
        data(:,MyS.mat_column)=outdata;
        comment=mymatin(sigfile,'comment');
        comment=framecomment(comment,functionname);
        
        %backup file if possible
        if exist([sigfile '.mak'],'file')
            disp('Backup file already exists');
            if iconfirm
                oks=abartstr('Overwrite?','y');
            else
                oks='y';
            end;
            
            if ~strcmp(lower(oks),'n')
                [Csuccess,Cmessage,Cmessageid]=copyfile([sigfile '.mat'],[sigfile '.mak'],'f');
                if ~Csuccess disp(Cmessage);disp(Cmessageid); end; 
                
            end;
            
            
        else
            [Csuccess,Cmessage,Cmessageid]=copyfile([sigfile '.mat'],[sigfile '.mak']);
            if ~Csuccess disp(Cmessage);disp(Cmessageid); end; 
            
        end;
        
        if Csuccess
            disp(['Saving to ' sigfile]);
            save(sigfile,'data','comment','-append');
            mt_seditd('unsavededits',0);
            editS.unsavededits=0;
            %                    command=K.return;
        else
            disp('Problem with backup; edited data not saved');
        end;
        
        
    end;
end;
