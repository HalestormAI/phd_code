function [ imc ] = wc2im( wc, alpha )
% Converts 3D world coordinates into 2D image coordinates.
%  We divide the X and Y components by the the normalisation factor,
% alpha, times the Z component. The normalisation factor is the
% reciprocol of max(size(img)).
%
% INPUT:
%   wc      A 3xn set of coordinates (Ci1,Cj1,Ci2,Cj2,...)
%   alpha   Normalisation factor
%
% OUTPUT:
%   imc     A 2xn set of coordinates in the same ordering as wc.

    imc = zeros( 2, size(wc,2) );
    for i=1:size(wc,2),
        imc(1,i) = wc(1,i) / (alpha*wc(3,i));
        imc(2,i) = wc(2,i) / (alpha*wc(3,i));
    end
end