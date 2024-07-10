{admcab.i}

def var vcatcod like categoria.catcod.
def var varquivo as char.

def temp-table tt-ven
    field etbcod like plani.etbcod
    field etbnom like estab.etbnom
    field vencod like plani.vencod
    field vennom as   char
    field qtd    as   int
    field bonus  as   dec
    field procod like produ.procod
    field pronom like produ.pronom
    index ivenproetb is primary unique etbcod vencod procod.

def var vetbcod like estab.etbcod.
    
def var vdata1 as date format "99/99/9999" init today.
def var vdata2 as date format "99/99/9999" init today.
def var vtotal as dec.

repeat:
    
    for each tt-ven:
        delete tt-ven.
    end.
    
    update vetbcod label "Filial......"
           with side-labels with frame f-dados width 80.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada.".
            undo.
        end.
        else disp estab.etbnom no-label with frame f-dados.
    end.
    else disp "Geral" @ estab.etbnom with frame f-dados.
        
    update skip vcatcod label "Departamento"
                with frame f-dados.

    find categoria where categoria.catcod = vcatcod no-lock no-error.
    if not avail categoria
    then do:
        message "Departamento nao cadastrado.".
        undo.
    end.
    else disp categoria.catnom no-label with frame f-dados.

    update skip
           vdata1 label "Data Inicial"
           vdata2 label "Data Final"
           with frame f-dados.

    if opsys = "UNIX"
    then
        varquivo = "/admcom/relat/rbonaste" + string(day(today),"99") 
                                            + string(month(today),"99") 
                                            + string(year(today),"9999").
    else 
        varquivo = "l:\relat\rbonaste" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
        
    for each estab where if vetbcod <> 0
                         then estab.etbcod = vetbcod
                         else true no-lock:

        for each plani where plani.movtdc = 5
                         and plani.etbcod = estab.etbcod
                         and plani.pladat >= vdata1
                         and plani.pladat <= vdata2 no-lock:

            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                         
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
            
                if produ.catcod <> vcatcod then next.

                if produ.pronom begins "*"
                then.
                else next.
            
                find func where func.etbcod = plani.etbcod
                            and func.funcod = plani.vencod no-lock no-error.
                        
                find tt-ven where tt-ven.etbcod = plani.etbcod
                              and tt-ven.vencod = plani.vencod
                              and tt-ven.procod = produ.procod no-error.
                if not avail tt-ven
                then do:
                    create tt-ven.
                    assign tt-ven.vencod = plani.vencod
                           tt-ven.etbcod = plani.etbcod
                           tt-ven.etbnom = estab.etbnom
                           tt-ven.vennom = func.funnom when avail func
                           tt-ven.procod = produ.procod
                           tt-ven.pronom = produ.pronom.
                end.
                tt-ven.qtd = tt-ven.qtd + movim.movqtm.

            end.             
        end.
    end.
    
    for each tt-ven:
        
        if tt-ven.pronom begins "***"
        then tt-ven.bonus = tt-ven.qtd * 15.
        else 
            if tt-ven.pronom begins "**" 
            then tt-ven.bonus = tt-ven.qtd * 10.
            else 
                if tt-ven.pronom begins "*" 
                then tt-ven.bonus = tt-ven.qtd * 5.
    
    end.
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""RBONASTE"" 
                &Nom-Sis   = """LISTAGEM DE BONUS """ 
                &Tit-Rel   = """VENDA DE PRODUTOS COM ASTERISCO"" +
                    "" - Data: "" + string(vdata1,""99/99/9999"") + "" A "" +
                        string(vdata2,""99/99/9999"")"
                &Width     = "100"
                &Form      = "frame f-cabcab"}
                
        for each tt-ven break by tt-ven.etbcod
                              by tt-ven.vencod:
    
            if first-of(tt-ven.etbcod)
            then disp tt-ven.etbcod label "Filial"
                      tt-ven.etbnom no-label skip
                      with frame f-cabetb side-labels.
            
            if first-of(tt-ven.vencod)
            then disp space(2)
                      tt-ven.vencod label "Vendedor"
                      tt-ven.vennom no-label skip
                      with frame f-cabven side-labels.

            disp space(5)
                 tt-ven.procod  column-label "Produto"
                 tt-ven.pronom  column-label "Descricao"
                 tt-ven.qtd     column-label "Quantidade"
                 tt-ven.bonus   column-label "Bonus" (total by tt-ven.vencod)
                 format ">>,>>9.99"
                 with frame f-ven width 100 down.
            down with frame f-ven.
            
        end.
            
    output close.

    /*os-command silent /fiscal/lp value(varquivo).*/
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
        {mrod.i}
    end.
end.
