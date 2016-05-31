function helptxt=helpme(myfile,varargin);
% HELPME Phil's version of help. Allows keywords
% helptxt=helpme(myfile,varargin);
% helpme: Version 10.04.2012
%
%	Syntax
%
%		Command line
%			Can be used as a command rather than a function (easier to type)
%			e.g "helpme mt_gdata syntax" corresponds to "helpme('mt_gdata','syntax')"
%			(this only works where keywords don't have blanks, 
%			so as a special case "see also" can also be written "see_also")
%
%		myfile: m-file for which help is wanted. Compulsory
%
%		varargin:
%			Optional. If missing, or present but empty, complete help text is displayed
%			If present, only the help text for the topic at the level of indentation
%			determined by the number of arguments in varargin is displayed.
%			If a topic is not found, the 3-line summary help text plus a table of topics up to
%			the level of indentation determined by varargin is displayed
%			Topic names need not be complete (and can be ambiguous)
%			Special case for "see also" (or "see_also"): If first argument in varargin is "see also"
%				and if further arguments follow, then helpme is called recursively for
%				each topic listed under "see also", using the remaining arguments in the call.
%				Giving multiple "see also" arguments thus allows multiple levels of recursion
%
%		helptxt: Optional output argument. If it is absent (which it probably will be, if using
%			the command line syntax) then the help text is displayed in a matlab help window
%
%	Examples
%		helpme('myfile'):	Complete help
%		helpme('myfile','topic1'):	Help for topic1
%		helpme('myfile','topic1','topic1_1'):	Help for (sub)topic1_1 in topic1
%		helpme('myfile','topic3','topic3_2','topic3_2_4'):	Help for (subsub)topic3_2_4 in (sub)topic3_2 in topic3
%		helpme('myfile','x','y'): Assuming there is no topic x, or subtopic y, this displays the table of topics
%			up to the 2nd level of indentation
%		helpme('myfile','see also','see also','see also'): Recursive helpme call through see also topics
%		helpme('helpme','s'):	The helpme function has two topics starting with 's'
%			namely 'Syntax' and 'See also'. Both will be shown
%		Below are examples of indentation of topic headings:
%			Note that each must be preceded by a blank line
%
%	topic2
%		blabla2
%
%		topic21
%			blabla21
%			more blabla at level 21
%
%			topic211
%				blabla211
%
%		topic22
%			blabla22
%
%	See also
%		VARARGIN HELPWIN
%
%   Updates 04.2012 handling of tabs and blanks improved (but still not
%   very good)

if nargout helptxt=[];end;
if isempty(myfile) return; end;
ss=help(myfile);
if isempty(ss) 
   disp([myfile ': no file or no help?']);
   
   return; 
end;

%convert tabs to blank (not very elegant)
%assume first tab preceded by '%' (already stripped), so will be one blank
%less
tablen=4;
tablen1=tablen-1;
ss=strrep(ss,setstr([9 9 9]),blanks(tablen1+tablen+tablen));
ss=strrep(ss,setstr([9 9]),blanks(tablen1+tablen));
ss=strrep(ss,setstr(9),blanks(tablen1));
%keyboard;
if nargin==1
   helpres=ss;
end;
   doseealso=0;
if nargin>1
   ssm=rv2strm(ss,crlf);
   ll=size(ssm,1);
   lb=[];
   topcol=[];
   
   %build up a list of topics, and their indentation level
   
   for ii=1:ll-1
      if length(deblank(ssm(ii,:)))==0 
         tmp=find(~isspace(ssm(ii+1,:)));
         if ~isempty(tmp)
            lb=[lb ii]; 
            %determine identation of topic name
            topcol=[topcol min(tmp)];
            %disp(lb);
         end;
      end;
   end;
   
   collist=unique(topcol);
   topindent=topcol;
   nuq=length(collist);
   for ii=1:nuq
      vv=find(topcol==collist(ii));
      topindent(vv)=ii;
   end;
