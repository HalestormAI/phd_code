function isit = isunit( vec )

    isit = round(norm(vec)*100) == 100;
end