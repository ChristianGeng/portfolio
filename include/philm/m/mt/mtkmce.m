function mtkmce
% MTKME mt user commands main_cursor_editsignal
% function mtkmce
% mtkmce: Version 31.05.2004
%
%   See Also MT_SIGEDIT MT_CALC MT_SEDITD MT_GEDITD

%Note initialization of edit structure is done by mt_org

persistent K
persistent oldmarker

functionname='MT edit signal (mtkmce). Version 31.05.2004';

kname='mce';
if isempty(K)
    myS=load('mt_skey',['k_' kname]);
    K=getfield(myS,['k_' kname]);
    clear myS;
    mlock;   
end;

[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;

editS=mt_geditd;


allsigs=mt_gcsid('signal_list');

%all commands that actually change the signal
editcmds=[K.deletebetweencursor K.deleteatactivecursor K.executeequation K.replacebetweencursor K.replaceatactivecursor];
%subset of above commands that use a replacement signal
replacecmds=[K.replacebetweencursor K.replaceatactivecursor];



while command~=K.return
    mystring=philinp([kname '> ']);
    if isempty(mystring)
        command=K.return;
    else
        command=abs(mystring(1));
    end;
    commandback=mtkcomm(command,K,'return');
    if commandback command=commandback; end;
    
    if command==K.usekeyboard
        keyboard;
    end;
    
    if command==K.defineequation
        E=editS.equations;
        disp('Current equations:');
        disp(E);
        myfield=abartstr('Name of equation');
        mydef=abartstr('Definition of equation');
        try
            E.(myfield)=mydef;
            %            setfield(E,myfield,mydef);
            editS.equations=E;
            mt_seditd('equations',E);
        catch
            disp('Problem with equation definition?');
        end;
        
    end;
    
    
    if command==K.chooseeditsignal
           oldsig=editS.sig2edit;
        sig2edit=abartstr('Choose signal to edit',deblank(allsigs(1,:)),allsigs,abscalar);
        
        %restore old marker type if changing edit signal

        if ~isempty(oldsig)
            if ~isempty(oldmarker)
        
                hlo=findobj(mt_gfigh('mt_f(t)'),'type','line','tag',oldsig);
                set(hlo,'marker',oldmarker);
            end;
        end;
        
                
        
        hl=findobj(mt_gfigh('mt_f(t)'),'type','line','tag',sig2edit);
        oldmarker=get(hl,'marker');
        set(hl,'marker',editS.editmarker);
        editS.sig2edit=sig2edit;
        mt_seditd('sig2edit',sig2edit);
        
    end;
    
    if command==K.choosereplacementsignal
        sig4replace=abartstr('Choose signal to replace edited signal',deblank(allsigs(1,:)),allsigs,abscalar);
        editS.sig4replace=sig4replace;
        mt_seditd('sig4replace',sig4replace);
    end;
    
    if command==K.saveandexit
        sig2edit=editS.sig2edit;
        if isempty(sig2edit)
            disp('No data to save as no edit signal chosen');
        else
            oks=abartstr('OK to store edited signal to file?','n');
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
                    oks=abartstr('Overwrite?','y');
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
    end;
    
    
    if any(editcmds==command)
        sig2edit=editS.sig2edit;
        %commands that actually modify the edit signal
        if isempty(sig2edit)
            disp('Choose signal to edit');
        else
            
            
            
            if command==K.deletebetweencursor
                mydef=[sig2edit '*NaN'];
                mt_sigedit(mydef,mt_gcurp);    
            end;
            
            if command==K.executeequation
                E=editS.equations;
                if isstruct(E)
                    mynames=char(fieldnames(E));
                    myfield=abartstr('Name of equation',deblank(mynames(:,1)),mynames,abscalar);
                    %            mydef=getfield(E,myfield);
                    mydef=E.(myfield);
                    %                    keyboard;
                    
                    mt_sigedit(mydef,mt_gcurp);
                end;
                
            end;
            
            %commands that also need a replacement signal
            if any(replacecmds==command)        
                sig4replace=editS.sig4replace;
                if isempty(sig4replace)
                    disp('Choose replacement signal');
                else
                    
                    if command==K.replacebetweencursor
                        mydef=sig4replace;
                        mt_sigedit(mydef,mt_gcurp);
                    end;
                    
                end;        %replacement signal not empty
            end;        %any replacement commands
            
            
        end;        %edit signal not empty    
    end;        %any edit commands
    
    
    
end;		%while not return

