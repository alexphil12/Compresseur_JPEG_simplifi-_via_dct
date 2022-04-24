
%PHILIPPON Alexandre et ALBERTELLI Benjamin, 2G1TD1TP1

% fonction annexe TP Théorie de l'information

function ZIGZAG = RumLength_dec(Vrlc)
    ZIGZAG = [];
    for i=1:2:length(Vrlc)%code inverse du code 'homonyme'
        for k=1:Vrlc(i)%On ajoute le nombre de fois ou il est compté le 
            ZIGZAG = cat(2, ZIGZAG, Vrlc(i+1));%symbole correspondant
        end
    end
end