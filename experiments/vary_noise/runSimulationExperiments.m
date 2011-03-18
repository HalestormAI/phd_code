

all_planes       = zeros(10^3,4);
all_ns           = zeros(10^3,3);

num = 1;
h = waitbar(0,'Starting...', 'Name', ...
            sprintf('Running %d iterations', 10^3 ));
for t1=0:0.5:1,
    for t2=0:0.5:1,
        for t3=0:0.1:0.2,
            close all;
            [cluster_info,planes,n,used_vectors,imc,wc] = simulatedPointEstimation( 40, 5, 7, 50, 3,[t1,t2,t3],num );
            num = num + 1;
            waitbar(num / 10^3, h, sprintf('Running Iteration: %d (%d%%)', ...
            num, round(num* 100 / 10^3) ));
        end
    end
end

delete(h)