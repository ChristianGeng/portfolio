function M = simmx(A,B)
% SIMMX Calculate a sim matrix between specgram-like feature matrices A and B.
% function M = simmx(A,B)
% simmx: Version 25.5.07
%
%   Description
%       This is original code downloaded from web, with my standard help
%       lines (Phil)
%       size(M) = [size(A,2) size(B,2)]; A and B have same #rows.
%       2003-03-15 dpwe@ee.columbia.edu
%       Copyright (c) 2003 Dan Ellis <dpwe@ee.columbia.edu>
%       released under GPL - see file COPYRIGHT

EA = sqrt(sum(A.^2));
EB = sqrt(sum(B.^2));

%ncA = size(A,2);
%ncB = size(B,2);
%M = zeros(ncA, ncB);
%for i = 1:ncA
%  for j = 1:ncB
%    % normalized inner product i.e. cos(angle between vectors)
%    M(i,j) = (A(:,i)'*B(:,j))/(EA(i)*EB(j));
%  end
%end

% this is 10x faster
M = (A'*B)./(EA'*EB);
