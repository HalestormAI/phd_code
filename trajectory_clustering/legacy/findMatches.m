function mymatches = findMatches( minerrorids )

    mymatches = {};

    for i=1:length(minerrorids)
        getMatchRun(i);
    end

    function getMatchRun (i,idx)
        mIdx = inMatches(i);
        
        if mIdx == 0
            mIdx2 = inMatches( minerrorids(i) );
            
            if mIdx2 > 0
                mymatches{mIdx2}(end+1) = i;
            elseif nargin < 2
                mIdx = length(mymatches)+1;
                mymatches{mIdx} = i;
            else
                mIdx = idx;
                mymatches{mIdx}(end+1) = i;
            end
            getMatchRun(minerrorids(i),mIdx)
        end
        
            
    end

    function idx = inMatches( i )
        for m=1:length(mymatches)
            if ismember(i,mymatches{m})
                idx = m;
                return;
            end
        end
        idx = 0;
    end
end