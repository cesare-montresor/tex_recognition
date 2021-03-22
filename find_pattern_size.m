function [res1, res2] = find_pattern_size(IMG)
% Data un'immagine, trova due possibili buone dimensioni per il kernel
% usando la funzione greycomatrix e considerando l'ultimo valore che
% massimizza (separatamente) correlazione e contrasto.

%% S E T T I N G S
    show_figures = false; % Shows plot with kernel size performance by parameter
    smpl = 28; % Maximum computable kernel size
    prints = false; % prints selected values

%% C O D E
    l = 1:30;
    offsets0 = [zeros(smpl,1) (1:smpl)'];
    glcms = graycomatrix(IMG, 'Offset', offsets0);

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
    
 % Figure, se abilitate:
    if show_figures
        subplot(313);    
        plot(l,corr);
        title('corr');
    end
    
    if prints == true
        fprintf('\t[find_pattern_size] Dimensioni ottimali contrast: %d\n',big_cont); 
        fprintf('\t[find_pattern_size] Dimensioni ottimali correlation: %d\n',big_corr);
    end
    
    
res1 = big_corr;
res2 = big_cont;

end