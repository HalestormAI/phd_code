function f = drawLabeledTracklets( T, L_t, colours )

    f = figure;
    % Prepend black to colours for zero-labelled tracklets.
    colours = ['k', colours]
    for t=1:2:length(T),
        % Get label
        lbl = L_t( (t+1)/2 );
        drawcoords(T(:,[t,t+1]),'',0,colours(lbl));
    end
end