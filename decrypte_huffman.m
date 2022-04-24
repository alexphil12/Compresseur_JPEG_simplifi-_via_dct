
%PHILIPPON Alexandre et ALBERTELLI Benjamin, 2G1TD1TP1

% fonction annexe TP Théorie de l'information

function [symb, p] =decrypte_huffman(Vrlc) %Cette fonction trouve tout les symboles
    symb(1) = Vrlc(1);%(nombre dans Vrlc) et calcule leur fréquences d'apparition
    p(1) = 1;
    verif = 0;
    for i=2:length(Vrlc)%elle construit au furs et à mesure du parcourt la
        for k=1:length(symb)%liste symb contenant les différents symbole
            if(Vrlc(i) == symb(k))%et la liste p contenant leur occurences
                verif = 10;%d'apparitions
                p(k) = p(k)+1;
            end
        end
        if(verif ~= 10)
            symb = cat(2, symb, Vrlc(i));
            p = cat(2, p, 1);
        end
        verif = 0;
    end
    p = p/length(Vrlc);%on divise enfin par la longueur total pour obtenir 
end                    %p la liste des fréquences d'apparition.
    