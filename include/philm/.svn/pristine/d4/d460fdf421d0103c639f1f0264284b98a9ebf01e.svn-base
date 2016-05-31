% EMMAPROA Script file to do emma processing
% emmaproa: Version 8.2.99
%
% Description
%   Intended to be usable with minor modifications for either MIT EMMA or Carstens AG100
%   Basic steps are:
%   1. Setup, initialization etc.
%   2. Loop thru input files
%      Read raw multiplexed data
%      demux, decimate/smooth if desired, compute basic stats
%      store data for each trial in a temporary MAT file (named emma_"trialnumber".mat)
%      this is then read in for the second pass thru the data
%      this should also simplify special purpose processing of
%      individual channels, e.g extra smoothing, notch filtering etc.
%      thus program can be terminated after stage 2, and restarted
%      skipping stage 2
%      Alternatively, after stage 2, the user can enter keyboard mode
%      this is mainly designed for interactive examination of the
%      statistics, e.g plot tilt values etc.
%      however at this stage a special purpose script operating on
%      the temporary mat file could be initiated
%   3. Set up data correction
%      This is based on the idea of using autokal or inaki plate
%      type measurements to correct x/y coordinates
%      the user can inspect the map of error vectors relative
%      to the actual data range of each sensor and decide on
%      what kind of data correction, if any, is required.
%      This also gives figures for the estimated final accuracy
%      of the data for each sensor
%   4. Process the data, loop thru temporary mat files
%      Processing steps are:
%                 1. Coordinate correction, based on results of stage 3
%                 2. Head correction, i.e translation to set origin at location
%                 of upper incisor sensor, with rotation to set line
%                 joining incisor and nose vertical (appropriate sensors
%                 must be specified at start of program). this is done point by
%                 point
%                 3. Translation and rotation to (normally) occlusal plane coordinates
%                 For this a small mat file must be specified at start of program
%                 containing two x/y pairs to define this mapping
%
%   ================================================
%  Input files:
%        1. Raw multiplexed data (either from NI board, or AG100)
%            trials assumed numbered in extension
%        2. Multiplex map (for NI board acquisition of MIT EMMA system)
%                  Currently ASCII with arrangement: channelno., gain code, samplerate divider
%                  could be incorporated in header of raw NI files in due course
%        3. Error map file (e.g produced by ag100cal)
%              Mat file , arranged sensornumber, true_x, true_y, measured_x, measured_y
%        4. Occlusal plane file
%                 mat file, 2 x/y pairs, i.e 2*2 matrix
%                 pair 1 gives desired coordinate system origin
%                 pair 2 defines rotation, i.e new x-axis orientation
%                 data will be rotated by the angle required to place
%                 pair 2 at 0 deg. relative to pair 1
%                 (actually, to the angle defined in variable "occlusal_orientation")
%        5. List of trial labels, e.g from PRT file
%        6. ASCII comment file
%   ==============================================
%   Output files:
%          1. Output format of processed data not yet decided
%	      as temporary measure use MAT files. (see mat2stf)
%	      ultimate solution will then require further specification
%	      from the user, e.g on sample rate, channels, scaling, etc.
%          2.	Mat file containing statistics of the processed data
%               pre- and post-processing. Name is output file name + 'sta'.
%               Apart from providing an overview of the ranges of the data
%	        this can be used as the basis for setting up the small mat
%	        file containing the occlusal plane coordinates
%	        Should also be useful for program testing etc.
%	        i.e checking the processing did what was intended.
%               However, note that input statistics are calculated after any
%               smoothing or decimation.
%               File contains:
%                    Means and standard deviations
%                    per trial (rows) and signal (columns), separately for input and output data.
%                    Total bad data per trial and sensor
%                    If two reference sensors were in use also contains statistics for the
%                    distance between the two sensors (ideally should be constant)
%          3.	Matlab's diary function is used to generate a log file
%          4.   CUT file  (new; 2.98)
%   ==================================================
%   Further specifications required from user:
%   Reference sensor(s)
%   Samplerate of input data
%   Decimation rate (defaults to 1);
%   Up to 2 MAT file containing coefficients of FIR filters (normally lowpass)
%      The first filter is applied to all channels. Optional but essential if decimation is performed
%      The second (supplementary) filter is currently applied only to the reference sensors.
%      It is applied after any decimation with the first filter has been carried out.
%      i.e it should be designed with respect to the samplerate AFTER decimation.
%      These MAT files must contain a variable 'data' with the coefficients
%      and should contain a string variable 'comment' with details of the design parameters
%   Temporary for AG100: number of sensors in input files
%   Sensor names e.g tback etc.
%   Number of first and last trial
%   ===================================================
%
% See also
%   ag100cal: Gets autokal output into shape required by this program
%   mat2stf: Get output of emmaproa into STF format
%

