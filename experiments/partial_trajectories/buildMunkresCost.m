function [costMat, proxs,angles] = buildMunkresCost( v_t1, v_t2, w )
% Build the cost matrix for Munkres (Hungarian) algorithm in terms of 
% matching vectors at t=1 to vectors in t=2 through a weighted cost of
% direction against proximity.


    if nargin < 3,
        w = 0.5;
    end
%     proxs   = zeros(size(v_t1,2)/2, size(v_t2,2)/2);
    angles  = zeros(size(v_t1,2)/2, size(v_t2,2)/2);
    costMat = zeros(size(v_t1,2)/2, size(v_t2,2)/2);

    for i=1:2:size(v_t1,2),
        for j=1:2:size(v_t2,2),

            % Cost Matrix Indices
            idx1 = cid2mpid( i );
            idx2 = cid2mpid( j );
            % Find proximity of endpoint at t1 to startpoint at t2
            proxs(idx1,idx2)  = vector_dist(v_t1(:,i+1), v_t2(:,j));
            % Get direction vectors for vectors at t1 and t2
            d_t1 = drn(v_t1(:,i:i+1));
            d_t2 = drn(v_t2(:,j:j+1));
            % Find angle between (radians)
            angles(idx1,idx2) = acos(dot(d_t1,d_t2)/(norm(d_t1)*norm(d_t2)));
        end
    end

    % Normalise angles and proxs S.T. values in R [0, ... ,1]
    proxs  = real(proxs  ./ max(max(proxs )));
    angles = real(angles ./ max(max(angles)));
    costMat = w*proxs + (1-w)*angles;
    
    function d = drn( imc )
        d = imc(:,1) - imc(:,2);
    end
end