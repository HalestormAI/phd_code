function [output_hypotheses, out_error, chosen_a, chosen_t, chosen_p] = hypotheses_from_region_errors( regions, E_regions, ALPHAS, THETAS, PSIS )

% Get error for regions
E_r  = cell(length(regions),1);
r_ca = cell(length(ALPHAS),length(regions));

for r=1:length(regions)
    E_ra_tmp = Inf.*ones(length(ALPHAS),length(THETAS),length(PSIS));
    for a=1:length(ALPHAS)
        for t=1:length(THETAS)
            for p=1:length(PSIS)
                E_ra_tmp(a,t,p) = E_regions{a,t,p}(r);
            end
        end
    end
    E_r{r} = E_ra_tmp;
    for a=1:length(ALPHAS)
        r_ca{a,r} = squeeze(E_r{r}(a,:,:));
    end
end



% Now sum(r,t,p) error for combination at a
sumerr = Inf.*ones(length(ALPHAS),1);
for a=1:length(ALPHAS)
    sumerr(a) = sum(cellfun(@(x) min2d(x), r_ca(a,:)));
end
% Choose a with minimum sum(r,t,p)
[~, chosen_a_idx] = min(sumerr);

chosen_a = ALPHAS(chosen_a_idx);

% Now find best (t,p) pair for each region at chosen_a
chosen_t  = zeros(length(regions),1);
chosen_p  = zeros(length(regions),1);
min_error = zeros(length(regions),1);
for r=1:length(regions)
    [min_error(r),min_tp_idx] = min2d(r_ca{chosen_a_idx, r});
    chosen_t(r) = THETAS(min_tp_idx(1));
    chosen_p(r) = PSIS(min_tp_idx(2));
end

out_error = sum(min_error);

output_hypotheses = [chosen_t,chosen_p,repmat(chosen_a,length(regions),1)];