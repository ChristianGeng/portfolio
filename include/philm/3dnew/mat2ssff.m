function mat2ssff(inbase, outbase, outext, iispec)
% MAT2SSFF Convert Phil Hoole's matlab data storage files to ssff (simple signal file
% format http://emu.sourceforge.net/manual/chap.ssff.html)
% function mat2ssff(inbase, outbase, outext, iispec)
% mat2ssff: Version 01.02.2013
% 
% Arguments:
%        inbase: basepath of input, i.e. common part of all input files
%        outbase: basepath of output, i.e. common part of all output
%        files
%        outext: output extension, works only for 2-dimensional data.
%        For 3-dimensional data it will be determined by the 2. or 3.
%        dimension's names
%        iispec: further specifies which input files to process
%
% Examples:
%        input files are "my_very_long_file_name_of_subject_peter_0001.mat ...
%        my_very_long_file_name_of_subject_peter_0132.mat" in directory "/matfiles"
%        Desired output: peter001.trx ... peter132.trx (skip one leading
%        zero) in directory /ssfffiles:rows
%        mat2ssff('/matfiles/my_very_long_file_name_of_subject_peter_0',...
%                 '/ssfffiles/peter','trx',1:132);
%
%   Updates
%       9.2012 replace Lasse's external function rows with subfunction
%       getrows.
%       function added to subversions repository

%       2.2013 removed superfluous end at end of main function

ssffsize=str2mat('CHAR', 'BYTE', 'SHORT', 'LONG', 'FLOAT', ...
                 'DOUBLE');
matsize =str2mat('uchar', 'int8', 'int16', 'int32', 'float32', ...
                 'float64');
sweepl=length(int2str(max(iispec)));
format=sprintf('%%0%ii',sweepl);
dir=fileparts(outbase);
if ~(exist(dir,'dir'))
    mkdir(dir);
end;
infile=[inbase num2str(iispec(1),format) '.mat'];
disp('');
disp(['Opening reference file ' infile]);
disp('Assuming specifications match *all* files!');
disp('');
load(infile);
ty=-11;
domode=[];
if exist('dimension','var')
    nr=size(dimension.descriptor);
    nr=nr(1);
    if (nr>3)
        disp('Data has too many dimensions. FIX ME. Exiting...');
        return;
    elseif (nr==3)
        disp('Data is 3-dimensional:');
        disp(size(data));
        disp([deblank(dimension.descriptor(1,:)) ' ' ...
              deblank(dimension.descriptor(2,:)) ' ' ...
              deblank(dimension.descriptor(3,:))]);
        while ((ty>3) || (ty<2))
            if (ty~=-11)
                disp('');
                disp(['Wrong # for dimension (' int2str(ty) '), try ' ...
                                    'again...']);
            end;
            disp('');
            disp(['One of ' deblank( dimension.descriptor(2,:)) '(2) or ' ...
                  deblank(dimension.descriptor(3,:)) '(3)']);
            disp('will be saved as an SSFF file, the other will be');
            disp('saved as tracks of the file');
            ty=input('Choose dimension for files: ');
        end;
        if ty==3
            tr=2;
        else
            tr=3;
        end;
        disp('');
        disp('These possible file types are available:');
        for i=1:length(dimension.axis{ty})
            disp([dimension.axis{ty}(i,:) ' (' int2str(i) ')']);
        end;
        sizes=zeros(1,length(dimension.axis{ty}));
        types=input('Enter list of types: ');
        ntypes=length(types);
        disp('');
        haveTypre=0;
        while (~haveTypre)
            typre=input(['Enter a list of type prefixes (for ssff ' ...
                         'tracks): ']);
            nsize = size(typre);
            if (nsize(1)==length(types))
                haveTypre=1;
            end;
            disp('');
        end;
        
        disp('These tracks are available:');
        for i=1:length(dimension.axis{tr})
            disp([dimension.axis{tr}(i,:) ' (' int2str(i) ')']);
        end;
        tracks=input('Enter list of tracks: ');
        disp('');
        disp('The storage size must be set for each track:');
        for i=1:length(ssffsize)
            disp([ssffsize(i,:) ' (' int2str(i) ')']);
        end;
        disp('');
        for i=tracks
            sizes(i)=input(['Enter storage for ' dimension.axis{tr}(i,:) ...
                            ': ']);
        end;
        ntracks=length(tracks);
        comment=[];
        %create ssff header
        for TY=1:length(types)
            hdr{TY}=sprintf('%s\n', 'SSFF -- (c) SHLRC');
            hdr{TY}=sprintf('%s%s\n', hdr{TY}, 'Machine IBM-PC');
            hdr{TY}=sprintf('%s%s %i\n', hdr{TY}, 'Record_Freq', samplerate);
            hdr{TY}=sprintf('%s%s\n', hdr{TY}, 'Start_Time 0');
            %hdr{TY}=sprintf('%s%s %s\n', hdr{TY}, 'Comment', comment);
            for i=tracks
            hdr{TY}=sprintf('%s%s %s %s %i\n', hdr{TY}, 'Column', ...
                        [deblank(typre(TY,:)) '_' dimension.axis{tr}(i,:)], ...
                        deblank(ssffsize(sizes(i),:)), 1);
            end;
            hdr{TY}=sprintf('%s%s\n', hdr{TY}, '-----------------');
        
            domode=3;
            dimdim = dimension;
        end;
    elseif (nr==2)
        disp('Data is 2-dimensional:');
        disp(size(data));
        disp([deblank(dimension.descriptor(1,:)) ' ' ...
              deblank(dimension.descriptor(2,:))]);
        disp(['Will save ' deblank(dimension.descriptor(2,:)) [' as ' ...
                            'tracks.']]);
        tr=2;
        disp('');
        disp('These tracks are available:');
        for i=1:length(dimension.axis{tr})
            disp([dimension.axis{tr}(i,:) ' (' int2str(i) ')']);
        end;
        tracks=input('Enter list of tracks: ');
        ntracks=length(tracks);
        comment=[];
        %create ssff header
        hdr=sprintf('%s\n', 'SSFF -- (c) SHLRC');
        hdr=sprintf('%s%s\n', hdr, 'Machine IBM-PC');
        hdr=sprintf('%s%s %i\n', hdr, 'Record_Freq', samplerate);
        hdr=sprintf('%s%s\n', hdr, 'Start_Time 0');
        %hdr=sprintf('%s%s %s\n', hdr, 'Comment', comment);
        for i=tracks
            hdr=sprintf('%s%s %s %s %i\n', hdr, 'Column', ...
                        dimension.axis{tr}(i,:),'DOUBLE', 1);
        end;
        domode=2;
    end;
