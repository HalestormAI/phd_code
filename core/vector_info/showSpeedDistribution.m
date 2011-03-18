function showSpeedDistribution( fn )
disp(strcat('Z:/PhD/year1/testscripts/c/speed_vals/',fn))
fid = fopen(strcat('Z:/PhD/year1/testscripts/c/speed_vals/',fn))
speeds = textscan( fid, '%f ')
figure,
histfit( speeds{1} )