%   disp(lb)
%   disp(topindent);
   
   %dummy level 0 ident at last line. Ensures search for topic stops
   lb=[lb ll];
   topindent=[topindent 0];
   nlb=length(lb);   
   
   myargin=lower(varargin);
   myargin=strrep(myargin,'see_also','see also');
   
   check1=myargin{1};
   varguse=myargin;
   if length(myargin)>1
   if strcmp(check1,'see also')
      varguse=myargin(1);
      seealsoarg=myargin(2:end);
      doseealso=1;
   end;
   end;
   
   
   
   narg=length(varguse);
   
   igo=1;iend=nlb;
   helpres=ssm(1:(lb(1)-1),:);
	stillok=1;   
   for iarg=1:narg
      if stillok
      mykey=varguse{iarg};
      %try and match keyword
      %should be only text on line following blank line
      foundone=0;
      for ii=igo:iend
         if topindent(ii)==iarg
            testit=deblank(ssm(lb(ii)+1,:));
            testit=fliplr(deblank(fliplr(testit)));
            mykey2=mykey;
            if isempty(mykey) mykey2=testit; end;	%empty matches anything
            if ~isempty(strmatch(lower(mykey2),lower(testit)))
               igo=ii;
               vv=find(topindent<=iarg);
               vv1=find(vv>ii);
               iend=vv(vv1(1));
               foundone=1;
               if iarg==narg
                  topicres=ssm(lb(igo):lb(iend),:);
                  helpres=[helpres;topicres];
               end;
               
               
            end;		%strmatch
         end;		%topindent==iarg
         
      end;		%lb loop
		if ~foundone stillok=0; end;      
   end;		%still ok   
   end;		%argument loop
   
   
   %if topic wasn't found
   
   if ~stillok
      topindent(end)=[];
      vv=find(topindent<=narg);
      helpres=[helpres;ssm(lb(vv)+1,:)];
   	doseealso=0;   
   end;
   
   
   
   %   keyboard;
   helpres=strm2rv(helpres,10);
end;


%disp(helpres);

if doseealso
   seelist=see_also_parse(strm2rv(topicres,10));
   if ~isempty(seelist)
   nsee=length(seelist);
%   keyboard
   for isee=1:nsee
%      disp(seelist{isee});
      seealsoresult=helpme(seelist{isee},seealsoarg{:});
   	helpres=[helpres crlf seealsoresult];   
   end;
end;   
end;

if nargout 
   helptxt=helpres;
else
   spec=[];
   if nargin>1
   spec=strm2rv(char(varargin),'>');
   spec(end)=[];
   end;
   helpwin(helpres,[myfile ': ' spec]);
end;

function mytopics=see_also_parse(helpstr);
% SEE_ALSO_PARSE uses code from helpwin to get a list of topics listed in see also

% Enable links to the related topics found after the 'See Also'.
%      seealso=max(findstr(helpstr,'See also'));  % Finds LAST 'See Also'.
%      overind = max(findstr(helpstr,'| Overloaded methods'));
mytopics=[];
if ~isempty(helpstr)
   p=1;
   cnt=0;
   lmask=[isletter(helpstr)];
   umask=helpstr==upper(helpstr);
   undmask=helpstr=='_';
   nmask = [((helpstr >= '0') & (helpstr <= '9'))];	%whats this for?
   rmask=[(lmask&umask | undmask | nmask) 0];	%last element =false
   ln=length(helpstr);
%   keyboard
   while 1
      q=p;
      while ~rmask(p) & p<ln
         p=p+1;
      end
      q=p+1;
      if q>=ln, break; end
      while rmask(q)
         q=q+1;
      end
      if q>p+1,  % Protects against single letter references.
      	cnt=cnt+1;
         ref{cnt}=lower(helpstr(p:q-1));
      end
      p=q;
   end
if cnt mytopics=ref; end;
end
