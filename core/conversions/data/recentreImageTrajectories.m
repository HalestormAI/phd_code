function imTraj_rc = recentreImageTrajectories( imTraj, frame, DEBUG )

    % First check where the centre is to see if we need to do this
    im_sz = size(frame);
    im_sz = im_sz(1:2);
    if ~needsCentering( imTraj, max(im_sz)*.1 )
        disp('It appears these have already been centred');
        imTraj_rc = imTraj;
        return;
    end

    im_sz = size( frame );
    im_sz = im_sz(2:-1:1)';
    
    translation = [im_sz ./ 2];
    
    imPos = [ [0;0] im_sz ] - repmat(translation,1,2);
    
    imTraj_rc = cellfun(@(x) x-repmat(translation,1,size(x,2)),imTraj,'uniformoutput',false);
    
    lengths = cellfun(@length,imTraj_rc);
    [~,sids] = sort(lengths);
    
    if nargin > 2 && DEBUG
        figure;
        image(imPos(1,:),imPos(2,:),frame)
        cellfun(@(x) drawcoords(x,'',0,'k'), imTraj_rc(sids(end-30:end)))
    end
    
    function doesit = needsCentering( traj, TOL )
       doesit = logical(sum(mean(minmax(horzcat(traj{:})),2) > TOL));
    end
end
    
   