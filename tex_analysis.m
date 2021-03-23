clear 
close all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @ CESARE!! 
% Relazione: 
%    [TODO: PRENDERE PIù KERNEL VARIEGATI + MEDIA]
%   comunque già così riconosce 34 immagini (ho migliorato alcune cose) ^-^
%  
    %  RELAZIONE:
    %  https://docs.google.com/document/d/1oUnQE5UUykekRmstjFRi4RPNVbs6H3F_cKcTdAV1ZF0/edit?usp=sharing
%
%   Per mantenere questo script (dato che già va e abbiamo poco tempo)
%   potremmo anche usare 1 sola dimensione kernel (aka quella che torna da
%   find_pattern_size), limitarci a prendere N volte quella lì e fare
%   media/somme/moltiplicazioni
%   In particolare, se facciamo questa cosa dentro al for krn=1:2 (linea
%   84), si fa la media usando una volta dim=CONT e una volta dim=CORR e si
%   generano due mappe separate. A quel punto il controllo finale decide 
%   quale usare (o se usare GABOR).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% --- IMPOSTAZIONI

% ---- Scelta dell'input e gestione files
    analyze_just_one = true; % Se true, analizza una sola immagine; 
                             % altrimenti analizza tutta la cartella

    rand_image = false; % Se true e se analyze_just_one è true, sceglie 
                        % randomicamente l'immagine da analizzare. 
                        % Altrimenti sceglie la unrand_number-esima.
                        
    unrand_number = 2;  % Se rand_image è false, seleziona l'immagine.
    
    flush_folder=false; % Se true, svuota la cartella result prima 
                        % di iniziare
                        
% ---- Impostazioni di risultato
    show_resume = true;  % se true apre la figura di riassunto coi passaggi
    
    show_resume_choice = true; %considerto solo se show_resume è true; mostra 
                              % sia la mappa CONT che la CORR.
                              
    show_result = false; % se true apre una figura che mostra la zona 
                         % selezionata

% ---- Parametri per l'analisi
    disk_dim = 5;% Specifica la dimensione da usare per la open della maschera
    areaopen = 300; % Specifica l'area minima selezionabile.
    num_kernels = 20;
%% --- RUN


%% Caricamento files

% ---- Gestione cartella risultati
    if not(isfolder('results'))
        mkdir('results')
    end

    if flush_folder == true
        delete('results\*')
    end

% ---- Caricamento tutte le immagini
    files = dir('defect_images\*.jpg');
    file_num = size(files);

% ---- Gestione di _quali_ immagini analizzare (secondo le impostazioni)
    to_be_analyzed = length(files);
    if analyze_just_one == true
        to_be_analyzed = 1;
    else
        rand_image = false;
    end

    
     kernel_types = ["CORR","CONT"]; %mi serve solo per avere le stringhe pronte comode
    
% for loop for each file in folder:
for fn=1:to_be_analyzed
 i=fn;
    [IMG_RGB, filename]= fileloader(fn,files,analyze_just_one,rand_image,unrand_number);
    IMG = rgb2gray(IMG_RGB); % 512x512
    [IMG_x,IMG_y]=size(IMG);
    %figure(101);imshow(IMG)
    
%% - Analisi
    avg_gray = floor(mean(mean(IMG)));
    morph_pat_mask = strel('disk',disk_dim); 

