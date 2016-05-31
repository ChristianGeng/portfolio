function makerefobjn(matfile,slist,vdistancein,indexrange);
% MAKEREFOBJN Make a reference object to define standardized coordinates for 3D articulatory data
% function makerefobjn(matfile,slist,vdistance,indexrange);
% makerefobjn: Version 29.03.2012
%
%	Syntax
%		matfile: Input file; assumed to contain AG500 trial data with 3D sensor position
%           Names of coordinates in descriptor variables must be posx,
%         posy, and posz for position. If orientations are in spherical
%         coordinates they are converted to unit vector representation
%         (otherwise they should be name orix, oriy, oriz).
%           If the input data is not normal trial data it must be arranged
%           to be compatible with it, i.e
%           second dimension is coordinates, third dimension is sensors and
%           dummy first dimension with length of 1, if necessary.
%           (Trial data is averaged over the first dimension)
%		slist: List of sensors to use
%		vdistance: Optional. Distance from sensor at which to place the virtual sensor defined by
%			the orientation information. Defaults to 50 (mm)
%		indexrange: Optional. If present, must be 2-element vector
%			specifying index of first and last sample to use in the input file.
%			Default is to use all data. Useful if trial to be used has
%			large movements at beginning or end
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
%
%	Updates
%		3.2010 minor text and graphic changes
%		10.2010 Introduce indexrange input argument (and default value for
%           vdistance). v (evaluate) command with graphics update
%       5.2011 New command to apply transformation from existing ref obj
%           (e.g. apply transformation from an occlusion trial to a rest postion
%           trial)
%       03.2012 Prepare for more flexible use of 'method' input argument to
%           new versions of rege_h and rota_ini. Will be made user configurable
%           if the new versions turn out to fail for very unusual transformations.
%           In the meantime, if problems occur use the keyboard command and
%           then enter
%           regemethod='Horn';

function_name='MAKEREFOBJN: Version 29.03.2012';

%03.2012 In view of updates to rege_h and rota_ini
%method argument passed to rege_h
%Possibly in unusual cases it may be better to set it to 'Horn'.
%Could be made an input argument if this really turns out to be necessary
regemethod=360;     %overrides default angular limit in rege_h for the Procrustes method

%description of coordinate system resulting from transformation
% Default is head coordinate system

co_comment=['Coordinate system resulting from transformation:' crlf ...
    'Skull-based' crlf ...
    'x: Transversal (Lateral). Increases from right to left' crlf ...
    'y: Anterior-Posterior. Increases from front to back' crlf ...
    'z: Longitudinal. Increases from low to high (foot to head)' crlf ...
    '===========================================' crlf];

philcom(0);
disp('Type h at the prompt to get a list of commands');

[abint,abnoint,abscalar,abnoscalar]=abartdef;

diary makerefobjlog.txt
[data,descriptor,unit,dimension,sensorsin]=loadpos_sph2cartm(matfile);
ndim=3;

vdistance=50;
if nargin>2
    if ~isempty(vdistancein)
        vdistance=vdistancein;
    end;
end;

nall=size(data,1);
igo=1;
iend=nall;
if nargin>3
    if length(indexrange)==2
        igo=indexrange(1);
        iend=indexrange(2);
    else
        disp('Indexrange must be 2-element vector');
        return;
    end;
end;
if igo<1
    disp('Start index out of range');
    return;
end;

if iend>nall
    disp('End index out of range');
    return;
end;


nsensor=size(slist,1);

outsuffix='_refobj';

P=desc2struct(descriptor);
S=desc2struct(sensorsin);

%if this was an actual trial, start by taking the mean
% input could be some kind of preprocessed composite of various trials
% with reference tasks to define an anatomical reference system

data=data(igo:iend,:,:);

%trial data may have harmless NaNs
if size(data,1)>1
    datax=squeeze(nanmean(data));
else
    datax=squeeze(data);
end;


