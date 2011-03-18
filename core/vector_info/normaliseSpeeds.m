function speeds_norm = normaliseSpeeds( speeds )

    speeds_norm = speeds - min(speeds);
    speeds_norm = speeds_norm ./ max(speeds_norm);

end