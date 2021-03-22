function [topology_test, selected_pixels_ratio] = is_reliable(mask,img)
% Ritorna il numero di aree sconnesse e la percentuale di pixel
% selezionata. Se abilitato, fa anche una stima grossolana di bonta' della
% maschera (stampando testo).

%% SETTINGS
    prints = false; % se true mostra se, secondo lui, la maschera è accettabile

%% RUN

%% Verifica 1: percentuale di selezione
% Se la % di selezione è troppo alta, probabilmente non va bene

% Range accettato:
min_ratio = 1; max_ratio = 10;

[img_x, img_y] = size(img);
selected_pixels = sum(mask(:) == 1);
selected_pixels_ratio = (selected_pixels/(img_x * img_y))*100;


result_1 = (selected_pixels_ratio < max_ratio) && (selected_pixels_ratio > min_ratio);

%% Verifica 2: componenti connesse
% Se ci sono centinaia di componenti connesse, è facile che si tratti di
% "freckles" rimaste in giro e che bisogni abbassare il livello di
% bwareaopen.

%Range massimo accettato
max_n_areas = 5;

topology_test = bwconncomp(mask).NumObjects;

result_2 = topology_test < max_n_areas;

%% Calcolo risultato e rispondo, se richiesto


if prints == true
    
    fprintf('\t[is_reliable] Topology: %d Ratio: %4.2f\n ',topology_test,selected_pixels_ratio);
    result = result_1 && result_2;

    if result == true
        disp('   [is_reliable] Result mask seems acceptable');
    else
        if result_1 == false 
            disp ('   [is_reliable] Selected area is suspiciously big or small');
        end
        if result_2 == false
            disp('   [is_reliable] Selected area is suspiciously unconnected..');
        end
    end
end

return