% --- Ricerca dimensione ottimale dei kernels
	[dim_contr, dim_corr] = find_pattern_size(IMG);
    
    kernel_dims = [dim_contr, dim_contr/2, dim_contr/4, dim_corr, dim_corr/2, dim_corr/4];    
    kernal_max = max(kernel_dims);
    
    map_x = IMG_x-(kernal_max*2);
    map_y = IMG_y-(kernal_max*2);
    map_size = [map_x, map_y];
    
    avg_corr = zeros(map_size);
    
    avg_mask = zeros(map_size);
    avg_mask_morph = zeros(map_size);
    
        avg_corr_mask = zeros(map_size);
    avg_corr_mask_morph = zeros(map_size);
    
    for k = 1:num_kernels
        kernel_dim = randsample(kernel_dims,1);
        if kernel_dim < 5
           kernel_dim = kernal_max;
        end
        % kernel_dim = kernel_dim / randi(3);
        if mod(kernel_dim,2) ~= 0
            kernel_dim = kernel_dim+1; % force even
        end
        kernel_dim = int32(kernel_dim);
        
        pat_x_max = IMG_x - kernel_dim;
        pat_y_max = IMG_y - kernel_dim;
        
        % Gaussian: Likes the center
        % pat_x = floor( randn() * pat_x_max );
        % pat_y = floor( randn()* pat_y_max );
        
        % Inverse Gaussian: Likes borders
        %igauss = makedist('InverseGaussian')
        %pat_x = int32(floor(igauss.random * pat_x_max));
        %pat_y = int32(floor(igauss.random * pat_y_max));
        
        % Uniform: Doesn't like anyone -_-
        pat_x = randi(pat_x_max);
        pat_y = randi(pat_y_max);
        
        % Extract pattern
        pat = IMG( pat_x : (pat_x+kernel_dim) ,  pat_y : (pat_y+kernel_dim) );
        xcorr_pat = normxcorr2(pat, pat);
        xcorr_pat = abs(xcorr_pat);
        xcorr_pat_avg = mean(mean(xcorr_pat))
        %pat = imsharpen(pat);
        
       
        % Add padding to image to obtain equally sized xcorr maps.
        % regardless of the kernel size.
        border = ceil(kernel_dim / 2);
        %padding borders
        %IMG_padded = padarray(IMG, border, avg_gray);
        % cross-correlation
        xcorr = normxcorr2(pat, IMG);
        % cropping borders based on kernel size
        xcorr = xcorr(border:IMG_x+(border-1),border:IMG_y+(border-1));
        % xcorr = imgaussfilt(xcorr,1);
        % figure(1); imshow(xcorr);  colormap gray;
        xcorr = abs(xcorr);
        xcorr = xcorr * xcorr_pat_avg;
        
        % figure(2); imshow(xcorr);  colormap gray;
        
        % Elimino i bordi prima di calcolare OTSU
        % cropping borders based accumulation map size
        xcorr = 1 - xcorr(kernal_max:IMG_x-(kernal_max+1) ,kernal_max:IMG_y-(kernal_max+1));        
        T = graythresh(xcorr);
        mask_raw = xcorr>T;
        
        % Image Open sulla maskera
        mask_morph = imopen(mask_raw, morph_pat_mask);        
        % figure(1); imshow(mask_raw);  colormap gray;
        
        
        % accumulate 
        avg_corr = avg_corr + xcorr;
        
        avg_mask = avg_mask + (mask_raw / num_kernels);
        avg_mask_morph = avg_mask_morph + ( mask_morph / num_kernels);
        
        avg_corr_mask = avg_corr_mask + (( mask_raw .* xcorr ) / num_kernels);
        avg_corr_mask_morph = avg_corr_mask_morph + (( mask_morph .* xcorr ) / num_kernels);
        
    end
    avg_corr_N = mat2gray(avg_corr);
    avg_corr_T = graythresh(avg_corr_N);
    avg_corr_MT = avg_corr_N>avg_corr_T;
    avg_corr_M = imopen(avg_corr_MT, morph_pat_mask);        
    avg_corr_M = (avg_corr_M .* avg_corr_N) + avg_corr_M;
    %avg_corr_M = imgaussfilt(avg_corr_M,3);
    
    avg_mask_N = mat2gray(avg_mask);
    avg_mask_T = graythresh(avg_mask_N);
    avg_mask_MT = avg_mask_N>avg_mask_T;
    avg_mask_M = imopen(avg_mask_MT, morph_pat_mask);   
    avg_mask_M = (avg_mask_M .* avg_mask_N) + avg_mask_M;
    %avg_mask_M = imgaussfilt(avg_mask_M,3);
    
    avg_corr_mask_N = mat2gray(avg_corr_mask);
    avg_corr_mask_T = graythresh(avg_corr_mask_N);
    avg_corr_mask_MT = avg_corr_mask_N>avg_corr_mask_T;
    avg_corr_mask_M = imopen(avg_corr_mask_MT, morph_pat_mask);   
    avg_corr_mask_M = (avg_corr_mask_M .* avg_corr_mask_N) + avg_corr_mask_M;
    %avg_corr_mask_M = imgaussfilt(avg_corr_mask_M,3);
    
    %avg_mask_morph = imgaussfilt(avg_mask_morph,3);
    %avg_corr_mask_morph = imgaussfilt(avg_mask_morph,3);
    
    figure(10);
    subplot(3,2,1); imagesc(avg_corr_MT); axis image; 
    subplot(3,2,2); imagesc(avg_corr_M); axis image; 
    subplot(3,2,3); imagesc(avg_mask_MT); axis image; 
    subplot(3,2,4); imagesc(avg_mask_M); axis image; 
    subplot(3,2,5); imagesc(avg_corr_mask_MT); axis image; 
    subplot(3,2,6); imagesc(avg_corr_mask_M); axis image; 
    
    
    total = avg_corr_M + avg_mask_M + avg_corr_mask_M + avg_mask_morph + avg_corr_mask_morph;
    total = mat2gray(total);
    total = imgaussfilt(total,5);
    T = graythresh(total);
    finalmask = total>T;
    % finalmask = imopen(finalmask, morph_pat_mask);      
    
    figure(15);
    subplot(2,3,1); imagesc(avg_corr); axis image; 
    subplot(2,3,2); imagesc(avg_mask); axis image; 
    subplot(2,3,3); imagesc(avg_mask_morph); axis image; 
    subplot(2,3,4); imagesc(avg_corr_mask); axis image; 
    subplot(2,3,5); imagesc(avg_corr_mask_morph); axis image; 
    subplot(2,3,6); imagesc(finalmask); axis image; 
    
    
    
    
    
    add_border_size = (IMG_x - map_x)/2;
    padded_final_mask = padarray(finalmask, [add_border_size,add_border_size], 0);
    
    selected_IMG = IMG;
    selected_IMG(padded_final_mask) = 255;
    final_IMG = cat(3,selected_IMG,IMG,IMG);
    
