% Martedi 03 Novembre 2020 - Mercoledi 04 Novembre 2020
% Corso di Elaborazione dei Segnali e Immagini
% Docente: Ilaria Boscolo Galazzo 
% Docente Coordinatore: Marco Cristani
% Tutor lab: Christian Joppi 
% LAB2 - parte 2

clear all
close all
clc

%%

imgs = dir("./immagini/*.jpg")
img = datasample(imgs,1);
filename = "./immagini/"+img.name


%% Esercizio 1 - Cross-correlazione 2D normalizzata per trovare difetti su tessuti
img = imread(filename);
gray = rgb2gray(img); % 512x512
figure(1);imshow(gray);


[R,C]=size(gray);
%%  
% Intializing sigma and muu 
sigma = 100;
mu = 0.0;
  
% Calculating Gaussian array 
gauss_low = gauss2D(mu, sigma, R*2, C*2);

figure(2);imshow(gauss,[]);

%%
[gray_filtered, Fsh, Fsh_filter] = FourierFilter2D(img,gauss_low);

figure(4); imshow(gray_filtered, []);

%%
gray_sharpened = imsharpen(gray_filtered);


figure(4); imshow(gray_sharpened, []);

gray = gray_sharpened
%%

% Definisco una serie di pattern, tutti quadrati 14x14
pattern1 = gray(1:14,1:14); 
pattern2 = gray(2:15,2:15);
pattern3 = gray(R-13:R,C-13:C);
pattern4 = gray(R-14:R-1,C-14:C-1);
pattern5 = gray(1:14,C-13:C);
pattern6 = gray(2:15,C-13:C);

figure;
imagesc(gray); axis image; colormap gray; hold on;
rectangle('position',[1,1,14,14],'EdgeColor','r'); % pattern1
rectangle('position',[2,2,14,14],'EdgeColor','g'); % pattern2
rectangle('position',[R-13,C-13,14,14],'EdgeColor','b'); %pattern3
rectangle('position',[R-14,C-14,14,14],'EdgeColor','c'); %pattern4
rectangle('position',[1,C-13,14,14],'EdgeColor','m'); %pattern5
rectangle('position',[2,C-13,14,14],'EdgeColor','k'); %pattern6

% Calcolo la xcorr-2D (normalizzata). Size = N+M-1
c1 = normxcorr2(pattern1,gray); % 525x525
c2 = normxcorr2(pattern2,gray);
c3 = normxcorr2(pattern3,gray);
c4 = normxcorr2(pattern4,gray);
c5 = normxcorr2(pattern5,gray);
c6 = normxcorr2(pattern6,gray);

% From MATLAB Help:
% C = normxcorr2(TEMPLATE,A) computes the normalized cross-correlation of
%     matrices TEMPLATE and A. The matrix A must be larger than the matrix
%     TEMPLATE for the normalization to be meaningful. The values of TEMPLATE
%     cannot all be the same. The resulting matrix C contains correlation
%     coefficients and its values may range from -1.0 to 1.0.

c = (c1+c2+c3+c4+c5+c6)/6; % calcolo media (525x525)
figure, imagesc(c); 

c = c(13:end-13,13:end-13); % size(pattern)-1 
figure, surf(abs(c)), shading flat
figure, imagesc(abs(c)), colorbar
c=abs(c);


t = graythresh(c)

mask = c<t;
figure, imagesc(mask)
se = strel('disk',2); % crea un disco con R = 3. Cosa succede se aumento R?
mask2 = imopen(mask,se);
figure, imagesc(mask2);

% Nota per IMOPEN = Perform morphological opening.
% The opening operation erodes an image and then dilates the eroded image,
% using the same structuring element for both operations.
% Morphological opening is useful for removing small objects from an image
% while preserving the shape and size of larger objects in the image.

gray=gray(6:end-7,6:end-7); % Passo da 512x512 a 500x500
A1 = gray;
A1(mask)=255;
Af=cat(3,A1,gray,gray);
figure;
imshowpair(gray,Af,'montage')

