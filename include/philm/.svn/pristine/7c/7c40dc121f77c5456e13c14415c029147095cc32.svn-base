function textgrid2mat(basepath,maxtrial,outcutfile,tierlist,typelist,refcutfile);
% TEXTGRID2MAT Convert Praat textgrid files to cut file
% function textgrid2mat(basepath,maxtrial,outcutfile,tierlist,typelist,refcutfile);
% textgrid2mat: Version 19.08.08
%
%   Syntax
%       basepath: Actually the common part of the textgrid filename, i.e
%           without trial number (and without extension). May be necessary to take leading zeros into account
%           depending on maxtrial
%       maxtrial: Does not matter if larger than the highest trial number
%           actually occurring (the program prints a warning message if a trial
%           is not found and continues)
%       tierlist: list of the tiers to extract from the textgrid file
%           N.B tiernames must not contain any whitespace characters
%           tier names are not case sensitive when looking for the tiers in
%           the textgrid file, but the case of input argument tierlist is
%           retained in the valuelabel variable of the output segment file
%       typelist: Corresponding list of marker types to use in the new cut
%           file (cut_type.value/.label in new cut file is based on
%           tierlist and typelist)
%       refcutfile: Optional. If present the label from the corresponding
%       trial is prefixed to any segment labels in the textgrid file
%
%   Notes
%       Currently only handles interval tiers
%       Currently only handles textgrids in short text format. Convert with
%       fixpraattextgridlong2short if necessary
%       Any segments whose label is empty - !after discarding any whitespace
%       characters! - are discarded. This is necessary because in interval
%       tiers Praat inserts a kind of dummy segment for example before the
%       first 'actual' segment and after the last one, in order to cover
%       the whole trial exhaustively.
%       Note that this version of the program cannot handle label fields
%       that contain crlf. This appears to be permitted in Praat, but is
%       very unlikely to happen in practice under the current version of
%       Windows because 'Enter' is the shortcut for setting a boundary, so
%       it is not easily possible to insert a crlf in the label field.
%       As the current version of Linux has different short cuts it appears
%       to be quite possible for a label to be inserted inadvertently in
%       the label field. Labels that would otherwise be empty are now
%       taken care of automatically by textgrid2praat, but it is
%       conceivable that some textgrids will need tidying by hand with a
%       text editor if the program crashes
%
%   Updates
%       5.08 Handle extraneous crlf in empty labels
%       8.08 Handle interval tier called IntervalTier

functionname='textgrid2mat: Version 19.08.08';

tierlistout=tierlist;       %keep input case when adding to cut_type_label (see below, at end)
tierlist=lower(tierlist);

ndig=length(int2str(maxtrial));
gridext='.TextGrid';            %note: linux case sensitive
%label in output file consists of any label from refcutfile and label in
%text grid, separated by sepchar
sepchar='/';

data=[];
label='';

refcut=0;
if nargin>5
    if ~isempty(refcutfile)
        refdata=mymatin(refcutfile,'data',[]);
        reflabel=mymatin(refcutfile,'label');
        if ~isempty(refdata) refcut=1; end;
    end;
end;



for itrial=1:maxtrial
    iis=int2str0(itrial,ndig);


    refstring='';
    if refcut
        vt=find(refdata(:,4)==itrial);
        if length(vt)==1 refstring=deblank(reflabel(vt,:)); end;
    end;

    disp(['Trial ' iis ':' refstring]);


    myname=[basepath iis gridext];
    if exist(myname,'file');
        ss=file2str(myname);
        disp(ss(1,:));
        %fix empty labels divided by extraneous crlf
        ssc=cellstr(ss);
        vv=strmatch('"',ssc,'exact');
        nsusp=length(vv);
        dellist=[];
        if nsusp>1
            disp(['Total number of suspicious lines : ' int2str(nsusp)]);
            for isusp=1:(nsusp-1)
                if vv(isusp+1)==vv(isusp)+1
                    ssc{vv(isusp)}='""';
                    dellist=[dellist vv(isusp+1)];
                end;
            end;
            if ~isempty(dellist)
                disp('List of deleted lines');
                disp(dellist);
                disp('Previous line set to empty label');
                ssc(dellist)=[];
            end;

        else
            %can this ever happen?
            if nsusp==1
                disp(['single suspicious line at line ' int2str(vv)]);
                keyboard;
            end;

        end;

        ss=char(ssc);


        vtier=strmatch('"IntervalTier"',ss);
        ntier=length(vtier);
        if ntier>1
            vx=find(diff(vtier)==1);
            if ~isempty(vx)
                vtier(vx+1)=[];
                disp('handling interval tier called IntervalTier');
                %keyboard;
                ntier=length(vtier);
            end;
        end;
        
        for itier=1:ntier
            vv=vtier(itier);

            tiername=deblank(ss(vv+1,:));
            tiername=strrep(tiername,'"','');
            tiername(isspace(tiername))=[];
            tiername=lower(tiername);
            vvl=strmatch(tiername,tierlist,'exact');
            if length(vvl)==1
                mytype=typelist(vvl);

                nseg=str2num(ss(vv+4,:));

                datbuf=ones(nseg,4)*NaN;
                labbuf=cell(nseg,1);


                ipi=vv+5;
                for isi=1:nseg
                    mystart=str2num(ss(ipi,:));
                    if length(mystart)~=1
                        disp('problem with mystart at line');
                        disp(ipi);
                        disp(ss(ipi,:));
                        disp(mystart);
                        keyboard;
                    end;

                    ipi=ipi+1;
                    myend=str2num(ss(ipi,:));
                    if length(myend)~=1
                        disp('problem with myend at line:');
                        disp(ipi);
                        disp(ss(ipi,:));
                        disp(myend);
                        keyboard;
                    end;
                    ipi=ipi+1;
                    mylab=deblank(ss(ipi,:));
                    mylab(isspace(mylab))=[];
                    ipi=ipi+1;
                    if ~strcmp(mylab,'""')
                        mylab=strrep(mylab,'"','');

                        tmpd=[mystart myend mytype itrial];
                        disp([nseg isi tmpd]);
                        datbuf(isi,:)=tmpd;
                        if myend<=mystart
                            disp('zero segment???');
                            keyboard;
                            datbuf(isi,1)=NaN;      %force deletion
                        end;

                        tmplab=mylab;
                        if refcut tmplab=[refstring sepchar tmplab];  end;
                        %                        tmplab=[triallabelx codeterminator mylab];
                        labbuf{isi}=tmplab;
                    end;
                end;        %seg loop
                vv=find(isnan(datbuf(:,1)));
                datbuf(vv,:)=[];
                labbuf(vv)=[];
                labbuf=char(labbuf);
                data=[data;datbuf];
                if isempty(label)
                    label=labbuf;
                else
                    %not very efficient
                    label=strvcat(label,labbuf);
                end;
            else
                disp('Tier name not in list');
                disp(tiername);
                keyboard;
                
            end;


        end;        %tier loop
        %    keyboard;

    else
        disp('No textgrid');
    end;

end;


comment='Segmentation from praat';

[descriptor,unit,valuelabel]=cutstrucn;

valuelabel.cut_type.label=str2mat(valuelabel.cut_type.label,tierlistout);
valuelabel.cut_type.value=[valuelabel.cut_type.value;typelist];

if refcut
    oldcomment=mymatin(refcutfile,'comment');
    comment=[comment crlf oldcomment];
end;
comment=framecomment(comment,functionname);


save(outcutfile,'data','label','valuelabel','comment','descriptor','unit');