% ---- Scelta della maschera migliore:
    % Di default prendo CORR.
    % Passo a CONT se:
    %   - CONT ha meno aree
    %   - a parità di aree, cont ha percentuale di selezione maggiore
    % Se nessuna delle due va bene lanciamo GABOR.
    
    [topology_corr, selected_ratio_corr] = is_reliable(mask_corr,IMG);
    [topology_cont, selected_ratio_cont] = is_reliable(mask_cont,IMG);

    mask = mask_corr;

    if selected_ratio_corr == 0 && selected_ratio_cont <= 0.1
        mask= mask_cont;
        kernel_type = 'CONT';
        fprintf("B) Switching to CONT because CORR mask was empty\n");
    elseif topology_cont < topology_corr
        mask = mask_cont;
        kernel_type = 'CONT';
        fprintf("B) Switching to CONT because of bad topology\n");
    elseif topology_cont == topology_corr && selected_ratio_cont > selected_ratio_corr
        mask = mask_cont;
        kernel_type = 'CONT';
        fprintf("B) Switching to CONT because of same topology + better selection ratio.\n");
    else
        fprintf("B) CORR map seems optimal.\n");
        kernel_type = 'CORR';
        kernel_dim = kernel_corr;
    end

    if selected_ratio_cont <= 0.1
        kernel_type = 'GABOR';
        fprintf("B.2) Both masks are empty; switching to GABOR. Potrebbe volerci qualche secondo.. >>\n");
        [mask, mask_raw, xcorr] = gabor_emergency(IMG,filename);
        kernel_dim = 1;
    end
    
% ---- Ritaglio IMG (solo se NON sto usando Gabor) e applicazione maschera
    if kernel_type ~= "GABOR"
        border = kernel_dim / 2;
        warning('off');IMG=IMG(border:end-border+1,border:end-border+1);warning('on');
    end

    % Clippiamo al massimo i valori dell'immagine che corrispondono alla maschera
    IMG_selected = IMG;    IMG_selected(mask)=255;

    % Creiamo immagine a tre canali mettendo la versione selezionata sulcanale rosso
     IMG_masked=cat(3,IMG_selected,IMG,IMG);

    
%% --- F I G U R E S 
% Questa sezione genera (e salva) le immagini di risultato, secondo quello
% che è settato dalle impostazioni.

   [~, selected_pixels_ratio] = is_reliable(mask,IMG); % mi tornerà utile :)
   
if show_resume == true
    
