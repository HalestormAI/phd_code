% NUM_POINTS = 5000;
% 
% disp('Rectifying using ground-truth homography.');
% points3D = homoTrans(H,makeHomogenous(horzcat(imTraj{:})));
% 
% disp('Rectifying using estimated plane parameters.');
% points3D_est = find_real_world_points(makeHomogenous(horzcat(imTraj{:})), iter2plane(x_iter{minid}(1:4)));
% 
% points3D_en   = zeros(2,length(points3D_est));
% points3D_t    = zeros(2,length(points3D_est));
% points3D_ens  = zeros(2,length(points3D_est));
% points3Dens_t = zeros(2,length(points3D_est));
% 
% disp('Creating normalised estimated parameters (project into image)');
% disp('Also translating ground-truth points to centre of frame');
% sz = range(points3D,2);
% 
% 
% % Get Image Dimensions & centre
% imgdim = range(points3D,2);
% imgcnt = imgdim ./ 2;
% 

% Find scale using trapezium size
I1 = imTrans( frame, H, [], max(size(frame)) );
I1bin = rgb2gray(I1) > 0;
I1bounds = bwboundaries(I1bin);
mnwidth = mean(I1bounds{1}(:,2));
ptwidth = range(points3D(1,:));
wFactor = mnwidth / ptwidth;

points3D_s = points3D.*wFactor;


% Get scaled GT points' centre
p3dcnt = mean(minmax(points3D_s),2);
p3dtlt = imgcnt - p3dcnt;

for d = 1:2
    
    points3D_en(d,:) = points3D_est(d,:) ./ points3D_est(3,:);
end

% Translate GT points 
points3D_t(1,:) = points3D_s(1,:) + p3dtlt(1);
points3D_t(2,:) = points3D_s(2,:) + p3dtlt(2);
hull = convhull(points3D_t(1,:)',points3D_t(2,:)');
% 
% 
% rng1 = range(points3D_en,2);
% rng2 = range(points3D_t,2);
% factor = rng1(1:2) ./ rng2;
% factor(3) = 1;
% 
% disp('Scaling to match GT points and translating to centre of frame');
% for d=1:2
%     points3D_ens(d,:) = points3D_en(d,:) ./ factor(d,:);
%     points3Dens_t(d,:) = points3D_ens(d,:) + (sz(d)-mean(points3D_ens(d,:)));
% end
% 
% disp('Drawing');
figure;
imagesc(I1);
hold on;
ids = randi(length(points3D),1,NUM_POINTS);
scatter(    points3D_t(1,ids),    points3D_t(2,ids), 24, 'r*');
% scatter( points3Dens_t(1,ids), points3Dens_t(2,ids), 24, 'g*');