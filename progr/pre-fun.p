
{admcab.i }
def var v-vencido like titulo.titvlcob.
def var v-vencer  like titulo.titvlcob.
def temp-table    tt-func
    field cod like func.funcod.

def var vetbcod like estab.etbcod.
repeat:
    for each tt-func:
        delete tt-func.
    end.
        
    update vetbcod label "Filial"
                with frame f1 side-label width 80.
    if vetbcod = 0
    then display "Geral" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    

    {mdadmcab.i
         &Saida     = "printer"
         &Page-Size = "64"
         &Cond-Var  = "80"
         &Page-Line = "66"
         &Nom-Rel   = ""pre-fun""
         &Nom-Sis   = """SISTEMA DE CREDIARIO"""
         &Tit-Rel   = """SALDO VENCIDO / A VENCER DE FUNCIONARIOS"""
         &Width     = "80"}
         


    if vetbcod = 0
    then do:
        for each func no-lock by funnom.
            
            find first tt-func where tt-func.cod = int(func.usercod) no-error.
            if not avail tt-func
            then do:
                create tt-func.
                assign tt-func.cod = int(func.usercod).
            end.
            else next.
            if usercod = "1"
            then next.
            
            find clien where clien.clicod = int(func.usercod) 
                                                         no-lock no-error.
            if not avail clien
            then next.
                
            v-vencido = 0.
            v-vencer  = 0.
            for each titulo use-index iclicod where
                                  titulo.clifor = int(usercod) and
                                  titulo.titnat = no           and
                                  titulo.titsit = "LIB" no-lock. 

                if titulo.titdtven < today
                then v-vencido = v-vencido + titulo.titvlcob.
                else v-vencer  = v-vencer  + titulo.titvlcob.
                            
            end.

            if v-vencido = 0 and
               v-vencer  = 0
            then next.
            display func.etbcod
                    clien.clicod 
                    clien.clinom format "x(25)"
                    v-vencer(total) column-label "Total!A Vencer" 
                        format ">>,>>9.99"
                    v-vencido(total) column-label "Total!Vencido" 
                        format ">>,>>9.99"
                                  with frame f2 down
                                        centered width 80.
        end.
    end.
    else do:
            
        for each func where func.etbcod = vetbcod no-lock by funnom.
            
            find first tt-func where tt-func.cod = int(func.usercod) no-error.
            if not avail tt-func
            then do:
                create tt-func.
                assign tt-func.cod = int(func.usercod).
            end.
            else next.
            if usercod = "1"
            then next.
            
            find clien where clien.clicod = int(func.usercod) 
                                                         no-lock no-error.
            if not avail clien
            then next.
                
            v-vencido = 0.
            v-vencer  = 0.
            for each titulo use-index iclicod where
                                  titulo.clifor = int(usercod) and
                                  titulo.titnat = no           and
                                  titulo.titsit = "LIB" no-lock. 

                if titulo.titdtven < today
                then v-vencido = v-vencido + titulo.titvlcob.
                else v-vencer  = v-vencer  + titulo.titvlcob.
                            
            end.

            if v-vencido = 0 and
               v-vencer  = 0
            then next.
            display func.etbcod 
                    clien.clicod 
                    clien.clinom format "x(25)"
                    v-vencer(total) column-label "Total!A Vencer" 
                        format ">>,>>9.99"
                    v-vencido(total) column-label "Total!Vencido" 
                        format ">>,>>9.99"
                                  with frame f3 down
                                        centered width 80.
        end.
    end.
    output close.

end.                        
