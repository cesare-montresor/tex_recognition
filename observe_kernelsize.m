
% OBSERVE FILE --> Non è usato nel progetto ma serve per osservare
% l'andamento della maschera.

    % COMPORTAMENTO:
    % Apre una schermata con l'andamento dei parametri di greycomatrix al
    % variare dell'offset. L'offset è  legato alla dimensione
    % ottimale del kernel.
    % In un'altra finestra, mostra (animazione) come risulta la maschera al variare
    % della dimensione del kernel. 
    
    % USO:
    % schermata quale range di valori produce un risultato ottimale, e
    % guardare a sinistra a cosa corrisponde (correlazione massima?
    % contrasto massimo? nessuno dei due? Quale dei picchi?)
    
    % NOTA:
    % greycomatrix --> misura la correlazione/contrasto fra un pixel e un
    % altro pixel, a distanza 'offset'
    
    
    close all
    clear
    clc
    
%% S E T T I N G S
    analyze_just_one = true; 
    rand_image = true;
    unrand_number = 1;
    files = dir('defect_images\*.jpg');
    disk_dim = 5;
    
    smpl = 28; %Fino a che dimensione di kernel computo
    
%% R U N
%% part 1: plot valori di corr&cont
    [IMG_0, filename] = fileloader(1,files,true,rand_image,unrand_number);
    IMG = rgb2gray(IMG_0);
%     f1 = figure(1);
%     imshow(IMG);
    offsets0 = [zeros(smpl,1) (1:smpl)'];
    glcms = graycomatrix(IMG, 'Offset', offsets0);
    l=1:smpl;
    
% --- Contrast
    cont = graycoprops(glcms,'Contrast').Contrast;

    [~,loc] = findpeaks(cont(5:smpl));
    big_cont = loc(end);
    
%     subplot(211);
%     plot(l,cont);
%     title('contrast');    
% --- Corr    
    corr = graycoprops(glcms,'Correlation').Correlation;
    
    
%     subplot(212);
%     plot(l,corr);
%     title('corr');
    
    [~,loc] = findpeaks(corr(5:smpl));
    big_corr = loc(end);

    



%% part 2: produzione della maschera per ogni valore possibile.

[IMG_x,IMG_y]=size(IMG); 

for kernel_dim = 5:smpl
    pattern1 = IMG(1:kernel_dim,1:kernel_dim); 
    pattern2 = IMG(2:kernel_dim+1,2:kernel_dim+1);
    pattern3 = IMG(IMG_x-kernel_dim+1:IMG_x,IMG_y-kernel_dim+1:IMG_y);
    pattern4 = IMG(IMG_x-kernel_dim:IMG_x-1,IMG_y-kernel_dim:IMG_y-1);
    pattern5 = IMG(1:kernel_dim,IMG_y-kernel_dim+1:IMG_y);
    pattern6 = IMG(2:kernel_dim+1,IMG_y-kernel_dim+1:IMG_y);
   
    
% ---- Calcolo della xcorr. 
    c1 = normxcorr2(pattern1,IMG);
    c2 = normxcorr2(pattern2,IMG);
    c3 = normxcorr2(pattern3,IMG);
    c4 = normxcorr2(pattern4,IMG);
    c5 = normxcorr2(pattern5,IMG);
    c6 = normxcorr2(pattern6,IMG);

    xcorr_full = (c1+c2+c3+c4+c5+c6)/6; % calcolo media 
    
 %   xcorr_full =     imgaborfilt(IMG,kernel_dim,90);

    % Tagliamo la xcorr alla dimensione corretta
    xcorr = xcorr_full(kernel_dim-1:end-kernel_dim+1,kernel_dim-1:end-kernel_dim+1); % size(pattern)-1 
    xcorr = abs(xcorr);
    xcorr = imgaussfilt(xcorr,1);


% ---- Calcoliamo la treshold ideale con Otsu (o iterativamente TBD)
 
       T = graythresh(xcorr);
       fprintf('\n2] Tresholds ottimale secondo Otsu: %.4f \n ',T); 


% ---- Generiamo la maschera
    mask_raw = xcorr<T;

% ---- Refining della maschera
    se = strel('disk',disk_dim); 
    mask = imopen(mask_raw,se);
%    per l'immagine stronza ci vuole se = strel('disk',10);
     mask = imclose(mask,se);
    mask = bwareaopen(mask, 200);

    
% ---- Ritaglio IMG e applicazione maschera
    border = kernel_dim / 2;
warning('off');
IMG_cut=IMG(border:end-border+1,border:end-border+1);
    % Clippiamo al massimo i valori dell'immagine che corrispondono alla
    % maschera
    IMG_selected = IMG_cut;    IMG_selected(mask)=255;
    % Creiamo immagine a tre canali mettendo la versione selezionata sul
    % canale rosso
    IMG_masked=cat(3,IMG_selected,IMG_cut,IMG_cut);
    
    [IMG_cut_x, IMG_cut_y] = size(IMG_cut);
    
    selected_pixels = sum(mask(:) == 1);
    selected_pixels_ratio = (selected_pixels/(IMG_cut_x * IMG_cut_y))*100;

    
    is_reliable(mask,IMG_cut);
    
    if analyze_just_one == false
        close(save_fig);
    end
    
    
%% F I G U R E S

    f1=figure(1);
    
    %Plot 
    subplot(211);
    plot(l,corr);
    title('correlation');
    hold on;
    plot(kernel_dim,corr(kernel_dim),'r*')
    hold off
    
    subplot(212);
    plot(l,cont);
    title('contrast');  
    hold on;
    plot(kernel_dim,cont(kernel_dim),'m*')
    hold off
    
    
    f2=figure(2);
    
    subplot(121);
    imagesc(xcorr);
    axis image;
    title('xcorr');
    
    subplot(122);
    imshow(IMG_masked);
       
    sgtitle(sprintf('Risultato immagine %s\nKernel size: %d',filename,kernel_dim));
  
    pause(.5);
 end