%Program is designed to run from command file
%see m files philcom.m, paramsub.m, philinp.m, abart.m
% (in phil\matlab\m)
% (other routines used from there: showferr (in getemmam))
%=========================================================
%
%set up command file input
philcom(0);

%initialization, prompt for various files
diaryname=philinp ('Diary file [emmaproc.log] * ');
if isempty (diaryname) diaryname='emmaproc.log'; end;
%eval error trap??
eval (['diary ' diaryname]);

namestr='';
functionname='emmaproa: Version 8.2.99';
disp (functionname);
namestr=[namestr '<Start of Comment> ' functionname crlf];
mitflag='N';    %switch mit vs. carstens system
unitstring='cm';
%is tilt scaling the same?
scaleinput=1./1000;
scaleoutput=1./scaleinput;      %temporary?????
%definition for missing data
%currently no special handling of missing data during processing, which could give some
%undesirable effects
%use tilt value of 0 to indicate missing data
missingvalue=0;
ndim=3;
maxsensor=10;
%definitions for coordinate transforms
%head correction is defined as placing ref2 vertically above ref1
ref_orientation=pi./2;
%occlusal plane sensors define x axis, i.e 0 degrees
occlusal_orientation=0;
%basic initialization for raw data
%actually only used in getemmam
indatabyte=2;
indatatype='short';
%if ag100 mm, 100??? or use cm internally??
%
%constants for use by abart
[abint,abnoint,abscalar,abnoscalar]=abartdef;



%no checks on file, cf. label file above
externalcomment='';
commentfile=philinp('Comment file name (optional): ');
if ~isempty(commentfile)
   externalcomment=readtxtf(commentfile);
end;

namestr=[namestr 'Comment file: ' commentfile ' ==========' crlf];
namestr=[namestr externalcomment crlf];
namestr=[namestr 'End of Comment ==========' crlf];


experiname=philinp('Purpose of this processing: ');

namestr=[namestr 'Purpose of this processing: ' experiname crlf];

%might be better as variable?????
tempname='emma_';  %temporary storage of trials as mat files
%coding of trial number currently fixed to 3 digits
trialnumlength=3;


namestr=[namestr 'Diary file: ' diaryname crlf];
%various definitions for transmitter location
%
%if ag100 ???
r_cen=27.5;
if mitflag=='N' r_cen=18.52717;end;      %32.090/2/cos(30)
pifac=2*pi./360;
transa=pifac*[0 120 240];
transx=r_cen*cos(transa);
transy=r_cen*sin(transa);
x_cen=0;y_cen=0;

%if ag100 subtract chin coordinates from others
%or change to origin at centre on input??
%this script does nidaq specific things
%sets up chandat, x_col etc. for demux routine
if mitflag=='Y'
   getnimux;
   
   sensorlist=find(x_col>0)
   nsensor=length(sensorlist);
   disp ([int2str(nsensor) ' emma sensors in multiplex map']);
   
end;

