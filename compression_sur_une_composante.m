
%PHILIPPON Alexandre et ALBERTELLI Benjamin, 2G1TD1TP1

% fonction annexe TP Théorie de l'information

%reprise du code sol_version1 en fonction puis appliqué sur chaques composantes

function [im_decompressee, len] = compression_sur_une_composante(image, fq)

    dim_bloc = 8;
    [m, n] = size(image);

    if mod(m,8)~=0
        image=cat(1,image,repmat(image(m,:),dim_bloc-mod(m,dim_bloc),1));
    end
    if mod(n,8)~=0
        image=cat(2,image,repmat(image(:,n),1,dim_bloc-mod(n,dim_bloc)));
    end

    [m, n] = size(image);
    dim_img = m*n;

    im_decompressee = zeros(size(image));

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
    
    s = facteur_qualite(fq);
    
    Q2 = floor((s*quantizer + 50)/100);

    zigzag = [];
    
    col = [1 2 1 1 2 3 4 3 2 1 1 2 3 4 5 6  5 4 3 2 1 1 2 3 4 5 6 7 8 7 6 5 4 3 2 1 2 3 4 5 6 7 8 8 7 6 5 4 3 4 5 6 7 8 8 7 6 5 6 7 8 8 7 8];
    lig = [1 1 2 3 2 1 1 2 3 4 5 4 3 2 1 1 2 3 4 5 6 7 6 5 4 3 2 1 1 2 3 4  5 6 7 8 8 7 6 5 4 3 2 3 4 5 6 7 8 8 7 6 5 4 5 6 7 8 8 7 6 7 8 8];
    ZIGZAG = zeros(1,dim_img);
    
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

    [symb, p] = decrypte_huffman(Vrlc);
    dico = huffmandict(symb, p);
    encode = huffmanenco(Vrlc, dico);
    len = length(encode);

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
end
