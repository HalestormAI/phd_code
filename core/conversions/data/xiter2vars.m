function vars = xiter2vars( xiters )

    if ~iscell(xiters)
        xiters = num2cell(xiters,2);
    end

    vars = cell2mat(cellfun( @getXiterVar, xiters, 'uniformoutput',false ));
    
    function v = getXiterVar( iter )
        [N,D] = abc2n(iter(1:3));
        
        [T,P] = anglesFromN(N,0,'degrees');
        
        v = [T P iter(4) D];
    end
end