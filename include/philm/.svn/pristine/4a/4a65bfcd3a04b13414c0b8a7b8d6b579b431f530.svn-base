function makepcscaniilogfile(filename,binformat,totalsamples,H,C,chanlist,chinputrange,scalefactor);
% MAKEPCSCANIILOGFILE Make log file compatible with pcscan ii data
% function makepcscaniilogfile(filename,binformat,totalsamples,H,C,chanlist,chinputrange,scalefactor);
% makepcscaniilogfile: Version 11.11.07
%
%   Description
%       Intended to be used by getxmx so that int16 binary output files can
%       be read and displayed by pcscan_ii
%       Main difference from a normal pcscan_ii file is that the format
%       field will indicate whether the file contains single rather than
%       integer data. Such files will not be displayable in pcscan_ii but
%       can be processed by upgraded versions of getlsbc_ii_f and
%       dat2mat_ii_f (which were originally designed to handle pcscan_ii
%       bin files

logfilename=[filename '.log'];
fid=fopen(logfilename,'w');
mytab=char(9);
nchan=length(chanlist);
ss=['// Sony PCscan II data log file' crlf  '// Warning:  Modify only channel information and keep others unchanged' crlf '//' crlf];

sss=ss;

ss=['VERSION' mytab '3.0' crlf]; sss=[sss ss];
ss=['DATA_FILE' mytab [filename '.bin'] crlf]; sss=[sss ss];
%If the format is 'int16' convert to the string that is used by genuine
%pcscan_ii files
binformat=strrep(binformat,'int16','0 INTEL-86');
ss=['FORMAT' mytab binformat crlf]; sss=[sss ss];
ss=['VOLUME_CH' mytab int2str(totalsamples) crlf]; sss=[sss ss];
samplerate=C{chanlist(1)}.samplerate;
ss=['FILE_INTVL_CH' mytab num2str(1/samplerate,10) ' s' crlf]; sss=[sss ss];
ss=['REMARKS' mytab 'Export of xmx file' crlf]; sss=[sss ss];
ss=['        Eng. value=[16-bit data]*[expression " *(slope/bit)+(offset in eng.unit) "]' crlf];sss=[sss ss];

for ii=1:nchan
    ichan=chanlist(ii);
    ss=['CHANNEL' mytab int2str0(ii,2) ', "' C{ichan}.channeltitle '", ' C{ichan}.engunits ', *' num2str(1/scalefactor(ii),'%2.10f') '+0.00000000' crlf];
    sss=[sss ss];
end;

ss=['//' crlf '// Info. at Data Copy' crlf '//' crlf]; sss=[sss ss];

%may not be appropriate, but perhaps it doens't matter
ss=['TAPE_BC_MODE' mytab int2str(nchan) crlf]; sss=[sss ss];

%pcscanii actually ssems to use file_intvl_ch
ss=['TAPE_SRATE_CH' mytab int2str(samplerate) ' original-samples/s/channel' crlf]; sss=[sss ss];

ss=['DECIMATION' mytab '0' crlf]; sss=[sss ss];
ss=['TAPE_SPEED' mytab '1' crlf]; sss=[sss ss];
ss=['ID' mytab '000' crlf]; sss=[sss ss];
%dummy. upgrade?
mytime=H.creationdatetime;
ss=['DATE_TIME' mytab int2str(mytime) crlf]; sss=[sss ss];
%ss=['DATE_TIME' mytab '070707 120000' crlf]; sss=[sss ss];
ss=['CNT_ADDRESS' mytab '+00000' crlf]; sss=[sss ss];

% normal entry: SONY#PC208Ax
ss=['MEMO' mytab 'SONY#EX' crlf]; sss=[sss ss];
ss=['TRIG_MODE' mytab '0 ON-THE-FLY' crlf]; sss=[sss ss];
for ii=1:nchan
ss=['INPUT_RANGE' mytab 'CH-' int2str0(ii,2) ', ' num2str(chinputrange(ii)) 'V' crlf]; sss=[sss ss];
    
end;

fwrite(fid,sss,'uchar');
fclose(fid);
