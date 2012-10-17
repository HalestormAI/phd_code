function regionTrajs = generate_irregular_region_trajectories( imTraj, regionImgs, img_offset )

    % For each region
    
    regionTrajs = cell(length(regionImgs),1);
    
    for r=1:length(regionImgs)
        regionTrajs{r} = {};
        for t=1:length(imTraj)    
            out = makeTrajectoryPieces( imTraj{t}, regionImgs{r}, img_offset );
            regionTrajs{r} = cat(1,regionTrajs{r}, out);
        end
    end
    
    function trajOut = makeTrajectoryPieces( traj, img, img_offset )
        
        trajIn = zeros(1,length(traj));
        
        for pt=1:length(traj)
            trajIn(pt) = pointInRegion( traj(:,pt), img, img_offset );
        end
        
%         trajIn
        
        [ids, in] = SplitVec( trajIn ,'equal','index','firstval' );
        
        if sum(in)
            trajOut = cell(sum(in),1);

            numin = 1;
            for i=1:length(in)
                if in(i)
                    trajOut{numin} = traj(:,ids{i});
                    numin = numin+1;
                end
            end
        else
            trajOut = {};
        end
    end
    
    function isit = pointInRegion( p, img, img_offset )
       
        if nargin > 2
            p_new = p - img_offset;
        else
            p_new = p;
        end
%         scatter( p_new(1), p_new(2), '*r');
        isit = logical(img( round(p_new(1)), round(p_new(2)) ));
    end
end