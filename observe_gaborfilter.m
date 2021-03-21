clc
clear
close all

% OBSERVE FILE --> Non è usato nel progetto ma serve per osservare
% l'andamento della maschera.

    % USO:
    % Per ogni impostazione possibile di gaborfilter computa la maschera e
    % la visualizza.

%%  S E T T I N G S
    analyze_just_one = true; 
    rand_image = false;
    unrand_number = 21;  
    disk_dim = 5;% Specifica la dimensione da usare per la open della maschera

    % Fino a che valore osserviamo il comportamento di gaborfiler? Quanti
    % angoli consideriamo?
        rot_max = 90;
        rot_step = 90;
        mag_max = 30;
    
%% C O D I C E
%%

    figure();
    
    % --- Caricamento
        i=unrand_number;
        fn=i;
        files = dir('defect_images\*.jpg');
        [IMG_0, filename ]= fileloader(fn,files,analyze_just_one,rand_image,unrand_number);
        IMG = rgb2gray(IMG_0); % 512x512
        [IMG_x,IMG_y]=size(IMG);

% Per ogni inclinazione (0°,90°) e per ogni magnitude (2-30), applica gaborfilt e
% visualizza la maschera che si genera
for rotation = 0:rot_step:rot_max
    for magnitude=2:mag_max

        gaborfilter = imgaborfilt(IMG,magnitude,rotation);
        gaborfilter = gaborfilter ./ max(gaborfilter);

        T = graythresh(IMG);
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
        border = magnitude / 2;
          IMG_cut=IMG; %IMG(border:end-border+1,border:end-border+1);
        % Clippiamo al massimo i valori dell'immagine che corrispondono alla
        % maschera
        IMG_selected = IMG_cut;    IMG_selected(mask)=255;
        % Creiamo immagine a tre canali mettendo la versione selezionata sul
        % canale rosso
        IMG_masked=cat(3,IMG_selected,IMG_cut,IMG_cut);

        [IMG_cut_x, IMG_cut_y] = size(IMG_cut);

        selected_pixels = sum(mask(:) == 1);
        selected_pixels_ratio = (selected_pixels/(IMG_cut_x * IMG_cut_y))*100;

        if selected_pixels_ratio > 50
            mask =~mask;
        end
        is_reliable(mask,IMG_cut);

        if analyze_just_one == false
            close(save_fig);
        end


    %% F I G U R E S
        sgtitle(sprintf('Risultato immagine %s\nmag = %d, rot = %d°',filename,magnitude,rotation));
  
        %gaborplot
        subplot(121);
        imagesc(gaborfilter);
        axis image
        title('gabor');
        colorbar;
        
        %maschera
        subplot(122);
        imshow(IMG_masked);
        title('risultato');
      
    pause(.1);
    end
end
 