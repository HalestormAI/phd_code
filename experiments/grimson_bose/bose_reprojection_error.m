function [err,reproj] = bose_reprojection_error( p, p_prime, G )

    reproj_2d = G\makeHomogenous(p);
    reproj    = reproj_2d(1,:) ./ reproj_2d(2,:);

    err = 2*sqrt(sum((reproj-p_prime).^2)); %Needs to be altered to match p78 of H&Z
end