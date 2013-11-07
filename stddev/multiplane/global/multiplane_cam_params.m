function params = multiplane_cam_params( aoe, aoy, focal, height, params )
% Creates parameters for camera and image creation, namely rotation and
% focal length of the camera. 
%
% Input:
%   aoe         The angle of elevation (rotation in x)
%   aoy         The angle of yaw (rotation in z)
%   focal       The camera's focal length
%   [params]    An existing parameters structure. Optional
%
% Output:
%   A parameters structure containing the camera rotation as a vector and 
%   the focal length.
%   If the `params` argument was given, these are appended to the existing
%   structure.
%

    if nargin < 4
        params = [];
    end
    params.camera.rotation = [aoy,aoe];
    params.camera.focal = focal;
    params.camera.height = height;
end