data3=zeros(nsensor,ndim);
data3v=ones(nsensor,ndim)*NaN;

for ii=1:nsensor
    sname=deblank(slist(ii,:));
    isi=getfield(S,sname);
    td=datax([P.posx P.posy P.posz],isi);
    tv=datax([P.orix P.oriy P.oriz],isi);
    %keyboard;
    data3v(ii,:)=td'+(tv*vdistance)';
    data3(ii,:)=td';
end;

%assume all units the same
outunit=deblank(unit(P.posx,:));


dataorg=[data3;data3v];

tmps=slist;
tmps=strcat('v_',tmps);
slistout=str2mat(slist,tmps);

slistoutx=slistout;
slistoutx(:,end+1)=':';

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
    
    
    
    xlabel(['X (' outunit ')']);
    ylabel(['Y (' outunit ')']);
    zlabel(['Z (' outunit ')']);
    view(myviews(ii,:));
    axis equal
    title(planelist(ii,:),'fontweight','bold');
    
    
    if ii==nview
        [hal,objh]=legend(hlv(:,ii),slist);
        hxx=findobj(objh,'type','text');
        set(hxx,'interpreter','none');
        drawnow;
    end;
    
    
end;

planelist(end,:)=[];		%dummy to get 3d axis title

datacur=dataorg;
S=desc2struct(slistout);

oldrefname='';      %indicates whether old ref object used
ifinished=0;

