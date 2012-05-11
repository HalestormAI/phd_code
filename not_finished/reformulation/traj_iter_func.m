function F = traj_iter_func( x, trajectories, func_handle, inner_func_handle )
    
    if nargin < 3 || isempty(func_handle),
        func_handle = @traj_F;
    end
    if nargin < 4 || isempty(inner_func_handle),
        inner_func_handle = [];
    end

    % get lengths of all trajectories and sum to predefine array
    lengths = cellfun(@length,trajectories)./2;
    
    F = zeros(1,sum(lengths));

    F(1:lengths(1)) = func_handle( trajectories{1}, 1, x, 1, inner_func_handle );
    curLength = lengths(1);
    for t = 2:length(trajectories),
        F(curLength+1:curLength+lengths(t)) = func_handle( trajectories{t}, t, x, 0, inner_func_handle );
        curLength = curLength+lengths(t);
    end
    
%     if x(4) > 0
%          F = F.^2;
%     end
end