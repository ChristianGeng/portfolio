function mt_storecontour(outfile)
% MT_STORECONTOUR Store average of data between cursors, e.g for reloading like palate trace
% function mt_storecontour(outfile)
% mt_storecontour: Version 11.10.2000
%
% See also LOADPALATE

%should check there is an xy figure

% currently only first axes can be used
%ev. axes as second input arg
%should be expanded for 3 dimensions

axname=mt_gxyad;
axname=deblank(axname(1,:));

xlist=mt_gxyad(axname,'x_specs');
ylist=mt_gxyad(axname,'y_specs');

nc=size(xlist,1);

data=zeros(nc,2);
descriptor=str2mat('X','Y');	%not yet satisfactory

unit=str2mat(mt_gsigv(xlist(1,:),'unit'),mt_gsigv(ylist(1,:),'unit'));

label=[xlist ylist];		%also not very clever

comment=['Cut file : ' mt_gcufd('filename') crlf];
comment=[comment 'Trial no. ' int2str(mt_gccud('trial_number')) crlf];
comment=[comment mt_gtrid('label') crlf];
comment=[comment 'Cut no. ' int2str(mt_gccud('number')) crlf];
comment=[comment 'Cut data ' num2str(mt_gccud) crlf];
comment=[comment 'label ' mt_gccud('label') crlf];
comment=[comment 'data position' num2str(mt_gcurp) crlf];

for ii=1:nc
   xx=mt_gdata(xlist(ii,:),mt_gcurp);
   yy=mt_gdata(ylist(ii,:),mt_gcurp);
   
   data(ii,1)=mean(xx);
   data(ii,2)=mean(yy);
end;

save(outfile,'data','descriptor','unit','label','comment');