%if ag100 just get nsensor (and set up x_col etc.
if mitflag=='N'
   nsensor=abart ('Number of sensors',5,1,maxsensor,abint,abscalar);
   sensorlist=1:nsensor;
   x_col=1:nsensor;
   y_col=x_col+nsensor;
   t_col=y_col+nsensor;
end;

hisensor=max(sensorlist);

ncheck=-1;
while ~(ncheck==nsensor)
   sensorstring=philinp('Sensor names (separated by blank) : ');
   %convert to string matrix....
   descriptmp=rv2strm(sensorstring);
   ncheck=size(descriptmp,1);
end;

namestr=[namestr 'Sensor names: ' sensorstring crlf];
desclen=size(descriptmp,2);
descbuf=setstr(ones(nsensor*3,desclen+1)*blanks(1));
unitslen=length(unitstring);
unitsbuf=setstr(ones(nsensor*3,unitslen)*blanks(1));

%not guaranteed to work right for MIT/NIDAQ data!!
for idd=1:nsensor
   sss=deblank(descriptmp(idd,:));
   ssl=length(sss)+1;
   descbuf(x_col(idd),1:ssl)=[sss 'X'];
   descbuf(y_col(idd),1:ssl)=[sss 'Y'];
   descbuf(t_col(idd),1:ssl)=[sss 'T'];
   unitsbuf(x_col(idd),1:unitslen)=unitstring;
   unitsbuf(y_col(idd),1:unitslen)=unitstring;
   %tilt currently without units....
end;
sensorstrm=descriptmp;
descriptor=descbuf;
unit=unitsbuf;

%===================================
%load error map mat file
%1.6.97; changed to standard MAT variables
%still assumes a specific arrangement of the matrix,
%could be upgraded to examine descriptor variable in MAT file
errormapname=philinp ('Error map MAT file * ');
if ~isempty(errormapname)	%and if exists??
   errormap=mymatin(errormapname,'data');
   mapcomment=mymatin(errormapname,'comment','<No Comment>');
   disp('Comment from error map file =====');
   disp(mapcomment);
   %handle errors etc.
end;


%==================================
%
%input scanning will be skipped if empty
inname=philinp ('Input file name (without extension) * ');
%no output generated if empty
%limit on length of output name???
outname=philinp ('Output file name (without extension) * ');

%trial numbers mainly designed for picking out e.g occlusal plane trials
%(or for skipping total rubbish at start or end)
%but be careful if trials have to be matched to a stimulus list
%
ntrial=0;       %if zero, then no input or output
firsttrial=0;lasttrial=0;
if length(outname)+length(inname) ~=0
   firsttrial=abart ('Number of first trial',1,1,999,abint,abscalar);
   lasttrial=abart ('Number of last trial',100,firsttrial,999,abint,abscalar);
   ntrial=lasttrial-firsttrial+1;
   cutlabel=blanks(lasttrial)';
   labelname=philinp('File with trial labels, e.g from PRT file : ');
   if ~isempty(labelname)
      tempstr=file2str(labelname);
      if (size(tempstr,1)>=lasttrial) cutlabel=tempstr; end;
   end;
   namestr=[namestr 'Label file: ' labelname crlf];
end;
namestr=[namestr 'Input files: ' inname ' from ' int2str(firsttrial) ' to ' int2str(lasttrial) crlf 'Output files: ' outname crlf];
%==========================================
%
%details of reference coils
%maybe set up some appropriate defaults in due course
%or obtain from more refined experiment setup file
%note: this can also be used as a way of getting statistics
%of the distance between any pair of sensors
%if actual processing stage is skipped
%
%check sensors actally in use.....?
icref1=maxsensor-3;
icrefdef=icref1+1;
disp ('Specify sensor number of first reference sensor');
disp ('(ususally upper incisors)');
disp ('The coordinates of this sensor will be subtracted');
disp ('from the other sensors');
disp ('0 = No reference sensor');
icref1=abart ('First reference sensor',icref1,0,hisensor,abint,abscalar);
icref2=0;
if icref1
   icref2=icref1;
   while icref2==icref1
      disp ('Specify sensor number of second reference sensor');
      disp ('(ususally nose)');
      disp ('The coordinates of this sensor will be used to rotate');
      disp ('the other sensors so line joining ref1 to ref2 is vertical');
      disp ('0 = No reference sensor');
      icref2=abart ('Second reference sensor',icrefdef,0,hisensor,abint,abscalar);
   end;
end;
namestr=[namestr 'Ref. Sensors ' int2str(icref1) ' ' int2str(icref2) crlf];

%===========================================================
%load occlusal plane data
% if no file is specified, no mapping to occlusal plane
% will be carried out
%initialize to no translation and rotation
%
Zocct=0+i*0;
Zoccr=1+i*0;

%procedure for occlusal plane could be as follows:
%Occlusal plane trials must be processed by this program
%to correct for head movement
%may well use different mux setup (MIT EMMA only)
%The mat file storing the statistics of the processed trials
%could be used as the basis for the input matrix
%with an additional amount of minor manipulation
%perhaps automated by means of an additional small script


occlusalcomment='';
occlusalname=philinp ('Occlusal plane MAT file * ');
if ~isempty(occlusalname)	%and if exists??
   occlusalplane=mymatin(occlusalname,'data');
   occlusalcomment=mymatin(occlusalname,'comment');
   
   
   %handle errors etc.
   if exist('occlusalplane')==1
      if size (occlusalplane)~=[2 2];
         disp ('Inappropriate matrix in occlusal plane file')
         disp ('No anatomical normalization will be carried out');
         occlusalname=[];
      end;
   else
      disp ('File does not contain matrix "data"');
      disp ('No anatomical normalization will be carried out');
      occlusalname=[];
   end;
   if ~isempty(occlusalname)
      disp ('Current coordinates of new origin');
      disp (occlusalplane(1,:));
      occang=occlusalplane(2,:)-occlusalplane(1,:);
      occang=angle(occang(1)+i*occang(2));
      disp ('Current orientation of new x-axis (in degrees)');
      disp (occang*(1./pifac));
      %translation and rotation using complex variables
      Zocct=occlusalplane(1,1)+i*occlusalplane(1,2);
      occang=occlusal_orientation-occang;
      Zoccr=exp(i*(occang));
   end;
end;
%==========================================================

namestr=[namestr 'Error map file: ' errormapname crlf 'Occlusal plane file: ' occlusalname ' ' occlusalcomment crlf];


sampleratein=abart('Samplerate of input data',500,1,2000,abnoint,abscalar);

%decimation of data will be done during first scan
%Load filter coefficients here
%Design must be FIR, as it simplifies handling of bad data
%See e.g kaiserd.m for convenient Kaiser filter design
% The actual filtering is carried out by decifir which is a home-grown variant of decimate.m
% see comments in decifir for pros and cons of various matlab filter routines
%
idown=abart ('Decimation rate (1=no decimation)',2,1,16,abint,abscalar);
samplerate=sampleratein./idown;
namestr=[namestr 'Decimation rate: ' int2str(idown) crlf];

ncof=0;          %this will act as filter flag
filtername=philinp('MAT file with coefficients of main filter : ');
if isempty(filtername) & idown>1 error('Filter compulsory for decimation');end;
if ~isempty(filtername)
   bcof=mymatin(filtername,'data');
   filtercom=mymatin(filtername,'comment','<No Comment>');
   ncof=length(bcof);
   namestr=[namestr 'Filter spec. (name/comment/n_cof/dc_gain) : ' filtername ' / ' filtercom ' / ' num2stre([ncof sum(bcof)]) crlf];
   disp (['No. of coefficients in FIR filter : ' int2str(ncof)]);
end;

%============================================================

%supplementary filtering for ref. sensors
ncofsup=0;          %this will act as filter flag
if icref1
   
   filternamesup=philinp('MAT file with coefficients of supplemtary filter for reference sensors : ');
   if ~isempty(filternamesup)
      bcofsup=mymatin(filternamesup,'data');
      filtercomsup=mymatin(filternamesup,'comment','<No Comment>');
      ncofsup=length(bcofsup);
      namestr=[namestr 'Supplementary filter spec. (name/comment/n_cof/dc_gain) : ' filternamesup ' / ' filtercomsup ' / ' num2stre([ncofsup sum(bcofsup)]) crlf];
      disp (['No. of coefficients in supplementary FIR filter : ' int2str(ncofsup)]);
      %get columns of ref. coils
      refcol=[x_col(icref1) y_col(icref1) t_col(icref1)];
      if icref2
         refcol=[refcol x_col(icref2) y_col(icref2) t_col(icref2)];
      end;
      disp ('Reference coil columns');
      disp(refcol);
   end;
end;     %icref1





%if two ref. sensors are available the distance between the two
%will be computed.
%this is a very useful quality control procedure!!
ref2=icref1&icref2;
statcol=nsensor*ndim;
if ref2 statcol=statcol+1;end;  %append as last column of stats buffers

%initialize stats buffers for pre and postprocessing

%initialize these anyway because mean and std are used by errorana
meanall=zeros(1,statcol);
stdall=zeros(1,statcol);
badall=zeros(1,nsensor);
%only initialize these if data actually processed
if ntrial
   meanbufin=zeros(ntrial,statcol);
   stdbufin=zeros(ntrial,statcol);
   nbufin=zeros(ntrial,statcol);
   meanbufout=zeros(ntrial,statcol);
   stdbufout=zeros(ntrial,statcol);
   nbufout=zeros(ntrial,statcol);
   badbuf=zeros(ntrial,nsensor);
   trialn=zeros(ntrial,1);
   
end;


%toggle whether processing raw voltage data or x/y data
%

rawflag='N';
%
if rawflag=='Y'
   emmaraw1;
end;           %initialization for raw data



namestr=[namestr 'Raw data: ' rawflag crlf];


%=============================================================
%end of initialization
%=====================
%
%	Processing - Stage 1
%scan data, decimate, compute stats, store as mat file
%
%==============================================================
%

if ~isempty(inname)
   for ii=1:ntrial
      jj=firsttrial+ii-1;	%actual trial number
      disp (['Scanning Trial ' int2str(jj)]);
      extstr=int2str0(jj,trialnumlength);
      
      emmafile=[inname '.' extstr];
      if mitflag=='Y'
         emmadat=getemmam(emmafile,chandat);
      end;
      if mitflag=='N'
         emmadat=getemmaa(emmafile,nsensor*ndim,indatatype);
      end;
      
      [nsamp,nemmacol]=size(emmadat);	%check expected cols, nsensor*ndim
      disp ('input samples/columns ');
      disp ([nsamp nemmacol]);
      %if emma data is still raw voltages (e.g if kaburagi adaptive
      % calibration is to be used) do this here.
      %this does smoothing/decimation and v2d conversion
      if rawflag=='Y'
         emmaraw2;
      end;                          %raw data input
      
      
      
      
      %first scan for bad data, as filtering will have funny
      %effects if bad data present, but what to do about it??
      
      %note: the values in badbuf are for the baddata count
      %BEFORE any decimation is carried out
      %the number of bad data after decimation (or filtering)
      %will be somewhat greater than the total before decimation divided
      %by the decimation factor, depending on the size of the filter window
      %and the actual location of the bad samples in the data stream
      %so really just use badbuf as a flag to sensors and trials where
      %bad data was found
      %
      badbuf (ii,:)=sum(emmadat(:,t_col(sensorlist))==missingvalue);
      
      %if any baddata set x y and t for that sensor to NaN
      
      for fixb=1:nsensor
         if badbuf(ii,fixb)
            isensor=sensorlist(fixb);
            vb=find(emmadat(:,t_col(isensor))==missingvalue);
            badcol=[x_col(isensor) y_col(isensor) t_col(isensor)];
            emmadat(vb,badcol)=ones(length(vb),3)*NaN;
         end;
      end;
      
      if rawflag ~='Y'
         %do smoothing/decimation
         emmaraw3;
         
         %do supplementary smoothing (currently ref. coils only) here
         if ncofsup
            for itmpr=1:length(refcol)
               itmpc=refcol(itmpr);
               
               %!!!prior to 30.7.02 there was a mistake here!!
               %supplementary filtering simply used coefficients of main filter again
               % instead of those from the supplementary filter itself!!!!
               
               %	          emmadat(:,itmpc)= decifir(bcof,emmadat(:,itmpc),1);
%!!!Correction 30.7.02. Next line is correct. Previous line is wrong
               emmadat(:,itmpc)= decifir(bcofsup,emmadat(:,itmpc),1);
            end;
         end;
         
      end;    %rawflag NE 'Y'
      trialn(ii)=nsamp;
      
      %assumes tilt scale is same as for coordinates
      emmadat=emmadat*scaleinput;
      %hopefully temporary??? adjust origin of AG100 data before proceeding
      %note numbering of transmitters!
      if mitflag=='N'
         emmadat(:,x_col)=emmadat(:,x_col)+transx(3);
         emmadat(:,y_col)=emmadat(:,y_col)+transy(3);
         emmadat(:,t_col)=emmadat(:,t_col)*10;
         %readjust tilt scale??
      end;
      if ref2
         %get difference between ref sensors (use abs of complex variable)
         ref2dist=eucdist(emmadat,[x_col(icref1) x_col(icref2) y_col(icref1) y_col(icref2)]);
      else
         ref2dist=[];
      end;
      
      [meanbufin(ii,:),stdbufin(ii,:),nbufin(ii,:)]=meansdpr([emmadat ref2dist],'Channel Stats.');
      
      %store measurement data as mat file for later use
      eval (['save mattmp' pathchar tempname extstr ' emmadat']);
   end;
   
   %=========================
   %end of loop thru trials
   %show overall stats
   %do some plotting?
   [meanall,dummy1,dummy2]=meansdpr(meanbufin,'Overall Means');
   [stdall,dummy1,dummy2]=meansdpr(stdbufin,'Overall Standard Deviations');
   
   badall=sum(badbuf);
   disp ('Total bad data per sensor');
   disp (badall);
   %
   %most useful plots are probably ref distance (if appropriate)
   % plus tiltfactors and tilt sd for each sensor
   
   hf(1)=figure;
   line((firsttrial:lasttrial)',meanbufin(:,t_col(sensorlist)));
   text(ones(nsensor,1)*firsttrial,(meanbufin(1,t_col(sensorlist)))',sensorstrm);
   text(ones(nsensor,1)*lasttrial,(meanbufin(ntrial,t_col(sensorlist)))',sensorstrm);
   
   title ('Tilt per trial: Means');
   eval(['print ' outname 'tx -depsc2;']);
   hf(2)=figure;
   line((firsttrial:lasttrial)',stdbufin(:,t_col(sensorlist)));
   text(ones(nsensor,1)*firsttrial,(stdbufin(1,t_col(sensorlist)))',sensorstrm);
   text(ones(nsensor,1)*lasttrial,(stdbufin(ntrial,t_col(sensorlist)))',sensorstrm);
   
   title ('Tilt per trial: Standard deviations');
   eval(['print ' outname 'ts -depsc2;']);
   
   if ref2
      hf(3)=figure;
      plot (meanbufin(:,statcol),'y-');
      title ('Ref1-Ref2 distance: Means');
      eval(['print ' outname 'rx -depsc2;']);
      hf(4)=figure;
      plot (stdbufin(:,statcol),'y-');
      title ('Ref1-Ref2 distance: Standard deviations');
      eval(['print ' outname 'rs -depsc2;']);
   end;
   
   %activate keyboard
   %this allows additional adhoc examination of the trial statistics
   %it could also be used to start an optional script file
   %to do additional further processing on the temporary mat files
   % of the trial data
   keyboard;
   
end;             %end of skip if inname undefined
%================================================
%Set up coordinate correction
%This stage is skipped if no error map mat file has been specified
%
%This stage can also just be used on its own to examine the error map
%if outname and inname both undefined
%it could be turned into a function fairly easily
%but currently it depends on the following variables defined in the
%main script:
%maxsensor, nsensor, sensorlist, x_col, y_col
%meanall, stdall     %these can both be zero
%r_cen, (and abart constants)
%inserts some processing details in namestr
%also on mitflag...????
%initialize the prediction coefficient arrays
%if error map not in use, the estimated error
%will then be zero
%note storage arrangement , because prediction coefficients
%come out as column vector
%errorana stores the correction coefficients in these matrices
perrx=zeros(3,maxsensor);
perry=zeros(3,maxsensor);


if ~isempty(errormapname) errorana; end;
%
%
%=====================================================
%
%	Stage 3
%	Process the measurement data
%	i.e coordinate correction, head correction, occlusal plane
%
if ~isempty(outname)
   %2.98 generate cutfile
   cutdata=zeros(ntrial,4);
   labelout=setstr(ones(ntrial,size(cutlabel,2))*blanks(1));
   maxlabel=0;
   for ii=1:ntrial
      currenttrial=firsttrial+ii-1;	%actual trial number
      disp (['Processing trial ' int2str(currenttrial)]);
      extstr=int2str0(currenttrial,trialnumlength);
      item_id=deblank(cutlabel(currenttrial,:));
      disp(item_id);
      
      %2.98 generate cutfile
      
      lablength=length(item_id);
      maxlabel=max([maxlabel lablength]);
      labelout(ii,1:lablength)=item_id;
      cutdata(ii,4)=currenttrial;
      
      
      eval (['load mattmp' pathchar tempname extstr]);
      triallength=size(emmadat,1);
      cutdata(ii,2)=triallength/samplerate;
      
      %set up head correction as translation and rotation
      %using complex variables
      Zheadt=zeros(triallength,1)+i*zeros(triallength,1);
      if icref1
         Zheadt=emmadat(:,x_col(icref1))+i*emmadat(:,y_col(icref1));
      end;
      Zheadr=ones(triallength,1)+i*zeros(triallength,1);
      if icref2
         %compute angle to rotate data to ref_orientation
         %probably vertical i.e pi/2
         %then convert angle back to position on unit circle
         Ztemp=emmadat(:,x_col(icref2))+i*emmadat(:,y_col(icref2));
         Ztemp=Ztemp-Zheadt;
         Ztemp=ref_orientation-angle(Ztemp);
         Zheadr=exp(i*Ztemp);
      end;
      
      
      %currently all processing is applied to all sensors
      %various subsets of the various possibilites could save
      %some processing time, but probably hardly worth the trouble
      
      
      for jj=1:nsensor
         isensor=sensorlist(jj);
         disp (['Sensor ' int2str(isensor)]);
         colx=x_col(isensor);
         coly=y_col(isensor);
         %extract current x and y coordinates to temporary matrix
         myA=[emmadat(:,[colx coly]) ones(triallength,1)];
         %generate predicted error data
         ptemp=[perrx(:,isensor) perry(:,isensor)];
         prederr=myA*ptemp;
         %be careful with the sign of the error!!!
         myA=myA(:,1:2)+prederr;
         
         %turn into complex variable for following steps
         myA=myA(:,1)+i*myA(:,2);
         
         %following two stages could be merged
         %
         %do head correction
         myA=myA-Zheadt;
         myA=myA.*Zheadr;
         %do occlusal plane mapping
         myA=myA-Zocct;
         myA=myA*Zoccr;
         
         %restore processed data to main matrix
         emmadat(:,[colx coly])=[real(myA) imag(myA)];
         
      end;		%loop thru sensors
      
      
      %recompute statistics
      
      if ref2
         %this is actually superfluous since after head correction
         %the ref1-ref2 distance is equal to the y-coordinate of the nose coil
         %but leave in as check
         %get difference between ref sensors (use abs of complex variable)
         ref2dist=eucdist(emmadat,[x_col(icref1) x_col(icref2) y_col(icref1) y_col(icref2)]);
      else
         ref2dist=[];
      end;
      
      [meanbufout(ii,:),stdbufout(ii,:),nbufout(ii,:)]=meansdpr([emmadat ref2dist],'Channel Stats.');
      
      %if storing as integer data it might be advisable to check that
      %data is still in range
      
      %missing data handling? convert from NaN back to desired output value
      %temporary: leave as NaN while output format is MAT
      %store the processed trial.......
      %temporary, with mat files name must not be longer than 5 letters (for DOS)
      comment=namestr;        %currently same for all trials
      comment=[comment '<End of Comment> ' functionname crlf];
      data=emmadat;
      eval (['save mat' pathchar outname extstr ' data descriptor unit item_id comment samplerate']);
   end;		%loop thru trials
   
   %store stats of processed data...
   %convert to standard form with descriptor and units etc...?????
   
   unittmp=unit;
   
   desctmp=strm2rv(descriptor,' ');
   if ref2
      desctmp=[desctmp 'ref12 '];
      unittmp=str2mat(unittmp,unitstring);
   end;
   
   %last blank must be removed before converting back to matrix
   sxi=rv2strm(deblank(strrep(desctmp,' ','_xi ')));
   ssi=rv2strm(deblank(strrep(desctmp,' ','_si ')));
   sxo=rv2strm(deblank(strrep(desctmp,' ','_xo ')));
   sso=rv2strm(deblank(strrep(desctmp,' ','_so ')));
   sbad=rv2strm(deblank(strrep([sensorstring ' '],' ','_bad ')));
   
   descriptor=str2mat(sxi,ssi,sxo,sso,sbad,'trialnumber');
   unit=str2mat(unittmp,unittmp,unittmp,unittmp,(blanks(nsensor))',' ');
   label=labelout;
   trialnum=cutdata(:,4);
   data=[meanbufin stdbufin meanbufout stdbufout badbuf trialnum];
   
   cutcomment=comment;
   comment=namestr;        %currently same for all trials
   comment=[comment 'Statistics (mean and sd) for input and output data' crlf]
   comment=[comment '<End of Comment> ' functionname crlf];
   
   
   eval (['save ' outname 'sta data descriptor unit comment label']);
   
   %2.98 generate cutfile
   data=cutdata;
   
   %next 2 lines assumes long signal files
   %should be eliminated in due course
   %8.2.99 commented out
   %        data(:,2)=cumsum(data(:,2));
   %        data(2:ntrial,1)=data(1:(ntrial-1),2);
   
   [descriptor,unit,cut_type_value,cut_type_label]=cutstruc;
   %at outset trial_number_label is simply identical
   %with main segement labels
   %but this ensures trial labels are kept in cut file
   %even if the trial segments are removed
   
   trial_number_value=trialnum;
   trial_number_label=label;
   comment=cutcomment;
   eval (['save ' outname 'cut data label descriptor unit comment cut_type_value cut_type_label trial_number_value trial_number_label']);
   
   
   
   
end;         %skip if outname not defined
diary off;
%delete figures
keyboard;
delete (hf);
fclose ('all');
