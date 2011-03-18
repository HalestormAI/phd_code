function fromForum( C )

C2 = zeros(size(C));

org = [01;0;0];

for i =1:size(C,2),
    d=dot(org, C(:,i));
   
    o2=org.*d;
    
    mag_old = sum(C(:,i).^2);
    
    C2(1,i) = C(1,i)-o2(1);
    C2(2,i) = C(2,i)-o2(2);
    C2(3,i) = C(3,i)-o2(3);
    mag_new = sum(C2(:,i).^2);
    
    factor = sqrt( mag_old / mag_new )
    
    C2(:,i) = C2(:,i).*factor;
    
end

drawcoords3(C2);