function [ ind ] = find_wrong_n( r, accuracy, lds )
%FIND_WRONG_N Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1,
    error('Not enough args - need results');
elseif nargin < 2,
    accuracy = 0.001;
end

rounding = 1 / accuracy;

sz = zeros(1, size(r,2) );
for i=1:size(r,2),
    sz(i) = vec_size(r(:,i));
end

% Normalise the sizes so that we round to n DP
sz_n = round((sz .* rounding)) ./ rounding;
% Now minus 1 to get non-zero elements
sz_n = sz_n - 1;


ind = find(sz_n)

end

