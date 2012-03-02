function f = drawDensityMap( x, y )
    yi = linspace(min(y(:)),max(y(:)),100);
    xi = linspace(min(x(:)),max(x(:)),100);
    xr = interp1(xi, 1:numel(xi),x,'nearest')';
    yr = interp1(yi, 1:numel(yi),y,'nearest')';
    Z = accumarray([xr yr],1,[100 100]);
    f = figure;
    surf(Z)