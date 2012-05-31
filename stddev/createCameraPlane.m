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
%     
%     % Find any elements on camPlane with Z >= 0
%     newPlane = NaN*ones(3,4);
%     
%     potentialLines = [4,1,2,3;
%                       2,3,4,1];
%     for p=1:4
%         
%         if camPlane(3,p) >= 0 % if point l is off the plane
%             
%             good = potentialLines(2,p);
%             
%             if(camPlane(3,good) == camPlane(3,p))
%                 good = potentialLines(1,p);
%             end
%            
%             % Get the direction
%             p1 = camPlane(:,good);
%             line = camPlane(:,p) - p1;
%             newPlane(:,p) = p1+line.*((0-p1(3))/line(3));
%         else
%             newPlane(:,p) = camPlane(:,p);
%         end
%     end
%     camPlane = newPlane;
%     
%     xRot = makehgtform('xrotate', -deg2rad(params(1)));
%     zRot = makehgtform('zrotate', -deg2rad(params(2)));
%     xRot = xRot(1:3,1:3);
%     zRot = zRot(1:3,1:3);
%     rotation = xRot*zRot;
%     
%     worldPlane = rotation*camPlane;

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
