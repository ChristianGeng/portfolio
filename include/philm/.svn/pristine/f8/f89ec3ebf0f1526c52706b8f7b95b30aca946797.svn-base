function [newx,newy]=transrot(oldx,oldy,transx,transy,rotang)
% TRANSNROT Translate and rotate 2D coordinates
% function [newx,newy]=transrot(oldx,oldy,transx,transy,rotang)
% transnrot: Version 21.6.99
%
%	Syntax
%		transx and transy are added to oldx/y. Result is rotated by rotang (given in degrees)


newx=oldx+transx;
newy=oldy+transy;

	rad=rotang*pi./180;
		zr=cos(rad)+i*sin(rad);
		zz=(newx+(i*newy)).*zr;
      newx=real(zz);
      newy=imag(zz);
