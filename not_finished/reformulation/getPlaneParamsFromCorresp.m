function F = getPlaneParamsFromCorresp( x, imc, C )

    F = ones(size(imc,2),1).*Inf;
    for f=1:size(imc,2),
        F(f) = imc(1,f)*x(1) + imc(2,f)*x(2) + x(3);
    end
end