% --- Figure 1: riassuntazzo
    figure();
    
    %Titolo
    sgtitle(sprintf('Risultato immagine %s\n%.1f%% selected',...
        filename,selected_pixels_ratio));
        
    % Visualizzazione patterns prelevati
    subplot(231); 
    imagesc(IMG_RGB); axis image; colormap gray; hold on;
        if kernel_type == "GABOR"
            title('Immagine originale');
        else
            title('Patterns prelevati');
            rectangle('position',[1,1,kernel_dim,kernel_dim],'EdgeColor','r'); % pattern1
            rectangle('position',[2,2,kernel_dim,kernel_dim],'EdgeColor','g'); % pattern2
            rectangle('position',[IMG_x-kernel_dim+1,IMG_y-kernel_dim+1,kernel_dim,kernel_dim],'EdgeColor','b'); %pattern3
            rectangle('position',[IMG_x-kernel_dim,IMG_y-kernel_dim,kernel_dim,kernel_dim],'EdgeColor','c'); %pattern4
            rectangle('position',[1,IMG_y-kernel_dim+1,kernel_dim,kernel_dim],'EdgeColor','m'); %pattern5
            rectangle('position',[2,IMG_y-kernel_dim+1,kernel_dim,kernel_dim],'EdgeColor','k'); %pattern6
            hold off
        end
    
    if show_resume_choice == false
        %Visualizziamo la xcorr risultante
        corr_img = subplot(232);
        imagesc(xcorr); axis image; colormap(corr_img,jet);
        if kernel_type == "GABOR"
           title('Gabor mediato');
        else
            title('Mappa di cross-correlazione');
        end

        %Visualizziamo la maschera raw
        subplot(233);
        imagesc(mask_raw); axis image;
        title('Maschera raw');

        %Visualizziamo maschera rifinita
        subplot(234);
        imagesc(mask); axis image; 
        title('Maschera strel-ata');

        %Visualizziamo risultato
        subplot(224);
        imshowpair(IMG,IMG_masked,'montage')
        title(sprintf('Risultato\n[%.2f%% - Kernel: %s,%d]',...
              selected_pixels_ratio,kernel_type,kernel_dim));

    else
        % Visualizziamo le due maschere alternative
       subplot(232);
        imagesc(mask_corr); axis image; 
        title('Maschera CORR strel-ata');      
       subplot(233);
        imagesc(mask_cont); axis image; 
        title('Maschera CONT strel-ata');
        
        %Visualizziamo risultato
        subplot(212);
        imshowpair(IMG,IMG_masked,'montage')
        title(sprintf('Scelta: %s',kernel_type));

    end
      
        
    % Salvataggio
    resname =sprintf('results\\%s - SCELTA %s',filename,kernel_type);
    saveas(gcf, resname,'png');
    
    if analyze_just_one == false
        close all;
    end
 end
    

 % ---- Figure 2 - risultato
 if show_result == true
     
    f=figure();
    subplot(121);
    imshow(IMG_RGB);
    title('Immagine originale');
    
    subplot(122);
    imshow(IMG_masked);
    title('Maschera');
    
   
   sgtitle(sprintf('Risultato immagine %s\n\nT = %.3f\n%.1f%% selected\nTipo di analisi: %s',...
       filename,T,selected_pixels_ratio,kernel_type));
  
    saveas(gcf, sprintf('results\\%s',filename),'png');

    

    
    
    %figure(11);
    %subplot(1,3,1); imshow(IMG); axis image; 
    %subplot(1,3,2); imshow(padded_final_mask); axis image; 
    %subplot(1,3,3); imshow(final_IMG); axis image; 
    
    IMG_masked = final_IMG;

    %% F I G U R E S
    %%
    if show_resume == true

    % --- Figure 1: riassuntazzo
        figure();
        % Visualizzazione patterns prelevati
        subplot(231); 
        imagesc(IMG_RGB); axis image; colormap gray; hold on;
        title('Patterns prelevati');
        rectangle('position',[1,1,kernel_dim,kernel_dim],'EdgeColor','r'); % pattern1
        rectangle('position',[2,2,kernel_dim,kernel_dim],'EdgeColor','g'); % pattern2
        rectangle('position',[IMG_x-kernel_dim+1,IMG_y-kernel_dim+1,kernel_dim,kernel_dim],'EdgeColor','b'); %pattern3
        rectangle('position',[IMG_x-kernel_dim,IMG_y-kernel_dim,kernel_dim,kernel_dim],'EdgeColor','c'); %pattern4
        rectangle('position',[1,IMG_y-kernel_dim+1,kernel_dim,kernel_dim],'EdgeColor','m'); %pattern5
        rectangle('position',[2,IMG_y-kernel_dim+1,kernel_dim,kernel_dim],'EdgeColor','k'); %pattern6
        hold off

        %Visualizziamo la xcorr risultante
        corr_img = subplot(232);
        imagesc(xcorr); axis image; colormap(corr_img,jet);
        title('X-Corr risultante');

        %Visualizziamo la maschera raw
        subplot(233);
        imagesc(mask_raw); axis image;
        title('Maschera raw');

        %Visualizziamo maschera rifinita
        subplot(234);
        imagesc(mask); axis image; 
        title('Maschera strel-ata');

        %Visualizziamo risultato
        subplot(224);
        imshowpair(IMG,IMG_masked,'montage')
        title(sprintf('Risultato\n[%.2f%% - Kernel: %s,%d]',...
              selected_pixels_ratio,kernel_type,kernel_dim));

        sgtitle(sprintf('Risultato immagine %s\n%.1f%% selected',...
                filename,selected_pixels_ratio));

        resname =sprintf('results\\%s-%s',filename,kernel_type);
        saveas(gcf, resname,'png');

        if analyze_just_one == false
            close all;
        end
     end


     % ---- Figure 2 - risultato
     if show_result == true

        figure(20);
        subplot(121); imshow(IMG);
        subplot(122); imshow(IMG_masked);
        sgtitle(sprintf('Risultato immagine %s',filename));
        saveas(gcf, sprintf('results/%s', filename),'png');

        %if analyze_just_one == false
        %    close(f);
        %end
     end
   

end



