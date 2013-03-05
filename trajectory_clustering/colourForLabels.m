function colour = colourForLabels( labels )
    
    increment = 2*(1/length(labels));
    
    COLOUR_DIFF = round(length(labels)/3);
    
    r = abs(1 - (0:length(labels)-1)*increment);
    g = abs(1 - (COLOUR_DIFF:length(labels)+COLOUR_DIFF-1)*increment);
    b = abs(1 - (2*COLOUR_DIFF:length(labels)+2*COLOUR_DIFF-1)*increment);
    colour = [r;g;b]';
    colour(colour > 1) = 1-mod(colour(colour > 1),1);
end