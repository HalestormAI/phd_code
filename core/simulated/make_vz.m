function vz = make_vz( vy, nx,ny,nz, x1,y1,Z1, d, l )


part1 = (d * nz) - (x1 * nx * nz) + (Z1 * nx ^ 2) - (ny * vy * nz) ;
denom = (nz ^ 2 + nx ^ 2);

rooted = (-nz ^ 2 * vy ^ 2 * nx ^ 2 - 2 * Z1 * nx ^ 2 * ny * vy * nz - nx ^ 2 * d ^ 2 - nx ^ 4 * vy ^ 2 - nx ^ 4 * x1 ^ 2 - nx ^ 4 * y1 ^ 2 + nx ^ 4 * l ^ 2 - nz ^ 2 * y1 ^ 2 * nx ^ 2 + 2 * d * nz * Z1 * nx ^ 2 - 2 * x1 * nx ^ 3 * nz * Z1 + 2 * nz ^ 2 * vy * y1 * nx ^ 2 + 2 * nx ^ 2 * d * ny * vy - 2 * nx ^ 3 * x1 * ny * vy + nz ^ 2 * l ^ 2 * nx ^ 2 - nz ^ 2 * nx ^ 2 * Z1 ^ 2 - nx ^ 2 * ny ^ 2 * vy ^ 2 + 2 * nx ^ 4 * vy * y1 + 2 * nx ^ 3 * x1 * d);
vz = (part1 + sqrt( rooted )) / denom;

