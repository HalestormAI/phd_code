function fig2jpg( figdirectory, chview )
%%Matlab program - fig2jpg


fullpath = sprintf('%s/*.fig',figdirectory)
d = dir(fullpath);
length_d = length(d)
if(length_d == 0)
disp('couldnt read the directory details\n');
disp('check if your files are in correct directory\n');
end

startfig = 1
endfig = length_d

for i = startfig:endfig
    [p1, p2, p3] = fileparts( d(i).name );
    
    fname = p2;
    
    fname_input = sprintf('%s/%s.fig',figdirectory,fname)
    fname_output = sprintf('%s/%s.jpg',figdirectory,fname)
    f = openfig(fname_input)
    if nargin ==2,
        view(chview);
    end
    saveas(f,fname_output,'jpg');
    close(f);
end 