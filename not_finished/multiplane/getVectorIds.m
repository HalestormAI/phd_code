    function ids = getVectorIds( vecs, NUM_VECS )
        PROX = 1/100;
        done=0;
        
        while ~done,
            try
                if PROX >= 1/(1e3),
                    ids = smartSelection( vecs, NUM_VECS, PROX );
                    done = 1;
                else
                    size(regions{r})
                    error('Prox is getting too small. Ending here.');
                end
            catch err,
                if strcmp(err.identifier,'IJH:VECSEL:OUTOFVECS'),
                    PROX = 1 / (1/PROX + 1); 
                    fprintf('PROX too high. Decreasing to 1 / %d\n\n', 1/PROX);
                else rethrow(err);
                end
            end
        end
    end