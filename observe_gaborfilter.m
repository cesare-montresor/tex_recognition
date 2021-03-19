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
    unrand_number = 15;  % Se rand_image è false, seleziona l'immagine.
    flush_folder=false; % Se true, svuota la cartella result prima 
                        % di iniziare

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

    

for kernel_dim=10:30

    
    gaborfilter = imgaborfilt(IMG,kernel_dim,00);

    % Tagliamo la xcorr alla dimensione corretta
%      gaborfilter = gaborfilter_full(kernel_dim-1:end-kernel_dim+1,kernel_dim-1:end-kernel_dim+1); % size(pattern)-1 
%     gaborfilter = abs(gaborfilter);
%     gaborfilter = imgaussfilt(gaborfilter,1);
    gaborfilter = gaborfilter ./ max(gaborfilter);
    
    

%    T = graythresh(gaborfilter);
    T = .9;
   fprintf('\n2] Tresholds ottimale secondo Otsu: %.4f \n ',T); 

% ---- Generiamo la maschera
    mask_raw = gaborfilter>T;

% ---- Refining della maschera
    se = strel('disk',disk_dim); 
    mask = imopen(mask_raw,se);
%    per l'immagine stronza ci vuole se = strel('disk',10);
     mask = imclose(mask,se);
    mask = bwareaopen(mask, 200);

    
% ---- Ritaglio IMG e applicazione maschera
    border = kernel_dim / 2;
      IMG_cut=IMG%IMG(border:end-border+1,border:end-border+1);
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
    imagesc(gaborfilter);
    title('gabor');
    colorbar;
    subplot(122);
    imshow(IMG_masked);
       
    sgtitle(sprintf('Risultato immagine %s\nKernel size: %d',filename,kernel_dim));
  
    
%     
pause(.5);
 end