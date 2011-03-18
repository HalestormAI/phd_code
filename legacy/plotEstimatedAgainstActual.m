function plotEstimatedAgainstActual( C_norm, C_est, title )

    drawcoords3( C_norm, 'Actual World Coordinates (normalised to scale)', 1, 'k' )
    drawcoords3( C_est, title, 0, 'b' )
    for i=3:size(C_est, 2),
        plot3( [C_norm(1,i), C_est(1,i)],[C_norm(2,i), C_est(2,i)],[C_norm(3,i), C_est(3,i)], 'r-' );
    end
end