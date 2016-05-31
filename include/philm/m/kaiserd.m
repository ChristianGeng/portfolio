function b=kaiserd(Wp,Ws,alfa,Fs);
% KAISERD Help with Kaiser window low-pass filter design
% function b=kaiserd(Wp,Ws,alfa,Fs);
% kaiserd: Version 4.7.97
%
% Description
%   Mostly copied out of filtdemo.m
%   Wp and Ws are passband and stopband edge respectively
%   alfa is damping in dB desired at start of stopband
%   return coefficients for Kaiser window with desired specs.
%   Fs is optional and defaults to 1. Note: This is not the same as spec. used for fir1
%
% Warning
%   Currently no checks that passband and stop band edges are appropriate

	if nargin < 4 Fs=1; end;
	if nargin < 3
		error ('kaiserd: Not enough input args.');
	end;
        if alfa > 50,
            beta = .1102*(alfa - 8.7);
        elseif alfa >= 21,
            beta = .5842*((alfa-21).^(.4)) + .07886*(alfa-21);
        else
            beta = 0;
        end
        n = ceil((alfa - 8)/(2.285*(Ws-Wp)*2*pi/Fs));
	%ensure order is even, gives odd number of coefficients
	n=n+rem(n,2);
        Wc=Wp+(Ws-Wp)./2;
	Wc=Wc*(2./Fs);	%convert to Nyqvist f= 1
	b=fir1(n,Wc,kaiser(n+1,beta));
        ncof=length(b);
        disp (['kaiserd: Design has ' int2str(ncof) ' coefficients']);
