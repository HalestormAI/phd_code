function [plane_details, output_details] = estimate_then_compare( vidname, params_only, params_name )

    folder = sprintf('%s/%s',vidname, datestr(now, 'HH-MM-SS'));
    mkdir(folder);
    pushd(folder);
    if nargin > 1 && params_only
        pd = load(strcat('../../',params_name));
        plane_details = pd.plane_details;
        clear pd;
    else
        plane_details = paramsFromVideo( vidname,15 );
    end
    [ output_params, finalError, fullErrors ] = multiscaleSolver( 1, plane_details, 3, 5, 1e-3 );
    gt_trajLengths = cellfun(@traj_speeds, plane_details.camTraj,'un',0)
    rectTrajectories = cellfun(@(x) backproj_c(output_params(1),output_params(2), ...
                                                                1,output_params(3), x), ...
                                                                plane_details.trajectories,'uniformoutput', false);
    est_trajLengths = cellfun(@traj_speeds, rectTrajectories,'un',0)
    % drawtrajlengths

    save data;

    output_details.output_params = output_params;
    output_details.finalError = finalError;
    output_details.fullErrors = fullErrors;
    output_details.gt_trajLengths = gt_trajLengths;
    output_details.rectTrajectories = rectTrajectories;
    output_details.est_trajLengths = est_trajLengths;

    popd();