{admcab.i}
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vdata       like titold.titdtemi.
def var vdt1        as   date  format "99/99/9999". 
def var vdt2        as   date  format "99/99/9999".


repeat with 1 down side-label width 80 row 4 color blue/white:
 
    update vetbi label "Filial" colon 20
           vetbf label "Filial".

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20.
        
    message "Deseja Excluir Movimentos Deste Periodo" update sresp.
     
    if sresp
    then do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:

        
            do vdata = vdt1 to vdt2:
                
                display "Excluindo Lancamentos...." 
                         vdata no-label 
                         " Filial....." estab.etbcod no-label
                                    with frame f1 1 down centered.
                pause 0.

 
                
                for each titold where titold.etbcobra = estab.etbcod and
                                      titold.titdtpag = vdata:
            
                    do transaction:
                        
                        delete titold.
                
                    end.
                
                end.

                for each plaold use-index pladat 
                               where plaold.movtdc = 5            and
                                     plaold.etbcod = estab.etbcod and
                                     plaold.pladat = vdata.
                    do transaction:
                    
                        delete plaold.
                        
                    end.
                        
                end.
            end.

        end.
    end.
end.
