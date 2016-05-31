function makerefobj(matfile,slist,vdistance);
% MAKEREFOBJ Make a reference object to define standardized coordinates for 3D articulatory data
% function makerefobj(matfile,slist,vdistance);
% makerefobj: Version 27.6.03
%
%	Syntax
%		matfile: Input file; assumed to contain AG500 data with 3D sensor position
%			and with orientation of sensor expressed as relative 3D position of unit vector
%			(Sensor names must be suffixed px/py/pz and ox/oy/oz for position and orientation
%			information respectively)
%		slist: List of sensors to use
%		vdistance: Distance from sensor at which to place the virtual sensor defined by
%			the orientation information
%		output: matfile (with '_refobj' appended to the input file name) containing:
%			(1) The positions of the sensors and virtual sensors defining the reference object.
%			(2) A structure (essentially consisting of a homogeneous matrix) 
%				defining the mapping from the input data to the output reference object
%			This output file can be specified as the 'refobj' or 'fixed_trafo' input argument to
%			RIGIDBODYANA. refobj makes use of (1), fixed_trafo makes use of (2).
%
%	See Also
%		RIGIDBODYANA Applies the transformation defined by the reference object
%		REGE_H and ROTA_INI Based on Christian Geng's implementation of the Gower procrustes algorithm for
%			finding the transformation mapping a measured object onto a reference object


function_name='MAKEREFOBJ: Version 27.06.2003';

philcom(0);
disp('Type h at the prompt to get a list of commands');

[abint,abnoint,abscalar,abnoscalar]=abartdef;

diary makerefobjlog.txt
load(matfile);
ndim=3;
nsensor=size(slist,1);

outsuffix='_refobj';

P=desc2struct(descriptor);

%if this was an actual trial, start by taking the mean
% input could be some kind of preprocessed composite of various trials
% with reference tasks to define an anatomical reference system


%trial data may have harmless NaNs
if size(data,1)>1
    datax=nanmean(data);
end;


data3=zeros(nsensor,ndim);
data3v=ones(nsensor,ndim)*NaN;

for ii=1:nsensor
   sname=deblank(slist(ii,:));
   td=datax([getfield(P,[sname '_px']) getfield(P,[sname '_py']) getfield(P,[sname '_pz'])]);
   tv=datax([getfield(P,[sname '_ox']) getfield(P,[sname '_oy']) getfield(P,[sname '_oz'])]);
   data3v(ii,:)=td+(tv*vdistance);
   data3(ii,:)=td;
end;

%assume all units the same
outunit=unit(getfield(P,[deblank(slist(1,:)) '_px']),:);


dataorg=[data3;data3v];

tmps=slist;
tmps=strcat('v_',tmps);
slistout=str2mat(slist,tmps);

npoint=size(slistout,1);

collist=hsv(nsensor);

planeco=[1 2;1 3;2 3];
planelist=str2mat('xy','xz','yz','3d');
myviews=[0 90;0 0;90 0;-37.5 30];
nview=size(myviews,1);

hlv=zeros(nsensor,nview);

for ii=1:nview
   
   hax(ii)=subplot(2,2,ii);
   vs=1:nsensor;
   hls(ii)=plot3(dataorg(vs,1),dataorg(vs,2),dataorg(vs,3));
   set(hls(ii),'color','k','linewidth',2,'marker','o');
   
   for kk=1:nsensor
      hlv(kk,ii)=line([dataorg(kk,1);dataorg(kk+nsensor,1)],[dataorg(kk,2);dataorg(kk+nsensor,2)],[dataorg(kk,3);dataorg(kk+nsensor,3)]);
      set(hlv(kk,ii),'color',collist(kk,:),'linewidth',2,'marker','x');
   end;
   
   
   
   xlabel('X');ylabel('Y'),zlabel('Z');
   view(myviews(ii,:));
   axis equal
   title(planelist(ii,:),'fontweight','bold');
   
   
   if ii==nview
      [hal,objh]=legend(hlv(:,ii),slist);
      hxx=findobj(objh,'type','text');
      set(hxx,'interpreter','none');
   end;
   
   
end;

planelist(end,:)=[];		%dummy to get 3d axis title

datacur=dataorg;
S=desc2struct(slistout);

ifinished=0;

