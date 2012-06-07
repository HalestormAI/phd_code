function f = drawtraj( traj, ttl, newfig, colour )

if nargin < 2
    ttl = '';
end
if nargin < 3
    newfig = 1;
end
if nargin < 4
    colour = 'k';
end

f = drawcoords(traj2imc(traj,1,1),ttl,newfig,colour);