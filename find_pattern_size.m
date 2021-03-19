function [res1, res2] = find_pattern_size(IMG)
% Given an images, finds 2 possible good sizes for the kernel, using
% greycomatrix function on Contrast and Correlation parameters.

%% Settings
    show_figures = false; % Shows plot with kernel size performance by parameter
    smpl = 28; % Maximum computable kernel size

%% Code
    l = 1:28;
    offsets0 = [zeros(smpl,1) (1:smpl)'];
    glcms = graycomatrix(IMG, 'Offset', offsets0);

% % --- Homogenuity %% Commented because il grafico è identico a
% Correlation, solo con un'ampiezza diversa
% 
%     homo = graycoprops(glcms,'Homogeneity').Homogeneity;
% 
%     [~,loc] = findpeaks(homo)
%     big_homo = loc(end);
%    
% 
%     if show_figures    
%       subplot(311);    
%       plot(l,homo);
%       title('homo');
%     end 
    
% --- Contrast
    cont = graycoprops(glcms,'Contrast').Contrast;
 
    [~,loc] = findpeaks(cont);
    big_cont = loc(end);
    
   if show_figures 
        subplot(312);
        plot(l,cont);
        title('contrast'); 
   end
% --- Corr    
    corr = graycoprops(glcms,'Correlation').Correlation;

    
    [~,loc] = findpeaks(corr);
    big_corr = loc(end);
    
    
    if show_figures
        subplot(313);    
        plot(l,corr);
        title('corr');
    end
    
    
%     fprintf('\t[observe_CvC] Dimensioni ottimali homogeneity: %d\n',big_homo);
    fprintf('\t[find_pattern_size] Dimensioni ottimali contrast: %d\n',big_cont); 
    fprintf('\t[find_pattern_size] Dimensioni ottimali correlation: %d\n',big_corr);
    
    
    
res1 = big_corr;
res2 = big_cont;

end