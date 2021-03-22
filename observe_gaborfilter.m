clc
clear
close all

% OBSERVE FILE --> Non è usato nel progetto ma serve per osservare
% l'andamento della maschera in funzione dei parametri che si danno alla
% funzione gaborfilter.

    % USO:
    % Per ogni impostazione possibile di gaborfilter computa la maschera e
    % la visualizza.

%%  S E T T I N G S

    analyze_just_one = true; 
    rand_image = false;
    unrand_number = 19;  
    disk_dim = 7;% Specifica la dimensione da usare per la open della maschera

    % Fino a che valore osserviamo il comportamento di gaborfiler? Quanti
    % angoli consideriamo?
        rot_max = 90;
        rot_step = 90;
        mag_max = 30;
    
%% C O D I C E
%%

    


% Per ogni inclinazione (0°,90°) e per ogni magnitude (2-30), applica gaborfilt e
% visualizza la maschera che si genera

nsample = length(0:rot_step:rot_max) * length(2:mag_max);

files = dir('defect_images\*.jpg');
% ---- Gestione di _quali_ immagini analizzare (secondo le impostazioni)
    to_be_analyzed = length(files);
    if analyze_just_one == true
        to_be_analyzed = 1;
    else
        rand_image = false;
    end

% for loop for each file in folder:

for file=1:to_be_analyzed
        % --- Caricamento
       
        [IMG_0, filename ]= fileloader(file,files,analyze_just_one,rand_image,unrand_number);
        IMG = rgb2gray(IMG_0); % 512x512
        [IMG_x,IMG_y]=size(IMG);
    
    for rotation = 0:rot_step:rot_max


        gaborfilter = zeros(size(imgaborfilt(IMG,2,1)));  

        for magnitude=2:mag_max

            gaborfilter_i = imgaborfilt(IMG,magnitude,rotation);
            gaborfilter_i = gaborfilter_i ./ max(gaborfilter_i);
            gaborfilter = gaborfilter + (gaborfilter_i .* (1/nsample));

            T = graythresh(gaborfilter(20:end-20,20:end-20))*1.4;

        % ---- Generiamo la maschera
            mask_raw = gaborfilter>T;

        % ---- Refining della maschera
            se = strel('disk',disk_dim); 
            mask = imopen(mask_raw,se);
        %    per l'immagine stronza ci vuole se = strel('disk',10);
             mask = imclose(mask,se);
            mask = bwareaopen(mask, 500);


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


            if analyze_just_one == true
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

        if rotation == 0
            mask1 = mask;
        else
            mask2 = mask;
        end
    end


[top_1,rat_1] = is_reliable(mask1(90:end-90,90:end-90),IMG_cut);
[top_2,rat_2] = is_reliable(mask2(90:end-90,90:end-90),IMG_cut);

if rat_1 > 10
    mask = mask2
elseif rat_2>10
    mask = mask1
end

if top_1 < top_2
    mask = mask1;
else
    mask = mask2;
end

        % Clippiamo al massimo i valori dell'immagine che corrispondono alla
        % maschera
        IMG_selected = IMG_cut;    IMG_selected(mask)=255;
        % Creiamo immagine a tre canali mettendo la versione selezionata sul
        % canale rosso
        IMG_masked=cat(3,IMG_selected,IMG_cut,IMG_cut);

        [IMG_cut_x, IMG_cut_y] = size(IMG_cut);

        selected_pixels = sum(mask(:) == 1);
        selected_pixels_ratio = (selected_pixels/(IMG_cut_x * IMG_cut_y))*100;


        
        f=figure();

        title(filename);
        
        %maschera
        imshow(IMG_masked);
      
        saveas(gcf, sprintf('results\\%s',filename),'png');
        
     if analyze_just_one == false
        close all;
     end
    
     
end

