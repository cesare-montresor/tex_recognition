function [mask, mask_raw, gaborfilter] = gabor_emergency(IMG,filename)
% Per ciascuna rotazione in esame (0,90) genera una mappa di gaborfilter 
% "totale" mediando il gaborfilter di ciascuna magnitudo possibile (nei
% limiti dati da settings). Dopo di che, genera una maschera usando Otsu
% come threshold, e stabilisce quale delle due maschere potrebbe essere più
% ottimale facendo considerazioni sulla topologia. Ritorna la maschera
% migliore.

%% SETTINGS

    show_animation = false;

    % Quanti valori testiamo? 
        rot_max = 90; %valore massimo di rotazione
        rot_step = 90; % step di rotazione 
        mag_max = 30; %valore massimo di magnitudo
        
        
        disk_dim = 7;% Specifica la dimensione da usare per la open della maschera.
       % Empiricamente noto che con Gabor è più efficace se è più
       % aggressiva.
        
        nsample = length(0:rot_step:rot_max) * length(2:mag_max);

        
%% RUN

    for rotation = 0:rot_step:rot_max
        
    % Genero una matrice di zeri della dimensione di GaborFilter dove
    % accumulare i risultati della media.
        gaborfilter = zeros(size(imgaborfilt(IMG,2,1)));  

        for magnitude=2:mag_max

        % Calcolo il gaborfilter con i parametri attuali
            gaborfilter_i = imgaborfilt(IMG,magnitude,rotation);
            gaborfilter_i = gaborfilter_i ./ max(gaborfilter_i);
            
        % Aggiungo il gaborfilter corrente alla media
            gaborfilter = gaborfilter + (gaborfilter_i .* (1/nsample));
 
        % --- A fini di visualizzazione, genero la maschera ogni volta
        % --- (Inoltre me la trovo già pronta per il finale)
                 
            % Con Otsu, calcolo la threshold ottimale
                T = graythresh(gaborfilter(20:end-20,20:end-20))*1.4;

            % Genero la maschera
                mask_raw = gaborfilter>T;

            % Refining della maschera
                se = strel('disk',disk_dim); 
                mask = imopen(mask_raw,se);
                mask = imclose(mask,se);
                mask = bwareaopen(mask, 500); % Empiricamente, noto che con gabor bisogna essere più aggressivi...


            % Applicazione maschera
              IMG_cut=IMG; 
              IMG_selected = IMG_cut;    IMG_selected(mask)=255;
              IMG_masked=cat(3,IMG_selected,IMG_cut,IMG_cut);

            if show_animation == true
            % --- Grafico animato
                sgtitle(sprintf('Risultato immagine %s\nmag = %d, rot = %d°',filename,magnitude,rotation));

                % Gabor mediato
                subplot(121); imagesc(gaborfilter);  title('gabor'); axis image; colorbar;

                % Maschera risultante 
                subplot(122); imshow(IMG_masked); title('risultato');

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
%         IMG_selected = IMG_cut;    IMG_selected(mask)=255;
        % Creiamo immagine a tre canali mettendo la versione selezionata sul
        % canale rosso
%         IMG_masked=cat(3,IMG_selected,IMG_cut,IMG_cut);

%         [IMG_cut_x, IMG_cut_y] = size(IMG_cut);

        
%         f=figure();
%         title(filename);
%         %maschera
%         imshow(IMG_masked);
%         saveas(gcf, sprintf('results\\%s',filename),'png');
       


end