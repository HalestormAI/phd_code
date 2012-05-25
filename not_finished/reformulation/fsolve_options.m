options = optimset( 'Display', 'off', ...
                    'Algorithm',{'levenberg-marquardt',.005}, ...
                    'MaxFunEvals', 10000, ...
                    'MaxIter', 10000, ...
                    'TolFun',1e-12 ...
                   );