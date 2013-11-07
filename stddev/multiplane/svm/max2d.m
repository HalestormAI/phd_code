function [minval,minidx] = max2d( values )

    [minval,MINIDX] = max(values(:));
    
    [i,j]=ind2sub(size(values),MINIDX);
    
    minidx = [i,j];
end