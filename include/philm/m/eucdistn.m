function d=eucdistn(data1,data2,squareflag);
% EUCDISTN Calculate euclidean distance for vectors of any length
% function d=eucdistn(data1,data2,squareflag);
% eucdistn: Version 5.7.2001
%
% Syntax
%		data1 and data2 are sets of m vectors of length n
%		squareflag: Optional; default to false; if true, return squared distances
% 		output is a column vector of length m
%		should check sizes match!!

leavesquare=0;
if nargin>2 leavesquare=squareflag; end;

dd=data1-data2;
d=(sum((dd.^2)'))';

if ~leavesquare d=sqrt(d); end;
