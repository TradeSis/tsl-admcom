{admcab.i}

def var vpend   as int format "->>>9".
def var vqtd like estoq.estinvctm format "->,>>9.99".


def var vimp as l.
def stream stela.
def var varquivo as char.
def var vest like estoq.estatual.
def var vant like estoq.estatual.
def var vmes as int.
def var vano as int.
def var vprocod like produ.procod.
def var vquan   like estoq.estatual.
def var vpath as char format "x(30)".
def temp-table wcol
    field wcol as char format "x(2)".
def var vcol as char format "x(2)".

def var vlei            as char format "x(26)".
def var vetb            as i    format "999".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var est like estoq.estatual.
def var tot1 like titulo.titvlcob format "->,>>>,>>9.99".
def var tot2 like titulo.titvlcob format "->,>>>,>>9.99".
def var vde like titulo.titvlcob format "->>>>>>>>>9".
def var vac like titulo.titvlcob format "->>>>>>>>>9".
def var vesc as log format "Alfabetica/Classe".
repeat:
    for each wcol:
        delete wcol.
    end.
    tot1 = 0.
    tot2 = 0.
    tot  = 0.
    vde  = 0.
    vac  = 0.

    prompt-for estab.etbcod colon 20
                with frame f1 side-label centered color white/red row 7.
    find estab using estab.etbcod no-lock.
    disp estab.etbnom no-label with frame f1.

    prompt-for categoria.catcod colon 20
                with frame f1.
    update vdata label "Data da Coleta" colon 20 with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    update vesc label "Ordem" colon 20 with frame f1.
    
    for each coletor where coletor.etbcod = estab.etbcod and
                           coletor.coldat = vdata use-index coletor1:
        find produ where produ.procod = coletor.procod no-lock no-error.
        if avail produ and produ.catcod = categoria.catcod
        then do transaction:
            delete coletor.
        end.
    end.
    repeat:
        update vcol label "Coletor" with frame f3 side-label centered.
        find first wcol where wcol.wcol = vcol no-error.
        if not avail wcol
        then do:
            create wcol.
            assign wcol.wcol = vcol.
        end.
    end.

    {confir.i 1 "Confronto com Coletor"}
    /***********************************/
    def var vpro like produ.procod.
    def var vq like estoq.estatual.
    def var vc as char format "x(20)".

    for each wcol:
       vpath = "m:\coletor\col" + string(wcol.wcol,"x(02)") + "\coleta99.txt".
       input from value(vpath).
       repeat:
            vqtd = 0.
            import vlei.
            assign vetb = int(substring(string(vlei),4,2))
                   vcod = int(substring(string(vlei),14,7))
                   vcod2 = int(substring(string(vlei),14,6))
                   vqtd = int(substring(string(vlei),21,6)).

            if vetb <> estab.etbcod or vcod = 0 or vcod = ? or
               vcod = 1 or vcod = 2 or vcod = 3 or vcod = 4 or vcod = 5
            then next.
            find produ where produ.procod = vcod no-lock no-error.
            if not avail produ
            then do:
                find produ where produ.procod = vcod2 no-lock no-error.
                if not avail produ
                then next.
            end.
            find coletor where coletor.etbcod = estab.etbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata no-error.
            if not avail coletor
            then do transaction:
                create coletor.
                assign coletor.etbcod = estab.etbcod
                       coletor.procod = produ.procod
                       coletor.coldat = vdata.
            end.
            do transaction:
                coletor.colqtd = coletor.colqtd + vqtd.
            end.
        end.
        
        INPUT CLOSE.
    end.

    message "Deseja alterar produtos" update sresp.
    if sresp
    then do:
        repeat:
            update vprocod with frame f4 side-label width 80.
            find produ where produ.procod = vprocod no-lock no-error.
            if avail produ
            then display produ.pronom no-label with frame f4.
            find coletor where coletor.etbcod = estab.etbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata no-error.
            if not avail coletor
            then do transaction:
                create coletor.
                assign coletor.etbcod = vetb
                       coletor.coldat = vdata
                       coletor.procod = produ.procod.
            end.
            
            do transaction:
                display coletor.colqtd with frame f-pro.
                update vqtd column-label "Quantidade"
                       vpend column-label "Pendencia" with frame f-pro.
                coletor.colacr = 0.
                coletor.coldec = 0.
                if vpend >= 0
                then coletor.colqtd =  coletor.colqtd + vqtd - vpend.
                else coletor.colqtd =  coletor.colqtd + vqtd + vpend.
                display coletor.colqtd with frame f-pro down.
                down with frame f-pro.
            end.
        
            display coletor.procod
                    coletor.etbcod
                    coletor.coldat with 1 down. pause 0.

            
            
        end.
    end.

    message "Deseja Processar" update sresp.
    if sresp = no
    then next.
    
    message "Imprimir tudo" update sresp.
    if sresp 
    then vimp = yes.
    else vimp = no.
    
    varquivo = "c:\temp\col" + string (estab.etbcod,"999") 
                             + string(day(today)).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """COLETA3"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                      categoria.catnom + ""  "" + string(vdata,""99/99/9999"")"
        &Width     = "160"
        &Form      = "frame f-cab"}

    output stream stela to terminal.
    
    if vesc
    then do:
    for each produ where produ.catcod = categoria.catcod
                                 no-lock by produ.pronom.
    
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        if not avail estoq
        then next.

        vest = estoq.estatual.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:


            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            

            
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.




        
        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then do transaction:
            create coletor.
            assign coletor.etbcod = estab.etbcod
                   coletor.coldat = vdata
                   coletor.procod = produ.procod
                   coletor.colqtd = 0.
        end.
        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.
        
        if vimp = no
        then do:
            if vest = coletor.colqtd
            then next.
        end.
        else do:
            if vest = 0 and coletor.colqtd = 0
            then next.
        end.
        
        tot = 0.

        if coletor.colacr > 0
        then assign tot1 = tot1 + (estoq.estcusto * coletor.colacr)
                    vac  = vac  + coletor.colacr
                    tot  = coletor.colacr.

        if coletor.coldec > 0
        then assign tot2 = tot2 + (estoq.estcusto * coletor.coldec)
                    vde  = vde  + coletor.coldec
                    tot  = coletor.coldec.

        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                vest(TOTAL) column-label "Qtd." format "->>>>9"
                coletor.colqtd(total) column-label "Dig." format "->>>>9"
                coletor.colacr(total) format "->>>>>>>9"
                        when colacr > 0 column-label "Acresc."
                coletor.coldec(total) format "->>>>>>>9"
                            when coldec > 0 column-label "Decres."
                estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                (colacr * estoq.estcusto)(total) when colacr > 0
                        column-label "Vl.Acresc." format "->>>,>>9.99"
                (coldec * estoq.estcusto)(total) when coldec > 0
                        column-label "Vl.Decresc." format "->>>,>>9.99"
                (estoq.estcusto * tot)(total)
                    column-label "Total Custo" format ">>,>>>,>>9.99"
                                with frame f2 down width 200.
    
    
        display stream stela
             
             tot1 label "TOTAL VL. ACRESCIMO : " 
             vac   label "TOTAL ACRESCIMO     : "  
             tot2  label "TOTAL VL. DECRESCIMO: " 
             vde   label "TOTAL DECRESCIMO    : " 
                    with frame f-tt centered 1 column no-label.
        pause 0.
                
    end.
    end.
    else do:
    for each produ where produ.catcod = categoria.catcod
                                 no-lock by produ.clacod.
    
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        if not avail estoq
        then next.

        vest = estoq.estatual.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:


            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            

            
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            find tipmov of movim no-lock.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.datexp >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.datexp >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.




        
        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then do transaction:
            create coletor.
            assign coletor.etbcod = estab.etbcod
                   coletor.coldat = vdata
                   coletor.procod = produ.procod
                   coletor.colqtd = 0.
        end.
        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.
        
        if vimp = no
        then do:
            if vest = coletor.colqtd
            then next.
        end.
        else do:
            if vest = 0 and coletor.colqtd = 0
            then next.
        end.
        
        tot = 0.

        if coletor.colacr > 0
        then assign tot1 = tot1 + (estoq.estcusto * coletor.colacr)
                    vac  = vac  + coletor.colacr
                    tot  = coletor.colacr.

        if coletor.coldec > 0
        then assign tot2 = tot2 + (estoq.estcusto * coletor.coldec)
                    vde  = vde  + coletor.coldec
                    tot  = coletor.coldec.

        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                vest(TOTAL) column-label "Qtd." format "->>>>9"
                coletor.colqtd(total) column-label "Dig." format "->>>>9"
                coletor.colacr(total) format "->>>>>>>9"
                        when colacr > 0 column-label "Acresc."
                coletor.coldec(total) format "->>>>>>>9"
                            when coldec > 0 column-label "Decres."
                estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                (colacr * estoq.estcusto)(total) when colacr > 0
                        column-label "Vl.Acresc." format "->>>,>>9.99"
                (coldec * estoq.estcusto)(total) when coldec > 0
                        column-label "Vl.Decresc." format "->>>,>>9.99"
                (estoq.estcusto * tot)(total)
                    column-label "Total Custo" format ">>,>>>,>>9.99"
                                with frame f5 down width 200.
    
    
        display stream stela
             
             tot1 label "TOTAL VL. ACRESCIMO : " 
             vac   label "TOTAL ACRESCIMO     : "  
             tot2  label "TOTAL VL. DECRESCIMO: " 
             vde   label "TOTAL DECRESCIMO    : " 
                    with frame f-ttt centered 1 column no-label.
        pause 0.
                
    end.
    
    end.
    
    
    output stream stela close.
    put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
             "TOTAL ACRESCIMO     : "       vac skip
             "TOTAL VL. DECRESCIMO: " at 40 tot2
             "TOTAL DECRESCIMO    : "       vde.
    output close.
    
    display varquivo label "Arquivo" format "x(20)"
              with frame f-arq side-label centered row 18 no-box.
    pause.
    hide frame f-arq.
              
    
    message "Deseja Imprimir Relatorio ? " update sresp.
    if sresp
    then dos silent value("type " + varquivo + "  > prn").

end.
