function [ P1 ] = find_real_world_point( point, plane )
%FIND_REAL_WORLD_POINTS Summary of this function goes here
%   Detailed explanation goes here


Z1 = z1( point(1), point(2), plane );

X1 = plane.alpha*point(1)*Z1;
Y1 = plane.alpha*point(2)*Z1;
P1 = [X1;Y1;Z1];