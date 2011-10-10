E_d_planes = cell(size(estplanes,1),2);
for p=1:size(estplanes,1),
    count = 1;
    for v=find(vecplanes==1),
        cid = mpid2cid( v );
        x = im_coords(:,cid);
        E_d_planes{p,1}(count) = dist_eqn(estplanes(p,:),x);
        count = count + 1;
    end
    disp('loop 1 done')
    count = 1;
    for v=find(vecplanes==2),
        cid = mpid2cid( v );
        x = im_coords(:,cid);
        E_d_planes{p,2}(count) = dist_eqn(estplanes(p,:),x);
        count = count + 1;
    end
    disp('loop 2 done')
end