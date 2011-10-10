function [out_iter, minidx, errs] = findBestEstimate( iters, im_coords )

    tic
    errs = cellfun( @(x) sum(gp_iter_func(x,im_coords).^2), num2cell(iters,2));
    [~,minidx] = min(errs);
    out_iter = iters(minidx,:);
    toc
end