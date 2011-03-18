function [validn, validd] = checkPlaneValidity( myplane )
% Checks if the following assumptions hold for a given plane:
%   \theta is between 0 and 60  degrees
%   \psi is between -25 and 25 degrees
%   d is between 2 and 10.
% Input:
%   myplane: A 4-d vector consisting of [d,n_x,n_y,n_z]
%
% Output:
%   validn:  Boolean representing validity of \theta and \psi
%   validd:  Boolean representing validity of d

TOL = 0;

% N must be unit
unitn = isunit( myplane(2:4) );

% Check yaw and elevation angles
[theta,psi] = anglesFromN( myplane(2:4) );
theta = rad2deg( theta );
psi   = rad2deg( psi );
TOL_theta = theta * TOL;
TOL_psi   = psi * TOL;
validTheta = (theta-TOL_theta >= 0) && (theta+TOL_theta <= 60);
validPsi = (psi-TOL_psi >= -45 ) && (psi+TOL_psi <= 45);

validn = unitn && validTheta && validPsi;

% d must lie between 2 and 10
validd = (2 <= myplane(1)) && (myplane(1) <= 10);