elseif (exist('descriptor', 'var'))
    if (length(size(data))~=2)
        disp('Unsupported dimensions of data. Exiting...');
        return;
    else
        sizes=zeros(1,getrows(descriptor));
        disp('Data is 2-dimensional:');
        disp(size(data));
        tr=2;
        disp('');
        disp('These tracks are available:');
        for i=1:getrows(descriptor)
            disp([descriptor(i,:) ' (' int2str(i) ')']);
        end;
        tracks=input('Enter list of tracks: ');
        ntracks=length(tracks);
        comment='';
        disp('');
        disp('The storage size must be set for each track:');
        for i=1:length(ssffsize)
            disp([ssffsize(i,:) ' (' int2str(i) ')']);
        end;
        disp('');
        for i=tracks
            sizes(i)=input(['Enter storage for ' descriptor(i,:) ...
                            ': ']);
        end;
        %create ssff header
        disp('Creating header');
        hdr=sprintf('%s\n', 'SSFF -- (c) SHLRC');
        hdr=sprintf('%s%s\n', hdr, 'Machine IBM-PC');
        hdr=sprintf('%s%s %i\n', hdr, 'Record_Freq', samplerate);
        hdr=sprintf('%s%s\n', hdr, 'Start_Time 0');
        %hdr=sprintf('%s%s %s\n', hdr, 'Comment', comment);
        for i=tracks
            hdr=sprintf('%s%s %s %s %i\n', hdr, 'Column', ...
                        descriptor(i,:), ...
                        deblank(ssffsize(sizes(i),:)), 1);
        end;
        hdr=sprintf('%s%s\n', hdr, '-----------------');
        domode=2;
    end;
% $$$     if length
end;

%%main loop
lftab=sprintf('\n\t%s','');
for ii=iispec
    disp('Entering main loop');
    disp('');
    sweep=num2str(ii,format);
    infile=[inbase sweep '.mat'];
    outfile=[outbase sweep];
    disp([infile ' ->' lftab outfile]);
    try
        load(infile);
    catch
        disp(['Unable to open infile: ' infile ', skipping...']);
    end;
    if (domode==3)
        
        if tr>ty
            data=permute(data,[1 3 2]);
        end;
        hc=0;
        for h=types
            hc=hc+1;
            ext = deblank(dimdim.axis{ty}(h,:));
            of = [outfile '.' ext];
            fid=fopen(of,'w');
            
            if fid==-1
                disp(['Unable to open outfile: ' of ', skipping...']);
                return;
            end;
            %write hdr
            fprintf(fid, '%s', hdr{hc});
            %write data
            %keyboard
            %disp(['h is' h]);
            for i=1:getrows(data)
                for j=tracks
                    fwrite(fid, data(i,j,h), deblank(matsize(sizes(j),:)), ...
                           0, 'ieee-le');
                end;
            end;
            fclose(fid);
        end;
    elseif(domode==2)
        %        keyboard
        of = [outfile '.' outext];
        fid=fopen(of,'w');
        fprintf(fid, '%s', hdr);
        if (min(sizes)==max(sizes))
            fwrite(fid,data',deblank(matsize(sizes(1),:)), 0, 'ieee-le');
        else
            for i=1:length(data)
                for j=tracks
                    fwrite(fid, data(i,j), deblank(matsize(sizes(j),:)), ...
                           0, 'ieee-le');
                end;
            end;
        end;
        fclose(fid);
    else
        disp('Forget it!');
    end;
    
    %    keyboard
    %fclose(fid);
    
    disp('Success');
end;

function nrow=getrows(x)
nrow=size(x,1);
