function [w,docstr]=kaiserdw(Ws,alfa,Fs);
% KAISERDW Help with use of Kaiser window as low-pass filter
% function [w,docstr]=kaiserdw(Ws,alfa,Fs);
% kaiserdw: Version 23.6.03
%
% Description
%   Originally mostly copied out of filtdemo.m
%   uses very rough heuristic to get damping of at least alpha at all
%   frequencies above Ws
%   Fs is optional and defaults to 1. Note: This is not the same as spec. used for fir1
%   Note: Difference to KAISERD is that this function returns the kaiser
%   window itself, NOT the filter coefficients output from use of the kaiser
%   window with the FIR1 filter design function
%   docstr returns the actually used call to kaiser as a text string for
%   documentation purposes
%
% Warning
%   Currently no checks that passband and stop band edges are appropriate

%	if nargin < 4 Fs=1; end;
%	if nargin < 3
%		error ('kaiserd: Not enough input args.');
%	end;

Wp=0;
alfa=alfa+30;        %!!!!seems to work out about right
if alfa > 50,
            beta = .1102*(alfa - 8.7);
        elseif alfa >= 21,
            beta = .5842*((alfa-21).^(.4)) + .07886*(alfa-21);
        else
            beta = 0;
        end
        n = ceil((alfa - 7.95)/(2.285*(Ws-Wp)*2*pi/Fs));
        n=n+1;	
        %rough try, seems to work out about right
        n=round(n/2);
        %ensure order is even, gives odd number of coefficients
	n=n+rem(n,2);
%        Wc=Wp+(Ws-Wp)./2;
%	Wc=Wc*(2./Fs);	%convert to Nyqvist f= 1
	w=kaiser(n+1,beta);
        ncof=length(w);

        w=w/sum(w);
        disp (['kaiserdw: Design has ' int2str(ncof) ' coefficients']);
docstr=['kaiser(' int2str(ncof) ',' num2str(beta) ')'];
