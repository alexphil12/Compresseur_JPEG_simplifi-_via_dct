clear all;
close all;
clc

%%
% TP Théorie de l'information 

% PHILIPPON Alexandre & ALBERTELLI Benjamin  -  2G1TD1TP1
% Mardi 22 mars 2022

dim_bloc = 8;

I = imread('lena.tif');
image = rgb2gray(I);
image = double(image);


%% Padding %% if the dimension are not multiple of 8

[m, n] = size(image);

heighttmp = m;
widthtmp = n;
    
%% TODO: %% Padding %% if the dimension are not multiple of 8
%....

[m, n] = size(image);
if mod(m,8)~=0
    image=cat(1,image,repmat(image(m,:),dim_bloc-mod(m,dim_bloc),1));
end
if mod(n,8)~=0
    image=cat(2,image,repmat(image(:,n),1,dim_bloc-mod(n,dim_bloc)));
end

[m, n] = size(image);
dim_img = m*n; 

fprintf('La taille du fichier (noir et blanc) non compresse est %d octets.\n',dim_img);


%% init
%jpeg = zeros(size(image)); 
im_decompressee = zeros(size(image));

%% le centrage


DCT = dctmtx(dim_bloc);

quantizer=[16 11 10 16  24  40  51  61;
   12 12 14 19  26  58  60  55;
   14 13 16 24  40  57  69  56;
   14 17 22 29  51  87  80  62;
   18 22 37 56  68 109 103  77;
   24 35 55 64  81 104 113  92;
   49 64 78 87 103 121 120 101;
   72 92 95 98 112 100 103 99];

quantizer_chrominance=[17 18 24 47  99  99  99  99;
   18 21 26 66  99  99  99  99;
   24 26 56 99  99  99  99  99;
   47 66 99 99  99  99  99  99;
   99 99  99  99  99  99 99  99;
   99 99  99  99  99  99 99  99;
   99 99  99  99  99  99 99  99;
   99 99  99  99  99  99 99  99;];

fq = 15;
s = facteur_qualite(fq);

Q2 = floor((s*quantizer + 50)/100);

% quality of factor, be used to calculate quantification matrix
% by default = 50 => use the above
% TODO


zigzag = [];
% col and lig indexes will be used to form the zigzag vector
col = [1 2 1 1 2 3 4 3 2 1 1 2 3 4 5 6  5 4 3 2 1 1 2 3 4 5 6 7 8 7 6 5 4 3 2 1 2 3 4 5 6 7 8 8 7 6 5 4 3 4 5 6 7 8 8 7 6 5 6 7 8 8 7 8];
lig = [1 1 2 3 2 1 1 2 3 4 5 4 3 2 1 1 2 3 4 5 6 7 6 5 4 3 2 1 1 2 3 4  5 6 7 8 8 7 6 5 4 3 2 3 4 5 6 7 8 8 7 6 5 4 5 6 7 8 8 7 6 7 8 8];
 ZIGZAG = zeros(1,dim_img);

%% codage

for i = 1:dim_bloc:m
   for j = 1:dim_bloc:n
        bloc = image((i-1)+1:(i-1)+8, (j-1)+1:(j-1)+8);% extraire une région de 8x8
    
        %centrage
        bloc = bloc - 128;
        
        %DCT
        bloc = DCT*bloc*DCT';
        
        %quantification
	    bloc = round(bloc./Q2);
        
        % zigzag of the block
        % see the code in "code_zigzag.m"
        for k = 1:64
            zigzag(k) = bloc(lig(k),col(k));
        end

        % concatenate all zigzag vectors (Vrlc)
        ZIGZAG(1,(j-1)*dim_bloc+(i-1)*n+1:(j-1)*dim_bloc+(i-1)*n+64) = zigzag;
        
        % Vrlc
        Vrlc = RumLength(ZIGZAG);
                   
    end
end

%% TODO 
%% Huffman 
[symb, p] = decrypte_huffman(Vrlc);
dico = huffmandict(symb, p);
encode = huffmanenco(Vrlc, dico);

%%
% Partie Decodage

Vrlc_dec = huffmandeco(encode, dico);
ZIGZAG_dec = RumLength_dec(Vrlc_dec);

for i = 1:dim_bloc:m
    for j = 1:dim_bloc:n

        zigzag_dec = ZIGZAG_dec(1,(j-1)*dim_bloc+(i-1)*n+1:(j-1)*dim_bloc+(i-1)*n+64);

        for k = 1:64
            bloc_dec(lig(k),col(k)) = zigzag_dec(k);
        end

        bloc_dec = bloc_dec.*Q2;

        bloc_dec = floor(DCT'*bloc_dec*DCT);

        bloc_dec = bloc_dec + 128;

        im_decompressee((i-1)+1:(i-1)+8, (j-1)+1:(j-1)+8) = bloc_dec; 

    end
end

%%
%PARTIE DE TEST

figure(1)

subplot(2, 2, 1);
colormap(gray)
imagesc(image)
title("image de base")

subplot(2, 2, 2);
colormap(gray)
imagesc(im_decompressee)
title("image décompressée")

erreur = (image - im_decompressee).^2;

subplot(2, 2, 3.5);
colormap(gray)
imagesc(erreur)
colorbar
title("erreur de décompression")

MSE = ((1/512)^2)*sum(sum(erreur));
PSNR = 10*log10((255^2)/MSE);
taux_compression = round((512*512*8)*100/length(encode));
a='%';

fprintf('La taille du fichier (noir et blanc) compresse est %d octets.\n', length(encode)/8);
fprintf('Le taux de compression (noir et blanc) est %d%c.\n',taux_compression,a);
fprintf('Le PSNR (noir et blanc) est de %f dB.\n',PSNR);

%%
% PARTIE COULEUR

dim_img_couleur = m*n*3;
fprintf('La taille du fichier (couleur) non compresse est %d octets.\n',dim_img_couleur);

composante1 = double(I(:,:,1));
composante2 = double(I(:,:,2));
composante3 = double(I(:,:,3));

[composante1_decompressee, len1] = compression_sur_une_composante(composante1, 15);
[composante2_decompressee, len2] = compression_sur_une_composante(composante2, 15);
[composante3_decompressee, len3] = compression_sur_une_composante(composante3, 15);

%%
% PARTIE TEST COULEUR

image_couleur_decompresse = zeros(m,n,3);
image_couleur_decompresse(:,:,1) = composante1_decompressee;
image_couleur_decompresse(:,:,2) = composante2_decompressee;
image_couleur_decompresse(:,:,3) = composante3_decompressee;

figure(2)

subplot(2, 2, 1);
imagesc(I)
title("image de base")

subplot(2, 2, 2);
imagesc(uint8(image_couleur_decompresse))
title("image décompressée")

erreur_couleur = (I - uint8(image_couleur_decompresse)).^2;

subplot(2, 2, 3.5);
imagesc(erreur)
colorbar
title("erreur de décompression")

MSE_couleur = mean(mean(mean(erreur)));
PSNR_couleur = 10*log10((255^2)/MSE_couleur);
taux_compression_couleur = round((512*512*8*3)*100/(len1+len2+len3));



fprintf('La taille du fichier (couleur) compresse est %d octets.\n', (len1+len2+len3)/8);
fprintf('Le taux de compression (couleur) est %d%c.\n',taux_compression_couleur,a);
fprintf('Le PSNR (couleur) est de %f dB.\n',PSNR_couleur);

%%
% FIN DU TP
