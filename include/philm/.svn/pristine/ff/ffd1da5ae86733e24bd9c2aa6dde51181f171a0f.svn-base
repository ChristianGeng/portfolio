function [descriptor,unit,dimension]=headervariables(ampflag,sensornames,dataspec);
% HEADERVARIABLES Generate default header variables for AG500 data
% function [descriptor,unit,dimension]=headervariables(ampflag,sensornames,dataspec);
% headervariables: Version 25.02.2012
%
%   Description
%       Generates descriptor, unit and dimension variables for using
%       AG500/501
%       data in MT style programs
%       ampflag: Optional. Default=0. If 1 (true) generate variables for
%       amp files, otherwise for pos files
%		pos files are assumed to be tapad-style, i.e where 7th parameter is
%		currently the exitflag from lsqnonlin
%       sensornames: optional, list of real sensor names to replace
%       defaults of sensor01 etc.
%       dataspec: Optional. 2-element vector [ntrans nsensor] to override
%           AG100 defaults of [6 12]
%
%	Updates
%		11.2010 change newflag to exitflag for 7th parameter of position
%		data
%       2.2012 add dataspec argument; improve error handling

nsensor=12;
ntrans=6;
ndim=3;

if nargin>2
    ntrans=dataspec(1);
    nsensor=dataspec(2);
end;


doamp=0;
if nargin doamp=ampflag; end;

realnames=0;
if nargin>1
    if ~isempty(sensornames)
        if size(sensornames,1)==nsensor
            realnames=1;
        else
            disp('Sensor names:');
            disp(sensornames)
            ssx=['Sensor names must have ' int2str(nsensor) ' entries!'];
            error(ssx);
        end;
    end;
end;


sensname='Sensor';
transname='Trans';
descriptor=str2mat('posx','posy','posz','phi','theta','rms','exitflag');
unit=str2mat('mm','mm','mm','deg','deg','ADunits',' ');

if doamp
    descriptor=strcat(transname,int2str((1:ntrans)'));
    unit=repmat('NormalizedAmp',[ntrans 1]);
end;



dd=cell(ndim,1);
dd{1}='Time';
dd{2}='Coordinate';
if doamp dd{2}='Transmitter'; end;

dd{3}=sensname;

aa=cell(ndim,1);
aa{1}=[];
aa{2}=descriptor;

if realnames
    aa{3}=sensornames;
else
    ss=strcat(sensname,int2str((1:nsensor)'));
    ss=char(strrep(cellstr(ss),' ','0'));
    aa{3}=ss;
end;

uu=(blanks(ndim))';

dimension.descriptor=char(dd);
dimension.unit=uu;      %irrelevant for this kind of data
dimension.axis=aa;

