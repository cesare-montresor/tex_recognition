clear 
close all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% @ CESARE!! 
% Relazione: 
%    [TODO: PRENDERE PI� KERNEL VARIEGATI + MEDIA]
%   --- Se vuoi (dato che io sto messa meglio su teoria) lo aggiungo io;
%   comunque gi� cos� riconosce 34 immagini (ho migliorato alcune cose) ^-^
%  
    %  RELAZIONE:
    %  https://docs.google.com/document/d/1oUnQE5UUykekRmstjFRi4RPNVbs6H3F_cKcTdAV1ZF0/edit?usp=sharing
%
%   Per mantenere questo script (dato che gi� va e abbiamo poco tempo)
%   potremmo anche usare 1 sola dimensione kernel (aka quella che torna da
%   find_pattern_size), limitarci a prendere N volte quella l� e fare
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

    rand_image = false; % Se true e se analyze_just_one � true, sceglie 
                        % randomicamente l'immagine da analizzare. 
                        % Altrimenti sceglie la unrand_number-esima.
                        
    unrand_number = 2;  % Se rand_image � false, seleziona l'immagine.
    
    flush_folder=false; % Se true, svuota la cartella result prima 
                        % di iniziare
                        
% ---- Impostazioni di risultato
    show_resume = true;  % se true apre la figura di riassunto coi passaggi
    
    show_resume_choice = true; %considerto solo se show_resume � true; mostra 
                              % sia la mappa CONT che la CORR.
                              
    show_result = false; % se true apre una figura che mostra la zona 
                         % selezionata

% ---- Parametri per l'analisi
    disk_dim = 5;% Specifica la dimensione da usare per la open della maschera
    areaopen = 300; % Specifica l'area minima selezionabile.

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
    
%% - Analisi

% --- Ricerca dimensione ottimale dei kernels
     
     % Salva le due pattern size ideali trovate dalla funzione apposita,
     % per provarle in sequenza.
     [kernel_corr, kernel_cont]  = find_pattern_size(IMG);
     kernels = [kernel_corr, kernel_cont];

    
     % L'analisi base (xcorr) viene fatta due volte: una usando il kernel 
     % che massimizza CORR e una usando quello che massimizza CONT. Poi si
     % decide quale delle due maschere � pi� bella.
    for krn=1:2   
        
     kernel_dim = kernels(krn);
     kernel_type = kernel_types(krn);
     fprintf('A.%d) Kernel %s scelto : %d\n',krn,kernel_type,kernel_dim);

    % ---- Definizione dei 6 kernels (in riga per brevit�)
        pattern1 = IMG(1:kernel_dim,1:kernel_dim);pattern2 = IMG(2:kernel_dim+1,2:kernel_dim+1); pattern3 = IMG(IMG_x-kernel_dim+1:IMG_x,IMG_y-kernel_dim+1:IMG_y);    pattern4 = IMG(IMG_x-kernel_dim:IMG_x-1,IMG_y-kernel_dim:IMG_y-1);pattern5 = IMG(1:kernel_dim,IMG_y-kernel_dim+1:IMG_y);    pattern6 = IMG(2:kernel_dim+1,IMG_y-kernel_dim+1:IMG_y);

    % ---- Calcolo della xcorr. (in riga per brevit�)
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
    % Di default prendo CORR.
    % Passo a CONT se:
    %   - CONT ha meno aree
    %   - a parit� di aree, cont ha percentuale di selezione maggiore
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
% che � settato dalle impostazioni.

   [~, selected_pixels_ratio] = is_reliable(mask,IMG); % mi torner� utile :)
   
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
    
    if analyze_just_one == false
        close(f);
    end
 end
   

end



