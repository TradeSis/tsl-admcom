{admcab.i}


def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999". 
def var vdtf as date format "99/99/9999".
    
def temp-table tt-nfmaior300
    field etbcod like plani.etbcod
    field placod like plani.placod
    field pladat like plani.pladat
    field vencod like plani.vencod
    field funnom like func.funnom
    field numero like plani.numero
    field clicod like clien.clicod
    field clinom like clien.clinom
    field valor  like plani.platot.
    
def temp-table tt-proprecodif
    field etbcod like plani.etbcod
    field procod like produ.procod
    field pronom like produ.pronom
    field placod like plani.placod
    field pladat like plani.pladat
    field vencod like plani.vencod
    field funnom like func.funnom
    field numero like plani.numero
    field clicod like clien.clicod
    field clinom like clien.clinom
    field movpc  like plani.platot
    field estvenda like estoq.estvenda.


def var vvalor like plani.platot.
    
repeat:
    
    for each tt-nfmaior300:
        delete tt-nfmaior300.
    end.
    for each tt-proprecodif:
        delete tt-proprecodif.
    end.
    
    vetbcod = 0.
    
    do on error undo:

        update vetbcod label "Filial......" 
               with frame fdata.
               
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao Cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame fdata.
        end.
        else undo. /*disp "TODAS" @ estab.etbnom with frame fdata.*/
        
    end.           

    vdti = today - 1.
    vdtf = today - 1.
    
    update skip
           vdti    label "Data Inicial"
           vdtf    label "Data Final"
           with frame fdata side-label width 80 row 3.

    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock:

        for each plani where plani.movtdc =  5
                         and plani.etbcod =  estab.etbcod
                         and plani.pladat >= vdti
                         and plani.pladat <= vdtf no-lock:

            vvalor = 0.
            vvalor = (if plani.biss > 0
                      then plani.biss
                      else plani.platot).

            if vvalor > 300
            then do:
                find first tt-nfmaior300 where 
                           tt-nfmaior300.etbcod = plani.etbcod and
                           tt-nfmaior300.placod = plani.placod no-error.
                if not avail tt-nfmaior300
                then do:
                    find func where 
                         func.etbcod = plani.etbcod and 
                         func.funcod = plani.vencod no-lock no-error.
                         
                    find clien where 
                         clien.clicod = plani.desti no-lock no-error.
                         
                    create tt-nfmaior300.
                    assign tt-nfmaior300.etbcod = plani.etbcod
                           tt-nfmaior300.placod = plani.placod
                           tt-nfmaior300.pladat = plani.pladat
                           tt-nfmaior300.vencod = plani.vencod
                           tt-nfmaior300.funnom = (if avail func
                                                   then func.funnom
                                                   else "NAO CADASTRADO")
                           tt-nfmaior300.numero = plani.numero
                           tt-nfmaior300.clicod = plani.desti
                           tt-nfmaior300.clinom = (if avail clien
                                                   then clien.clinom
                                                   else "NAO CADASTRADO")
                           tt-nfmaior300.valor = vvalor.                        
                
                end.
            end.
            
            for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock:
                             
              if movim.procod = 405497 or
                 movim.procod = 403037 or
                 movim.procod = 405227 or
                 movim.procod = 401788 or
                 movim.procod = 405689 or 
                 movim.procod = 400017     
              then do:

                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ 
                then next.
                    
                find estoq where estoq.etbcod = plani.etbcod
                             and estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.
                else if estoq.estvenda <> movim.movpc
                then do:
                
                find first tt-proprecodif where 
                           tt-proprecodif.etbcod = plani.etbcod and
                           tt-proprecodif.placod = plani.placod and
                           tt-proprecodif.procod = movim.procod no-error.
                if not avail tt-proprecodif
                then do:
                    find func where 
                         func.etbcod = plani.etbcod and 
                         func.funcod = plani.vencod no-lock no-error.
                         
                    find clien where 
                         clien.clicod = plani.desti no-lock no-error.

                    find produ where 
                         produ.procod = movim.procod no-lock no-error.
                    if not avail produ then next.
                    
                    find estoq where estoq.etbcod = plani.etbcod
                                 and estoq.procod = produ.procod 
                                 no-lock no-error.
                         
                    create tt-proprecodif.
                    assign tt-proprecodif.etbcod = plani.etbcod
                           tt-proprecodif.placod = plani.placod
                           tt-proprecodif.pladat = plani.pladat
                           tt-proprecodif.vencod = plani.vencod
                           tt-proprecodif.funnom = (if avail func
                                                   then func.funnom
                                                   else "NAO CADASTRADO")
                           tt-proprecodif.numero = plani.numero
                           tt-proprecodif.clicod = plani.desti
                           tt-proprecodif.clinom = (if avail clien
                                                   then clien.clinom
                                                   else "NAO CADASTRADO")
                           tt-proprecodif.procod = movim.procod
                           tt-proprecodif.pronom = produ.pronom
                           tt-proprecodif.movpc = movim.movpc
                           tt-proprecodif.estvenda = estoq.estvenda.
                end.
                end.
              end.
            end.
            
        end.

    end.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/rpromcax." + string(time).
    else varquivo = "l:\relat\rpromcax." + string(time).
    
/*    varquivo = "/admcom/relat/rpromcax." + string(time).*/

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "0"
        &Nom-Rel   = ""rpromcax""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """LISTAGEM - PROMOCAO INAUGURACAO CAXIAS - DE "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

    disp "VENDAS ACIMA DE 300 REAIS"
         skip(1) with frame ftit1 centered side-labels no-labels.
         
    for each tt-nfmaior300 break by tt-nfmaior300.etbcod
                                 by tt-nfmaior300.pladat
                                 by tt-nfmaior300.numero:
        
        disp tt-nfmaior300.etbcod column-label "Loja"
             tt-nfmaior300.pladat

             tt-nfmaior300.numero format ">>>>>>>9"
             tt-nfmaior300.valor
             tt-nfmaior300.clicod format ">>>>>>>>>9" 
                                  column-label "Codigo!Cliente"
             tt-nfmaior300.clinom column-label "Cliente"
             tt-nfmaior300.vencod column-label "Codigo!Vendedor"
             tt-nfmaior300.funnom format "x(15)" column-label "Vendedor"
             with frame f-mostra width 130 down.

        down with frame f-mostra.              
             
    end.

    disp skip(2)
         "PRODUTOS DA PROMOCAO VENDIDOS COM VALOR DIFERENTE AO P.VENDA"
         skip(1) with frame ftit2 centered side-labels no-labels.
    
    for each tt-proprecodif break by tt-proprecodif.etbcod
                                  by tt-proprecodif.pladat
                                  by tt-proprecodif.numero:
        
        disp tt-proprecodif.etbcod column-label "Loja"
             tt-proprecodif.pladat
             tt-proprecodif.numero format ">>>>>>>9"
             tt-proprecodif.procod
             tt-proprecodif.pronom format "x(20)"
             tt-proprecodif.movpc  column-label "Valor!Vendido"
             tt-proprecodif.estvenda column-label "Preco de!Venda"
             /*tt-proprecodif.clicod format ">>>>>>>>>9" 
                                  column-label "Codigo!Cliente"
             tt-proprecodif.clinom column-label "Cliente"*/
             tt-proprecodif.vencod column-label "Codigo!Vendedor"
             tt-proprecodif.funnom format "x(15)" column-label "Vendedor"
             with frame f-mostra2 width 130 down.

        down with frame f-mostra2.
             
    end.
    
    
    output close.
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else {mrod.i}.
    
    /*run visurel.p (input varquivo, input "").*/

end.