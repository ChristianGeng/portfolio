function myresult=mt_loadt(itrial);
% MT_LOADT Load trial data
% function myresult=mt_loadt(itrial);
% mt_loadt: Version 13.10.2005
%
%	Syntax
%		Returns 0 if any mat files not found, or if no segments in cutfile for requested trial; 1 otherwise
%
%	See also
%		MT_SSIG MT_GTRID MT_GCUF MT_STRID MT_SCALI MT_ORGMM

%only proceed if trial occurs in cutfile
%i.e check for any cuts for this trial ---> trial axis
%also trial label from cut file axis
%if nothing, return

%also check itrial is not already current

global MT_DATA

figorgh=mt_gfigh('mt_organization');
saxh=findobj(figorgh,'tag','signal_axis');
taxh=findobj(figorgh,'tag','trial_axis');

if mt_gtrid('number')==itrial
    myresult=1;
    return;
end;

vc=find(mt_gcufd('trial_number')==itrial);
if isempty(vc)
    disp(['mt_loadt: No segment information for trial ' int2str(itrial)]);
    myresult=0;
    %note: this leaves last trial intact
    return;
else
    cutdata=mt_gcufd('data');
    cutdata=cutdata(vc,:);
    cutlabel=mt_gcufd('label');
    cutlabel=cutlabel(vc,:);	%elimnate trailing blanks??


    mt_strid('cut_data',cutdata);
    mt_strid('cut_label',cutlabel);

    triallabel=mt_gcufd('trial_label');

    triallabel=deblank(triallabel(itrial,:));
    mt_strid('label',triallabel);
    mt_strid('number',itrial);

    disp(['Loading trial ' int2str(itrial) ': ' triallabel]);

end;


myS=mt_gcsid;

mypath=myS.signalpath;
reftrial=myS.ref_trial;
ll=length(reftrial);
signamelist=myS.signal_list;
unilist=myS.unique_matname;
mat2signal=myS.mat2signal;

nmat=size(unilist,1);
totalsig=size(signamelist,1);
tbuf=zeros(totalsig,2);	%for t0 and tend

myresult=1;

myresultx=ones(nmat,1);

for ii=1:nmat

    matname=[mypath deblank(unilist(ii,:)) int2str0(itrial,ll)];
    siginmat=signamelist(mat2signal{ii},:);
    nsig=size(siginmat,1);
    %handle defaults for variables that might be missing
    t0=0;
    scalefactor=1;
    signalzero=0;
    try
        load(matname);
    catch
        myresultx(ii)=0;
        disp(['mt_loadt: mat file not found ' matname]);
    end;

    fsize=length(scalefactor);
    zsize=length(signalzero);


    for jj=1:nsig
        %get the structure with signal data from the signal axis
        signame=deblank(siginmat(jj,:));
        ht=findobj(saxh,'tag',signame);
        sigstruct=get(ht,'userdata');
        mycol=sigstruct.mat_column;
        ichan=sigstruct.signal_number;

        if myresultx(ii)

            if jj==1
                if strmatch('flatflag',fieldnames(sigstruct))
                    if sigstruct.flatflag==1
                        data=reshape(data,[size(data,1) size(data,2)*size(data,3)]);
                    end;
                end;
            end;


            if mycol
                x=data(:,mycol);
                fcol=min([fsize mycol]);
                zcol=min([zsize mycol]);
                fuse=scalefactor(fcol);
                zuse=signalzero(zcol);
                tend=length(x)./sigstruct.samplerate;
            else
                x=data;
                fuse=scalefactor(1);
                zuse=signalzero(1);
                dsize=size(x);
                tend=dsize(end)./sigstruct.samplerate;
            end;

            if ~strcmp(sigstruct.class_mem,sigstruct.class_mat)
                x=double(x);
            end;


            if (fuse~=1) | (zuse~=0)
                if strcmp(sigstruct.class_mem,'double')
                    x=mt_scali(x,fuse,zuse);
                else
                    %treat as warning and continue
                    %mt_ssig should block this happening when the reference trial is examined

                    disp('mt_loadt: WARNING! Unable to scale non-double data')
                    disp(signame);
                end;

            end;
            tbuf(ichan,:)=[t0 tend+t0];
            %allow for session????
            MT_DATA{ichan}=x;

            %update trial-dependent variables in sigstruct

            sigstruct.t0=t0;
            sigstruct.scalefactor=fuse;
            sigstruct.signalzero=zuse;
            sigstruct.data_size=size(x);
            %retrieve with e.g newx=MT_DATA{ichan}(1000:2000);
            set(ht,'userdata',sigstruct);
        else
            %reset data
            MT_DATA{ichan}=[];
            sigstruct.t0=0;
            sigstruct.scalefactor=1;
            sigstruct.signalzero=0;
            sigstruct.data_size=0;
            set(ht,'userdata',sigstruct);
            tbuf(ichan,:)=[0 0];
        end;			%myresult

    end; %signal loop
end; %mat loop


if any(myresultx==0) myresult=0; end;


%more things in trial axis.....????

mt_strid('signal_t0',tbuf(:,1));
mt_strid('signal_tend',tbuf(:,2));

%if myresult
%if signal could not be loaded mt_orgmm should take care of it
maxminsig=mt_gtrid('maxmin_signal');
xlimtmp=max(tbuf(:,2));
if xlimtmp<=10*eps xlimtmp=1; end;      %will happen if no data at all could be loaded
set(taxh,'xlim',[0 xlimtmp]);

%example of trial overview with e.g audio envelope
%no reason to be restricted to maxmin
%this function should do something appropriate to the line objects in
%the trial axis

mt_orgmm(taxh,maxminsig);

%end;
