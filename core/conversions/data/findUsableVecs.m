function [im_usable, c_usable] = findUsableVecs( paths, pathlengths, pathtimes, c_times, min_length, H )

if nargin < 4,
    min_length = 4;
end


id_usable    = find( pathlengths >= min_length );
times_usable = pathtimes(id_usable);
paths_usable = {paths{id_usable}};
im_usable    = {};
c_usable     = {};

for p=1:length(id_usable),
    
%     tu = times_usable(p)
    pu = paths_usable{p}
    num = 1;
    imu_t = [];
    for t=times_usable(p):(times_usable(p)+length(paths_usable{p})-1),
        imu_t(:,end+(1:2)) = c_times{t}(:,mpid2cid(pu(num)));
        num = num + 1
    end
    im_usable{end+1} = imu_t;
    if nargin == 6
        c_usable{end+1} = H*makeHomogenous(imu_t);
    end
end
