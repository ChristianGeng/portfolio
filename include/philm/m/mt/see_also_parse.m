function mytopics=see_also_parse(helpstr);
% SEE_ALSO_PARSE uses code from helpwin to get a list of topics listed in see also

% Enable links to the related topics found after the 'See Also'.
%      seealso=max(findstr(helpstr,'See also'));  % Finds LAST 'See Also'.
%      overind = max(findstr(helpstr,'| Overloaded methods'));
      if ~isempty(helpstr)
         p=1;
         cnt=0;
         lmask=[isletter(helpstr)];
         umask=helpstr==upper(helpstr);
         undmask=helpstr=='_';
         nmask = [((helpstr >= '0') & (helpstr <= '9'))];	%whats this for?
         rmask=[(lmask&umask | undmask | nmask) 0];	%last element =false
         ln=length(helpstr);
         keyboard
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
            cnt=cnt+1;
            if q>p+1,  % Protects against single letter references.
               ref{cnt}=lower(helpstr(p:q-1));
            end
            p=q;
         end
      end
      mytopics=ref;
      