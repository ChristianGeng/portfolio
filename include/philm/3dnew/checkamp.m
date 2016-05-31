function checkamp(totaldur,chunkdur,chanlist,myfunc,calpath)
% CHECKAMP: Continuous display of amplitudes for Linux AG500 system
% function checkamp(totaldur,chunkdur,chanlist,myfunc,calpath)
% checkamp: Version 18.07.08
%
%   Description
%       totaldur: total duration of recording and display (in s)
%           default: 20
%           termination is always possible by clicking in the figure.
%           Thus totaldur can be specified as inf to run indefinitely.
%       chunkdur: Amount of data (in s) per screen update. Default: 1
%       chanlist: Channels to display. Default: 1:12
%       myfunc: name of function to apply to the amplitude data
%           since amplitude data is complex it should be a function like
%           'real', 'imag', 'abs', or 'complex'
%           amplitude is shown as a function of time unless myfunc is
%           'complex', in which case a z-plane display is used
%           Default is 'real'
%       calpath: Optional. Determines whether phase values from an existing
%           calibration will be used. Should be name of a directory (without
%           pathchar) below /srv/ftp/data/calibration/
%           Since phases normally don't change much there should be no problem
%           in using an old calibration with this function when doing a sensor
%           test prior to a fresh calibration
%           Note: Confusingly, if phase information is available the signal
%           acutally used for position calculation corresponds to the
%           imaginary part of the amplitude input (so normally use 'imag'
%           as myfunc in this case)
%
%   See Also
%       LOADCAMPB, GETRAW4SHOWZ


if ~nargin totaldur=20; end;


samplerate=200;
if nargin<2 chunkdur=1; end;

ntrans=6;

nsamp=chunkdur*samplerate;
nchunk=round(totaldur/chunkdur);
if nchunk<1 return; end;

tdat=((0:(nsamp-1))/samplerate)';
tdat=repmat(tdat,[1 ntrans]);

maxsensor=12;

if nargin<3 chanlist=1:maxsensor; end;
if nargin<4 myfunc='real'; end;

calbase='-c /srv/ftp/data/calibration/&/TMP00000.tmp/stage2.xml';

calstring='';

if nargin>4
    calstring=strrep(calbase,'&',calpath);
end;




hf=figure;

nsensor=length(chanlist);

sprow=floor(sqrt(nsensor));
spcol=ceil(nsensor/sprow);


hl=ones(ntrans,nsensor)*NaN;
for ii=1:nsensor
    hax(ii)=subplot(sprow,spcol,ii);
    hl(:,ii)=plot(tdat,zeros(size(tdat)));
    title([int2str(chanlist(ii)) ' ' myfunc]);
    if ii==nsensor
        if ~strcmp(myfunc,'complex')
            xlabel('t (s)');
            ylabel('Amp');
            xlim([0 chunkdur]);
        else
            xlabel('real');
            ylabel('imag');
        end;
    end;


end;


                set(hf,'windowbuttondownfcn',@checkamp_cb);
                set(hf,'userdata',0);


tic;
for ii=1:nchunk
    if get(hf,'userdata') break; end; %button press in figure
    
    [mystat,myresult]=system(['getrawdatawait ' num2str(chunkdur) ' | sincosdemod ' calstring ' > tmp.camp']);
    if mystat
        disp('checkamp error?');
        disp(mystat);
        disp(myresult);
        return;
    end;

    data=loadcampb('tmp.camp');
    nd=size(data,1);
    if nd>nsamp nd=nsamp;end;
    data=data(:,:,chanlist);
    if ~strcmp(myfunc,'complex')
        tmp=feval(myfunc,data);
    else
        tmp=data;
    end;

    data=ones(nsamp,ntrans,nsensor)*NaN;
    data(1:nd,:,:)=tmp(1:nd,:,:);
    for jj=1:nsensor
        axes(hax(jj));
        for iti=1:ntrans
            if ~strcmp(myfunc,'complex')
                set(hl(iti,jj),'ydata',data(:,iti,jj));
            else
                set(hl(iti,jj),'xdata',real(data(:,iti,jj)),'ydata',imag(data(:,iti,jj)));
            end;

        end;
    end;
    drawnow;
end;


toc;


function checkamp_cb(cbobj,cbdata)
% Indicates button press in figure

set(cbobj,'userdata',1);
