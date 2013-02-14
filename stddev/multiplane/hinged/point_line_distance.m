function d = point_line_distance( line_x0, line_x1, P )

    if nargin == 2 % Allow for the line to be specified as a pair.
        P = line_x1;
        line_x1 = line_x0(:,2);
        line_x0 = line_x0(:,1);
    end

    d = norm( cross( (line_x1 - line_x0), (line_x0 - P)) ) / norm(line_x1 - line_x0);
end