{admcab.i}
def var vprocod like produ.procod.
def var vquan   like estoq.estatual.
def var vpath as char format "x(30)".
def var vetbcod like estab.etbcod.
def temp-table wcol
    field wcol as char format "x(1)".
def var vcol as char format "x(1)".

def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var vqtd            as i    format "999999".
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var est like estoq.estatual.
def var tot1 like titulo.titvlcob format "->,>>>,>>9.99".
def var tot2 like titulo.titvlcob format "->,>>>,>>9.99".
def var vde like titulo.titvlcob format "->,>>>,>>9.99".
def var vac like titulo.titvlcob format "->,>>>,>>9.99".

def temp-table tt-lista
    field procod like produ.procod
    field pronom like produ.pronom
    field qtdbal as int format ">>>,>>9"
    field qtdest as int format ">>>,>>9"
    field estcusto like estoq.estcusto
        index ipronom pronom.

repeat:
    for each wcol:
        delete wcol.
    end.
    for each tt-lista:
        delete tt-lista.
    end.

    tot1 = 0.
    tot2 = 0.
    tot  = 0.
    vde  = 0.
    vac  = 0.

    prompt-for categoria.catcod
                with frame f1 side-label row 4 centered width 80.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.
    update vdata label "Data da Coleta" with frame f1.
    
    update vetbcod with frame f4 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f4.


    repeat:
        update vcol label "Coletor" with frame f3 side-label centered.
        find first wcol where wcol.wcol = vcol no-error.
        if not avail wcol
        then do:
            create wcol.
            assign wcol.wcol = vcol.
        end.
    end.

    message "Confirma Listagem ?" update sresp.
    if not sresp
    then leave.
    /***********************************/
    def var vpro like produ.procod.
    def var vq like estoq.estatual.
    def var vc as char format "x(20)".
    for each wcol:
       vpath = "h:\aplic\coletor\col" + string(wcol.wcol,"x") + "\coleta99.txt".
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
            
           
            
            if produ.catcod <> categoria.catcod
            then next.

            find tt-lista where tt-lista.procod = produ.procod no-error.
            if not avail tt-lista
            then do:
                disp produ.procod with 1 down. pause 0.
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod no-lock.
                create tt-lista.
                assign tt-lista.procod = produ.procod
                       tt-lista.pronom = produ.pronom
                       tt-lista.estcusto = estoq.estcusto.
            end.
            assign tt-lista.qtdbal = tt-lista.qtdbal + vqtd.
        end.
        INPUT CLOSE.
    end.

 /*   for each tt-lista:
        disp tt-lista.procod with 1 down centered.
        pause 0.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = tt-lista.procod no-lock.
        tt-lista.qtdest = estoq.estatual.
        
        for each movim where movim.procod = tt-lista.procod and
                             movim.movdat >= vdata no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.

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
               then if movim.movdat > vdata
                    then tt-lista.qtdest = tt-lista.qtdest + movim.movqtm.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then if movim.movdat > vdata
                 then tt-lista.qtdest = tt-lista.qtdest - movim.movqtm.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then if movim.movdat > vdata
                     then tt-lista.qtdest = tt-lista.qtdest + movim.movqtm.
                if plani.desti = estab.etbcod
                then if movim.movdat > vdata
                     then tt-lista.qtdest = tt-lista.qtdest - movim.movqtm.
            end.
        end.
    end.*/

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """CMPCOL01"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE "" +
                        string(estab.etbnom,""x(30)"") +
                        ""Data do Estoque => "" + string(vdata,""99/99/9999"")"
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each tt-lista no-lock:
        disp tt-lista.procod
             tt-lista.pronom
             tt-lista.qtdbal (total) column-label "Qtd.Estoque" 
             tt-lista.estcusto column-label "P.Custo"
             (tt-lista.qtdbal * tt-lista.estcusto) (total)
                column-label "Total Custo"
                                        with frame ff down width 120.
    end.
    output close.

end.
