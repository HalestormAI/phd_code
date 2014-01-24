function linePoints = multiplane_svm_get_line( fig_handle )

    
    kiddies = get(fig_handle,'Children');
    hghand = kiddies(1);
    linehandle = get(hghand,'Children');
    xvals = get(linehandle,'XData');
    yvals = get(linehandle,'YData');

    % Use line data to get equation
    m=(yvals(2)-yvals(1))/(xvals(2)-xvals(1));
    b=yvals(1)-m*xvals(1);
    % plot(xvals, m*xvals+b, '--', 'LineWidth', 3);
    % close;

    linePoints = [xvals(~isnan(xvals)), yvals(~isnan(yvals))]; % Line points is transpose of coord system.

end