{admcab.i}

def var vtotal-etb-v like plani.platot format ">>>,>>>,>>9.99".
def var vtotal-etb-q as   int.
def var vtotal-ven-v like plani.platot format ">>>,>>>,>>9.99".
def var vtotal-ven-q as   int.

def var fila as char.
def var vetbcod like estab.etbcod.
def var vfuncod like func.funcod. 
def var varquivo as char.
def var vdata as date format "99/99/9999".
def var vdata1 as date format "99/99/9999".
def var vdata2 as date format "99/99/9999".

def temp-table tt-etb
    field etbcod like estab.etbcod
    field vencod like plani.vencod
    field movpc like movim.movpc
    field movqtm like movim.movqtm.
        
def temp-table tt-pro
    field procod like produ.procod
    field pronom like produ.pronom
    field etbcod like estab.etbcod
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field vencod like plani.vencod.

repeat:

    assign vdata1 = today - 1
           vdata2 = today - 1
           vtotal-etb-q = 0
           vtotal-etb-v = 0
           vtotal-ven-q = 0
           vtotal-ven-v = 0.
           
    do on error undo:
        update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-dados.
        if vetbcod = 0
        then disp "TODOS" @ estab.etbnom with frame f-dados.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.    
    end.       
     
    update skip vdata1 label "Data Inicial..."
           vdata2 label "Data Final"
           with frame f-dados side-labels width 80.

    update skip vfuncod label "Vendedor......." with frame f-dados.
    if vfuncod <> 0
    then do:
        find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod no-lock no-error.
        if not avail func
        then do:
            message "Vendedor nao cadastrado".
            undo.
        end.
        else disp func.funnom no-label with frame f-dados.
    end.

    if opsys = "UNIX"
    then do:                           /*
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)*/
                    varquivo = "/admcom/relat/rpromon" + string(time).
    end.
    else assign fila = ""
                varquivo = "l:\relat\rpromon" + string(time).
    
    do vdata = vdata1 to vdata2:
        disp vdata no-label
             with frame ff centered 1 down. pause 0.
        
        for each movim where movim.etbcod = (if vetbcod <> 0
                                             then vetbcod
                                             else movim.etbcod)
                         and movim.movtdc = 5
                         and movim.movdat = vdata no-lock:

            find produ where
                 produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.protam <> "SIM" then next.
            
            find first plani where plani.etbcod = movim.etbcod
                               and plani.placod = movim.placod
                               and plani.movtdc = movim.movtdc
                               and plani.pladat = movim.movdat
                               no-lock no-error.
            if not avail plani
            then next.

            if vfuncod <> 0
            then if plani.vencod <> vfuncod
                 then next.
        
            disp produ.pronom  no-label
                 with frame ff centered 1 down. pause 0.
            
            find first tt-pro where 
                       tt-pro.etbcod = movim.etbcod and
                       tt-pro.procod = movim.procod and 
                       tt-pro.vencod = plani.vencod no-error.
            if not avail tt-pro
            then do:
                create tt-pro.
                assign tt-pro.etbcod = movim.etbcod
                       tt-pro.procod = movim.procod 
                       tt-pro.pronom = produ.pronom
                       tt-pro.vencod = plani.vencod.
            end.                       
            assign
               tt-pro.movpc  = tt-pro.movpc  + (movim.movpc * movim.movqtm)
               tt-pro.movqtm = tt-pro.movqtm + movim.movqtm.

            find first tt-etb where 
                       tt-etb.etbcod = movim.etbcod no-error.
            if not avail tt-etb
            then do:
                create tt-etb.
                assign tt-etb.etbcod = movim.etbcod.
            end.
            assign
               tt-etb.movpc  = tt-etb.movpc  + (movim.movpc * movim.movqtm)
               tt-etb.movqtm = tt-etb.movqtm + movim.movqtm.
            
        end.
    end.
 
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "00 "
        &Cond-Var  = "100"
        &Page-Line = "00"
        &Nom-Rel   = ""RPROMON""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """RELATORIO DE PRODUTOS VENDIDOS COM MONTAGEM -""
                        + "" PERIODO DE "" +
                         string(vdata1,""99/99/9999"") + "" A "" +
                         string(vdata2,""99/99/9999"") "
        &Width     = "100"
        &Form      = "frame f-cabcab"}

        /****************** se pedirem sintetico****
        if vfuncod <> 0
        then disp vfuncod label "Vendedor"
                  func.funnom no-label
                  with frame f-vend side-labels.
        else disp 0 @ vfuncod
                  "TODOS" @ func.funnom
                  with frame f-vend.
        
        for each tt-etb break by tt-etb.etbcod:
            
            disp tt-etb.etbcod column-label "Filial"
                 tt-etb.movqtm column-label "Quantidade" (total)
                 tt-etb.movpc  column-label "Valor"      (total)
                 with frame f-etb centered down.
            down with frame f-etb.     
        
        end.
        ******************/
        
        
        for each tt-pro no-lock break by tt-pro.etbcod
                                      by tt-pro.vencod
                                      by tt-pro.pronom:
        
            if first-of(tt-pro.etbcod)
            then do:
                vtotal-etb-q = 0. vtotal-etb-v = 0.
                find estab where
                     estab.etbcod = tt-pro.etbcod no-lock no-error.
                     
                disp tt-pro.etbcod label "Filial" 
                     " - "
                     estab.etbnom no-label
                     skip(1)
                     with frame f-estab side-labels.
                     
            end.

            if first-of(tt-pro.vencod)
            then do:
                vtotal-ven-q = 0. vtotal-ven-v = 0.
                find func where func.etbcod = tt-pro.etbcod and
                                func.funcod = tt-pro.vencod no-lock no-error.
                                
                disp space(2)
                     tt-pro.vencod label "Vendedor" 
                     " - "
                     func.funnom no-label when avail func
                     skip(1)
                     with frame f-vend side-labels.
                     
            end.
            
            assign
                vtotal-etb-q = vtotal-etb-q + (tt-pro.movqtm)
                vtotal-etb-v = vtotal-etb-v + (tt-pro.movqtm * tt-pro.movpc)
                vtotal-ven-q = vtotal-ven-q + (tt-pro.movqtm)
                vtotal-ven-v = vtotal-ven-v + (tt-pro.movqtm * tt-pro.movpc).
            
            disp space(5)
                 tt-pro.procod 
                 tt-pro.pronom 
                 tt-pro.movqtm 
                 tt-pro.movpc 
                 with frame f-mostra down width 100 centered.
                 
            down with frame f-mostra.


            if last-of(tt-pro.vencod)
            then put         "----------" to 74
                             "--------------" to 89 skip
                             vtotal-ven-q  to 74
                             vtotal-ven-v  to 89
                             skip.
            
            if last-of(tt-pro.etbcod)
            then put skip(2) "Total por Filial -------------------> "
                          vtotal-etb-q  to 74
                          vtotal-etb-v  to 89
                          skip.
        
        end.
        
    output close.
    
    
    if opsys = "UNIX"
    then do:
        
        /*
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then os-command silent lpr value(fila + " " + varquivo).
        */
        
        run visurel.p (input varquivo, input "").
        
    end.
    else do:
        {mrod.i}
    end.    
    
end.
