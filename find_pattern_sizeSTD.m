% function res = find_pattern_sizeSTD(A)
% clear
    %smpl = round(min(height, width) / 8);
    
    clear 
    clc
    A = rgb2gray(imread('defect_images\i10.jpg'));
    figure();
    imshow(A);
    smpl = 30;
    offsets0 = [zeros(smpl,1) (1:smpl)'];
    glcms = graycomatrix(A, 'Offset', offsets0);
    
    
% --- Homogenuity

    homo = graycoprops(glcms,'Homogeneity');
    subplot(311);
    plot(homo.Homogeneity);
   title('homo');
    
% --- Contrast
    cont = graycoprops(glcms,'Contrast');
    subplot(312);
    plot(cont.Contrast);
   title('contrast');
    
% --- Corr    
    corr = graycoprops(glcms,'Correlation').Correlation;
    corr(1) = 0;
    subplot(313);
    plot(corr);
   title('xcorr');
    % big = find(corr == max(corr(int32(end/2):end)), 1);
    [~,loc] = findpeaks(corr);
    big = loc(end);

    
    if numel(loc) > 1
        small = loc(end - 1);
    else
        small = big;
    end
    fprintf('\t[find_size] Dimensioni ottimali trovate: %d, %d\n',small,big);
    %{
    if small > 15
       res=small;
    else
        res=big;
    end
    %}
% end