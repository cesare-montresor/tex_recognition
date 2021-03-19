function [res1, res2] = find_pattern_size(A)
    %smpl = round(min(height, width) / 8);
    smpl = 30;
    offsets0 = [zeros(smpl,1) (1:smpl)'];
    glcms = graycomatrix(A, 'Offset', offsets0);
    corr = graycoprops(glcms,'Contrast').Contrast;
    corr(1) = 0;
    plot(corr);
    % big = find(corr == max(corr(int32(end/2):end)), 1);
    [~,loc] = findpeaks(corr);
    big = loc(end);
    if numel(loc) > 1
        small = loc(end - 1);
    else
        small = big;
    end
    
%     if small > 15
%        res=small;
%     else
%         res=big;
%     end
%     
    
    res1 = max(loc);
    res2 = small;
    
    fprintf('\t[find_size] Dimensioni ottimali trovate: %d, %d\n',small,big);
    

end