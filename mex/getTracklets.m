function [im_coords, im1, im_sz] = getTracklets( filename )
%  C++ function (using openCV) to find the set of tracklets using the KLT
% tracker. Tracklets are ordered by imaged-speed.
% TODO: Change to time-based ordering!
%
% INPUT:
%   filename    The path to the video
%
% OUTPUT:
%   im_coords   The set of image motion vectors
%   im1         The first frame of the video
%   im_sz       The image dimensions