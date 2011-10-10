
failReasons  = { };
x_iters      = { };
pass         = { };
passiters    = { };
pass2        = { };


% grid = generateNormalSet( );

for i=1:length(acceptable)
    
    
    [failReasons{i}, pi, x_iters{i}, pass{i}] = runsForX0( acceptable{i}, 1:(length(acceptable{i})), grid, 1, -1 );
    passiters{i} = cell2mat(pi);
end