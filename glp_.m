function res = glp(im, thresh)
    [r,c] = size(im);
    d0 = thresh;
    
    d = zeros(r,c);
    h = zeros(r,c);
    
    for i = 1:r
        for j = 1:c
            d(i,j) = sqrt((i-(r/2))^2 + (j-(c/2))^2);
        end
    end
    
    for i = 1:r
        for j = 1:c
            h(i,j) = exp(-( (d(i,j)^2) / (2*(d0^2)) ));
        end
    end
    
    res = h;
end