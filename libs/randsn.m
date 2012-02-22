function output = randsn( skew, location, scale, rows, cols )

    if nargin < 4
        rows = 1;
        cols = 1;
    elseif nargin < 5 && length(rows) ~= 2
        error('If only one size param is given, it should be a 2x1 vector [rows,cols]');
    elseif nargin < 5
        cols = rows(2);
        rows = rows(1);
    end
    
    output = zeros( rows, cols );

    for r = 1:rows
        for c = 1:cols
            sigma = skew / sqrt( 1 + skew^2 );
            afRn  = randn(2,1);
            u0    = afRn(1);
            v     = afRn(2);
            u1    = sigma * u0 + sqrt( 1 - sigma ^ 2) * v;

            if u0 < 0
                u1 = -u1;
            end
        output(r,c) = u1 * scale + location;
        end
    end
end
