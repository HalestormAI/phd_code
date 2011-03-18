function [ x2_1, x2_2 ] = solve_x2_eqn( a, b )
%SOLVE_X2_EQN Summary of this function goes here
%   (a - x2) ^2 = b

x2_1 = a - sqrt(b);
x2_2 = a + sqrt(b);