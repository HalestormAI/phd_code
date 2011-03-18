function lengths = get_line_lengths( C );

lengths = zeros(1,size(C,2) / 2);

for i=1:2:size(C,2),
    lengths( (i+1)/2 ) = vector_dist( C(:,i), C(:,i+1) );
end
    