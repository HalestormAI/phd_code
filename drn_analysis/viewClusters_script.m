fig_hists =figure;
nums = size(centres,1);
if mod(nums,2),
    height = (2/(nums+1))-0.075;
else 
    height = (2/(nums))-0.075;
end
for i=1:2:size(centres,1),
    idx = (i-1)*2 + 1;
    subplot('Position',[ 0, (i)/nums, 0.075, 2/size(centres,1) ] );
    %rectangle('Position', [ 0, 0,1,1 ], 'FaceColor', colours(i,:) );
    
    
if mod(nums,2),
    vpos = 1-((i+1)/2-1)*(2/(nums+1))-height-0.02;
else 
    vpos = 1-((i+1)/2-1)*(2/nums)-height-0.02;
end
    
    %     vpos = 1-1/size(centres,1) - (0.9*i)/size(centres,1);
    mTextBox = annotation('textbox',[ 0,vpos,0.075,height ]);
    set(mTextBox,'String',sprintf('%d',i), 'HorizontalAlignment', 'center', 'VerticalAlignment','middle' );
    set(mTextBox,'BackgroundColor', colours(i,:) );
    axis off;
    
    
    
    subplot('Position',[ 0.1, vpos, 0.39, height ] );
    bar(1:size(centres,2),centres(i,:));
    if i+1 <= size(centres,1),
        j = i+1;
        idx = (j-1)*2 + 1;
        subplot('Position',[ 0.51, vpos, 0.075, height ] );
        mTextBox = annotation('textbox',[ 0.51,vpos,0.075,height ]);
        set(mTextBox,'String',sprintf('%d',j), 'HorizontalAlignment', 'center', 'VerticalAlignment','middle' );
        set(mTextBox,'BackgroundColor', colours(j,:) );
        axis off;
        subplot('Position',[ 0.61, vpos, 0.39, height ] );
        bar(1:size(centres,2),centres(j,:));
    end
end
    
    