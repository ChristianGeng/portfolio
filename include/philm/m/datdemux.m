function datdemux
% DATDEMUX Split multichannel sony DAT files, store in STF or raw format
% function datdemux
% datdemux: Version 27.8.97 for Siemens1000
%
% Description
%   based on splitphx; also similar to mat2stf
%   Similar to dat2stf but store individual files per trial
%   controlled by input cut file (MAT file)
%   e.g derived from processing of LSB signal
%   This cut file should include labels and comment to be copied to output cut file
%
% See also
% getlsb, timadj, emmaproa, mat2stf

%   Unlike dat2stf trials can be unlimited length, but end
%   of trial is not yet processed accurately
%   This version also extracts lsb information from laryngo pulse signal
%=======================================
%
    functionname='datemux: Version 27.8.97 for Siemens1000';
    philcom(0);
    %all these constants could/should be loaded from a script file
    %constants, flag values for abart
    [stcfid,stccifdo,stcnt,stccdo,stcio,stiffcomlength]=stcomdef;
    [abint,abnoint,abscalar,abnoscalar]=abartdef;

    stiffgo;
    %processing details will be appended to comment
    namestr=['<Start of Comment> ' functionname crlf];

    diary datdemux.log

      %cut file to control extraction of sweeps from long input file
      %should be set up so that all times are an integer multiple of the
      %sample interval of the signal with the lowest samplerate
      %This could either be separately acquired data, of signals resulting
      %after downsampling of the DAT data
      %
      %The labels in this cut file will be copied to the output cut file
      %These are included automatically by timadj

      timfile=philinp('MAT file with input cuts: ');
      timdat=mymatin(timfile,'cutdata');
      totalcuts=size(timdat,1);
      timlabel=mymatin(timfile,'cutlabel');
      timlabel=setstr(timlabel);
      externalcomment=mymatin(timfile,'comment','');

      maxlsb=5000;



      namestr=[namestr 'Control cut file: ' timfile crlf];

      fidin=0;
      while fidin<=2
            infile=philinp('Multiplexed Sony input file (without extension - must be .BIN) : ');
            [fidin,message]=fopen([infile '.bin'],'r');
            if ~isempty(message) disp(message); end
      end
      namestr=[namestr 'Sony file: ' infile crlf];
      %bytes per sample for input file
      datbyt=2;
      indatatype='short';
      %use STIFF output format
      [outdatatype,forcode,forlength,forstr]=stiffdtd('short');
      if forcode==0
         disp ('Program error, for output data type');
      end;

      sonycomment=readtxtf([infile '.log']);
      disp(sonycomment);
      %quite a bit of the following info could be obtained from the DAT log file

      maxchan=8;
      nchanin=abart ('Number of channels in input file',4,1,maxchan,abint,abscalar);
      chanlist=abart ('Channels to extract (vector)',1,1,nchanin,abint,abnoscalar);
      nchan=max(size(chanlist));
      %This is potentially confusing!!
      chanrange=abart ('Channel range settings of extracted channels (vector)',1,0.5,20,abnoint,abnoscalar);
      if length(chanrange)~=nchan
         disp ('Bad vector length');
         return;
      end;

      sfbase=96000;
      tapespeed=abart ('Speed: Single (1), Double (2)',1,1,2,abint,abscalar);
      %sfbase is overall data rate
      %sfchannel is samplerate of each channel in the input file
      %sf is a vector giving output sample rate for each channel
      %i.e will be different from sfchannel if downsampling is performed
      sfbase=sfbase*tapespeed;
      sfchannel=sfbase./nchanin;

      sf=ones(1,nchan)*sfchannel;
      framebyt=datbyt*nchanin;

      %adjust input time data to be integer multiples of channel sample interval
      timdat=round(timdat.*sfchannel)./sfchannel;



      %get decimation factors ......
      %disabled for this version!!
      idown=ones(1,nchan);

      namestr=[namestr 'Total input channels: ' int2str(nchanin) crlf];
      namestr=[namestr 'Channels extracted: ' num2stre(chanlist) crlf];
      namestr=[namestr 'Tape speed: ' int2str(tapespeed) crlf];

      namestr=[namestr 'Range settings: ' int2str(chanrange) crlf];


      %ev. include decimation........

      %because of headroom (2.5 dB) nominal fsd is at this value, not at 2**15
      fsdval=24576;
      scalefac=chanrange./fsdval;
      %
      %------------------------------

      outpath=philinp('Common part of output signal file names: ');
      outnamerow=philinp('File name list (blank separated, no extension) : ');
      descrow=philinp('Descriptor list (blank separated) : ');
      unitrow=philinp('Unit list (blank separated) : ');


      namestr=[namestr 'Output file path: ' outpath crlf];
      namestr=[namestr 'Output file names: ' outnamerow crlf];

      reclist=rv2strm(outnamerow);
      desclist=rv2strm(descrow);
      unitlist=rv2strm(unitrow);

      namestr=[namestr 'Comment from control cut file===========' crlf];
      namestr=[namestr externalcomment crlf];
  namestr=[namestr '<End of Comment> ' functionname crlf];
  comment=namestr;
      %still need to allow scale factors for conversion to actual units







      %================================
      %set up tag structure
      %--------------------------------
      %set up list of tag names
      tagnamelist=str2mat('tagnames','data','samplerate','comment','descriptor','unit','scalefactor');
      tagnamelist=str2mat(tagnamelist,'signalmax','signalmin','signalmean');
      tagnamelist=str2mat(tagnamelist,'sweepstart','sweepend','sweeplabel');
      %check in appropriate order????, e.g get tag code number and sort by code
      % at end, check all intended tags have actually been written
      ntags=size(tagnamelist,1);


      %====================================================
      % Main loop, thru cuts
      % for each cut, open individual output files for each channel
      %read thru data in chunks
      % reading complete multiplexed data
      %seach for lsb data, then demux. i.e lsb positions determined
      % at maximum resolution . lsb data also stored in individual mat file for each cut

      %===================================================
      for loop=1:totalcuts
          timbegin=timdat(loop,1);timend=timdat(loop,2);
          timlength=timend-timbegin;
          disp (['cut#/label: '  int2str(loop) ' ' timlabel(loop,:)]);
          disp (['Times: ' num2str(timbegin) ' ' num2str(timend)]);
          %position input file at correct offset
          filepos=round(timbegin*sfchannel)*framebyt;
          disp (['File byte offset: ' int2str(filepos)]);
