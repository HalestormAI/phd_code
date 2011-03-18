function F = getAnglesFromRotation( x_i, R )

theta = x_i(1);
psi   = x_i(2);
gamma = x_i(3);

R_theta = [ 1     0           0       0
            0 cos(theta) -sin(theta)  0
            0 sin(theta)  cos(theta)  0
            0     0           0       1];
        
R_psi   = [ cos(psi)  0  sin(psi)  0
               0      1     0      0   
           -sin(psi)  0  cos(psi)  0
               0      0     0      1];
        
R_gamma = [ cos(gamma) -sin(gamma)  0  0
            sin(gamma)  cos(gamma)  0  0
                0            0      1  0
                0            0      0  1];
          
%R_all = R_theta * R_psi * R_gamma;

R_all = R_gamma * R_psi;

R_fixed = [R, zeros(3,1); 0 0 0 1];

F = R_fixed - R_all;
        
