syms a b c f

x1 = imTraj{1}(1,1:2:end);
x2 = imTraj{1}(1,2:2:end);
y1 = imTraj{1}(2,1:2:end);
y2 = imTraj{1}(2,2:2:end);

for i=1:length(x1)
    g1 = f*x1(i)*a + f*y1(i)*b + c;
    g2 = f*x2(i)*a + f*y2(i)*b + c;
    
    F(i) = ( f*(x1(i)/g1 - x2(i)/g2)^2 + f*(y1(i)/g1 - y2(i)/g2)^2 + f*(1/g1 - 1/g2)^2 ) - 1;
end

v = [ a b c f ];
J = jacobian(F,v);