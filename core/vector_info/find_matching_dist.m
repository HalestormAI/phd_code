function [ a ] = find_matching_dist( dss )
%FIND_MATCHING_DIST Summary of this function goes here
%   Detailed explanation goes here


h = waitbar( 0, 'Finding Matching Distances' );
for i=1:size(dss,2),
    waitbar( i/size(dss,2) );
    a = [ ];
    for j=i+1:size(dss),
        if ceil(dss(i)) == ceil(dss(j))
            a(:,cnt) = [i;j; dss(i)];
        end
    end
end

close(h);