while ~ifinished
   mycmd=philinp('Command : ');
   
   if mycmd=='h'
      
      disp(['o: Choose sensor to locate at origin' crlf ...
            'r: Set second sensor at desired angle relative to first sensor in desired plane' crlf ...
            'a: Rotate all sensors by desired angle in desired plane' crlf ...
            'x: Reset sensors to original position' crlf ...
            'k: Enter keyboard mode' crlf ...
            'e: Store results and exit' crlf]);
      
   end;
   
   
   %origin at sensor
   if mycmd=='o'
      mysensor=abartstr('Choose sensor to locate at origin',deblank(slistout(1,:)),slistout,abscalar);
      tmpd=datacur(getfield(S,mysensor),:);
      datacur=datacur-repmat(tmpd,[npoint 1]);
      dographs(datacur,hls,hlv);
   end;
   
   if mycmd=='r'
      myplane=abartstr('Choose plane','xy',planelist,abscalar);
      mysensor1=abartstr('Choose first sensor ',deblank(slistout(1,:)),slistout,abscalar);
      mysensor2=abartstr('Choose second sensor',deblank(slistout(1,:)),slistout,abscalar);
      myangle=abart('Choose desired angle of sensor2 relative to sensor1 (in deg.)',90,0,360,abnoint,abscalar);
      
      ip=strmatch(myplane,planelist);
      d1=datacur(getfield(S,mysensor1),planeco(ip,:));
      d2=datacur(getfield(S,mysensor2),planeco(ip,:));
      
      %current angle
      
      curangle=atan2(d2(2)-d1(2),d2(1)-d1(1));
      
      disp(['Current angle (deg.) ' num2str(curangle*180/pi)]);
      
      myangle=myangle*pi/180;
      rotangle=myangle-curangle;
      rotmat=plane_rot(rotangle,myplane);
      
      datacur=(rotmat*datacur')';
      dographs(datacur,hls,hlv);
      
   end;
   
   if mycmd=='a'
      myplane=abartstr('Choose plane','xy',planelist,abscalar);
      myangle=abart('Specify rotation angle (in deg.)',90,-180,180,abnoint,abscalar);
      
      myangle=myangle*pi/180;
      rotmat=plane_rot(myangle,myplane);
      
      datacur=(rotmat*datacur')';
      dographs(datacur,hls,hlv);
      
   end;
   
   if mycmd=='x'
      datacur=dataorg;
      dographs(datacur,hls,hlv);
   end;
   
   
   
   
   if mycmd=='k'
      keyboard;
   end;
   
   if mycmd=='e'
      ifinished=1;
   end;
   
end;

%prepare results for output

%get transformation


[hmat,taxdist]=rege_h(datacur,dataorg,360);     %last arg now needed: no limit on angle

%need this!!!
showth(hmat,'Translation and rotation from input to output');

keyboard;

data=datacur;
label=slistout;
descriptor=('xyz')';
unit=repmat(outunit,[size(descriptor,1) 1]);


namestr=['Input file : ' matfile crlf];
namestr=[namestr 'Virtual sensor distance: ' num2str(vdistance) crlf];
briefcomment=philinp('Enter brief description of the reference object');
namestr=[namestr 'Brief description of reference object and transformation:' crlf briefcomment crlf];


comment=namestr;
comment=framecomment(comment,function_name);

private.hmat=hmat;
private.vdistance=vdistance;
private.comment=['hmat is the homogeneous matrix giving the transformation from the input data ' crlf ...
      'to the output reference object.' crlf ...
      'It is designed for use in the form hmat*v, with v a column vector of coordinates' crlf ...
      '(with 1 appended as last element)' crlf ...
      'vdistance is the distance of the virtual sensor from the actual sensor, generated using the ' crlf ...
      'sensor orientation information' crlf];


save([matfile outsuffix],'data','label','descriptor','unit','comment','private');

diary off


function dographs(data,hls,hlv);

nview=size(hlv,2);
nsensor=size(hlv,1);

vs=1:nsensor;
for ii=1:nview
   
   set(hls(ii),'xdata',data(vs,1),'ydata',data(vs,2),'zdata',data(vs,3));
   
   for kk=1:nsensor
      set(hlv(kk,ii),'xdata',[data(kk,1);data(kk+nsensor,1)],'ydata',[data(kk,2);data(kk+nsensor,2)],'zdata',[data(kk,3);data(kk+nsensor,3)]);
   end;
end;

