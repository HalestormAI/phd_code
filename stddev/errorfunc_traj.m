function [E,meanLength,stdLength,rectTrajectories] = errorfunc_traj( orientation, scales, trajectories, DEBUG, backproj_func )   

    if nargin < 4
        DEBUG = false;
    end
    
    if nargin < 5 || isempty(backproj_func)
        backproj_func = @backproj_c;
    end
    
    imc = traj2imc(trajectories,1,1);
    
    [E,meanLength,stdLength,rectTrajectories] = errorfunc( orientation, scales, imc, DEBUG, backproj_func );
end
