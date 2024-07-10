{admcab.i}

def var vetbcod like estab.etbcod.
def var vnumero like plani.numero.
def var varquivo as char.

repeat:

    vnumero = 0.

    do on error undo:

        assign
            vetbcod = setbcod.

        update vetbcod label "Emitente"
               with frame f-dados.

        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento nao Cadastrado".
            undo.
        end.
        disp estab.etbnom no-label with frame f-dados.
        
    end.           

    update skip
           vnumero label "Numero.."
           with frame f-dados width 80 side-labels.

    find plani where plani.movtdc = 3
                 and plani.etbcod = vetbcod
                 and plani.emite  = vetbcod
                 and plani.serie  = "V"
                 and plani.numero = vnumero no-lock no-error.

    if not avail plani
    then do:
        
        find plani where plani.movtdc = 3
                     and plani.etbcod = vetbcod
                     and plani.emite  = vetbcod
                     and plani.serie  = "VC"
                     and plani.numero = vnumero no-lock no-error.

        if not avail plani
        then do:
            message "Transferencia nao Cadastrada".
            undo.
        end.
             
    end.
    else do:

        if opsys = "UNIX"
        then varquivo = "/admcom/relat/pedcondv" + string(time).
        else varquivo = "l:\relat\pedcondv" + string(time).
    
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "110"
            &Page-Line = "0"
            &Nom-Rel   = ""pedcondv""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """TRANSFERENCIA P/ DEPOSITO VIRTUAL"""
            &Width     = "110"
            &Form      = "frame f-cabcab"}
         
            disp plani.emite
                 plani.desti
                 plani.serie column-label "Serie"
                 plani.pladat
                 plani.platot
                 with frame f-dados1.

            for each movim where movim.etbcod = plani.etbcod and 
                                 movim.placod = plani.placod and 
                                 movim.movtdc = plani.movtdc and 
                                 movim.movdat = plani.pladat no-lock:

                find produ where produ.procod = movim.procod no-lock no-error.
                                                 
                disp space(6) 
                     movim.procod column-label "Produto"
                     produ.pronom column-label "Descricao"
                     movim.movqtm column-label "Quantidade"
                     (total)
                     movim.movpc  column-label "Valor Unit"
                     (total)
                     (movim.movqtm * movim.movpc)
                                  column-label "Qtd x Val"
                     (total)
                     with frame f-prod down width 110.
                
                down with frame f-prod.
            end.
    
        output close.
        
        if opsys = "UNIX"
        then run visurel.p (input varquivo, input "").
        else do:
            {mrod.i}
        end.
        
    end.
    
end.    
