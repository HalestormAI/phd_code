function [ f_idx, e_idx, f, e ] = get_erroneous_lds( lds, minim )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

lds
minim

e_idx = find( lds < minim )
f_idx = setxor( e_idx, 1:size(lds,2) )

e = lds(e_idx);
f = lds(f_idx);
end

