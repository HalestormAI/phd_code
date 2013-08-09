function [error,rectified] = multiplane_global_error( params, num_planes, traj )

    
        s_params = multiplane_global_extract_parameters( params );
        
        if num_planes > (length(s_params.chain)+1)
            error('Number of planes ~= number of param sets');
        end
        
        rectified = cell(num_planes,1);
        
        % Rectify plane 1 given parameter set
        rectified{1} = cellfun(@(x) backproj_c(s_params.ref_plane.theta, ...
                                               s_params.ref_plane.psi, ...
                                               s_params.ref_plane.d,...
                                               s_params.alpha, ...
                                               x ...
                                    ),  traj,'un', 0);
    
        for p=2:num_planes
            rectified{p} = hinged_rectify_plane( s_params.chain(p-1), traj );
        end
            

end