function p=desc2struct(d)
% DESC2STRUCT Convert list of parameter names to field names of struct
% function p=desc2struct(d)
% desc2struct: Version 25.3.07
%
%   Notes
%       If list of parameter names is ambiguous then the list and the
%       unique list is displayed, the function enters keyboard mode, and
%       after 'return' the returned structure is empty
%       Same behaviour if an illegal field name is encountered

p=[];

if iscell(d) d=char(d); end;
n=size(d,1);

du=unique(d,'rows');

if size(du,1)~=n
    disp('desc2struct: parameter names are not unique. Returned structure will be empty');
    disp('Input parameter names');
    disp('=====================');
    disp(d);
    disp('Unique list');
    disp('===========');
    disp(du);
    keyboard;
    return;
end;



for ii=1:n
   s=deblank(d(ii,:));
    sold=s;
   s=strrep(s,'<','');
    s=strrep(s,'>','');
    if ~strcmp(sold,s)
        disp(['desc2struct: Fields modified: ' sold ' ' s]);
    end;
    
   try
      eval(['p.' s '=' int2str(ii) ';']);
   catch
      disp(['desc2struct: Unable to set field  " ' s '"']);
      keyboard;
      p=[];
      return;
      
   end;
end;
