clear 
close all
clc

%% --- I M P O S T A Z I O N I
%%
% ---- Scelta dell'input e gestione files
    analyze_just_one = true; % Se true, analizza una sola immagine; altrimenti analizza tutta la cartella
    rand_image = false; % Se true e se analyze_just_one è true, sceglie 
                        % randomicamente l'immagine da analizzare. 
                        % Altrimenti sceglie la unrand_number-esima.
    unrand_number =82;  % Se rand_image è false, seleziona l'immagine.
    flush_folder=false; % Se true, svuota la cartella result prima 
                        % di iniziare

% ---- Impostazioni sulla selezione del kernel
man_kernel = false; % Se true, usa un valore fisso anziché calcolare 
                    % il migliore autonomamente
kernel_dim = 60;    % Specifica la dimensione da usare se man_kernel è true

% ---- Impostazioni sulla threshold
man_tresh = false; % Se true, usa un valore fisso anziché calcolare 
                   % il migliore autonomamente
T = 0.2;           % Specifica la dimensione da usare se man_thresh è tru


% ---- Impostazioni di risultato
show_resume = true;  % se true apre la figura di riassunto coi passaggi
show_result = false; % se true apre una figura che mostra la zona 
                     % selezionata

disk_dim = 5;% Specifica la dimensione da usare per la open della maschera
firsttime=true;

%% --- C O D I C E
%%

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

% --- Ricerca parametri ottimali per Gabor 
    for len=1:30
        for phase=1:45:270
            gab = imgaborfilt(IMG,len,phase);
            fprintf('minmax: [%.3f %.3f], stddev %.3f',max(gab), min(gab), val = std2(IMG));
        end
    end



% ---- Facciamo Gabor
    gabor_full = 

    % Tagliamo la xcorr alla dimensione corretta
    gabor = gabor_full(kernel_dim-1:end-kernel_dim+1,kernel_dim-1:end-kernel_dim+1); % size(pattern)-1 
    gabor = abs(gabor);
    gabor = imgaussfilt(gabor,1);


% ---- Calcoliamo la treshold ideale con Otsu (o iterativamente TBD)
    if man_tresh == false
       T = graythresh(gabor);
       fprintf('\n2] Tresholds ottimale secondo Otsu: %.4f \n ',T); 

    end

% ---- Generiamo la maschera
    mask_raw = gabor<T;

% ---- Refining della maschera
    se = strel('disk',disk_dim); 
    mask = imopen(mask_raw,se);
%    per l'immagine stronza ci vuole se = strel('disk',10);
     mask = imclose(mask,se);
    mask = bwareaopen(mask, 200);

    
% ---- Ritaglio IMG e applicazione maschera
    border = kernel_dim / 2;
    warning('off');
    IMG=IMG(border:end-border+1,border:end-border+1);
    % Clippiamo al massimo i valori dell'immagine che corrispondono alla
    % maschera
    IMG_selected = IMG;    IMG_selected(mask)=255;
    % Creiamo immagine a tre canali mettendo la versione selezionata sul
    % canale rosso
    IMG_masked=cat(3,IMG_selected,IMG,IMG);
    

    
    selected_pixels = sum(mask(:) == 1);
    selected_pixels_ratio = (selected_pixels/(IMG_x * IMG_y))*100;

    
    isReliable(mask,IMG);
    
    
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
    imagesc(gabor); axis image; colormap(corr_img,jet);
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
     
    f=figure();
    subplot(121);
    imshow(IMG);
    
    subplot(122);
    imshow(IMG_masked);
    
    sgtitle(sprintf('Risultato immagine %s\nT = %.3f\n%.1f%% selected',filename,T,selected_pixels_ratio));
  
    saveas(gcf, sprintf(results\filename),'png');
    
    if analyze_just_one == false
        close(f);
    end
 end
   

end



