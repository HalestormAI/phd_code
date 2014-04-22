function [grp] = draw_camera_pyramid(params, l,w,h) 
    % PYRAMID will accept four inputs. P0 is an array of 3 scalar numbers for 
    % the origin (x, y, and z). l is the length of the box in the x-direction, 
    % w is the width of the box in the y-direction, and h is the height of the 
    % box in the z-direction. The functin will draw a square pyramid. 
    % Input: Four inputs, an array of the point of origin, a length, width, and 
    % height. 
    % Output: A pyramid drawn with a set transparency and different colors for 
    % the faces 
    % Proecessing: The first thing I will do is use the figure funciton in 
    % order to prevent any previous figures from being overwritten.

    grp = hggroup;
    hnd = zeros(1,5);
    
    P = [0;0;0];
    
    %faces = [x,y,z];
    
    rotations = makehgtform( 'zrotate', deg2rad(params.camera.rotation(1)), 'xrotate', deg2rad(params.camera.rotation(2)));
    
    
    faces{1}(1,:) = [P(1),P(1)+l,P(1)+l,P(1)];
    faces{1}(2,:) = [P(2),P(2),P(2)-w,P(2)-w]; 
    faces{1}(3,:) = [P(3),P(3),P(3),P(3)]; 
    faces{2}(1,:) = [P(1),P(1)+l,P(1)+ l/2]; 
    faces{2}(2,:) = [P(2),P(2),P(2)-w/2]; 
    faces{2}(3,:) = [P(3),P(3),P(3)+h]; 
    faces{3}(1,:) = [P(1)+l,P(1)+l,P(1) + l/2]; 
    faces{3}(2,:) = [P(2), P(2)-w,P(2)- w/2]; 
    faces{3}(3,:) = [P(3),P(3),P(3)+h]; 
    faces{4}(1,:) = [P(1)+l,P(1),P(1)+ l/2]; 
    faces{4}(2,:) = [P(2)-w,P(2)-w,P(2)- w/2]; 
    faces{4}(3,:) = [P(3),P(3),P(3)+h];  
    faces{5}(1,:) = [P(1),P(1),P(1) + l/2]; 
    faces{5}(2,:) = [P(2),P(2)-w,P(2)- w/2]; 
    faces{5}(3,:) = [P(3),P(3),P(3)+h];  
    
    
    faces_r = cell(5,1);
    for f=1:5    
%         faces{f}
        faces_r{f} = rotations*makeHomogenous(faces{f})+makeHomogenous(repmat(params.camera.position,1,size(faces{f},2)));
        hnd(f) = fill3(faces_r{f}(1,:)-l/2,faces_r{f}(2,:)+w/2,faces_r{f}(3,:),'k','FaceColor',[0.45,0.45,0.45],'EdgeColor',[0.25,0.25,0.25]);
    end
   
    for i=hnd
        set(hnd,'Parent',grp);
    end
end