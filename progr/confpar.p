{admcab.i}

def var varquivo as char.
def var tot  like plani.platot.
def var tot1  like plani.platot.
def var vac   like plani.platot.
def var tot2  like plani.platot.
def var vde   like plani.platot.
def var vest like estoq.estatual.
def var vtipo as char format "x(10)" extent 2
                initial ["Numerica","Alfabetica"].
def var vpend   as int format "->>>9".
def var vetbcod like estab.etbcod.
def var vqtd like estoq.estinvctm format "->,>>9.99".
def var vprocod like estoq.procod.
def var vdata   like estoq.estbaldat format "99/99/9999".
def var vcatcod like produ.catcod.
form vprocod
     produ.pronom format "x(30)"
     vqtd
     vpend
     coletor.colqtd column-label "Qtd" with frame f-pro width 80 down.

update  vcatcod with frame f-data.
find categoria where categoria.catcod = vcatcod no-lock.
display categoria.catnom no-label with frame f-data.
update  vdata label "Data Referencia" with frame f-data side-label centered.

repeat:
    update vetbcod with frame f-etbcod side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f-etbcod.
    message "Nova digitacao?" update sresp.
    if sresp
    then do :
        for each coletor where coletor.etbcod = estab.etbcod and
                               coletor.coldat = vdata:

            find produ where produ.procod = coletor.procod no-lock no-error.
            if avail produ and produ.catcod = categoria.catcod
            then delete coletor.
        end.

    end.
    
    repeat:
        assign tot  = 0
               tot1 = 0
               vac  = 0
               tot2 = 0
               vde  = 0
               vprocod = 0.
                                                 pause 0.
        update vprocod with frame f-pro down width 80.
        find produ where produ.procod = vprocod no-lock.
        display produ.pronom format "x(30)"
                    with frame f-pro.  pause 0.
        vqtd = 0.
        vpend = 0.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.

        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then do transaction:
            create coletor.
            assign coletor.etbcod = estab.etbcod
                   coletor.procod = produ.procod
                   coletor.coldat = vdata
                   coletor.catcod = vcatcod.
                   pause 0.
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
            pause 0.
        end.
        vest = estoq.estatual.
        for each movim where movim.procod = produ.procod and
                             movim.movdat > vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.
                                                     pause 0.

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
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.

