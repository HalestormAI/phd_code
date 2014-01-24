    
    function ids = build_window( i, region_dims, offset )
        [row_idx, col_idx] = ind2sub(region_dims,i);

        ids = [];

        r_start = row_idx - offset;
        r_end = row_idx + offset;

        c_start = col_idx - offset;
        c_end = col_idx + offset;

        win_rows = r_start:r_end;
        win_cols = c_start:c_end;

        win_rows(or(win_rows < 1, win_rows > region_dims(1))) = []
        win_cols(or(win_cols < 1, win_cols > region_dims(2))) = []

%         for i=1:length(win_rows)
%             for j=1:length(win_cols)
%                 ids = [ids sub2ind(region_dims, win_rows(i),win_cols(j))];
%             end
%         end
        [XS,YS]=meshgrid(win_rows,win_cols)
        win_rows = reshape(XS,1,numel(XS));
        win_cols = reshape(YS,numel(XS),1)';

        ids = mysub2ind( region_dims, win_rows, win_cols );

        function ind = mysub2ind( dims, ri, ci)
            if isrow(ri)
                ri = ri';
                ci = ci';
            end
            subs = [ri,ci];
            ind = subs*[1; dims(1)] - dims(1);
        end
    end