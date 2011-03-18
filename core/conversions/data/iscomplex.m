function [ isit ] = iscomplex( n )
%ISCOMPLEX Summary of this function goes here
%   Detailed explanation goes here

   isit = ~(abs(imag(n))<abs(1e-15*real(n)));


end