%         filepos=filepos+chanoffb;
          datlen=round(timlength*sfchannel);
          status=fseek(fidin,filepos,'bof');
          if status~=0 disp ('!Bad seek (input)!'); end

          %from control cut file for each trial
          sweepstart=timbegin;
          sweepend=timend;
          sweeplabel=deblank(timlabel(loop,:));
          stiffcom=zeros(nchan,stiffcomlength);

%         open output files , variant for stf output
          for ido=1:nchan
              %name for raw output
              %fido(ido)=fopen([outpath deblank(reclist(ido,:)  '.' int2str0(loop,3)],'w');

              %????adjust name if not stf

              %if stf format watch out for filename length!!
              stiffcx=stiffcom(ido,:);  %get stiffcom for current channel
              fid=0;
              filename=[outpath deblank(reclist(ido,:)) int2str0(loop,3) '.stf'];
              disp (['Input Channel ' int2str(chanlist(ido)) '. ' filename]);
              %open with w+ as tags are modified at end
              [fid,message]=fopen(filename,'w+');
              disp(['Fid: ' int2str(fid)]);
              if ~isempty(message)
                 disp(['Datdemux: File open error. ' message]);
                 return;
              end;
              %write as much of the ifd as possible
              %this provides the data offset to use for the actual sampled data
              %(some dummies will be filled in at end)
              stiffcx(stcfid)=fid;
              stiffcx=stwifh(stiffcx);
              stiffcx=stwnifd(stiffcx,ntags);
              stiffcx=stwtbn(stiffcx,'tagnames',tagnamelist,tagnamelist);
              stiffcx=stwtbn(stiffcx,'samplerate',tagnamelist,sf(ido));


              stiffcx=stwtbn(stiffcx,'comment',tagnamelist,comment);
              descriptor=deblank(desclist(ido,:));
              stiffcx=stwtbn(stiffcx,'descriptor',tagnamelist,descriptor);
              units=deblank(unitlist(ido,:));
              stiffcx=stwtbn(stiffcx,'unit',tagnamelist,units);
              stiffcx=stwtbn(stiffcx,'scalefactor',tagnamelist,scalefac(ido));
              %these will be updated at end
              %could also simply be done at end as they don't require external storage
              %i.e do not affect current data offset (as long as all storage is
              %single channel)
              %
              stiffcx=stwtbn(stiffcx,'signalmax',tagnamelist,chanrange(ido));
              stiffcx=stwtbn(stiffcx,'signalmin',tagnamelist,(-chanrange(ido)));
              stiffcx=stwtbn(stiffcx,'signalmean',tagnamelist,0);

              stiffcx=stwtbn(stiffcx,'sweepstart',tagnamelist,sweepstart);
              stiffcx=stwtbn(stiffcx,'sweepend',tagnamelist,sweepend);
              stiffcx=stwtbn(stiffcx,'sweeplabel',tagnamelist,sweeplabel);
              %update multichannel stiffcom
              stiffcom(ido,:)=stiffcx;


              %position output file
              stiffcdo=stiffcx(stccdo);
              status=fseek(fid,stiffcdo,'bof');
              %check io error

          end;

          nchunk=10000;

          %note: end of cut not yet handled accurately!!!!
          nibbles=floor((timlength*sfchannel)./nchunk);
          datlen=nchunk*nchanin;

          %for lsb handling
      	  lastdat=0;
          lsbindex=1;
          lsbdat=zeros(maxlsb,2);

	  nsamp=0;
		totalsamp=zeros(1,nchan);

          %for statistics
          chanmax=zeros(nibbles,nchan);
          chanmin=zeros(nibbles,nchan);
          chanmean=zeros(nibbles,nchan);


          for inib=1:nibbles


              %data in type as variable
              dat=fread(fidin,datlen,indatatype);
              iocode=showferr(fidin,'DAT file read');
              if length(dat) < datlen
                 %it may be better to break off here
                 disp ('Read incomplete??');
                 disp ([datlen length(dat)]');
                 dat(datlen)=0;
                 keyboard;
              end
	      ndat=datlen;
              %process lsb signal

              %lastdat must be copied, so signal can be differentiated
              %note: bitand requires positive integers
              %as we are reading proper data we can't simply read with 'ushort'
              bdat=[lastdat;bitand(dat+32768,1)]; %replace with bitand in Version 5
              lastdat=bdat(ndat+1);
              bdat=diff(bdat);
              %allow polarity reversal.....
              %look for +1 as onset, -1 as offset
              vv=find(abs(bdat)==1);

              if ~isempty(vv)
                 nv=length(vv);
                 disp (['No. of lsb changes : ' int2str(nv)]);
                 xpos=(vv+nsamp-1)./sfbase;     %position in seconds
                 idat=bdat(vv);
                 for ilsb=1:nv
                     if idat(ilsb) > 0
                        %onset
			if lsbdat(lsbindex,1) disp ('multiple onset!!');end;
                        lsbdat(lsbindex,1)=xpos(ilsb);
                     else
                         %offset
			 if lsbdat(lsbindex,1)==0 disp ('offset without onset!!');end;

                         lsbdat(lsbindex,2)=xpos(ilsb);
                         lsbindex=lsbindex+1;
                     end;            %lsb sign
                 end;                %lsb loop
              end;                   %vv not empty



              %process the data, esp. downsample

              dat=reshape(dat,nchanin,nchunk);
              %n.b not correct for nonadjacent channels
		dat=dat(1:nchan,:)';

              %do max/min etc
              chanmax(inib,:)=max(dat);
              chanmin(inib,:)=min(dat);
              chanmean(inib,:)=sum(dat);

              for ido=1:nchan
                  fid=stiffcom(ido,stcfid);
                  status=fwrite(fid,dat(:,ido),outdatatype);
                  iocode=showferr(fid,'Demux Write');
              end;
              %nsamp is total data  over all channels
              %totalsamp is total per channel
	      nsamp=nsamp+datlen;
		totalsamp=totalsamp+nchunk;

          end; %nibbles in current cut

          %work out max/min etc.

          chanmax=max(chanmax).*scalefac;
          chanmin=min(chanmin).*scalefac;
          chanmean=sum(chanmean);

          chanmean=(chanmean./totalsamp).*scalefac;

          %assume no. of samples same for all channels
          for ido=1:nchan
              stiffcx=stiffcom(ido,:);
              fid=stiffcx(stcfid);
              myoffset=stiffcx(stccdo);
              %write offset and totalsamp to data tag
              %temporary switch of diary file to log data offset and length
              format long;
              format compact;
              eval(['diary ' outpath '.log;']);
              [filename,perm,arch]=fopen(fid);
              disp([filename ' <' sweeplabel '>']);

              disp ([loop ido myoffset totalsamp(ido)]);
              diary datdemux.log;
              format short;
              format loose;

              stiffcx=stwtlo(stiffcx,'data',tagnamelist,totalsamp(ido),stiffcx(stccdo),outdatatype);
              stiffcx=stmtbn(stiffcx,'signalmax',tagnamelist,chanmax(ido));
              stiffcx=stmtbn(stiffcx,'signalmin',tagnamelist,chanmin(ido));
              stiffcx=stmtbn(stiffcx,'signalmean',tagnamelist,chanmean(ido));
              status=fclose(fid);
              if status~=0
                 disp(['Datdemux: Fclose unsuccessful on fid ' int2str(fid)]);
              end;
          end;
          %save synch impulses as individual cut matfile
	  lsbindex=lsbindex-1;
	  lsbdat=lsbdat(1:lsbindex,:);
          %arbitrary cut types!!!
          cutdata=[0 nsamp./sfbase 7];
          cutdata=[cutdata;[lsbdat ones(lsbindex,1)*3]];
          tmp1=lsbindex+1;
          cutlabel=blanks(tmp1*3);
          cutlabel=reshape(cutlabel,tmp1,3);
          if length(sweeplabel>2) cutlabel(1,1:3)=sweeplabel(1:3);end;

	  eval(['save ' outpath 'cut' int2str0(loop,3) ' cutdata cutlabel comment sweepstart sweepend sweeplabel;']);

      end                            %end of cut loop

      fclose(fidin);
      %
      fclose ('all');

      diary dodo
      diary off
