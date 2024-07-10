{admcab.i}
def var v-de like plani.platot.
def var v-ac like plani.platot.
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def temp-table tt-tipmov 
    field tt-movtdc like tipmov.movtdc
    field tt-movtnom like tipmov.movtnom
    field tt-qtd like movim.movqtm
    field tt-custo like plani.platot
    field tt-venda like plani.platot.
    
def var qtdsai like plani.platot.
def var qtdent like plani.platot.
def var cusent like plani.platot.
def var cussai like plani.platot.
def var vensai like plani.platot.


repeat:
    
    assign qtdsai = 0
           qtdent = 0
           cusent = 0
           cussai = 0
           vensai = 0.


    for each tt-tipmov.
        delete tt-tipmov.
    end.
    for each tipmov no-lock:
        create tt-tipmov.
        assign tt-tipmov.tt-movtdc  = tipmov.movtdc
               tt-tipmov.tt-movtnom = tipmov.movtnom.
        if tipmov.movtdc = 6
        then tt-tipmov.tt-movtnom = "TRANSF. DE SAIDA".
    end.
    create tt-tipmov.
    assign tt-tipmov.tt-movtdc = 99
           tt-tipmov.tt-movtnom = "TRANF. DE ENTRADA".


    update vetbcod colon 16 label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f1.
    update vdti colon 16 label "Data Inicial"
           vdtf colon 16 label "Data Final"with frame f1.
    
    for each plani where plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.movtdc = 6     and
                         plani.desti = estab.etbcod no-lock:

        disp plani.numero
             plani.pladat
                    with frame ff2 1 down side-label. pause 0.
        find first tt-tipmov where tt-tipmov.tt-movtdc = 99 no-error.
        if not avail tt-tipmov
        then do:
            create tt-tipmov.
            assign tt-tipmov.tt-movtdc = 99
                   tt-tipmov.tt-movtnom = tipmov.movtnom.
        end.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            
            find estoq where estoq.etbcod = movim.etbcod and
                             estoq.procod = movim.procod no-lock no-error.
            if not avail estoq
            then next.
            tt-tipmov.tt-qtd = tt-tipmov.tt-qtd + movim.movqtm.
            tt-tipmov.tt-custo = tt-tipmov.tt-custo + 
                               (movim.movqtm * estoq.estcusto).
        end.
    end.

    hide frame ff2 no-pause.
    for each plani where plani.pladat >= vdti and
                         plani.pladat <= vdtf and
                         plani.movtdc = 6     and
                         plani.etbcod = estab.etbcod no-lock:

        disp plani.numero
             plani.pladat
                    with frame f2 1 down side-label. pause 0.
        
        find first tt-tipmov where tt-tipmov.tt-movtdc = plani.movtdc 
                                      no-error.
        if not avail tt-tipmov
        then do:
            create tt-tipmov.
            assign tt-tipmov.tt-movtdc = plani.movtdc.
        end.
            
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            
            
            v-de = 0.
            v-ac = 0.
            if plani.crecod = 2 and plani.movtdc = 5
            then do:
                for each contnf where contnf.etbcod = plani.etbcod and
                                      contnf.placod = plani.placod no-lock.
                    find contrato where contrato.contnum = contnf.contnum
                                    no-lock no-error.
                    if avail contrato
                    then do:
                        if contrato.vltotal > ( plani.platot - 
                                                plani.vlserv)
                        then do:
                            v-ac = contrato.vltotal /
                                   (plani.platot - 
                                    plani.vlserv).
                        end.
                        if contrato.vltotal < ( plani.platot - 
                                                plani.vlserv) 
                        then do:
                           v-de = (plani.platot 
                                   - plani.vlserv)
                                   / contrato.vltotal.
                        end.
                    end.
                    else do:
                        if plani.acfprod > 0
                        then v-ac = (plani.platot + plani.acfprod) / 
                                     plani.platot.
                        if plani.descprod > 0
                        then v-de = plani.platot /
                                   (plani.platot - plani.descprod).
                    end.
                end.
                if plani.platot < 1
                then assign v-de = 0
                            v-ac = 0.
            end.
            find estoq where estoq.etbcod = movim.etbcod and
                             estoq.procod = movim.procod no-lock no-error.
            if not avail estoq
            then next.

            if v-ac = 0 and v-de = 0
            then do:
                if ( ( movim.movqtm * movim.movpc ) -
                 ( ( ( movim.movqtm * movim.movpc ) / plani.platot ) *
                       plani.vlserv ) ) <> ? 
                then tt-tipmov.tt-venda = tt-tipmov.tt-venda +
                        ( ( movim.movqtm * movim.movpc ) - 
                        ( ( ( movim.movqtm * movim.movpc ) / plani.platot ) *
                              plani.vlserv ) ).
            end.
            if v-ac > 0
            then do:
              if ( movim.movqtm * movim.movpc * v-ac ) - 
                 ( ( ( movim.movqtm * movim.movpc ) / plani.platot ) * 
                       plani.vlserv ) <> ?
              then tt-tipmov.tt-venda = tt-tipmov.tt-venda +
                             ( movim.movqtm * movim.movpc * v-ac ) - 
                        ( ( ( movim.movqtm * movim.movpc ) / plani.platot ) * 
                              plani.vlserv).
            end.
                
            if v-de > 0
            then do:
               if ( movim.movqtm * movim.movpc / v-de ) - 
                    ( ( ( movim.movqtm * movim.movpc ) / plani.platot ) *
                          plani.vlserv ) <> ?
               then tt-tipmov.tt-venda = tt-tipmov.tt-venda +
                            ( movim.movqtm * movim.movpc / v-de ) - 
                      ( ( ( movim.movqtm * movim.movpc ) / plani.platot ) *
                              plani.vlserv ).
            end.

            tt-tipmov.tt-qtd = tt-tipmov.tt-qtd + movim.movqtm.
            tt-tipmov.tt-custo = tt-tipmov.tt-custo + 
                               (movim.movqtm * estoq.estcusto).
        end.
    end.
    hide frame f2 no-pause.
    for each tt-tipmov :
        if tt-tipmov.tt-movtdc <> 5
        then tt-tipmov.tt-venda = 0.
        if tt-tipmov.tt-qtd = 0
        then next.
        display tt-tipmov.tt-movtnom format "x(20)"
                tt-tipmov.tt-qtd column-label "Quantidade"
                                   format ">,>>>,>>9.99"
                tt-tipmov.tt-custo column-label "Valor!Custo"
                                   format ">>,>>>,>>9.99"
                tt-tipmov.tt-venda column-label "Valor!Venda" 
                                   format ">>,>>>,>>9.99"
                        with frame f3 down overlay.

        if tt-tipmov.tt-movtdc = 4 or
           tt-tipmov.tt-movtdc = 1 or
           tt-tipmov.tt-movtdc = 7 or
           tt-tipmov.tt-movtdc = 12 or
           tt-tipmov.tt-movtdc = 15 or
           tt-tipmov.tt-movtdc = 17 or
           tt-tipmov.tt-movtdc = 99
        then do:
            assign qtdent = qtdent + tt-tipmov.tt-qtd
                   cusent = cusent + tt-tipmov.tt-custo.
        end.



        if tt-tipmov.tt-movtdc = 5 or
           tt-tipmov.tt-movtdc = 6 or
           tt-tipmov.tt-movtdc = 13 or
           tt-tipmov.tt-movtdc = 14 or
           tt-tipmov.tt-movtdc = 16 or
           tt-tipmov.tt-movtdc = 8  or
           tt-tipmov.tt-movtdc = 18
        then do:
            assign qtdsai = qtdsai + tt-tipmov.tt-qtd
                   cussai = cussai + tt-tipmov.tt-custo
                   vensai = vensai + tt-tipmov.tt-venda.
        end.

    end.
    display "    Qtd     Vl. Custo     Vl. Venda" at 20 skip(1)
                        
    "Entradas........    "   
            qtdent no-label  format ">,>>>,>>9.99"
            cusent no-label  format ">>,>>>,>>9.99" skip 


    "Saidas..........    "  
            qtdsai no-label  format ">,>>>,>>9.99"
            cussai no-label  format ">>,>>>,>>9.99"
            vensai no-label  format ">>,>>>,>>9.99"
            with frame f4 color white/cyan  
                                centered side-label overlay row 17 no-box.
end.



            
    
