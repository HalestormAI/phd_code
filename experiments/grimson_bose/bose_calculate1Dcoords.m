function c = bose_calculate1Dcoords( t )
    spd = traj_speeds(t{1});
    c = cumsum(spd)-spd(1);
end
