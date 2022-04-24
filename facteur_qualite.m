
%PHILIPPON Alexandre et ALBERTELLI Benjamin, 2G1TD1TP1

% fonction annexe TP Théorie de l'information

function s = facteur_qualite(fq)
    if (1 <= fq) && fq < 50
        s = 5000/fq;
    elseif fq < 100
        s = 200-2*fq;
    else 
        error ("fq must be contained between 1 and 99");
    end
end
