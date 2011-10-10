function [validn,validalpha] = checkPlaneValidity( myplane )
% Checks if the following assumptions hold for a given plane:
%   \theta is between 0 and 60  degrees
%   \psi is between -25 and 25 degrees
%   d is between 2 and 10.
% Input:
%   myplane: A plane structure.
%
% Output:
%   validn:  Boolean representing validity of \theta and \psi
%   validd:  Boolean representing validity of d

TOL  =  0;
MAXD = 20;
MIND =  2;

d = 1/norm(myplane.abc);

unitn = myplane.abc .* d;
% N must be unit
% unitn = isunit( myplane.n )

% Check yaw and elevation angles
[theta,psi] = anglesFromN( unitn );
theta       = rad2deg( theta );
psi         = rad2deg( psi );
TOL_theta   = theta * TOL;
TOL_psi     = psi * TOL;
validTheta  = (theta-TOL_theta >= 0) && (theta+TOL_theta <= 80);
validPsi    = (psi-TOL_psi >= -45 ) && (psi+TOL_psi <= 45);

validn      = validTheta && validPsi;
validalpha  = abs(myplane.alpha) < 1;

% d must lie between MIND and MAXD
validd = (MIND <=d) && (d <= MAXD);
