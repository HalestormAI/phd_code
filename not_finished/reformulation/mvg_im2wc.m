function wc = mvg_im2wc( im, P, C, lamda )

ims = num2cell( im,1 );

P_inv = P'/((P*P'));

wc = cell2mat(cellfun(@(x) to3d(x,P_inv,C,lamda), ims,'uniformoutput',false ));

    function out = to3d( im, P_inv, C, lamda )
        pt1 = P_inv*makeHomogenous(im);
        pt2 = lamda*makeHomogenous(makeHomogenous(C));
        out = pt1 + pt2;
        out = out(1:3)./out(4);
    end

end