function [descriptor,unit,dimension]=headervariablesNDI(nsensor,sensornames)

ntrans=6;
ndim=3;

realnames=0;
if nargin>1
if ~isempty(sensornames)
    if size(sensornames,1)==nsensor
        realnames=1;
    else
        disp(['Sensor names must have ' int2str(nsensor) ' entries']);
        return;
    end;
end;
end;

sensname='Sensor';

descriptor=char('posx','posy','posz','phi','theta','status','compdist');
unit=char('mm','mm','mm','deg','deg','','mm');

dd=cell(ndim,1);
dd{1}='Time';
dd{2}='Coordinate';

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


