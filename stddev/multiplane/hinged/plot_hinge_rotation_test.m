traj_rectified_wrong_hypothesis = cellfun(@(x) backproj_c( ordered_hypotheses(1,1), ordered_hypotheses(1,2), ordered_hypotheses(1,4), ordered_hypotheses(1,3), x ), plane_details(2).trajectories, 'un', 0);

N = planeFromPoints([traj_rectified{1}{:}],300);
P = mean([traj_rectified_wrong_hypothesis{:}],2);

clear hinged;
angles = -90:90;

for i=1:length(angles)
    [hinged(i).raw_error,hinged(i).rectTraj, hinged(i).rotN, hinged(i).rotP, hinged(i).rotD, hinged(i).rotAx] = hinged_rotation_solver( plane_details(2).trajectories, constraints_3d, N, P, angles(i), ordered_hypotheses(1,3) );
    hinged(i).error = sum(hinged(i).raw_error .^2);
end

[~,minidx] = min([hinged.error])

the_supposed_best_angle = angles(minidx);

[estimate.raw_error,estimate.rectTraj, estimate.rotN, estimate.rotP, estimate.rotD, estimate.rotAx] = hinged_rotation_solver( plane_details(2).trajectories, constraints_3d, N, P, angles(minidx), ordered_hypotheses(1,3) );


figure;
hold on;
drawtraj(traj_rectified{1},'',0,'k');
drawtraj(estimate.rectTraj,'',0,'r');
% drawtraj(traj_rectified_wrong_hypothesis,'',0,'b');
scatter3( P(1),P(2),P(3),24,'bo','filled');
scatter3( estimate.rotP(1),estimate.rotP(2),estimate.rotP(3),24,'mo','filled');
vectarrow([0,0,0]',estimate.rotN(1:3),'r-');
vectarrow([0,0,0]',N);
plot3( estimate.rotAx(1,:),estimate.rotAx(2,:),estimate.rotAx(3,:),'b-','LineWidth',2);
plot3( constraints_3d(1,:),constraints_3d(2,:),constraints_3d(3,:),'c--','LineWidth',2);
axis equal;