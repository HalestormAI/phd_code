function movie2jpgs( M, vid_name )

    date_folder = sprintf('%s',datestr(now, 'dd-mm-yy'));
    if ~exist(date_folder,'dir'),
        mkdir('.',date_folder);
    end
    
    if nargin < 2,
        vid_name =  input('Desired Filename? ','s');
        while exist( sprintf('./%s/%s',date_folder,vid_name) ,'dir'),
            new_vid_name =  input('Filename in use. New Filename [enter nothing to force]? ','s');
            if isempty(new_vid_name),
                break;
            end
        end
    end
    mkdir(sprintf('./%s/%s',date_folder,vid_name));
    
    files = cell( 1, size(M,2) );
    
    h = waitbar(0,'Starting','Name',sprintf('Saving %d jpgs', size(M,2)), ...
            'CreateCancelBtn',...
            'setappdata(gcbf,''Cancelling'',1)');
    setappdata(h,'canceling',0)
    
    for i=1:size(M,2),
        imwrite(M(1,i).cdata(:,:,:),sprintf('%s/%s/frame_%05d.jpg',date_folder,vid_name,i),'jpg');
        files{i} = sprintf('frame_%05d.jpg',i);
        if getappdata(h,'Cancelling')
            return;
        end
        waitbar(i/size(M,2),h,sprintf('%d%% Complete',round(100*i/size(M,2))));
    end
    
    delete(h);
    
    zip(sprintf('./%s/%s/%s.zip',date_folder,vid_name,vid_name),files,sprintf('./%s/%s',date_folder,vid_name));
end