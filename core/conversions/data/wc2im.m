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

%     imc = zeros( 2, size(wc,2) );
%     for i=1:size(wc,2),
%         c(1) = wc(1,i) / (alpha*wc(3,i));
%         c(2) = wc(2,i) / (alpha*wc(3,i))
%         imc(:,i) = c;
%     end
%imc = wc(1:2,:) .* repmat((ones(1,size(wc,2)) ./ ( alpha.*wc(3,:))),2,1);

imc(1,:) = wc(1,:) ./ (alpha*wc(3,:));
imc(2,:) = wc(2,:) ./ (alpha*wc(3,:));
end
