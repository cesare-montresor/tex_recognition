function result = is_reliable(mask,img)
% Stabilisce (molto indicativamente, non essendo un essere umano) se la
% maschera ottenuta in risultato può essere accettata o meno. //Sarebbe
% carino anggiungere anche in result un indizio su cosa può essere
% aggiustato ma ci penserò...


%% Verifica 1: percentuale di selezione
% Se la % di selezione è troppo alta, probabilmente non va bene

% Range accettato:
min_ratio = 1; max_ratio = 10;

[img_x, img_y] = size(img);
selected_pixels = sum(mask(:) == 1);
selected_pixels_ratio = (selected_pixels/(img_x * img_y))*100;

fprintf('\n\t[is_reliable] Selected pixels: %d\t Selected ratio: %4.2f\n ',selected_pixels,selected_pixels_ratio);

result_1 = (selected_pixels_ratio < max_ratio) && (selected_pixels_ratio > min_ratio);

%% Verifica 2: componenti connesse
% Se ci sono centinaia di componenti connesse, è facile che si tratti di
% "freckles" rimaste in giro e che bisogni abbassare il livello di
% bwareaopen.

%Range massimo accettato
max_n_areas = 5;

topology_test = bwconncomp(mask);

result_2 = topology_test.NumObjects < max_n_areas;

%% Calcolo risultato e rispondo

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

return
