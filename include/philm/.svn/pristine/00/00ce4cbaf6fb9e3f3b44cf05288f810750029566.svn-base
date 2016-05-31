function outval=mtxcode(codestruc,inval,codemode,missingflag);
%MTXCODE encode and decode data
% function outval=mtxcode(codestruc,inval,codemode);
% mtxcode: Version 20.8.99
%
%	Syntax
%		codestruc
%			A structure with fields in, out, function_in, function_out
%			In contains the list of coded values. 
%			Currently each coded value must be a scalar
%			out contains the corresponding decoded value
%			the decoded value can be a scalar, a vector, or a cell (any contents possible)
%			function_in and _out, if present, are the names of functions
%			converting from decoded to encoded (_in) or vice-versa (_out)
%			This can be a much faster alternative to searching the list each time
%		codemode
%			'encode', or 'decode'
%		missingflag
%			optional. When decoding, if present and true, then no warning is
%			issued if inval contains values not matched in codestruc.in
%			The flag has no effect on the values returned in these cases.
%			These vary (unfortunately) depending on the format of codestruc.out
%				cell array: return empty cell
%				string matrix: return vector of blanks, corresponding to number
%					of colums in codestruc.out
%				numeric matrix: return vector of NaNs, corresponding to number
%					of colums in codestruc.out


modelist=str2mat('encode','decode');
vm=strmatch(codemode,modelist);
if length(vm)~=1
   disp(['mtxcode: Unknown code operation "' codemode '"']);
   outval=[];
   return;
end;

fieldlist=fieldnames(codestruc);

%determine whether to work with functions or lists....????



codes=codestruc.in;
decodes=codestruc.out;



if vm==2		%decode
   
   nval=length(inval);
   allowmissing=0;
   if nargin>3 allowmissing=missingflag;end;
   if iscell(decodes)
      
      outval=cell(nval,1);
   else
      if ischar(decodes)
         inival=' ';
         outval=rpts([nval size(decodes,2)],inival);
      else
         inival=NaN;
         outval=ones(nval,size(decodes,2))*inival;
      end;
      
   end;
   
   
   %use quickmode if codes are a simple list of adjacent integers
   %and if no missing codes can occur
   quickmode=0;
   if all(diff(codes)==1)
      if all(ismember(inval,codes))
         quickmode=1;
      end;
   end;
   
      
      if quickmode
         inuse=inval-codes(1)+1;
         try
            outval=decodes(inuse,:);
         catch
            disp('mmxcode: Error in quick decoding');
            disp(lasterr);
         end;
         
      else
         
         for ii=1:nval
            vv=find(codes==inval(ii));
            if length(vv)==1
               %this works both for a vector of cells, and for a normal matrix
               outval(ii,:)=decodes(vv,:);
            else
               %if missingcodes are expected, suppress error message
               if ~allowmissing
               disp(['mtxcode(decoding): Bad code?: ' num2str(inval(ii))]);
               disp('Indices in list of code values');
               disp(vv);
               end;
            end;
         end;
      end;		%quickmode vs. single mode
      
   end;		%decode
   