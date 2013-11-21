function pdfFig( filename, fh,dim )

    if nargin < 2
        fh = gcf;
    end

    if nargin < 3
        dim = [50 25];
    end

    set(fh, 'PaperPosition', [0 0 dim]); %Position plot at left hand corner with width 5 and height 5.
    set(fh, 'PaperSize', dim); %Set the paper to have width 5 and height 5.
    set(fh, 'Color', 'w')
    textObj = findall(fh,'Type','Text');
    set(textObj,'Interpreter','latex')
    set(textObj,'FontSize',14);
    set(findall(fh,'type','axes'),'FontSize',16)
    export_fig(filename,fh);
end