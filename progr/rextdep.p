{admcab.i}

def var vdata1 as date format "99/99/9999".
def var vdata2 as date format "99/99/9999".
def buffer bestab for estab.
def var vetbemite like estab.etbcod.
def var vetbdesti like estab.etbcod.

def temp-table tt-pro
    field procod like produ.procod
    field pronom like produ.pronom
    field qtd    like movim.movqtm
    field valor  like movim.movpc
    index iprocod is primary unique procod.
    

repeat:

    for each tt-pro:
        delete tt-pro.
    end.
    vetbemite = 95.
    update vetbemite label "Emite"
           with frame f-dados width 80 side-labels.
    find estab where estab.etbcod = vetbemite no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado.".
        undo.
    end.
    else disp estab.etbnom no-label with frame f-dados.
    
    vetbdesti = 98.
    update vetbdesti label "Desti"          
           with frame f-dados.           
           
    find bestab where bestab.etbcod = vetbdesti no-lock no-error.
    if not avail bestab
    then do:
        message "Estabelecimento nao cadastrado.".
        undo.
    end.
    else disp bestab.etbnom no-label with frame f-dados.

    vdata1 = today. vdata2 = today.
    update skip
           vdata1 label "Dt. Inicial" 
           vdata2 label "Dt. Final" 
           with frame f-dados.

    for each plani where plani.movtdc = 3
                     and plani.etbcod = vetbemite
                     and plani.pladat >= vdata1
                     and plani.pladat <= vdata2 no-lock:
        
        if plani.desti <> vetbdesti 
        then next.
         
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock:
                     
            find tt-pro where tt-pro.procod = movim.procod no-error.
            if not avail tt-pro
            then do:
                find produ where produ.procod = movim.procod no-lock no-error.
                
                create tt-pro.
                assign tt-pro.procod = movim.procod
                       tt-pro.pronom = produ.pronom when avail produ.
            end.

            assign tt-pro.qtd   = tt-pro.qtd + movim.movqtm
                   tt-pro.valor = tt-pro.valor + (movim.movqtm * movim.movpc).
        
        end.
        
        
    end.
     
    for each tt-pro:

        disp tt-pro.procod column-label "Produto"
             tt-pro.pronom column-label "Descricao" format "X(45)"
             tt-pro.qtd    column-label "Qtd"       format ">>,>>9.99"
             tt-pro.valor  column-label "Valor"
             with frame f-rel width 80 down.
        down with frame f-rel.     
             
    end.

end.