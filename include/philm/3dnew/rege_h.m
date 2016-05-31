function [hmat,taxdist]=rege_h(refobj,data,methodSpec);
% REGE_H Determine homogeneous matrix to map multiple objects to reference object
% function [hmat,taxdist]=rege_h(refobj,data,method);
% rege_h: Version 28.03.2012
%
%	Description
%		version of regejaw2 for large datasets with reference object specified separately
%		and transformation result returned as a homogeneous matrix
%		refobj: has dimension npoints*ndim
%		data: has dimension npoints*ndim*nobj
%		hmat: has dimension 4*4*nobj
%		taxist: has dimension nobj*1
%		If there are any NaNs in the object to be registered the output matrix (and taxonomic distance) will be NaNs
%		(also if rota_ini fails)
%       methodSpec: 'Procrustes' or 'Horn'
%           Special case for backward compatibility:
%           If methodSpec is numeric then method is set to Procrustes and the
%           input argument defines a threshold for permitted resulting
%           rotation angles.
%           The default threshold is 85 deg. (no threshold is used with the
%           Horn method).
%           (The angle threshold is probably now superfluous since rota_ini
%           now catches cases of apparent reflections).
%
%
%	See Also ROTA_INI Christian's implementation of Gower Procrustes and Horn Quaternion procedure

method='Procrustes';
anglim=85;

if nargin>2
    if ischar(methodSpec)
        method=methodSpec;
    else
        anglim=methodSpec;
    end;
end;

checkangle=1;
if strcmp(method,'Horn') checkangle=0; end;

%disp(['rege_h: method ' method '; angle limit ' int2str(anglim)]);
DimX=size(data);

nobj=1;
if ndims(data)>2 nobj=DimX(3); end;


hmat=ones(4,4,nobj)*NaN;
taxdist=ones(nobj,1)*NaN;

if ~any(isnan(refobj(:)))
    
    unitv=[1 0 0;0 1 0;0 0 1];
    
    [refcenter, refxbar]=zentriert(refobj);
    refxbar=refxbar';	%we need it as a column vector below
    
    for ind=1:nobj
        %   disp(ind);
        curobj=data(:,:,ind);
        if ~any(isnan(curobj(:)))
            [center, xbar]=zentriert(curobj);
            try
                [H, X2dot, Deltasquare, taxout]=rota_ini(refcenter,center,method);
                
                %transpose H for use as Mv rather than vM
                H=H';
                
                %the basic idea for the transformation is:
                % subtract centroid of current object
                % rotate
                % add centroid of reference object
                %
                % Here we conflate this into one multiplication
                
                %rotate the centroid of the second object
                
                cent2t=H*xbar';
                %this now gives the translation
                tt=refxbar-cent2t;
                
                resultok=1;
                
                if checkangle
                    %keyboard;
                    vrot=H*unitv;
                    myang=acos(diag(vrot'*unitv))*180/pi;
                    
                    if any(abs(myang)>anglim)
                        disp(['rege_h: Unreliable registration? ' int2str(ind) ' ' num2str(myang')]);
                        taxdist(ind)=-1;        %use as flag; temporary????
                        resultok=0;
                    end;
                end;
                
                if resultok
                    %merge rotation and translation components
                    hmat(:,:,ind)=[[H tt];[0 0 0 1]];
                    taxdist(ind)=taxout;
                    
                end;
                
                docheck=0;
                if docheck
                    
                    %check for screwy results???. this does translation and rotation
                    %step by step. results identical
                    np=size(curobj,1);
                    xobj=curobj-repmat(xbar,[np 1]);
                    xobj=H*xobj';
                    xobj=xobj+repmat(refxbar,[1 np]);
                    taxtst=trace((refobj'-xobj)*(refobj'-xobj)');
                    taxtst=sqrt(taxtst/np);
                    disp(ind);
                    disp([taxout taxtst])
                    
                    
                    if abs(taxtst-taxout)>10*eps
                        disp('rege_h: unreliable result? ');
                        disp([taxtst taxout]);
                        taxdist(ind)=NaN;
                    end;
                    
                end;         %disp('in rege_h');
                %         keyboard;
                
            catch
                disp('rota_ini: Registration failed');
                disp(lasterr);
                taxdist(ind)=NaN;		%superfluous???
                
            end;
            
            
            
        end;
        
    end;
    
end;
