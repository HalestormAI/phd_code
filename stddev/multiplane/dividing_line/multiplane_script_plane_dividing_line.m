function [errors_1, errors_2] = multiplane_script_plane_dividing_line( imTraj, hypotheses, linePoints, angles )

    % multiplane_script_plane_dividing_line
    % Tries to find the rough position of the plane dividing line for two
    % planes only.

    errors_1 = zeros(size(linePoints,2), length(angles));
    errors_2 = zeros(size(linePoints,2), length(angles));
    for l = 1:size(linePoints,2)
        for angleID=1:length(angles);
            sideTrajectories = multiplane_split_trajectories_for_line( imTraj, linePoints(:,l), angles(angleID) );
            if isempty( sideTrajectories{1} )
                err(1,1) = Inf;
                err(2,1) = Inf;
            else
                err(1,1) = sum(errorfunc( hypotheses(1,1:2), [1,hypotheses(1,3)], traj2imc(sideTrajectories{1},1,1) ).^2);
                err(2,1) = sum(errorfunc( hypotheses(2,1:2), [1,hypotheses(2,3)], traj2imc(sideTrajectories{1},1,1) ).^2);
            end
            if isempty( sideTrajectories{2} )
                err(1,2) = Inf;
                err(2,2) = Inf;
            else
                err(1,2) = sum(errorfunc( hypotheses(1,1:2), [1,hypotheses(1,3)], traj2imc(sideTrajectories{2},1,1) ).^2);
                err(2,2) = sum(errorfunc( hypotheses(2,1:2), [1,hypotheses(2,3)], traj2imc(sideTrajectories{2},1,1) ).^2);
            end
            errors_1(l,angleID) = err(1,1) + err(2,2); % (s1,h1) + (s2,h2) (s1 = side 1, h1 = hypothesis 1)
            errors_2(l,angleID) = err(2,1) + err(1,2); % (s1,h2) + (s2,h1)
        end
        fprintf('Point %d of %d complete.\n', l, size(linePoints,2));
    end

end