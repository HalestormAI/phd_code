function [im_coords, im_times, im1, im_sz] = getTracklets( filename )
%  C++ function (using openCV) to find the set of tracklets using the KLT
% tracker. Tracklets are ordered by imaged-speed, but can be ordered by
% time using "im_times".
%
% INPUT:
%   filename    The path to the video
%
% OUTPUT:
%   im_coords   The set of image motion vectors
%   im_times    Tracklet frame times
%   im1         The first frame of the video
%   im_sz       The image dimensions