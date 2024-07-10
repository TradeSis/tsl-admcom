{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.


def temp-table tt-pla
    field etbcod like plani.etbcod
    field mes    as int format "99" 
    field totent like plani.platot format "->>>,>>>,>>9.99"
    field totsai like plani.platot format "->>>,>>>,>>9.99".
    
repeat:
    
    for each tt-pla:
        delete tt-pla.
    end.
    
    update vetbcod label "Filial      " colon 15
            with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final" with frame f1.
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod:
                         
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 06           and
                             plani.pladat >= vdti        and
                             plani.pladat <= vdtf no-lock.
                             
            
            display plani.etbcod
                    plani.pladat with 1 down. pause 0.
                    
            find first tt-pla where tt-pla.etbcod = estab.etbcod and
                                    tt-pla.mes    = month(plani.pladat)
                        no-error.
            if not avail tt-pla
            then do:
                create tt-pla.
                assign tt-pla.etbcod = plani.etbcod
                       tt-pla.mes    = month(plani.pladat).
            end.
            tt-pla.totsai = tt-pla.totsai + plani.platot.
            
        end.    
                         
        for each plani where plani.desti  = estab.etbcod and
                             plani.movtdc = 06           and
                             plani.pladat >= vdti        and
                             plani.pladat <= vdtf no-lock.
                             
            find first tt-pla where tt-pla.etbcod = estab.etbcod and
                                    tt-pla.mes    = month(plani.pladat)
                                                no-error.
            if not avail tt-pla
            then do:
                create tt-pla.
                assign tt-pla.etbcod = plani.etbcod
                       tt-pla.mes    = month(plani.pladat).
            end.
            tt-pla.totent = tt-pla.totent + plani.platot.
            
        end.    
        
    end.
 
    {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "119"
            &Page-Line = "66"
            &Nom-Rel   = ""reltran2""
            &Nom-Sis   = """SISTEMA CONTABILIDADE"""
            &Tit-Rel   = """NOTAS DE TRANSFERENCIA - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") + ""  ""
                                  + ""  Filial: "" + 
                                  string(vetbcod,"">>9"")"
            &Width     = "119"
            &Form      = "frame f-cabcab"}

 
    
    for each tt-pla by tt-pla.mes:
    
        display tt-pla.mes column-label "Mes "
                tt-pla.totent(total) column-label "Entrada"
                tt-pla.totsai(total) column-label "Saida  "
                            with frame f2 down.
    end.

    output close.
                
        
                    

                                  
        
end.         
        
        
        
        
        
    

