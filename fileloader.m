function [IMG, filename] = fileloader(fn,files,analyze_just_one,rand_image,unrand_number)
    % Given settings, it loads an image and outputs its RGB matrix + its
    % clean filename (no extension).

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