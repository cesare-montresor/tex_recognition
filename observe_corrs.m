clc
clear
% close all

%% --- I M P O S T A Z I O N I
%%
% ---- Scelta dell'input e gestione files
    analyze_just_one = true; % Se true, analizza una sola immagine; altrimenti analizza tutta la cartella
    rand_image = true; % Se true e se analyze_just_one è true, sceglie 
                        % randomicamente l'immagine da analizzare. 
                        % Altrimenti sceglie la unrand_number-esima.
    unrand_number = 83;  % Se rand_image è false, seleziona l'immagine.
    flush_folder=false; % Se true, svuota la cartella result prima 
                        % di iniziare

% ---- Impostazioni sulla selezione del kernel
man_kernel = false; % Se true, usa un valore fisso anziché calcolare 
                    % il migliore autonomamente

% ---- Impostazioni sulla threshold
man_tresh = false; % Se true, usa un valore fisso anziché calcolare 
                   % il migliore autonomamente
T = 0.2;           % Specifica la dimensione da usare se man_thresh è tru


disk_dim = 5;% Specifica la dimensione da usare per la open della maschera
firsttime=true;

    figure();
%% C O D I C E
%%
i=unrand_number;
fn=i;

files = dir('defect_images\*.jpg');

[IMG_0, filename ]= fileloader(fn,files,analyze_just_one,rand_image,unrand_number);
IMG = rgb2gray(IMG_0); % 512x512
[IMG_x,IMG_y]=size(IMG);

    

for kernel_dim=2:25
    pattern1 = IMG(1:kernel_dim,1:kernel_dim); 
    pattern2 = IMG(2:kernel_dim+1,2:kernel_dim+1);
    pattern3 = IMG(IMG_x-kernel_dim+1:IMG_x,IMG_y-kernel_dim+1:IMG_y);
    pattern4 = IMG(IMG_x-kernel_dim:IMG_x-1,IMG_y-kernel_dim:IMG_y-1);
    pattern5 = IMG(1:kernel_dim,IMG_y-kernel_dim+1:IMG_y);
    pattern6 = IMG(2:kernel_dim+1,IMG_y-kernel_dim+1:IMG_y);
   
    
% ---- Calcolo della xcorr. 
%     c1 = normxcorr2(pattern1,IMG);
%     c2 = normxcorr2(pattern2,IMG);
%     c3 = normxcorr2(pattern3,IMG);
%     c4 = normxcorr2(pattern4,IMG);
%     c5 = normxcorr2(pattern5,IMG);
%     c6 = normxcorr2(pattern6,IMG);

%     xcorr_full = (c1+c2+c3+c4+c5+c6)/6; % calcolo media 
    
    xcorr_full =     imgaborfilt(IMG,kernel_dim,90);

    % Tagliamo la xcorr alla dimensione corretta
    xcorr = xcorr_full(kernel_dim-1:end-kernel_dim+1,kernel_dim-1:end-kernel_dim+1); % size(pattern)-1 
    xcorr = abs(xcorr);
    xcorr = imgaussfilt(xcorr,1);


% ---- Calcoliamo la treshold ideale con Otsu (o iterativamente TBD)
    if man_tresh == false
       T = graythresh(xcorr);
       fprintf('\n2] Tresholds ottimale secondo Otsu: %.4f \n ',T); 

    end

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

    
    isReliable(mask,IMG_cut);
    
    if analyze_just_one == false
        close(save_fig);
    end
    
    
%% F I G U R E S


    subplot(121);
    imagesc(xcorr);
    title('xcorr');
    
    subplot(122);
    imshow(IMG_masked);
       
    sgtitle(sprintf('Risultato immagine %s\nKernel size: %d',filename,kernel_dim));
  
    
%     
pause(.5);
 end