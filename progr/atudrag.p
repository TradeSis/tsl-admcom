def buffer titoutro for d.titulo.

for each d.titulo where d.titulo.empcod =  19
    and d.titulo.titnat = no
    and d.titulo.modcod = "CRE"
    and d.titulo.titdtpag >= today - 1 no-lock . 
             
    find first d.titoutro where d.titoutro.clifor = d.titulo.clifor
                            and d.titoutro.titsit = "LIB"
                          no-lock no-error.
    if not avail d.titoutro
    then do :
        find first ger.flag where ger.flag.clicod = d.titulo.clifor
                            no-error.
        if avail ger.flag
        then do :
            /********** O CLIENTE NAO TEM MAIS LP *****************/
            ger.flag.flag1 = no.
            ger.flag.datexp1 = today.
        end.
    end.
    else do :
        /*********** O CLIENTE AINDA TEM LP **************/
    end.
end.

/*************** ATUALIZANDO CLIENTES NOVOS EM LP ********************/

for each d.titulo where d.titulo.empcod = 19
                    and d.titulo.titnat = no
                    and d.titulo.modcod = "CRE"
                    and d.titulo.titsit = "LIB" 
                  no-lock break by d.titulo.clifor.
                    
    if first-of (d.titulo.clifor) 
    then do :
        find first ger.flag where ger.flag.clicod = d.titulo.clifor
                            no-error.
        if avail ger.flag 
        then do :
            if ger.flag.flag1 = no
            then do :
                ger.flag.flag1 = yes.
                ger.flag.datexp1 = today.
            end.
        end.
        else do :
            create ger.flag.
            ger.flag.clicod = d.titulo.clifor.
            ger.flag.flag1 = yes.
            ger.flag.datexp1 = today.
        end.
    end.
end.  