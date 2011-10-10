function imc = imc2px( im_coords )

    Tx = -min(im_coords(1,:));
    imc2(1,:) = im_coords(1,:)+Tx;
    Sx = 720/max(imc2(1,:));
    imc(1,:) = imc2(1,:).*Sx;
    
%     im_coords(2,:) = max(im_coords(2,:)) - im_coords(2,:)
    Sy = 540 /max(im_coords(2,:));
    imc(2,:) = Sy.*im_coords(2,:);
    imc = round(imc);
end