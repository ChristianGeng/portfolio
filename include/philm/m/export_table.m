function export_table(filelist,outpath,briefcomment,newdescriptor,labeldescriptor,labelv)
% EXPORT_TABLE Export matlab data to SPSS
% function export_table(filelist,outpath,briefcomment,newdescriptor,labeldescriptor,labelv)
% export_table: Version 10.12.2007
%
%	Description
%		Produce tab delimited ASCII files for import to  SPSS using GET TRANSLATE,
%		and SPSS syntax file to actually perform the import, assign value labels etc.
%
%	Syntax
%       filelist: string matrix. List of matlab files to convert
%       outpath: Common part of filename of output files
%       briefcomment: Short description of file to be used with the SPSS
%           FILE LABEL command. (The comment variable of the input file is
%           placed in the SPSS file using the DOCUMENT command)
%		newdescriptor: Optional
%			newdescriptor must be used if the original descriptor is not unambiguous
%			when truncated to the first 64 characters.
%           (Note that older versions of SPSS could not handle variable
%           names longer than 8 characters)
%			newdescriptor can of course be used optionally to simply override the variable
%			names that would be derived by default from descriptor.
%			Note that the complete original descriptor, plus unit, is retained in the SPSS
%			variable labels.
%       labeldescriptor: Optional
%			labeldescriptor must be specified when it is desired to use each column of label
%			as a separate variable in the SPSS file. It must be a string matrix, like descriptor,
%			each line providing a variable name for the corresponding columns of label.
%			(If there are less lines in labeldescriptor than there are columns in label, then
%			only the first n columns of label are retained as individual variables)
%			Regardless of whether labeldescriptor is present, the complete label (if present) is
%			always inserted as the first variable in the SPSS file, with variable name 'labels'.
%			If labeldescriptor is used, but it is not desired to use newdescriptor, then
%			an empty newdescriptor must be included in the argument list.
%			If both labeldescriptor and newdescriptor are used then newdescriptor must include
%			corresponding entries for labeldescriptor. These must be the first entries in
%			newdescriptor, since the individual label variables are placed
%			first in the SPSS file
%
%       labelv: Optional
%           If present, must be a vector specifying the columns of 'label'
%           to retain in the output. Simplest case is to truncate the label
%           variable, but could also be used to rearrange it.
%           If labeldescriptor is used, it must refer to the arrangement of
%           label AFTER selection by labelv. If not used, it must be
%           specified as empty
%
%	See Also SHOW_VALUELABEL


functionname='export_table: Version 10.12.2007';

varnamemaxlen=64;

%use optional input args to change?
mydelim=char(9);	%tab
%mydelim=',';
nanstr='';

scriptname=[outpath deblank(filelist(1,:))];
fids=fopen([scriptname '.sps'],'w');
if fids<3
    disp('Unable to open SPSS script file');
    return
end;

nfile=size(filelist,1);

