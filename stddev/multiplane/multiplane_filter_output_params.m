function good_params = multiplane_filter_output_params( output_params )

    bounds(1,:) = mean(output_params) + 2*std(output_params);
    bounds(2,:) = mean(output_params) - 2*std(output_params);

    bad = zeros(length(output_params),1);

    for b=1:length(output_params)

        if abs(output_params(b,2)) > 80 || sum(or((output_params(b,:) > bounds(1,:)),(output_params(b,:) < bounds(2,:)))) > 0
            bad(b) = 1;
            continue;
        end

    end

    good_params = output_params(~bad,:);
end