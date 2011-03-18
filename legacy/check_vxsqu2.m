function vx = check_vxsqu(  )
%CHECK_VXSQU Summary of this function goes here
%   Detailed explanation goes here

d=4;ny=5;vy=9;nz=2;vz=4;nx=8;l=8;x1=2;y1=3;d=1.5;Z1=12;

vx = (d - ny*vy - nz*vz) / nx;
vx

l2 = sqrt( x1^2 + vx^2 - 2*vx*x1 + y1^2 + vy^2 - 2*y1*vy + Z1^2 + vz^2 - 2*Z1*vz )

l2_def = sqrt( (x1 - vx) ^ 2 + (y1 - vy) ^2 + (Z1 - vz)^2 )

end

