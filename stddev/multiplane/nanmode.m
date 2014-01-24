function md = nanmode( input )
    md = mode( input(~isnan(input)) );
end