def var i as int.

for each dragao.titulo where dragao.titulo.empcod = 19
    and dragao.titulo.titnat = no
    and dragao.titulo.modcod = "CRE"
    and dragao.titulo.titsit = "LIB" break by clifor .
    
    if first-of (dragao.titulo.clifor) 
    then do :
        i = i + 1.
        disp 
            dragao.titulo.titsit dragao.titulo.titnum
            dragao.titulo.titpar dragao.titulo.clifor
            dragao.titulo.etbcod i. 
            pause 0.

        find first ger.flag where ger.flag.clicod = dragao.titulo.clifor
                            no-error.
        if not avail ger.flag
        then do :
            create ger.flag.
            ger.flag.clicod = dragao.titulo.clifor.
            ger.flag.flag1 = yes.
            ger.flag.datexp1 = today.
        end.
    end.
end.           
               
