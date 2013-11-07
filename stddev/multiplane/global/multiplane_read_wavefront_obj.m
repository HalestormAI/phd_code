function [planes, trajectories, params, plane_params] = multiplane_read_wavefront_obj( filename, params, draw )
% Load a wavefront object from software such as blender as a world plane
% in our coord system & plane format.

    fid = fopen(filename,'r');
    
    planes = struct('ID',{},'world',{});
    
    while ~feof(fid)
        intxt = textscan(fid,'%s',1,'delimiter','\n'); 
        
        % Object definitions begin with 'o <name>'
        if ~isempty(intxt{1}) && length(intxt{1}{1}) > 1 && strcmp(intxt{1}{1}(1:2),'o ')
            
            fprintf('\tReading Object: %s\n', intxt{1}{1}(3:end));
            pln_s.ID = intxt{1}{1}(3:end);
            
            %We're now in a plane object, so read the next 4 vertex lines
            vertices_txt = textscan(fid, '%c %f %f %f', 4, 'delimiter', '\n');
            
            %Skip irrelevant data
            textscan(fid,'%s',2,'delimiter','\n'); 
            
            % Load vertex ordering
            col_raw = textscan(fid,'%c %d %d %d %d',1,'delimiter','\n');
            
            col = [col_raw{2:5}] - min([col_raw{2:5}]) + 1; % Account for global vertex num
        
            pln_raw = cell2mat(vertices_txt(2:4))';
            pln = pln_raw([3,1,2],col); % Alter coord-system to concur with mine
            
            pln_s.world = pln;
            planes(end+1) = pln_s;
            
        end
    end
    
%         zrot = makehgtform('zrotate',pi/2);zrot = zrot(1:3,1:3);
%         
%         for p=1:length(planes)
%             planes(p).world = zrot*planes(p).world;
%         end
%     planes.world
    
    if nargin > 1 && ~isempty(params)
        [planes, trajectories, params, plane_params] = multiplane_process_world_planes( planes, params );
    elseif nargout > 1
        warning('ijh:notEnoughArgs','Cannot output trajectories without additional parameters');
        trajectories = [];
    end
    
    if nargin > 2 && draw
        worldfig = figure;
        for p=1:length(planes)
            drawPlane(planes(p).world,'',0,'r');    
        end
        if nargin > 1 && ~isempty(params)
            drawtraj(trajectories.world,'',0);
            
        end
    end
    
end