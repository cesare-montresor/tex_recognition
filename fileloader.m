function [IMG filename] = fileloader(fn,files,analyze_just_one,rand_image,unrand_number)
    
    i=fn; 
    
    if rand_image == true 
        i=randi(20,1,1);
    end

    path = strcat('defect_images\',files(i).name);
%     fprintf('%s',path,i);

    if rand_image == false && analyze_just_one == true
        path = sprintf('defect_images\\i%d.jpg',unrand_number);
        fprintf('|| Loading %s ...\n',path);
    end
    
    filename = path(15:end-4);
    IMG = imread(path);
return