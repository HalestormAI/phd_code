function [minval,minidx] = min2d( values )

    [minval,MINIDX] = min(values(:));
    
    [i,j]=ind2sub(size(values),MINIDX);
    
    minidx = [i,j];
end