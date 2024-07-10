    def shared var setbcod like estab.etbcod.
    def var s-etbcod as int format "999".
    def var s-serie as int format "9".
    def var s-seq as int format "9999999".
    def var vcertifi like com.vndsegur.certifi.
    def var vcodsegur as int init 9839.
    def var vcert1 like com.vndsegur.certifi.
    def var vcert2 like comloja.vndsegur.certifi.
    /*
    vcertifi = string(setbcod, "999") +
               "2" /* P2K */ +
                          "0000001".
                          
    find last com.vndseguro where com.vndseguro.tpseguro = 1
                           and com.vndseguro.etbcod   = setbcod
                           and com.vndseguro.codsegur = vcodsegur
                           and com.vndseguro.certifi  < vcertifi 
                           no-lock no-error.
    if avail com.vndseguro
    then vcert1 = com.vndsegur.certifi.
    */
    
    for each comloja.vndseguro :
        find first com.vndseguro where
                   com.vndseguro.tpseguro = comloja.vndseguro.tpseguro and
                   com.vndseguro.etbcod   = comloja.vndseguro.etbcod and
                   com.vndseguro.certifi  = comloja.vndseguro.certifi
                   no-lock no-error.
        if avail com.vndseguro and
                 com.vndseguro.pladat <> comloja.vndseguro.pladat
        then do:
            disp comloja.vndsegur.certifi comloja.vndsegur.pladat
                com.vndsegur.certifi com.vndsegur.pladat
                .
            
            s-etbcod = int(substr(string(comloja.vndsegur.certifi),1,3)).
            s-serie  = int(substr(string(comloja.vndsegur.certifi),4,1)).
            s-seq    = int(substr(string(comloja.vndsegur.certifi),5,7)).
            /*if s-seq <= 10
            then*/ do:
                s-serie = 9.
                vcertifi = string(s-etbcod,"999") + 
                string(s-serie,"9") + 
                string(s-seq,"9999999").
                disp vcertifi. 
                comloja.vndsegur.certifi = vcertifi.
                comloja.vndsegur.datexp = today.
                comloja.vndsegur.exportado = no.
            end.
            /*else leave.*/    
        end. 
        /***
        else do:
            disp comloja.vndsegur.certifi.
            update comloja.vndsegur.datexp 
            comloja.vndsegur.exportado.
        end.
        ***/             
    end. 

