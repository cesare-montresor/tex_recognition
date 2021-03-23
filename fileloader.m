function [IMG, filename] = fileloader(fn,files,analyze_just_one,rand_image,unrand_number)
    % Partendo dalle impostazioni del file main, carica l'immagine e
    % outputa l'immagine + il suo nome pulito.

    [n_files, ~] = size(files);
    
    path = sprintf('defect_images\\%s',files(fn).name);
    
    if  analyze_just_one == true && rand_image == true
        fn=randi(n_files,1,1);
        path = sprintf('defect_images\\%s',files(fn).name);
    end
    
    if  analyze_just_one == true && rand_image == false
        fn = unrand_number;
        path = sprintf('defect_images\\i%d.jpg',fn);
    end
    
    fprintf('\t\t--------\n|| Loading %s ...\n\t\t--------\n',path);
    filename = path(15:end-4);
    IMG = imread(path);
    
return