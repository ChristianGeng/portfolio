function getxmx(myfile,chanlist,outsuffix,binaryformat,supplementaryoutput);
% GETXMX Get data from Sony EX file
% function getxmx(myfile,chanlist,outsuffix,binaryformat,supplementaryoutput);
% getxmx: Version 20.02.08
%
%   Description
%       Read sony xmx format files and store in various formats for further processing.
%       If called with only one input argument (myfile), then the xmx
%       header information is stored in a mat file,
%       but no signal data is output (this can be used a quick way of checking on the integrity of the file)      
%       If there are more than 1 events in the xmx file these will be stored in separate
%       files with '_' and four-digit event number added to the output filename.
%       (Currently, I believe this only happens of triggering functions are
%       used during data acquisition.)
%
%   Syntax
%       myfile: Input filename, without extension (must be xmx)
%       chanlist: Chosen channels must have same sample rate
%           If chanlist is missing or empty (or has mixed sample rates), only the header structures will be stored
%           in files named myfile'_info'. (This info file is also stored
%           when signal output is stored.)
%           In addition, a second version of the info file is stored when a
%           binary output file is created. It has the name of the binary
%           file with '_info' appended. The only difference to the first
%           info file is that the block header information is omitted. This
%           makes the file much smaller, and thus more suitable for being
%           included by dat2mat_ii_fx in all individual mat files of signal
%           data.
%       outsuffix: Optional. Default to empty. Appended to input file name to form output file
%           name. The input argument binaryformat is additionally appended to
%           the name of the binary output file
%       binaryformat: Optional. Default to single. Data format to use for the binary output file
%           Main choices are either 'int16' or 'single'
%           Use 'int16' if the binary file needs to be readable by the
%           PCSCANII program. This is probably also the most convenient
%           format if the file is to be processed by getlsbc_ii_f to
%           extract synchronization impulses.
%           Use 'single' if signal data is subsequently to be extracted by
%           dat2mat_ii_f. This ensures full resolution if the Sony EX is
%           operated in 24bit mode, and ensures no problems with scaling of
%           the data, since the xmx file also stores signal data as scaled
%           single values (and not as raw integer values from the ADC).
%           A pcscan_ii logfile is also generated to accompany the bin
%           file (see makepcscaniilogfile). This is fully compatible with pcscan_ii if the output
%           format is 'int16'. If the output format is 'single' then the
%           bin file cannot be displayed in pcscan_ii but getlsbc_ii_f and
%           dat2mat_ii_fx will use the log file to determine the precision
%           of the bin file, and will handle single-precision bin files
%           correctly.
%           Further note: Supplementary output (see below) is only possible if
%           binaryformat is 'single'.
%           This is because supplementary output to mat file or wav file (or
%           as plot) involves first creating the binary file and then
%           reading it back in, so this again guarantees full resolution
%           and correct scaling.
%       supplementaryoutput (optional): A string matrix containing any combination of the
%           strings 'mat', 'wav', or 'plot'
%           This is intended to give quick access to the data from simple xmx
%           files where more complicated extraction procedures using
%           getlsbc_ii_f and dat2mat_ii_fx are not required.
%           Note that very long xmx files may cause memory problems if directly
%           output to mat files in this way, whereas there are no restrictions
%           for conversion of xmx files to binary files.
%           (The same applies to creation of wav files; this is also not
%           performed very memory-efficiently. To create very long wav files it
%           may be better to use some other utility program to convert from
%           binary to wav (this can be done by PCScanII, for example).
%
%   See Also
%       GETXMXGENHEAD, GETXMXEVENTHEAD, GETXMXCHANHEAD, GETXMXDATAHEAD
%           (Functions for getting the various header structures in the xmx file)
%       MAKEPCSCANIILOGFILE 
%       GETLSBC_II_F Extract synchronization pulses from pcscanii-style file
%       DAT2MAT_II_F Extract series of trials from pcscanii-style file (old
%       version
%       DAT2MAT_II_FX New Version; handles floating point data; calibration
%       implemented
%
%   Updates
%       1.08 Adjust channel name for compatibility with mtnew syntax
%       2.08 Store two versions of the info file when binary output is
%       generated


functionname='GETXMX: Version 20.02.08';

doplot=0;       %flag for timewave plots
matout=0;       %mat output
wavout=0;       %wav output

if nargin<4 binaryformat='single'; end;



%a binary file is always created (except when only info is output); this flag is only reset if there is any
%problem with writing data to the binary file
binout=1;       %binary output activated



xmxfile=[myfile '.xmx'];

%convert input range setting index in the channel header to input range in
%volts (needed for scaling for integer output)
inputrangelist=zeros(1,18);
inputrangelist(11:18)=[0.1 0.2 0.5 1 2 5 10 20];

%binary output data will be scaled if format is in this list
%If scaling is performed, then no supplementary output (plot, mat, wav) is
%possible
headroomfactor=0.75;
integerformatlist=str2mat('int16','int8');
integeroutputrange=[32768 128]*headroomfactor;

binaryformat=lower(binaryformat);


scaleoutflag=0;

vv=strmatch(binaryformat,integerformatlist);
if length(vv)==1
    scaleoutflag=1;
    fsdout=integeroutputrange(vv);
end;

if ~scaleoutflag
    if nargin > 4
        supplementaryoutput=lower(supplementaryoutput);
        vv=strmatch('mat',supplementaryoutput);
        if ~isempty(vv) matout=1; end;
        vv=strmatch('wav',supplementaryoutput);
        if ~isempty(vv) wavout=1; end;
        vv=strmatch('plot',supplementaryoutput);
        if ~isempty(vv) doplot=1; end;
    end;
end;






dataprecision='single';     %precision of data in xmx file
databytes=4;

eventdig=4; %number of digits to use in event numbering (choice is really arbitrary)



chan2store=[];
if nargin>1 chan2store=chanlist; end;

ok2store=0;     %true > store signal data (and info); otherwise store info  only

suffix2use='';
if nargin>2 suffix2use=outsuffix; end;

newcomment=['XMX file : ' myfile crlf 'Channel list : ' int2str(chan2store) crlf];
newcomment=[newcomment 'Binary format : ' binaryformat crlf];
%also note supplementary output??



fid=fopen(xmxfile,'r');

fseek(fid,0,'eof');
filelenbyte=ftell(fid);
fseek(fid,0,'bof');

%disp(['File length in bytes: ' int2str(filelenbyte)]);

H=getxmxgenhead(fid);

nchan=H.numchan;
C=getxmxchanhead(fid,H.offsetchanhead,nchan);

disp('Generic header');
disp(H);

chanspec=ones(1,nchan);
sflist=ones(1,nchan)*NaN;

disp('Channel header');

%set up for all channels here????
descriptor=cell(nchan,1);
unit=cell(nchan,1);
chinputrange=ones(1,nchan);
scalefactor=ones(1,nchan);

for ichan=1:nchan
    CC=C{ichan};
    disp(C{ichan});
    chanspec(ichan)=CC.mgnum*100 + CC.imnum*10 + CC.imchannum;
    sflist(ichan)=CC.samplerate;    
    %1.08 channeltitle includes chanspec in the form '1.1.1 - '
    %This is awkward to handle in mtnew, so rearrange here
    
    tmptitle=C{ichan}.channeltitle;
    tmpi=findstr(' - ',tmptitle);
    tmptitle=tmptitle((tmpi+3):end);
    tmptitle=[tmptitle '_' int2str(chanspec(ichan))];
    C{ichan}.channeltitle=tmptitle;
    descriptor{ichan}=C{ichan}.channeltitle;
    unit{ichan}=C{ichan}.engunits;
    tmpi=C{ichan}.inputrangeindex;
    chinputrange(ichan)=inputrangelist(tmpi);
    if scaleoutflag scalefactor(ichan)=fsdout/chinputrange(ichan); end;
    
    
end;

disp('Chan specs and samplerates');
disp(chanspec);
disp(sflist);

%enable signal storage if all samplerates are same (and channel numbers are
%legal
if ~isempty(chan2store)
    if all(ismember(chan2store,1:nchan))
        sflistout=sflist(chan2store);
        if all(sflistout==sflistout(1))
            ok2store=1;
            nchanout=length(chan2store);
            samplerate=sflistout(1);
        end;
    end;
end;

if ~ok2store
    disp('Storing info, not signal data');
else
    %reduce lists (execept chanspec) to the output channels
    descriptor=descriptor(chan2store);
    unit=unit(chan2store);
    chinputrange=chinputrange(chan2store);
    scalefactor=scalefactor(chan2store);
    
    
end;



nevent=H.totalevents;


eventoffset=H.offseteventhead;

for ievent=1:nevent
    
    eventstr=['_' int2str0(ievent,eventdig)];
    if nevent==1 eventstr=''; end;
    outfile=[myfile suffix2use eventstr];
    binfile=[myfile suffix2use '_' binaryformat eventstr];
    
    
    [E,B,chanchk,nblist,byteslist,offsetlist,buffernumlist,firstlastblist]=getxmxeventhead(fid,eventoffset,chanspec,filelenbyte);
    
    disp(['Event header for event ' int2str(ievent) ' of ' int2str(nevent)]);
    disp(E);
    
    eventoffset=E.offsetnexteventhead;
    
    tmpcomment=[newcomment 'Event number: ' int2str(ievent) crlf];
    comment=framecomment(tmpcomment,functionname);
    if ok2store
        
        [fido,mymessage]=fopen([binfile  '.bin'],'w');
        if fido<2
            disp('Unable to open binary output file');
            disp(mymessage);
            disp('Unable to continue');
            return;
            
        end;
        
        %    disp('read after return');
        %    keyboard;
        
        %to take care of complicated cases where channels do not have exactly the
        %same buffers, first set up a list of buffers guaranteed to include those
        %available for all channels, and use this to order the data available
        %for each channel
        %main possibility is that some channels may then have NaNs at the beginning
        %or the end of the complete data buffer
        
        basebuf=min(firstlastblist(1,:));
        bufvec=basebuf:max(firstlastblist(2,:));
        nbuf=length(bufvec);
        
        
        disp('Reading data from XMX file and writing to BIN file');        
        for ibuf=bufvec
            
            %            disp(['Block ' int2str(ibuf)]);        
            for ichan=1:nchanout
                showchan=chan2store(ichan);
                mybytes=byteslist(showchan);
                myn=mybytes/databytes;
                
                %this assumes that channels with the same sample rate must have the same
                %amount of data
                
                if ichan==1
                    data=repmat(single(NaN),[myn nchanout]);
                    
                    %set up scaling matrix
                    if ibuf==bufvec(1)
                        if scaleoutflag
                            Mscale=repmat(scalefactor,[myn 1]);
                        end;
                    end;
                end;
                
                offb=offsetlist{showchan};
                buffn=buffernumlist{showchan};
                
                vv=find(buffn==ibuf);
                if length(vv)==1
                    
                    
                    %                    disp(['Channel ' int2str(showchan)]);
                    
                    fseek(fid,offb(vv),'bof');
                    %note: data is single, regardless of whether digitized at 16 or 24 bit
                    data(:,ichan)=fread(fid,myn,['*' dataprecision]);
                    
                end;        %buffer present for this channel
            end;        %channel loop
            
            
            %data may need scaling if precision is not single
            
            if scaleoutflag
                data=double(data).*Mscale;
            end;
            
            %note: transpose data for output; gives a mulitplexed arrangengement as in PCScanII 
            fstatus=fwrite(fido,data',binaryformat);
            if fstatus~=myn*nchanout
                disp('Unable to write binary output file');
                binout=0;
            end;
            
        end;        %block loop
        
        totalsamples=length(bufvec)*myn;
        
        fclose(fido);        
        disp('BIN file created');
        
        %write log file for compatibility with PCScanII
        makepcscaniilogfile(binfile,binaryformat,totalsamples,H,C,chan2store,chinputrange,scalefactor);        
        
        
        if any([doplot matout wavout])
            [fido,mymessage]=fopen([binfile  '.bin'],'r');
            if fido<2
                disp('Unable to re-open binary output file for reading');
                disp(mymessage);
                disp('Unable to continue');
                return;
                
            end;
            
            data=fread(fido,[nchanout inf],['*' binaryformat]);
            fclose(fido);
            data=data';
            
            %            keyboard;
            
            if doplot
                figure;
                mytime=((0:(size(data,1)-1))/samplerate)';
                
                for ichan=1:nchanout
                    hax=subplot(nchanout,1,ichan);
                    
                    plot(mytime,data(:,ichan));
                    %replace with channel name
                    ylabel(descriptor{ichan});
                    
                    if ichan==1 title(outfile,'interpreter','none'); end;
                    if ichan==nchanout xlabel('Time (s)','interpreter','none'); end;
                end;
                
                
            end;        %doplot
            
            %write to mat file here
            if matout
                
                descriptor=char(descriptor);
                unit=char(unit);
                
                save(outfile,'data','descriptor','unit','samplerate','private','comment');
                
            end;
            if wavout
                %rough and ready wav output
                
                data=double(data);
                for ii=1:nchanout data(:,ii)=(data(:,ii)./chinputrange(ii))*headroomfactor; end;
                disp('writing wav file');
                wavwrite(data,samplerate,16,outfile);
            end;
            
        end;        %doplot | matout | wavout
        
    end  %ok2store
    %save info
    
    private.xmx.genericheader=H;
    private.xmx.eventheader=E;
    private.xmx.channelheader=C;
    
    if ok2store
        save([binfile '_info'],'private','comment');
    end;
    
    private.xmx.blockheader=B;
    
    save([outfile '_info'],'private','comment');
    
    
    
    
    
end;        %event loop

fclose(fid);
