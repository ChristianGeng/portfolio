function mt_rmark
% MT_RMARK Read markers from MAT file
% function mt_rmark;
% mt_rmark: Version 15.03.09
%
%   Updates
%       3.09 Revise to be compatible with new version of mt_imark and
%       mt_lmark
%
%	See also
%		MT_IMARK etc.

orgdat=mt_gmarx;
if isempty(orgdat) return; end;
maxmark=orgdat.n_markers;
curmark=orgdat.current_marker;

editmode=orgdat.edit_mode;
matname=orgdat.filename;

fileactive=((~isempty(matname))&(findstr(editmode,'RE')));


if fileactive
    
    %Note: cutdata is initialized to empty (MT_IMARK)
    %9.99 old style variable names no longer allowed
    
    
    cutdata=mymatin(matname,'data');
    cutlabel=mymatin(matname,'label');
    if ~isempty(cutdata)
        cutdescriptor=mymatin(matname,'descriptor');
        
        %this is really current cut data, not trial data
        trialdata=mt_gccud;
        triallabel=mt_gccud('label');
        trialdescriptor=mymatin(mt_gcufd('filename'),'descriptor');
        
        CD=desc2struct(cutdescriptor);
        TD=desc2struct(trialdescriptor);
        
        
        %for full edit mode we need to keep track of the original cut number of the input data
        ncut=size(cutdata,1);
        cutnum=(1:ncut)';
        
        %look for markers within the current cut
        % and whose type is in the correct range
        %also don't load any markers whose cut type is identical to
        %cut type of current cut (can this cause problems?)
        %18.2.98 revised; allow NaNs for start or end boundary
        %(makes it all a bit more complicated)
        %10.98 corrected
        %3.09 could allowoption of also selecting based on link_target and
        %link_id
        l1=(trialdata(4)==cutdata(:,4));
        l2=((cutdata(:,3)>=1)&(cutdata(:,3)<=maxmark));
        l3=(cutdata(:,3)~=trialdata(3));
        l4=(((cutdata(:,1)>=trialdata(1))&(cutdata(:,1)<=trialdata(2)))|isnan(cutdata(:,1)));
        l5=(((cutdata(:,2)>=trialdata(1))&(cutdata(:,2)<=trialdata(2)))|isnan(cutdata(:,2)));
        %don't load where both boundaries are NaNs
        l6=(~(isnan(cutdata(:,1))&isnan(cutdata(:,2))));
        
        vv=find(l1&l2&l3&l4&l5&l6);
        
        if ~isempty(vv)
            cutdata=cutdata(vv,:);
            cutlabel=cutlabel(vv,:);
            cutnum=cutnum(vv);
            lm=length(vv);
            %       disp(['mm_rmark: Loading ' int2str(lm) ' markers']);
            mylen=cutdata(:,2)-cutdata(:,1);
            vl=find(isnan(mylen));
            if ~isempty(vl)
                disp ('mt_rmark: Only one boundary set');
                disp (cutdata(vl,1:4))
            end;
            
            utype=unique(cutdata(:,3));
            nu=length(utype);
            if nu~=lm
                disp(['mt_rmark: ' int2str(nu) ' cut types for total of ' int2str(lm) ' cuts']);
                disp('See help window for list of skipped records');    
            end;
            
            %3.09. Now need to loop through cut types in order to handle
            %multiple segments per type
            %temporary
            skiprecord=[];
            
            doautolabel=0;
            if isfield(orgdat,'autocurrentlabelflag')
                if orgdat.autocurrentlabelflag
                    addlabel_status=orgdat.addlabel_status;
					autolabelsep=orgdat.autolabelsep;
                    doautolabel=1;
                end;
            end;
            
            for iu=1:nu
                mytype=utype(iu);
                vu=find(cutdata(:,3)==mytype);
                if length(vu)>1
                    skiprecord=[skiprecord;cutnum(vu(2:end))];
                end;
                vx=vu(1);
                mylabel=deblank(cutlabel(vx,:));
                
                %sort out autolabelmode
                if doautolabel
    %allow for label separator. POtential problem if current setting is not
    %same as that used when input file was created
                    lcl=length(mylabel);
                    ltl=length(triallabel);
					lal=length(autolabelsep);
                    addlabel_status(mytype)=0;
					ltx=ltl+lal;
                    if lcl>=ltx
                        if all([triallabel autolabelsep]==mylabel(1:ltx))
                            mylabel(1:ltx)=[];
                            addlabel_status(mytype)=1;
                        end;
                    end;
                end;
                
                
                
                
                %replace with 'cut' mode eventually
                mt_smark('start',cutdata(vx,3),cutdata(vx,1));
                mt_smark('end',cutdata(vx,3),cutdata(vx,2));
                mt_smark('label',cutdata(vx,3),mylabel);
                
                
                %store cut number of input data
                mt_smark('source_cut',cutdata(vx,3),cutnum(vx));
                
                %normal mt_smark functions set the edit flag
                %so now reset it
                mt_smark('status',cutdata(vx,3),0);
                %
            end;           %loop thru cut types
            
            ss=showcutfile(matname,cutnum,1);
            if ~isempty(skiprecord)
                sss=str2mat('Note: Skipped records:',int2str(skiprecord'));
                ss=str2mat(sss,ss);
            end;
            
            helpwin(ss,'MT_RMARK');
            
            if doautolabel mt_smarx('addlabel_status',addlabel_status); end;
            
        end;  %vv not empty
    end;		%cutdata not empty
end;  %file active
