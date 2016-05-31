function prompter_playwav(mymode,mystim)
% function prompter_playwav(mymode,mystim)
% wav output in prompt programs
%   mymode: 'start', 'end', 'list'
%   mystim: Only relevant in list mode. Stimulus number. If not present,
%   retrieved from main data structure
%
%   Notes
%       13.06.2012
%       start basing use on audioplayer objects rather than the old sound
%       function.
%       This has the potential advantages that with asynchronous sound
%       output it becomes possible to stop sound under program control, to
%       query how far sound output has progressed, and to define additional
%       timer-controlled callbacks.
%       This change was triggered by the fact that R2012 now implements
%       sound with the playblocking function, making asynchronous operation
%       impossible.
%       There seem to have been some memory issues with audioplayer (see
%       links below to disscusion fora); no idea yet if they are still
%       relevant.
%       The new approach means that play back of wavstart and wavend may
%       start more promptly (mainly relevant for AG500 etc. which triggers
%       wavstart after detecting the attention signal). Nevertheless, for
%       really precise audio control it is probably better to use the data
%       acquisition toolbox

try
    if strcmp(mymode,'list')
        
        if nargin<2
            P=prompter_gmaind;
            mystim=P.istim;
        end;
        S=prompter_gstimd;
        wavlist=S.wavlist;
        tmpname=deblank(wavlist(mystim,:));
        [wavd,sf,mybits]=wavread(tmpname);
        asyncflag=S.wavlist_async;
    myplayer=audioplayer(wavd,sf,mybits);
%not necessary to store the player object if output is synchronous
    if asyncflag
    S.wavlist_player=myplayer;
    prompter_sstimd(S);
    end;
    
    
        
    else
        
        A=prompter_gwaved;
        %check required fields exist?
%        wavd=A.(['wav' mymode '_d']);
        myplayer=A.(['wav' mymode '_player']);
        sf=A.(['wav' mymode '_sf']);
%        mybits=A.(['wav' mymode '_bits']);
        asyncflag=A.(['wav' mymode '_async']);
        
    end;
    
        play(myplayer);
    if ~asyncflag
        tmppause=get(myplayer,'TotalSamples')/sf;
        pause(tmppause);
    end;

% the crucial point about audioplayer seems to be that the player object
% has to be stored outsided the function that calls play, otherwise
% the object will be deleted when the function terminates (which would
%abort asynchronous output

    %for start and end the player is created when the wav file is read
    %    myplayer=audioplayer(wavd,sf,mybits);
%in one of the online discussions about audioplayer there was a suggestion
%that an explicit pause might give callbacks a better chance to run than
%playblocking

%    if asyncflag
%        play(myplayer);
%    else
%        playblocking(myplayer);
%    end;

%http://www.mathworks.com/matlabcentral/answers/18530-audioplayer 
%http://blogs.mathworks.com/loren/2008/07/29/understanding-object-cleanup/
    
    %around version 2012a matlab suddenly started using the blocking version of
%audioplayer as the implementation of sound
    %    sound(wavd,sf,mybits);
%    if ~asyncflag
%        tmppause=length(wavd)/sf;
%        pause(tmppause);
%    end;
    
catch
    disp(['prompter_playwav: problem playing audio in mode ' mymode]);
    disp(lasterr);
    keyboard;
end;
