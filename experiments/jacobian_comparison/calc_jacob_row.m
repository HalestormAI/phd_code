function R = calc_jacob_row( iter,xy )
% Takes values for all parameters and calculates the row of results for the
% corresponding jacobian matrix.

a = iter(1);
b = iter(2);
c = iter(3);
f = iter(4);

x = xy(1,:);
y = xy(2,:);

dg1 = f * a * x(1) + f * b * y(1) + c;
dg2 = f * a * x(2) + f * b * y(2) + c;

da = 2 * f * (x(1) / (dg1) - x(2) / (dg2)) * (-x(1) ^ 2 / (dg1) ^ 2 * f + x(2) ^ 2 / (dg2) ^ 2 * f) + 2 * f * (y(1) / (dg1) - y(2) / (dg2)) * (-y(1) / (dg1) ^ 2 * f * x(1) + y(2) / (dg2) ^ 2 * f * x(2)) - 1 / (dg1) ^ 2 * f * x(1) + 1 / (dg2) ^ 2 * f * x(2);


db = 2 * f * (x(1) / (dg1) - x(2) / (dg2)) * (-y(1) / (dg1) ^ 2 * f * x(1) + y(2) / (dg2) ^ 2 * f * x(2)) + 2 * f * (y(1) / (dg1) - y(2) / (dg2)) * (-y(1) ^ 2 / (dg1) ^ 2 * f + y(2) ^ 2 / (dg2) ^ 2 * f) - 1 / (dg1) ^ 2 * f * y(1) + 1 / (dg2) ^ 2 * f * y(2);

dc = 2 * f * (x(1) / (dg1) - x(2) / (dg2)) * (-x(1) / (dg1) ^ 2 + x(2) / (dg2) ^ 2) + 2 * f * (y(1) / (dg1) - y(2) / (dg2)) * (-y(1) / (dg1) ^ 2 + y(2) / (dg2) ^ 2) - 1 / (dg1) ^ 2 + 1 / (dg2) ^ 2;

df = (x(1) / (dg1) - x(2) / (dg2)) ^ 2 + 2 * f * (x(1) / (dg1) - x(2) / (dg2)) * (-x(1) / (dg1) ^ 2 * (a * x(1) + b * y(1)) + x(2) / (dg2) ^ 2 * (a * x(2) + b * y(2))) + (y(1) / (dg1) - y(2) / (dg2)) ^ 2 + 2 * f * (y(1) / (dg1) - y(2) / (dg2)) * (-y(1) / (dg1) ^ 2 * (a * x(1) + b * y(1)) + y(2) / (dg2) ^ 2 * (a * x(2) + b * y(2))) - 1 / (dg1) ^ 2 * (a * x(1) + b * y(1)) + 1 / (dg2) ^ 2 * (a * x(2) + b * y(2));

R = [da,db,dc,df];