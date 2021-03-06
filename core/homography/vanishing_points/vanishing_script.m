close all
if (needfresh),
    lines = cell(2,1);

    figure,
    im_handle = imagesc( I1 );

    colors = ['b','r'];
    for i=1:2,
        disp('Enter pair of parallel lines');
        for j=1:2,
            disp('Entering New Line');
            p1 = impoint;
            p1.setColor( colors(i) );
            p1.getPosition
            p2 = impoint;
            p2.setColor( colors(i) );
            p2.getPosition
            endpoints = [p1.getPosition',p2.getPosition']
            ps{i}(:,j) = [p1.getPosition';p2.getPosition'];
            lines{i}(:,j) = cross( [endpoints(:,1);1], [endpoints(:,2);1] )
      %      lines{i}(:,j) = lines{i}(:,j) ./ lines{i}(3,j);
            hline( lines{i}(:,j), colors(i) )
        end
    end
else
    figure,
    im_handle = imagesc( I1 );

    colors = ['b','r'];
    for i=1:2, 
        for j=1:2,
            hline( lines{i}(:,j), colors(i) )
        end
    end
end


[intersects,l_inf] = findVanishingPoints( lines, I1);
P = eye(3);
P(3,:) = l_inf'
P_t = maketform( 'projective',P' );

I3 = imtransform( I1, P_t, 'bicubic','size',size(I1));


%% Conics - We have 2 pairs of lines, l(1):a,b and l(2):a,b
% We need at least two conditions to find the intersection of the 
% Get 1st set of orthagonal lines
disp('Now we need orthangonal lines in corrected image...')

if exist('have_circles','var') && have_circles == 1,
    done = 1;
else
    done=0;
end
while ~done,
f = figure,imagesc(I3);
l = cell( 2,1 );
for j=1:2,
    disp('Entering New Line');
    p1 = impoint;
    p1.setColor( colors(1) );
    p1.getPosition
    p2 = impoint;
    p2.setColor( colors(1) );
    p2.getPosition
    endpoints = [p1.getPosition',p2.getPosition']
    ps_p{1}(:,j) = [p1.getPosition';p2.getPosition'];
    l{j} = cross( [endpoints(:,1);1], [endpoints(:,2);1] );
%      lines{i}(:,j) = lines{i}(:,j) ./ lines{i}(3,j);
    hline( l{j}, colors(1) )
end

theta = 90;
a = -l{1}(2) / l{1}(1);
b = -l{2}(2) / l{2}(1);
c_alpha = (a+b)./2;
c_beta = (a - b)*cotd(theta);
r = abs( (a - b)./(2*sind(theta)) );

disp('Now doing the others')
    % Keep trying if we don't get an intersection

    % Now find the next condition
    l2 = cell( 2,1 );
    for j=1:2,
        disp('Entering New Line');
        p1 = impoint;
        p1.setColor( colors(2) );
        p1.getPosition
        p2 = impoint;
        p2.setColor( colors(2) );
        p2.getPosition
        endpoints = [p1.getPosition',p2.getPosition']
        ps_p{1}(:,j) = [p1.getPosition';p2.getPosition'];
        l2{j} = cross( [endpoints(:,1);1], [endpoints(:,2);1] );
    %      lines{i}(:,j) = lines{i}(:,j) ./ lines{i}(3,j);
        hline( l2{j}, colors(2) )
    end

    theta = 90;
    a2 = -l2{1}(2) / l2{1}(1);
    b2 = -l2{2}(2) / l2{2}(1);
    c_alpha2 = (a2+b2)./2;
    c_beta2 = (a2 - b2)*cotd(theta);
    r2 = abs( (a2 - b2)./(2*sind(theta)) );
    
    % find distance between centres
    d = vector_dist( [c_alpha, c_beta], [c_alpha2, c_beta2] );
    if d < abs(r - r2),
        disp('Circles contained :(');
        close(f)
    elseif d > r + r2,
        disp('Circles separate');
        close(f)
    else
        disp('Circles intersect :)');
        have_circles = 1;
        done = 1;
    end
end
[xout,yout] = circ_intersect(c_alpha,c_beta,r,c_alpha2,c_beta2,r2)

% Only need point w/ +ve y intersect
[~,pve] = max(yout);
alpha = xout(pve);
beta = yout(pve);


A = [ 1/beta, -alpha/beta, 0 ;
        0   ,      1     , 0 ;
        0   ,      0     , 1 ];
    
figure,
circle( [c_alpha,c_beta],r );
hold on
circle( [c_alpha2,c_beta2],r2,1000,'-r' );


 H = A*P;
H_t = maketform( 'projective',H' );
I4 = imtransform( I1, H_t, 'bicubic','size',size(I1));
figure, imagesc(I4);
title('Affine Transformed')