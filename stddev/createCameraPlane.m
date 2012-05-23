function [worldPlane,camPlane,imPlane,rotation] = createCameraPlane( params, constants,  l )

    %{

    scaled_width = l/constants(1);

    x1 = [ -scaled_width*sind(params(1)); -scaled_width*cosd(params(1)) ];
    x2 = [  scaled_width*sind(params(1)); -scaled_width*cosd(params(1)) ];
    x3 = [  scaled_width*sind(params(1));  scaled_width*cosd(params(1)) ];
    x4 = [ -scaled_width*sind(params(1));  scaled_width*cosd(params(1)) ];

   camPlane = [x1,x2,x3,x4]; 
%}

    worldPlane = [ -l l l -l; -l -l l l; -ones(1,4).*constants(1) ];

    xRot = makehgtform('xrotate', deg2rad(params(1)));
    zRot = makehgtform('zrotate', deg2rad(params(2)));

    xRot = xRot(1:3,1:3);
    zRot = zRot(1:3,1:3);

    rotation = zRot*xRot;

    camPlane = rotation*worldPlane;

    imPlane(1,:) = camPlane(1,:) ./ (constants(2).*camPlane(3,:));
    imPlane(2,:) = camPlane(2,:) ./ (constants(2).*camPlane(3,:));

%{    Z = camPlane(3,1)
    x = imPlane(1,1);
    y = imPlane(2,1);

    alpha = constants(2);

    abc = normalFromAngle( -params(1), params(2) );

    d = constants(1);

    Zest = d / ( alpha*abc(1)*x + alpha*abc(2)*y + abc(3) );

    % Z != Zest THEREFORE EQUATION IS WRONG! 
%}
end
