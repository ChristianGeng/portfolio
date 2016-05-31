function cut2textgrid(cutfile,textgridfile,tierlist,triallengthspec)
% CUT2TEXTGRID Convert cut file to praat textgrid
% function cut2textgrid(cutfile,textgridfile,tierlist,triallengthspec)
% cut2textgrid: Version 10.3.06

load(cutfile);

%remove any zero length cuts
vv=find(data(:,2)<=data(:,1));
if ~isempty(vv)
    keyboard;
    disp('Eliminating zero (or negative) segment lengths');
    disp(strcat(label(vv,:),' :' ,num2str(data(vv,:))));
    data(vv,:)=[];
    label(vv,:)=[];
    
end;



ntier=size(tierlist,1);
%check tiertypes matches
triallist=unique(data(:,4));

maxtrial=max(triallist);
ndig=length(int2str(maxtrial));

if length(triallengthspec)==1 triallengthspec=repmat(triallengthspec,[maxtrial 1]); end;

startstr=['File type = "ooTextFile short"' crlf '"TextGrid"' crlf crlf '0' crlf '$gridlength$' crlf '<exists>' crlf int2str(ntier) crlf];


for iti=triallist'
    triallength=triallengthspec(iti);
    
    triallengths=num2str(triallength);
    disp(iti);
    vv=find(data(:,4)==iti);
    tdata=data(vv,:);
    tlabel=label(vv,:);
    
    outstr=strrep(startstr,'$gridlength$',triallengths);
    
    
    for itier=1:ntier
        tt=tierlist{itier,2};
        tiername=tierlist{itier,1};
        disp(tiername);
        
        outstr=[outstr '"IntervalTier"' crlf '"' tiername '"' crlf '0' crlf triallengths crlf];
        
        vv=find(ismember(tdata(:,3),tt));
        tierdata=tdata(vv,:);
        tierlabel=tlabel(vv,:);
        
        [dodo,isi]=sort(tierdata(:,1));
        tierdata=tierdata(isi,:);
        tierlabel=tierlabel(isi,:);
        nseg=size(tierdata,1);
        
        blankseg=[];
        
        mylast=0;
        for ii=1:nseg
            if not(tierdata(ii,1)==mylast)
                blankseg=[blankseg;[mylast tierdata(ii,1)]];
            end;
            mylast=tierdata(ii,2);
        end;
        blankseg=[blankseg;[mylast triallength]];
        if not(isempty(tierdata))
            tierdata=[tierdata(:,1:2);blankseg];
            tierlabel=str2mat(tierlabel,(blanks(size(blankseg,1)))');
        else
            tierlabel=' ';
        end;
        
        
        % keyboard;
        
        nseg=size(tierdata,1);
        [dodo,isi]=sort(tierdata(:,1));
        tierdata=tierdata(isi,:);
        tierlabel=tierlabel(isi,:);
        
        disp([num2str(tierdata) tierlabel]);

        if any((tierdata(:,2)-tierdata(:,1))<0)
            disp('Overlapping segments not possible in Praat');
            return;
        end;
        
          
        
        outstr=[outstr int2str(nseg) crlf];        
        %write this tier
        for ii=1:nseg
            outstr=[outstr num2str(tierdata(ii,1)) crlf num2str(tierdata(ii,2)) crlf '"' deblank(tierlabel(ii,:)) '"' crlf];
            
        end;
        
    end;
    
    %write textgrid file
    fid=fopen([textgridfile int2str0(iti,ndig) '.TextGrid'],'w');
    mycount=fwrite(fid,outstr,'uint8');
    if mycount ~= length(outstr)
        disp('problem writing text grid?');
        keyboard;
    end;
    
    fclose(fid);
    
    
end;
