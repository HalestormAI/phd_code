function fixPerspFrames( jpgDir, outputDir, H )

fullpath = sprintf('%s/*.jpg',jpgDir);
d = dir(fullpath);
length_d = length(d);
if(length_d == 0)
    disp('couldnt read the directory details\n');
    disp('check if your files are in correct directory\n');
end


f_st = 1;
f_nd = length_d;

% Setup homography
t = maketform('projective',H')

parfor i = f_st:f_nd
    fname = d(i).name;
    fname_input = sprintf('%s/%s',jpgDir,fname);
    fname_output = sprintf('%s/%s',outputDir,fname);
    
    disp(sprintf('Processing image: %d', i));
    
    % open frame
    I = imread( fname_input );
    I2 = imrotate( I, 90 );
    [I3, ~, ~] = imtransform(I2, t, 'bicubic','size',size(I));
    I4 = imrotate(I3, -90);
    imwrite(I4,fname_output,'jpg');
end 