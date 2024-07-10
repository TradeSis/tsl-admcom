/*  rjusexpv.p      */
/* solic 20363 colocada opção sintetica/analitico   */
{admcab.i}
def var vsintetico  as log label "Tipo" init yes.
def var varquivo as   char.
def var vetbcod  like estab.etbcod.
def var vdti     as   date format "99/99/9999" init today.
def var vdtf     as   date format "99/99/9999" init today.
def var vjuscod  like jusexpv.juscod.
def var vcatcod  like categoria.catcod.
def var vprox    as   log.

def temp-table tt-ven
    field etbcod like estab.etbcod
    field valven like plani.platot
    field qtdven as   int format ">>>>>>>>>>9"
    field juscod like jusexpv.juscod
    field valneg like plani.platot
    field qtdneg as   int format ">>>>>>>>>>9".

def temp-table tt-ana
    field rec-plani as recid
    field etbcod    like plani.etbcod
    field juscod    as int
    index rec is primary unique rec-plani asc
    index jus juscod .
    
def var vtot-valven like tt-ven.valven.
def var vtot-qtdven like tt-ven.qtdven.
def var vtot-valneg like tt-ven.valneg.
def var vtot-qtdneg like tt-ven.qtdneg.

repeat:

    for each tt-ven:
        delete tt-ven.
    end.
    for each tt-ana.
        delete tt-ana.
    end.

    do on error undo:  
        
        update vetbcod label "Filial......" 
               with frame f-dados.  
        
        if vetbcod <> 0 
        then do: 
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab 
            then do: 
                message "Filial nao Cadastrada". 
                undo. 
            end. 
            else disp estab.etbnom no-label with frame f-dados. 
        end. 
        else disp "Geral" @ estab.etbnom with frame f-dados.
    
    end.

    do on error undo:
        
        update skip
               vcatcod label "Departamento"
               with frame f-dados.
        
        if vcatcod <> 0
        then do:
            find categoria where categoria.catcod = vcatcod no-lock no-error.
            if not avail categoria
            then do:
                message "Departamento nao cadastrado.".
                undo.
            end.
            else disp categoria.catnom no-label with frame f-dados.
        end.
        else disp " Geral" @ categoria.catnom with frame f-dados.
               
    end.

    update vjuscod at 7 label "Motivo"
                with frame f-dados.
    if vjuscod > 0            
    then do:
        find jusexpv where jusexpv.juscod = vjuscod no-lock.
        disp jusexpv.jusdes no-label with frame f-dados.
    end.
    else disp "Todos os Motivos" @ 
             jusexpv.jusdes no-label with frame f-dados.

    
    update skip 
           vdti    label "Data Inicial" 
           vdtf    label "Data Final" 
           vsintetico   format "Sintetico/Analitico"
           with frame f-dados side-label width 80 row 3.
    
    for each estab where (if vetbcod <> 0
                          then estab.etbcod = vetbcod
                          else true) no-lock:
                                        
        for each plani where plani.movtdc = 5
                         and plani.etbcod = estab.etbcod
                         and plani.pladat >= vdti
                         and plani.pladat <= vdtf no-lock:
            sresp = yes.             
            if vcatcod > 0
            then
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ then next.
                if produ.catcod <> vcatcod
                then do:
                    sresp = no.
                    leave.
                end.    
            end.
            if sresp = no
            then next.                                     
            find tt-ven where tt-ven.etbcod = plani.etbcod no-error.
            if not avail tt-ven
            then do:
                create tt-ven.
                assign tt-ven.etbcod = plani.etbcod.
            end.

            assign tt-ven.qtdven = tt-ven.qtdven + 1
                   tt-ven.valven = tt-ven.valven + (if plani.biss > 0
                                                    then plani.biss
                                                    else plani.platot).

        end.    
    
    end.


    for each estab where (if vetbcod <> 0
                          then estab.etbcod = vetbcod
                          else true) no-lock:
                                        
        for each plani where plani.movtdc = 30
                         and plani.etbcod = estab.etbcod
                         and plani.pladat >= vdti
                         and plani.pladat <= vdtf no-lock:

            if plani.notped <> "U"
            then next.
            
            if not plani.notobs[2] begins "JUSCOD"
            then next.

            if vjuscod > 0 and
               vjuscod <> int(acha("JUSCOD",plani.notobs[2]))
            then next.    

            vprox = no.
            
            if vcatcod > 0
            then 
                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                 and movim.movdat = plani.pladat
                                 and movim.movtdc = plani.movtdc no-lock:
                    
                    find produ where 
                         produ.procod = movim.procod no-lock no-error.

                    if not avail produ 
                    then next.
                         
                    if produ.catcod <> vcatcod
                    then do:
                        vprox = yes.
                        leave.
                    end.    
                end.

            if vprox then next.

            find tt-ven where tt-ven.etbcod = plani.etbcod no-error.
            if not avail tt-ven
            then do:
                create tt-ven.
                assign tt-ven.etbcod = plani.etbcod.
            end.

            /*if acha("JUSCOD",plani.notobs[2]) <> ? 
            then tt-ven.juscod = int(acha("JUSCOD",plani.notobs[2])).*/
 
            assign tt-ven.qtdneg = tt-ven.qtdneg + 1
                   tt-ven.valneg = tt-ven.valneg + (if plani.biss > 0
                                                    then plani.biss
                                                    else plani.platot).
            create tt-ana.
            assign tt-ana.rec-plani = recid(plani)
                   tt-ana.etbcod    = plani.etbcod.
            assign tt-ana.juscod    = int(acha("JUSCOD",plani.notobs[2])).
        
        end.    
    
    end.

    if opsys = "UNIX" 
    then varquivo = "/admcom/relat/rjusexpv." + string(time). 
    else varquivo = "l:\relat\rjusexpv." + string(time).
        

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "91" 
        &Page-Line = "66" 
        &Nom-Rel   = ""rjusexpv"" 
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO""" 
        &Tit-Rel   = """RELATORIO DE VENDAS PERDIDAS - DE "" 
                   + string(vdti,""99/99/9999"") + "" A "" 
                   + string(vdtf,""99/99/9999"") + "" - "" +
                   string(vsintetico,""Sintetico/Analitico"")
                   "
        &Width     = "91" 
        &Form      = "frame f-cabcab"}

    assign vtot-valven = 0
           vtot-qtdven = 0
           vtot-valneg = 0
           vtot-qtdneg = 0.

    for each tt-ven break by tt-ven.etbcod:
    
        find jusexpv where jusexpv.juscod = tt-ven.juscod no-lock no-error.
        
        disp tt-ven.etbcod  column-label "Filial"
             tt-ven.valven  column-label "Venda do!Periodo"
             tt-ven.qtdven  column-label "Quant.!Vendas"
             tt-ven.valneg  column-label "Valor!Negado"
             tt-ven.qtdneg  column-label "Quant!Negada"
             
             ((tt-ven.valneg / tt-ven.valven) * 100) 
                    column-label "%Valor!Negado" format "->>9.99 %"
             ((tt-ven.qtdneg / tt-ven.qtdven) * 100) 
                    column-label "%Quant!Negada" format "->>9.99 %"
             with frame f-ven width 91 down.
        
        down with frame f-ven.
         
        assign vtot-valven = vtot-valven + tt-ven.valven
               vtot-qtdven = vtot-qtdven + tt-ven.qtdven
               vtot-valneg = vtot-valneg + tt-ven.valneg
               vtot-qtdneg = vtot-qtdneg + tt-ven.qtdneg.
               
        if  vsintetico = yes /* sintetico */
        AND last(tt-ven.etbcod)
        then do:
             disp "TOTAL" @ tt-ven.etbcod  column-label "Filial"
                  vtot-valven @ tt-ven.valven  column-label "Venda do!Periodo"
                  vtot-qtdven @ tt-ven.qtdven  column-label "Quant.!Vendas"
                  vtot-valneg @ tt-ven.valneg  column-label "Valor!Negado"
                  vtot-qtdneg @ tt-ven.qtdneg  column-label "Quant!Negada"
                  with frame f-ven width 91 down.

             end.
        
        if vsintetico = no
        then do.
            def var vvtotal like plani.platot.
            for each tt-ana where tt-ana.etbcod = tt-ven.etbcod
                                    by tt-ana.juscod.
                find plani where recid(plani) = tt-ana.rec-plani no-lock.
                find clien where clien.clicod = plani.desti no-lock no-error.
                vvtotal = if plani.biss > 0
                          then plani.biss 
                           else plani.platot.
                display plani.etbcod  at 1
                        plani.desti     format ">>>>>>>>>>>>9" 
                                        column-label "Cliente"
                        clien.clinom    format "x(25)" Column-label "Nome"
                        vvtotal  (total count) column-label "Vlr Negado" 
                         
                         with frame fanalitico
                                width 200 down.
                               
               if num-entries(plani.notobs[2],"=") > 1
               then do:
                   find jusexpv where jusexpv.juscod = 
                             int(entry(2,plani.notobs[2],"="))
                              no-lock no-error.
                   disp int(entry(2,plani.notobs[2],"=")) format ">>9"
                       column-label "Mot"
                       (if avail jusexpv 
                       then jusexpv.jusdes else "") format "x(25)" 
                               column-label "Descricao"
                                  with frame fanalitico
                                width 200 down.
                                
               end.

                                             
               if can-find(first movim 
                              where movim.etbcod = plani.etbcod
                                and movim.placod = plani.placod
                                and movim.movtdc = plani.movtdc)
               then put unformat "Produto"   at 5
                            "Descricao" at 13
                            "Qtde"      at 55
                            "-------"   at 5
                            "---------" at 13
                            "----"      at 55.


               for each movim where movim.etbcod = plani.etbcod
                                and movim.placod = plani.placod
                                and movim.movtdc = plani.movtdc
                                  no-lock:
                    find produ where produ.procod = movim.procod 
                                    no-lock no-error.
                    if not avail produ then next.                

                    if vcatcod > 0 and
                        produ.catcod <> vcatcod
                    then next.    
                    put unformat
                        movim.procod at 05
                        (if avail produ 
                         then produ.pronom else "") format "x(35)" at 13
                           movim.movqt to 58.
                                
                end.
               put unformat skip(1).                 

            end.
        end.
    end.

    if opsys = "UNIX" 
    then do: 
        output close. 
        run visurel.p (input varquivo, 
                       input ""). 
    end. 
    else do: 
        {mrod.i}.
    end.
                                                                       
end.
