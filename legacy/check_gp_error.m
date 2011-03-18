function out = check_gp_error ( n,num_runs,noise )

if nargin < 1,
    n = [0; sin(deg2rad(120)); cos(deg2rad(120)) ];
end
if nargin < 2,
    num_runs = 10;
end
if nargin < 3,
    noise = 0.1;
end


n = n ./ vec_size(n);
n = n ./ vec_size(n);
if vec_size(n) ~= 1,
    error('Error creating unit vector');
end

d = 5000;
l = 175;

errors = zeros(1,num_runs);
distance_errors = zeros( 1,num_runs );
noisy_error = zeros(1, num_runs );

full_coords = zeros( 3, num_runs*2 );
full_im_coords = zeros( 2, num_runs*2 );
cnt = 1;

for i=1:num_runs,
    coords = make_angled_coords( n, d, l, 2 );
    full_coords(:,cnt) = coords(:,1);
    full_coords(:,cnt+1) = coords(:,2);
    
    distance_errors(i) = vector_dist(coords(:,1),coords(:,2));
            
    im_coords = image_coords_from_rw_and_plane( coords );
    full_im_coords(:,cnt) = im_coords(:,1);
    full_im_coords(:,cnt+1) = im_coords(:,2);
    
    val = gp_formula( [n(1), n(2), d, l,n(3)], im_coords(1,1), im_coords(2,1), im_coords( 1,2 ), im_coords( 2,2 ) );
    errors(i) = val;
    cnt = cnt + 2;
end

[noisy_im_coords, noise_avg] = add_coord_noise(full_im_coords,noise,0);

%now convert each noisy image coordinate to world using the formula
plane = struct('n', n, 'd', d );
noisy_world_coords = find_real_world_points( noisy_im_coords, plane );


% Find length errors in noisy real world coords
cnt = 1;
for i=1:2:num_runs*2,
    noisy_error(cnt) = (l - vector_dist( noisy_world_coords(:,i), noisy_world_coords(:,i+1) )) / l;
    
    cnt = cnt + 1;
end

es_X = 1:num_runs;
es_X_2 = 1:num_runs;

figure

% Draw image points and lines
subplot(3,2,1);
%title('Length Errors Post-Conversion');
%scatter( es_X , errors );
scatter(full_im_coords(1,:),full_im_coords(2,:))
hold on;
title('Image View of Points');
xlabel('x');
ylabel('y');
for i=1:2:num_runs*2,
    plot( full_im_coords(1,i:i+1), full_im_coords(2,i:i+1), '-or' );
end
hold off;

% Draw Noisy Image Points and Lines
subplot(3,2,2);
%title('Length Errors Post-Conversion');
%scatter( es_X , errors );
scatter(noisy_im_coords(1,:),noisy_im_coords(2,:))
hold on;
title('Noisy Image View of Points');
xlabel('x');
ylabel('y');
for i=1:2:num_runs*2,
    plot( noisy_im_coords(1,i:i+1), noisy_im_coords(2,i:i+1), '-or' );
end
hold off;

% Draw World view points and lines
subplot(3,2,3);
scatter3(full_coords(1,:),full_coords(2,:), full_coords(3,:))
hold on
title('World View of Points');
xlabel('x');
ylabel('y');
zlabel('z');
for i=1:2:num_runs*2,
    plot3( full_coords(1,i:i+1), full_coords(2,i:i+1),full_coords(3,i:i+1), '-or' );
end
hold off;

% Draw Noisy World view points and lines
subplot(3,2,4);
scatter3(noisy_world_coords(1,:),noisy_world_coords(2,:), noisy_world_coords(3,:))
hold on
title('World View of Noisy Points');
xlabel('x');
ylabel('y');
zlabel('z');
for i=1:2:num_runs*2,
    plot3( noisy_world_coords(1,i:i+1), noisy_world_coords(2,i:i+1),noisy_world_coords(3,i:i+1), '-or' );
end
hold off;

% Show real world points error after noise

subplot(3,2,[5,6]);
scatter( es_X_2 , abs(noisy_error), '*' );
hold on

P = polyfit( es_X_2, abs(noisy_error), 1 );
p = polyval( P, es_X_2 );
plot( es_X_2, p );
title(strcat('Real World Error After Noise (Avg: ', num2str(noise_avg), '%)' ) );
xlabel('Line Number');
ylabel('Percentage Error');

out = struct( 'errors', errors, 'coords', coords, 'im_coords', im_coords, 'n', n, 'd', d, 'l', l );