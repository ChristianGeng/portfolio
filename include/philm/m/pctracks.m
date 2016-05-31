function pctracks(matin,matout,nmat,ndec,eigvec,xbar,sd,addcomment);
% PCTRACKS Computes principal component scores for a list of mat files
% function pctracks(matin,matout,nmat,ndec,eigvec,xbar,sd,addcomment);
% pctracks: Version ??? (untested??)
%        (can also be used as a skeleton m-file for similar kinds
%        of mat file processing)
%        matin/out: first part of mat file name
%        nmat: number of mat files, assumed identified by number in
%              last part of file name (numbering starting from 1);
%        ndec: number of decimal digits for file number
%        eigvec: eigenvector matrix, from PC analysis
%                number of rows must equal number of columns in
%                input mat files. Number of columns determines
%                number of principal component tracks generated:
%                calling program should select desired columns
%                from complete eigenvector matrix generated during PC analysis
%        xbar, sd: means and standard deviations, for normalizing
%              input variables, probably produced during PC analysis
%              vector length must be equal to number of columns in
%              input mat files
%              output mat file contains following variables:
%              data, descriptor (generated automatically), unit (dummy),
%                    comment ("addcomment" from calling program, plus any
%                    existing comment in the input mat file

functionname='pctracks: Version 29.1.97';
dataname='data';
%generate descriptors
npc=size(eigvec,2);
descriptor='';
unit='';
bls='  ';
for loop=1:npc
    pcs=['PC' int2str(loop)]
    eval ('descriptor=str2mat(descriptor,pcs);');
    eval ('unit=str2mat(unit,blss);');
end;
%eliminate first row
descriptor(1,:)=[];
unit(1,:)=[];

for loop=1:nmat
    %open input file
    filein=[matin int2str0(nmat,ndec)];
    fileout=[matout int2str0(nmat,ndec)];
    disp ([int2str(loop) ' ' filein]);
    data=mymatin(filein,dataname);
    %assume empty corresponds to error
    if isempty(data)
        error ('No data in this trial');
    end;
    %check consistent size
    [nsamp,incol]=size(data);
    
    temp=ones(size(data,1),1);
    data=data-(temp*xbar);
    data=data./(temp*sd);
    
    data=data*eigvec;
    oldcomment=mymatin(filein,'comment');
    oldcomment=setstr(oldcomment);
    comment=[functionname crlf addcomment crlf oldcomment];
    
    eval (['save ' fileout 'data descriptor unit comment'];
end;