for ifile=1:nfile
    matfile=deblank(filelist(ifile,:));
    outname=[outpath matfile];
    outnamea=[outname '_tab.txt'];

    comment='';
    load(matfile);


    commentm=rv2strm(comment,crlf);
    ncom=size(commentm,1);
    %spss doesn't seem to like blank lines, or period as last nonblank character
    for ipi=1:ncom
        comx=deblank(commentm(ipi,:));
        if isempty(comx)
            commentm(ipi,1)='#';
        else
            if comx(end)=='.'
                commentm(ipi,length(comx))='#';
            end;
        end;

    end;

    commentm=strm2rv(commentm);

    namestr=[functionname crlf datestr(now) crlf commentm];
    %set up for SPSS document

    namestr=[namestr '.' crlf];

    labelsexist=exist('label','var');
    dbig=descriptor;
    nlabp=0;

    %handle rearrangement with labelv

    if labelsexist

        if nargin>4
            %insert label parameters
            if nargin>5
                label=label(:,labelv);
            end;
            if ~isempty(labeldescriptor)
                nlabp=size(labeldescriptor,1);
                dbig=str2mat(labeldescriptor,dbig);
                unit=str2mat((blanks(nlabp))',unit);
            end;

        end;



        dbig=str2mat('labels',dbig);
        unit=str2mat(' ',unit);
    end;


    %allow for optional replacement of variable names before proceeding
    %note this will have to be the same for all files in the file list


    %but use original matlab names as variable label

    %note: new descriptor must take any label parameters just created into
    %account

    dvar=dbig;

    if nargin>3
        if ~isempty(newdescriptor)
            dtmp=newdescriptor;
            if labelsexist dtmp=str2mat('labels',dtmp); end;
            if size(dtmp,1)==size(dbig,1)
                dvar=dtmp;
            end;
        end;
    end;

    %keyboard;
    %checks on resulting variable names
    %doesn't catch all potential problems, but they should become obvious
    %when the import is actually carried out


    if size(dvar,2)>varnamemaxlen
        disp('Variable names will be truncated');
        dvar=dvar(:,1:varnamemaxlen);
        disp(dvar);

    end;

    duni=unique(dvar,'rows');
    if size(duni,1)<size(dvar,1)
        disp('Ambiguous variable names; Unable to proceed');
        disp(duni);
        keyboard;
        return;
    end;



    fid=fopen(outnamea,'w');
    if fid<3
        disp('Unable to open output file');
        return
    end;

    myformat='%0.15g';
    myformat=[myformat mydelim];

    d=strm2rv(dvar,mydelim);
    %eliminate last delimiter
    d=d(1:(end-1));

    d=[d crlf];


    status=fwrite(fid,d,'uchar');

    [m,n]=size(data);

    for ii=1:m
        d=sprintf(myformat,data(ii,:));
        %eliminate last delimiter
        d=d(1:(end-1));
        d=strrep(d,'NaN',nanstr);
        d=[d crlf];
        sl='';
        if labelsexist
            ssl=deblank(label(ii,:));
            if isempty(ssl) ssl='<empty label>'; end;
            sl=[ssl mydelim];

            if nlabp
                for ill=1:nlabp
                    sl=[sl label(ii,ill) mydelim];
                end;
            end;
        end;
        if ~isempty(sl) d=[sl d]; end;
        status=fwrite(fid,d,'uchar');
    end;
    status=fclose(fid);

    %write commands to SPSS syntax file

    ss=['GET TRANSLATE FILE=' quote outnamea quote ' /TYPE=TAB /FIELDNAMES.' crlf];
    status=fwrite(fids,ss,'uchar');

    if exist('valuelabel','var')
        vs=show_valuelabel(valuelabel);
        ss=['ADD VALUE LABELS ' crlf vs '.' crlf];
        status=fwrite(fids,ss,'uchar');
    end;

    %ADD VALUE LABELS vowel 37 '/%/' 69 '/E/' 73 '/I/' 89 '/Y/'
    %	/cons 75 '/K/' 80 '/P/' 84 '/T/'
    %	/tense 43 'Tense'.

    ss=['DOCUMENT' crlf namestr];
    status=fwrite(fids,ss,'uchar');


    nvar=size(dbig,1);
    ss='VARIABLE LABELS';
    keyboard;
    for ivar=1:nvar
        us=deblank(unit(ivar,:));
        if ~isempty(us) us=[' (' us ')']; end;
        ss=[ss ' ' deblank(dvar(ivar,:)) ' ' quote deblank(dbig(ivar,:)) us quote];
    end;
    ss=[ss '.' crlf];
    status=fwrite(fids,ss,'uchar');

    ss=['FILE LABEL ' briefcomment '.' crlf];

    status=fwrite(fids,ss,'uchar');

    ss=['SAVE OUTFILE=' quote outname '.sav' quote '.' crlf];
    status=fwrite(fids,ss,'uchar');





end;		%file loop

status=fclose(fids);
