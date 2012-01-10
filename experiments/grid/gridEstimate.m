function [output_mean,output_iters,errored,pass1,pass2] = gridEstimate( C_im, grid, ids_full, ALLOW_RESELECTION )

    PROPORTION = 1;
    MAX_ATTEMPTS = 100;
   
    if nargin < 2 || isempty(grid),
        grid = generateNormalSet( );
    end
    if nargin < 4
        ALLOW_RESELECTION = 1;
    end

    if (nargin < 3 || isempty(ids_full)) && ALLOW_RESELECTION
        PROX = 1/6;
        done = 0;
        while ~done,
            try
                ids_full = smartSelection(C_im, 4, PROX);
                done = 1;
            catch err,
                if strcmp(err.identifier,'IJH:VECSEL:OUTOFVECS'),
                    PROX = 1 / (1/PROX + 1); 
                    fprintf('PROX too high. Decreasing to 1 / %d\n\n', 1/PROX);
                else rethrow(err);
                end
            end
        end
    end
    
    [~, ~, x_iters, pass] = runsForX0( C_im, ids_full, grid, 1, -1 );
    griderrors = cell2mat( cellfun(@(x) sum(gp_iter_func(x,C_im).^2), num2cell(grid,2), 'UniformOutput',false ) );

    exits = cell2mat(pass);

    goodgrid = grid(exits > 0,:);
    goodgriderrs = griderrors(exits > 0);

    [~,sortedids] = sort(goodgriderrs);
    best_few = sortedids(1:ceil(length(goodgriderrs)*PROPORTION));
    pass1.x_iters = x_iters;
    pass1.pass = pass;
    attempts = 0;
    while 1,
        if ALLOW_RESELECTION
            for counter=(1:25),
                PROX = 1/6;
                done = 0;
                while ~done,
                    try
                        fprintf('Adding another set of ids: %d.\n', counter);
                        pass2ids(counter,:) = smartSelection(C_im, 4, PROX);
                        done = 1;
                    catch err,
                        if strcmp(err.identifier,'IJH:VECSEL:OUTOFVECS'),
                            PROX = 1 / (1/PROX + 1); 
                            fprintf('PROX too high. Decreasing to 1 / %d\n\n', 1/PROX);
                        else rethrow(err);
                        end
                    end
                end
            end
        else
            pass2ids = ids_full;
        end
        disp('goodgrid size :');
        % ns = cell2mat(cellfun(@(x) x(1:3)/norm(x(1:3)), num2cell(goodgrid(best_few,:),2),'UniformOutput',false))

        attempts = attempts + 1;
        [pass2.failReasons, pass2.passiters, pass2.x_iters, pass2.pass] = runsForX0( C_im, pass2ids, goodgrid(best_few,:), size(pass2ids,1), -1 );

        xmat = cell2mat(pass2.x_iters);
        passmat = cell2mat(pass2.pass);
        output_iters = xmat(passmat > 0,:);
        if attempts > MAX_ATTEMPTS,
            errored = 1;
            break;
        elseif isempty(output_iters),
%             PROPORTION = PROPORTION * 5;
            disp('NO RESULTS CAME OF THIS - CHANGING VECS!');
        else
            errored = 0;
            break;
        end
    end
    output_mean = mean(output_iters,1);
end