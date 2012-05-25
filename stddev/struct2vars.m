s2var_fnames = fieldnames( varStruct );

for s2var_i=1:length(s2var_fnames)
    eval(sprintf('%1$s = varStruct.%1$s;',s2var_fnames{s2var_i}))
end

clear s2var*;
