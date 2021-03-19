function [img_filtered, Fsh, Fsh_filter] = FourierFilter2D(img, filter,R,C)
    %% O P T I O N S
    figures = false;
    
    %% C O D E
    
    % Applico padding all'immagine 
    padded = padarray(img,[R C],0,'post');
    
    % Calcolo la trasformata di Fourier dell'immagine 
    Fsh = fftshift(fft2(padded));

    % Applico il filtro
    Fsh_filter = Fsh .* filter;
     
    % Ricostruisco immagine a partire dalla sola selezione di frequenze fatta
    img_filtered_padded = ifft2(ifftshift(Fsh_filter));
    img_filtered = uint8(real(img_filtered_padded(1:R,1:C)));
    
    % Opzionale: figure
    if figures == true
        figure(); subplot(221); imshow(padded); title('Padded image');
        subplot(222);imshow(log10(1+abs(Fsh)),[]); title('Fourier Transform');
        subplot(223);imshow(log10(1+abs(Fsh_filter)),[]); title('Fourier Transform filtered');
	    subplot(224); imshow(img_filtered); title('Ricostruzione');
    end
    
    return