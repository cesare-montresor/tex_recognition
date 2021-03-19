% Given a textile image, computes graycomatrix for correlation, homogeneity
% and contrast by kernel size and plots the result.
    clear 
    clc    
    
%% SETTINGS
    rand_image = false;
    unrand_number = 23;
    files = dir('defect_images\*.jpg');
    
%% CODE
    IMG = rgb2gray(fileloader(1,files,true,rand_image,unrand_number));
    figure();
    imshow(IMG);
    smpl = 28;
    offsets0 = [zeros(smpl,1) (1:smpl)'];
    glcms = graycomatrix(IMG, 'Offset', offsets0);
    l=1:smpl;
    
% --- Homogenuity

    homo = graycoprops(glcms,'Homogeneity').Homogeneity;
    subplot(311);
    
    [~,loc] = findpeaks(homo(5:smpl));
    big_homo = loc(end);
    
    plot(l,homo);
    title('homo');
    
% --- Contrast
    cont = graycoprops(glcms,'Contrast').Contrast;
    subplot(312);
   
    [~,loc] = findpeaks(cont(5:smpl));
    big_cont = loc(end);
    
    plot(l,cont);
    title('contrast');    
% --- Corr    
    corr = graycoprops(glcms,'Correlation').Correlation;
    
    subplot(313);
    
    plot(l,corr);
    title('corr');
    
    [~,loc] = findpeaks(corr(5:smpl));
    big_corr = loc(end);
    
    fprintf('\t[observe_CvC] Dimensioni ottimali homogeneity: %d\n',big_homo);
    
    fprintf('\t[observe_CvC] Dimensioni ottimali contrast: %d\n',big_cont);
    
    fprintf('\t[observe_CvC] Dimensioni ottimali correlation: %d\n',big_corr);
