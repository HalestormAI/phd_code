function [vs] = nastyquad( l )

d=4;ny=5;vy=9;nz=2;nx=8;x1=2;y1=3;d=1.5;Z1=12;



a = nz^2 + nx^2

b = 2*d*nz + 2*vy*ny*nz - 2*x1*nx*nz - Z1*nx^2

c = nx^3*l^2 - nx^2 * (x1^2 + y1^2 + vy^2 - 2*y1*vy) - d^2 - (vy*ny)^2 - 2*d*vy*ny + 2*x1*nx*d - 2*x1*nx*ny*vy - nx^2*Z1^2

vs = quadformula( a,b,c );