function [E,meanLength,stdLength] = errorfunc_traj( orientation, scales, trajectories, DEBUG )   

    
    if nargin < 4
        DEBUG = false;
    end
    
    imc = traj2imc(trajectories,1,1);
    
    [E,meanLength,stdLength] = errorfunc( orientation, scales, imc, DEBUG );
end
