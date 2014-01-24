folders = dir;

view = '001';

fnbase = '~/PhD/groundplane_matlab/data/pets_S1_L3_';

for i=1:length(folders)
    if sum(strcmp( folders(i).name, {'..','.'})) > 0
        continue
    end
    if folders(i).isdir
        disp(folders(i).name)
        time_index = folders(i).name;
        
        filename = [time_index,'/',view,'/trajectory_data.txt'];
        [trajectories,frame] = processTrajText( filename );
        calib_fn = ['/home/csunix/sc06ijh/PhD/groundplane_matlab/data/pets/View_',view,'.xml'];
        
        output_fn =  [fnbase,time_index,'_view',view,'.mat']
        save( output_fn, 'trajectories','frame','calib_fn' );
    end
end