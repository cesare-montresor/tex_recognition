function [IMG, filename] = fileloader(fn,files,analyze_just_one,rand_image,unrand_number)
    % Given settings, it loads an image and outputs its RGB matrix + its
    % clean filename (no extension).

    i=fn; 
    
    if rand_image == true 
        i=randi(20,1,1);
    end

    if i<=50
    path = strcat('defect_images\',files(i).name);
    end
   
    if rand_image == false && analyze_just_one == true
        path = sprintf('defect_images\\i%d.jpg',unrand_number);
        fprintf('\t\t--------\n|| Loading %s ...\n\t\t--------\n',path);
    end
    
    filename = path(15:end-4);
    IMG = imread(path);
    
return