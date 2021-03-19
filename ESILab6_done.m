
%% Esercizio 2 - Analisi delle tessiture, dove si trova il difetto? 
% Utilizzare in combinazione filtro passa-basso e metodo di otsu per
% ottenere la porzione di tessitura danneggiata. 

clear all
close all
clc

clear all
close all
clc

I = rgb2gray(imread('texture.jpg'));
[M,N] = size(I);

% 1. Analizzare l'output della binarizzazione di Otsu direttamente
% sull'immagine non filtrata
BW = imbinarize(I);
imagesc(BW);

% Troppe alte frequenze! Proviamo a toglierle con un filtro passa-basso!

I = double(I);
imagesc(I);

% 2. Creare il padding
Ipad = padarray(I,[M N],0,'post');

% 3. Calcolare la DFT dell'immagine appena creata
FFT_Ipad_center = fftshift(fft2(Ipad));

% 4. Generare un filtro passa-basso Gaussiano
thresh = 20; % Raggio di cutoff minimo nel dominio delle frequenze
H = glp(FFT_Ipad_center,thresh); % filtro Gaussiano
figure; imshow(H,[]); title('Filtro');

% 5. Eseguire la moltiplicazione tra filtro e il risultato della
% DFT 
him = H.*FFT_Ipad_center; 

% 6. Ricostruire l'immagine tramite FFT inversa e ricentratura (immagine
% di dimensione PxQ)
ifim = real(ifft2(ifftshift(him)));

% 7. Rimozione del padding, in modo da tornare ad una immagine di
% dimensioni MxN

rim = ifim(1:M,1:N);
rim=uint8(rim);
figure,imshow(rim,[]); title ('Immagine dopo filtraggio ferma-banda')

% 8. Attraverso il metodo di Otsu, binarizzo l'immagine e cerco il difetto
% nella texture
BW = imbinarize(rim);

I_highlight =  cat(3, I, I, I);
[rr,cc] = ind2sub(size(BW),find(BW==0));
for i=1:numel(rr)
    I_highlight(rr(i),cc(i),1:3)=255.0;
    I_highlight(rr(i),cc(i),3)=0.0;
end

% Visualizzazione dei risultati

figure;
subplot(2,3,1);imshow(uint8(I));title('Original image');
subplot(2,3,2);imshow(uint8(Ipad));title('Padding');
subplot(2,3,3);imshow(log10(1+abs(him)),[]); title('Fourier Transform');
subplot(2,3,4);imshow(uint8(rim),[]);title('Filtered image');
subplot(2,3,5);imshow(uint8(BW),[]);title('Binarized image');
subplot(2,3,6);imshow(uint8(I_highlight),[]);title('Original Image with defects highlighted');