pause 0.

        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.
    end.
    pause 0.

    {confir.i 1 "Relatorio da Digitacao"}

    display vtipo no-label with frame ff centered row 10.
    choose field vtipo with frame ff.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/conf" + string(time).
    else varquivo = "l:~\relat~\conf.txt".

    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = """CONFPAR"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom
                                            + string(vdata,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}
        if frame-index = 1
        then do:
            for each coletor where coletor.etbcod = vetbcod and
                                   coletor.coldat = vdata by coletor.procod:
                find produ where produ.procod = coletor.procod no-lock.
                find estoq where estoq.etbcod = coletor.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                    
                vest = estoq.estatual.
                for each movim where movim.procod = produ.procod and
                                     movim.movdat > vdata no-lock:

                    find first plani where plani.etbcod = movim.etbcod and
                                           plani.placod = movim.placod and
                                           plani.movtdc = movim.movtdc and
                                           plani.pladat = movim.movdat
                                                             no-lock no-error.
                                      pause 0.
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
                       if movim.movdat >= vdata
                       then vest = vest + movim.movqtm.
                    end.

                    if movim.movtdc = 4 or 
                       movim.movtdc = 1 or 
                       movim.movtdc = 7 or 
                       movim.movtdc = 12 or 
                       movim.movtdc = 15 or 
                       movim.movtdc = 17
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest - movim.movqtm.
                    end.

                    if movim.movtdc = 6 
                    then do: 
                        if plani.etbcod = estab.etbcod
                        then do:
                            if movim.movdat >= vdata
                            then vest = vest + movim.movqtm.
                        end.
                        if plani.desti = estab.etbcod
                        then do: 
                            if movim.movdat >= vdata
                            then vest = vest - movim.movqtm.
                        end.    pause 0.
                    end.
                end.         pause 0.
                
                if vest = coletor.colqtd
                then assign coletor.colacr = 0
                            coletor.coldec = 0.

 
                if coletor.colacr > 0
                then assign tot = coletor.colacr
                            tot1 = tot1 + (estoq.estcusto * coletor.colacr)
                            vac  = vac  + coletor.colacr.

                if coletor.coldec > 0 
                then assign tot = coletor.coldec 
                            tot2 = tot2 + (estoq.estcusto * coletor.coldec)
                            vde  = vde  + coletor.coldec.

                                     pause 0.
                display produ.procod 
                        produ.pronom format "x(37)"
                        vest(total)  
                            column-label "Comput." format "->>>>9"
                        coletor.colqtd(total) 
                            column-label "Fisico" format "->>>>9"

                        coletor.colacr when coletor.colacr > 0
                                            format "->>>>>9"
                        coletor.coldec when coletor.coldec > 0
                                            format "->>>>>9"
                        estoq.estcusto column-label "Pc.Custo" when avail estoq
                        format "->>>,>>9.99"
                                                (total)
                       (coletor.colacr * estoq.estcusto) when colacr > 0
                                column-label "Acresc" format   "->>>>9"
                       (coletor.coldec * estoq.estcusto) when coldec > 0
                                column-label "Decres"  format "->>>>9"
                       (vest * estoq.estcusto) format "->>>,>>9.99" (total)                                     column-label "Total!Pc.Custo"
                                        with frame f-cotac down width 200.
            end.
            pause 0.
            
            put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
                     "  TOTAL ACRESCIMO     : "       vac skip
                     "TOTAL VL. DECRESCIMO: " at 40 tot2
                     "  TOTAL DECRESCIMO    : "       vde.



        end.
        else do:
            for each produ use-index catpro where
                                     produ.catcod = categoria.catcod,
                each coletor where coletor.etbcod = vetbcod and
                                   coletor.procod = produ.procod and
                                   coletor.coldat = vdata 
                                        break by produ.catcod:

                find estoq where estoq.etbcod = coletor.etbcod and
                                 estoq.procod = produ.procod no-lock.
                    
                vest = estoq.estatual.
                for each movim where movim.procod = produ.procod and
                                     movim.movdat > vdata no-lock:

                    find first plani where plani.etbcod = movim.etbcod and
                                           plani.placod = movim.placod and
                                           plani.movtdc = movim.movtdc and
                                           plani.pladat = movim.movdat
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
                        if movim.movdat >= vdata
                        then vest = vest + movim.movqtm.
                    end.

                    if movim.movtdc = 4 or 
                       movim.movtdc = 1 or 
                       movim.movtdc = 7 or 
                       movim.movtdc = 12 or 
                       movim.movtdc = 15 or 
                       movim.movtdc = 17
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest - movim.movqtm.
                    end.

                    if movim.movtdc = 6 
                    then do: 
                        if plani.etbcod = estab.etbcod
                        then do: 
                            if movim.movdat >= vdata
                            then vest = vest + movim.movqtm.
                        end. 
                        if plani.desti = estab.etbcod
                        then do: 
                            if movim.movdat >= vdata
                            then vest = vest - movim.movqtm.
                        end.
                    end.
                end.
                    pause 0.
                if vest = coletor.colqtd
                then assign coletor.colacr = 0
                            coletor.coldec = 0.

  
                if coletor.colacr > 0
                then assign tot = coletor.colacr
                            tot1 = tot1 + (estoq.estcusto * coletor.colacr)
                            vac  = vac  + coletor.colacr.

                if coletor.coldec > 0
                then assign tot = coletor.coldec
                            tot2 = tot2 + (estoq.estcusto * coletor.coldec)
                            vde  = vde  + coletor.coldec.

                display produ.procod 
                        produ.pronom format "x(37)"
                        vest(total)  
                            column-label "Comput." format "->>>>9"
                        coletor.colqtd(total) 
                            column-label "Fisico" format "->>>>9"

                        coletor.colacr when coletor.colacr > 0
                                            format "->>>>>9"
                        coletor.coldec when coletor.coldec > 0
                                            format "->>>>>9"
                        estoq.estcusto column-label "Pc.Custo" when avail estoq
                                            format "->>>,>>9.99" (total)
                       (coletor.colacr * estoq.estcusto) when colacr > 0
                                column-label "Acresc" format   "->>>>9"
                       (coletor.coldec * estoq.estcusto) when coldec > 0
                                column-label "Decres"  format "->>>>9"
                                
                       (vest * estoq.estcusto) format "->>>,>>9.99" 
                                    (total)         
                                column-label "Total!Pc.Custo"
                                
                                        with frame f-cotac2 down width 200.
            end.           pause 0.
            
            put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
                     "  TOTAL ACRESCIMO     : "       vac skip
                     "TOTAL VL. DECRESCIMO: " at 40 tot2
                     "  TOTAL DECRESCIMO    : "       vde.
        end.
        pause 0.
        output close.

        if opsys = "UNIX"
        then do:
            run visurel.p (input varquivo,
                           input "").
        end.
        else do:
            {mrod.i} 
        end.

end.


