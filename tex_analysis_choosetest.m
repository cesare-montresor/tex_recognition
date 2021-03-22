clear 
close all
clc

%%% TODO: PRENDERE PIù KERNEL VARIEGATI + MEDIA
%%% TODO: DECIDERE SE USARE CONT O CORR

%% --- I M P O S T A Z I O N I

% ---- Scelta dell'input e gestione files
    analyze_just_one = false; % Se true, analizza una sola immagine; altrimenti analizza tutta la cartella
    rand_image = true; % Se true e se analyze_just_one è true, sceglie 
                        % randomicamente l'immagine da analizzare. 
                        % Altrimenti sceglie la unrand_number-esima.
    unrand_number = 2;  % Se rand_image è false, seleziona l'immagine.
    flush_folder=false; % Se true, svuota la cartella result prima 
                        % di iniziare
                        
% ---- Impostazioni di risultato
show_resume = false;  % se true apre la figura di riassunto coi passaggi
show_resume_choice = false; %considerto solo se show_resume è true; mostra 
                          % sia la mappa CONT che la CORR.
show_result = true; % se true apre una figura che mostra la zona 
                     % selezionata

disk_dim = 5;% Specifica la dimensione da usare per la open della maschera
areaopen = 300; % Specifica l'area minima selezionabile.

%% --- R U N


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

% ---- Gestione di _quali_ immagini analizzare (secondo le impostazioni)
    to_be_analyzed = length(files);
    if analyze_just_one == true
        to_be_analyzed = 1;
    else
        rand_image = false;
    end

% for loop for each file in folder:

for fn=1:to_be_analyzed
 i=fn;
    [IMG_RGB, filename]= fileloader(fn,files,analyze_just_one,rand_image,unrand_number);
    IMG = rgb2gray(IMG_RGB); % 512x512
    [IMG_x,IMG_y]=size(IMG);
    
%% - Analisi

% --- Ricerca dimensione ottimale dei kernels

     kernel_types = ["CORR","CONT"];
     
     % Salva le due pattern size ideali trovate dalla funzione apposita,
     % per provarle in sequenza.
     [kernel_corr, kernel_cont]  = find_pattern_size(IMG);
     kernels = [kernel_corr, kernel_cont];

    
     % QUIFA TUTTO IL PROCEDIMENTO, UNA VOLTA PER CORR (krn=1) E UNA
     % VOLTA PER CONT (krn=2). 
    for krn=1:2   
        
     kernel_dim = kernels(krn);
     kernel_type = kernel_types(krn);
     fprintf('A.%d) Kernel %s scelto : %d\n',krn,kernel_type,kernel_dim);

    % ---- Definizione dei 6 kernels (in riga per brevità)
        pattern1 = IMG(1:kernel_dim,1:kernel_dim);pattern2 = IMG(2:kernel_dim+1,2:kernel_dim+1); pattern3 = IMG(IMG_x-kernel_dim+1:IMG_x,IMG_y-kernel_dim+1:IMG_y);    pattern4 = IMG(IMG_x-kernel_dim:IMG_x-1,IMG_y-kernel_dim:IMG_y-1);pattern5 = IMG(1:kernel_dim,IMG_y-kernel_dim+1:IMG_y);    pattern6 = IMG(2:kernel_dim+1,IMG_y-kernel_dim+1:IMG_y);

    % ---- Calcolo della xcorr. (in riga per brevità)
        c1 = normxcorr2(pattern1,IMG);    c2 = normxcorr2(pattern2,IMG);    c3 = normxcorr2(pattern3,IMG);c4 = normxcorr2(pattern4,IMG);    c5 = normxcorr2(pattern5,IMG);    c6 = normxcorr2(pattern6,IMG);

        xcorr_full = (c1+c2+c3+c4+c5+c6)/6; % calcolo media 

        % Tagliamo la xcorr alla dimensione corretta
        xcorr = xcorr_full(kernel_dim-1:end-kernel_dim+1,kernel_dim-1:end-kernel_dim+1); % size(pattern)-1 
        xcorr = abs(xcorr);
        xcorr = imgaussfilt(xcorr,1);

    % ---- Calcoliamo la treshold ideale con Otsu 
           T = graythresh(xcorr);

    % ---- Generiamo la maschera
        mask_raw = xcorr<T;

    % ---- Refining della maschera
        se = strel('disk',disk_dim); 
        mask = imopen(mask_raw,se);
        mask = imclose(mask,se);
        mask = bwareaopen(mask, areaopen);
        
        
        %Salviamo la maschera finale (nel tipo corretto)
        if krn==1
            mask_corr = mask;
        else
            mask_cont = mask;
        end

    end
    
% ---- Scelta della maschera migliore:
    % Di default prendo corr.
    % Passo a cont se:
    %   - cont ha meno aree
    %   - a parità di aree, cont ha percentuale di selezione maggiore
    % Se nessuna delle due va bene lanciamo Gabor.
    
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
        fprintf("B.2) Both masks are empty; switching to GABOR. Potrebbe volerci qualche secondo!\n");
        mask = gabor_emergency(IMG,filename);
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

    
%% F I G U R E S
%%  
    selected_pixels = sum(mask(:) == 1);
    selected_pixels_ratio = (selected_pixels/(IMG_x * IMG_y))*100;

if show_resume == true
    
% --- Figure 1: riassuntazzo
    figure();
    
    %Titolo
    sgtitle(sprintf('Risultato immagine %s\n%.1f%% selected',...
        filename,selected_pixels_ratio));
        
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
    
    if show_resume_choice == false
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
    
    if analyze_just_one == false
        close(f);
    end
 end
   

end



