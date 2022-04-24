
%PHILIPPON Alexandre et ALBERTELLI Benjamin, 2G1TD1TP1

% fonction annexe TP Théorie de l'information

function Vrlc = RumLength(X)
    compteur = 1;
    index = 1;
    for i =2:length(X)
        if(X(i-1)==X(i))
            compteur = compteur + 1;%Le code ici parcout ici le tableau X
            if (i == length(X))     %(Grand zigzag dans sol_version1) et 
                Vrlc(index) = compteur;%compte le nombre de symbole égaux consécutif
                Vrlc(index+1) = X(i);
            end
        else 
            Vrlc(index) = compteur;
            Vrlc(index+1) = X(i-1);%une fois ce nombre trouvé, on entre en 
            index = index + 2;     %Vrlc(index) le compte et en Vrlc(index+1) 
            compteur = 1;          %le symbole compté et ainsi de suite jusqu'a 
            if (i == length(X))    %atteindre la fin du tableau
                Vrlc(index) = compteur;%ps:il aurait été plus judicieux 
                Vrlc(index+1) = X(i);%d'appliquer ce codage uniquement aux
            end                      %zéros ceux ci étant presque les seuls 
        end                          %symbole consécutifs apparaisant dans
    end                              %grand Zigzag
end