while ~ifinished
    mycmd=philinp('Command : ');
    
    if mycmd=='h'
        
        disp(['o: Choose sensor to locate at origin' crlf ...
            'O: Choose single sensor coordinate to locate at origin' crlf ...
            'r: Set second sensor at desired angle relative to first sensor in desired plane' crlf ...
            'a: Rotate all sensors by desired angle in desired plane' crlf ...
            'x: Reset sensors to original position' crlf ...
            'k: Enter keyboard mode' crlf ...
            'v: Evaluate (allows additional manipulations not available with other commands)' crlf ...
            't: Apply transformation from existing reference object' crlf ...
            'l: List current coordinates' crlf ...
            'c: Change description of transformed coordinate system' crlf ...
            'e: Store results and exit' crlf]);
        
    end;
    
    
    %origin at sensor
    if mycmd=='o'
        mysensor=abartstr('Choose sensor to locate at origin',deblank(slistout(1,:)),slistout,abscalar);
        tmpd=datacur(getfield(S,mysensor),:);
        datacur=datacur-repmat(tmpd,[npoint 1]);
        dographs(datacur,hls,hlv);
    end;
    
    %Adjust origin for single coordinate
    if mycmd=='O'
        mysensor=abartstr('Choose sensor to define origin for single coordinate',deblank(slistout(1,:)),slistout,abscalar);
        tmpd=datacur(getfield(S,mysensor),:);
        
        myco=abart('Choose coordinate to adjust (1/2/3 = x/y/z)',1,1,3,abint,abscalar);
        
        datacur(:,myco)=datacur(:,myco)-tmpd(myco);
        dographs(datacur,hls,hlv);
    end;
    
    if mycmd=='t'
        oldrefname=abartstr('Enter name of existing ref. object mat file');
        oldrefdata=mymatin(oldrefname,'data');
        oldreflabel=mymatin(oldrefname,'label');
        disp('Sensors in old ref object');
        disp(oldreflabel);
        disp('Sensors in current data');
        disp(slistout);
        ntmp=size(slistout,1);
        ikeep=zeros(ntmp,1);
        olduse=ones(ntmp,size(oldrefdata,2))*NaN;
        for ii=1:ntmp
            vv=strmatch(slistout(ii,:),oldreflabel);
            if ~isempty(vv)
                olduse(ii,:)=oldrefdata(vv,:);
                ikeep(ii)=1;
            end;
        end;
        vv=find(ikeep);
        olduse=olduse(vv,:);
        curuse=dataorg(vv,:);
        keeplabel=slistout(vv,:);
        %allow further selection
        disp('Retained sensors');
        disp(keeplabel);
        disp('data from current object');
        disp(curuse);
        disp('data from old object');
        disp(olduse);
        [hmat_t,taxdist_t]=rege_h(olduse,curuse,regemethod);
        disp(['Taxonomic distance : ' num2str(taxdist_t)]);
        showth(hmat_t,'Translation and rotation from input to output');
        %do the transformation just for the common sensors
        %This may give an indication if e.g. one sensor makes a particularly large
        %contribution to the taxonomic distance.
        tmpd=(hmat_t*[curuse';ones(1,size(curuse,1))])';
        tmpd=tmpd(:,1:3);
        
        disp('Difference between transformed current data and the old reference object (Columns are coordinates)');
        disp([keeplabel blanks(size(keeplabel,1))' num2str(olduse-tmpd)]);
        
        %If everything is ok, transform the full data, and update current data and
        %display
        
        
        tmpd=(hmat_t*[dataorg';ones(1,size(dataorg,1))])';
        tmpd=tmpd(:,1:3);
        datacur=tmpd;
        dographs(datacur,hls,hlv);
        private.oldref.oldrefname=oldrefname;
        %data actually used
        private.oldref.oldrefdata=olduse;
        private.oldref.oldreflabel=keeplabel;
        private.oldref.hmat_t=hmat_t;
        private.oldref.taxdist_t=taxdist_t;
        
        
    end;
    
    
    
    
    if mycmd=='c'
        disp('Current description');
        disp(co_comment);
        xcomment=philinp('Enter new description of transformed coordinate system [no change] : ');
        if ~isempty(xcomment) co_comment=xcomment; end;
    end;
    
    
    if mycmd=='l'
        disp('Current sensor coordinates: ');
        disp(strcat(slistoutx,num2str(datacur,'%10.2f')));
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
        
        disp(['%Current angle (deg.) ' num2str(curangle*180/pi)]);
        
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
    
    if mycmd=='v'
        disp('For additional manipulations enter a matlab command to modify the variable datacur');
        disp('Rows are sensors (actual sensors followed by virtual sensors), columns are coordinates (pos x, y, x)');
        disp('Example (Vertical shift of 10mmm) : datacur(:,3)=datacur(:,3)+10');
        
        evalstr=philinp('Enter string for evaluation : ');
        
        try
            eval(evalstr);
        catch
            disp('Problem with evaluation');
            lasterrorstruct=lasterror;
            disp(lasterrorstruct.message);
            disp(lasterrorstruct.identifier);
            disp('Type ''return'' to continue');
            keyboard;
            
        end;
        dographs(datacur,hls,hlv);
    end;
    
    
    
    if mycmd=='e'
        ifinished=1;
    end;
    
end;

%prepare results for output

%get transformation


[hmat,taxdist]=rege_h(datacur,dataorg,regemethod);     %last arg now needed: no limit on angle

%need this!!!
showth(hmat,'Translation and rotation from input to output');

disp('Final sensor coordinates: ');
disp(strcat(slistoutx,num2str(datacur,'%10.2f')));


keyboard;

data=datacur;
label=slistout;
descriptor=('xyz')';
unit=repmat(outunit,[size(descriptor,1) 1]);


namestr=['Input file : ' matfile crlf];
namestr=[namestr 'Virtual sensor distance: ' num2str(vdistance) crlf];
namestr=[namestr 'Start and end index, trial length : ' int2str([igo iend nall]) crlf];
regemethodstr=regemethod;
if ~ischar(regemethod) regemethodstr=int2str(regemethod); end;
namestr=[namestr 'rege_h method: ' regemethodstr crlf];

briefcomment=philinp('Enter brief description of the reference object : ');

coco_comment=[co_comment 'Brief description of reference object and transformation:' crlf briefcomment crlf];
disp('Full description of transformation: ');
disp(coco_comment);

namestr=[namestr coco_comment crlf];


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
drawnow;
