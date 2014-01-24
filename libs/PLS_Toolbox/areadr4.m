function [out] = areadr4(file,strng,nrow);
%AREADR4 reads ascii text and converts to a data matrix
%  Input is (file) an ascii string containing the file name
%  to be read, (strng) the first few characters of the first
%  number to be read (used to skip header information) and
%  (nrow) the number of rows common to the input data and
%  the output data matrix (out).
%
%Warning: conversion may not be successful for files from
%  other platforms.
%
%I/O: out = areadr4(file,strng,nrow);
%
%See also: AREADR1, AREADR2, AREADR3

%Copyright Eigenvector Research, Inc. 1996-98

[fid,message] = fopen(file,'r');
if fid<0
  error(message)
end
ns          = length(strng)-1;
i           = 0;
j           = [];
line        = fgets(fid);
while isempty(j)
  i         = i+1;
  if strcmp(line(i:i+ns),strng)
    j       = i;
  end
end
status      = fseek(fid,i,'bof');
if status<0
  [message,errnum] = ferror(fid);
  error(message)
end
[a,count]    = fscanf(fid,'%g',[inf]);
[na,ma]      = size(a);
no           = na/nrow;
if (no-floor(no))~=0
  s = ['Error-Number of columns nvar does'];
  s = [s,' not appear to be correct for file ',file];
  error(s)
elseif count<1
  disp('Conversion does not appear to be successful')
else
  for i=1:nrow
    jj       = (i-1)*no;
    j        = [jj+1:jj+no];
    out(i,:) = a(j,1)';
  end
end
fclose(fid);
