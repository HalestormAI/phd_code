function [newplanes,matches] = cleanEstimateSet( planes )
    THRESHOLD = 0.5;
    
    % Find the pairwise angles between each $n$
    D_n = ones(size(planes,1));
    for i=1:size(planes,1),
        for j=1:size(planes,1),
            D_n(i,j) = real(acos(dot(planes(i,2:4),planes(j,2:4))));
        end
    end

    % Find the pairwise distances in $d$
    D_d = squareform(pdist(planes(:,1)));

    % Normalise each over max, then get product
    D = (D_d ./ max(max(D_d))) .* (D_n ./ max(max(D_n)));
    D = D + diag(ones(1,size(planes,1)));
    [I,J]=ind2sub(size(planes,1),find(D < THRESHOLD));
    matches = unique(sort([I,J],2),'rows');
    
    if ~isempty(matches),
        
        % Find all connected components (by index) and get their mean
        COMPIDX = getConnectedComponents( matches );
        meanplanes = cell2mat(cellfun(@(x) ...
                                joinMatch(x,planes),...
                                COMPIDX,...
                                'UniformOutput',false)'...
                            );
                        
        % Now find all individual rows (any who aren't in a component)
        newplanes = planes(setxor(unique(cell2mat(COMPIDX)),1:size(planes,1)),:);


        newplanes = [newplanes;meanplanes];
    else
        newplanes = planes;
    end

    function mn = joinMatch( idxs, planes )
        mn = mean(planes(idxs,:));
    end

end