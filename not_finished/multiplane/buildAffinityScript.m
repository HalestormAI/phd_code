im_subset = cell2mat(regions');
mp_subset = coord2midpt( im_subset );

% Assign random labels to each vector
idxs = randi(size(estplanes,1),1, size(im_subset,2));
nPlanes = estplanes(idxs,:);

aff_sim = zeros(length(mp_subset));

for i=1:length(mp_subset),
    iidx = idxs(i);
    ePlane = estplanes(iidx,:);
    vec = im_subset(:,mpid2cid(i));
    parfor j=1:length(mp_subset),
        nMids = mp_subset(:,j);
        %costFn( vec, nMids, nPlanes, plane )
        if(i==j)
            aff_sim(i,j) = 0;
        else
            aff_sim(i,j) = -costFn(vec, nMids, nPlanes, ePlane );
        end;
    end
end

aff_sim