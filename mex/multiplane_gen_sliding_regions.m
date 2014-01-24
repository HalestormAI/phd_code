function multiplane_gen_sliding_regions( minmax_coords, window_size, image_trajectories, step_size )
% Generate a series of sliding regions within the imaged scene
%
% Usage:
% R = MULTIPLANE_GEN_SLIDING_REGIONS( MM, WS ) 
%     Generates a number of region structs, with window size WS within the
%     bounds defined by MM. MM could be created using:
%       MM = minmax([T_i{:}]);
%
% R = MULTIPLANE_GEN_SLIDING_REGIONS( MM, WS, I_t ) 
%     As above, but also populates the ``traj'' field of the regions
%     structs with trajectory segments occuring within the region window.
%
% R = MULTIPLANE_GEN_SLIDING_REGIONS( MM, WS, I_t, SS ) 
%     As above, but instead of creating the window at every pixel, SS
%     defines the step-size in pixels between regions.
%     
% SEE ALSO: MINMAX
%
% N.B. This is provided for help-text only. Actual function is
% multiplane_gen_sliding_regions.cpp