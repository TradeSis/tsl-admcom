disable triggers for load of finloja.titulo.
def input parameter vetbcod like estab.etbcod.
def input parameter v-data like plani.pladat.
def var vsit as char format "x(14)".



for each finloja.titulo where  
         finloja.titulo.etbcobra = vetbcod and
         finloja.titulo.titdtpag = v-data no-lock:
                   
    if finloja.titulo.titpar = 0 or
       finloja.titulo.clifor = 1 or
       finloja.titulo.titpar >= 50 
    then next.  

    vsit = "".

    find fin.titulo where fin.titulo.empcod = finloja.titulo.empcod and
                          fin.titulo.titnat = finloja.titulo.titnat and
                          fin.titulo.modcod = finloja.titulo.modcod and
                          fin.titulo.etbcod = finloja.titulo.etbcod and
                          fin.titulo.clifor = finloja.titulo.clifor and
                          fin.titulo.titnum = finloja.titulo.titnum and
                          fin.titulo.titpar = finloja.titulo.titpar 
                                no-lock no-error.
    if not avail fin.titulo
    then vsit = "nao encontrado".
    else if fin.titulo.titsit = "LIB"
         then vsit = "em aberto".
         else if fin.titulo.titvlcob <>
                 finloja.titulo.titvlcob 
              then vsit = "Valores Dif".
              else if (fin.titulo.etbcobra <> finloja.titulo.etbcobra or
                       fin.titulo.titdtpag <> finloja.titulo.titdtpag)
                   then vsit = "Consultar Conta: " + string(fin.titulo.clifor)
                                + " Contrato: " + fin.titulo.titnum.
                   else vsit = "ok".

    
    if vsit = "ok" 
    then next.
                                

    
    display vsit  column-label "Situacao"
            finloja.titulo.exportado format "Sim/Nao"
            finloja.titulo.clifor
            finloja.titulo.titnum 
            finloja.titulo.titpar 
            finloja.titulo.titvlcob(total)
                    with frame f1 centered down.
                
    /*
    if vsit <> "ok"
    then do transaction:
        assign finloja.titulo.exportado = no.
    end.
    */

end.
                 