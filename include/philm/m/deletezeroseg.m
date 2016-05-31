function deletezeroseg(cutfile);

disp(cutfile);
data=mymatin(cutfile,'data');
label=mymatin(cutfile,'label');
vv=find(data(:,2)<=data(:,1));

if ~isempty(vv)
%    keyboard;
    disp('Eliminating zero (or negative) segment lengths');
    disp(strcat(label(vv,:),' :' ,num2str(data(vv,:))));
    data(vv,:)=[];
    label(vv,:)=[];
    save(cutfile,'data','label','-append');
    
end;
