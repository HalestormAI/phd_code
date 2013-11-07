function [param_struct] = multiplane_global_extract_parameters( params )
% Takes a vector of numbers representing global plane parameters and
% creates a structure containing formatted params.  
%   params = [alpha,theta_1,psi_1,d_1,b1_sx,b1_sy,b1_ex,b1_ey,gamma_1,...]
%
% Output format:
%   p
%   |    .alpha
%   |
%   |    .ref_plane
%   |       |  .theta
%   |       |  .psi
%   |       |  .n
%   |       |  .d
%   |
%   |    .chain
%   |       |  .boundary
%   |       |      |   .start [x;y]
%   |       |      |   .end   [x;y]
%   |       | 
%   |       |  .gamma
%
    param_struct.alpha           = params(1);
    param_struct.ref_plane.theta = params(2);
    param_struct.ref_plane.psi   = params(3);
    param_struct.ref_plane.d     = params(4);
    param_struct.chain = struct('boundary',{},'gamma',{});
    
    for p=5:5:length(params)
        if (length(params)-p) >= 5
            
            pln.boundary.start = params(p:(p+1))';
            pln.boundary.end   = params((p+2):(p+3))';
            pln.gamma          = params(p+4);
            
            param_struct.chain(p/5) = pln;
        end
    end
end