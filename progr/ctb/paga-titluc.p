
{admcab-batch.i}

def input parameter vrec as recid.


find fin.titluc where recid(fin.titluc) = vrec no-error.
if avail fin.titluc
then do transaction:  
           
    find foraut where foraut.forcod = fin.titluc.clifor no-lock no-error.
    
    /* antonio 
    if not avail foraut
    then do:
        output to "/admcom/logs/paga-titluc.log" append.
        put skip fin.titluc.etbcod fin.titluc.clifor 
                 fin.titluc.titnat fin.titluc.titnum fin.titluc.titpar.
        output close.
    end.
    */
        
    if avail foraut and foraut.autlp = no
    then do:
             
        find fin.titulo where fin.titulo.empcod = fin.titluc.empcod and 
                              fin.titulo.titnat = fin.titluc.titnat and 
                              fin.titulo.modcod = foraut.modcod and 
                              fin.titulo.etbcod = fin.titluc.etbcod and 
                              fin.titulo.clifor = fin.titluc.clifor and 
                              fin.titulo.titnum = fin.titluc.titnum and 
                              fin.titulo.titpar = fin.titluc.titpar no-error.
        if not avail fin.titulo
        then do:

            create fin.titulo.
            buffer-copy fin.titluc to fin.titulo.
            fin.titulo.modcod = foraut.modcod.
            run ctb/cria-lancxa.p (input recid(fin.titluc)).
            
        end.
        else if fin.titulo.titvlpag <> fin.titluc.titvlpag or
                fin.titulo.etbcobra <> fin.titluc.etbcobra or
                fin.titulo.titdtpag <> fin.titluc.titdtpag or
                (fin.titulo.titsit = "PAG" and
                 fin.titulo.titdtpag = ?)
            then do:
                fin.titulo.etbcobra = fin.titluc.etbcobra.
                if fin.titluc.titvlpag = 0 and
                   fin.titluc.titsit = "PAG"
                then fin.titulo.titvlpag = fin.titluc.titvlcob.
                else fin.titulo.titvlpag = fin.titluc.titvlpag.
                if fin.titluc.titdtpag = ? and
                   fin.titluc.titsit = "PAG"
                then fin.titulo.titdtpag = fin.titluc.titdtven.
                else fin.titulo.titdtpag = fin.titluc.titdtpag.
            end.
 
    end.
    else 
    if avail foraut then do:
        find banfin.titulo where 
                                banfin.titulo.empcod = fin.titluc.empcod and
                                banfin.titulo.titnat = fin.titluc.titnat and
                                banfin.titulo.modcod = foraut.modcod and
                                banfin.titulo.etbcod = fin.titluc.etbcod and
                                banfin.titulo.clifor = fin.titluc.clifor and
                                banfin.titulo.titnum = fin.titluc.titnum and
                                banfin.titulo.titpar = fin.titluc.titpar 
                                                            no-error.
        if not avail banfin.titulo
        then do:

            create banfin.titulo.
            buffer-copy fin.titluc to banfin.titulo.
            banfin.titulo.modcod = foraut.modcod.
        end.
        else if banfin.titulo.titvlpag <> fin.titluc.titvlpag or
                banfin.titulo.etbcobra <> fin.titluc.etbcobra or
                 banfin.titulo.titdtpag <> fin.titluc.titdtpag  or
                 (banfin.titulo.titsit = "PAG" and
                  banfin.titulo.titdtpag = ?)
            then do:
                if fin.titluc.titvlpag = 0 and
                   fin.titluc.titsit = "PAG"
                then banfin.titulo.titvlpag = fin.titluc.titvlcob.
                else banfin.titulo.titvlpag = fin.titluc.titvlpag.
                banfin.titulo.etbcobra = fin.titluc.etbcobra.
                if fin.titluc.titdtpag = ? and
                   fin.titluc.titsit = "PAG"
                then banfin.titulo.titdtpag = fin.titluc.titdtven.
                else banfin.titulo.titdtpag = fin.titluc.titdtpag.
            end.
        
    end.
                                                            
end.
                     

        
 