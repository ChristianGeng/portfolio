function num=hhmmssff2num(hhmmssff)

if size(hhmmssff,2)~=4
    error('wrong input to hhmmssff2num, expecting an ntimes x 4 Matrix ');
end

num=3600.*hhmmssff(:,1)+60.*hhmmssff(:,2)+hhmmssff(:,3)+hhmmssff(:,4).*(1/24);