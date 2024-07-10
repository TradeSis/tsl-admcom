{admcab.i}
def var vde like titulo.titvlcob format "->,>>>,>>9.99".
def var vac like titulo.titvlcob format "->,>>>,>>9.99".

def var tot1 as dec format "->>>,>>9.99".
def var tot2 as dec format "->>>,>>9.99".
def var ac  as i.
def var tot as i.
def var de  as i.
def var vdata like plani.pladat.
def var est like estoq.estatual.
def var vetbcod like estab.etbcod.

repeat:
    tot1 = 0.
    tot2 = 0.
    vde  = 0.
    vac  = 0.

    update vetbcod with frame f1 side-label centered color white/red row 7.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label skip(1) with frame f1.

    prompt-for categoria.catcod
                with frame f1.
    update vdata with frame f1.
    find categoria using categoria.catcod no-lock.
    disp categoria.catnom no-label with frame f1.

    {confir.i 1 "Posicao de Estoque"}
    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """LISCONF"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                                                   categoria.catnom "
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each produ no-lock by pronom.

        if produ.catcod <> categoria.catcod
        then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-error.
        if not avail estoq
        then next.
        est = estoq.estatual.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = vetbcod      and
                             movim.movdat >= vdata + 1 no-lock:

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if not avail plani
            then next.
            
            if movim.movtdc = 5  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then. 
            else next.
            


            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then est = est + movim.movqtm.


            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then est = est - movim.movqtm.

            if movim.movtdc = 6
            then do:
                if movim.etbcod = vetbcod
                then est = est + movim.movqtm.
            
                if movim.desti = vetbcod
                then est = est - movim.movqtm.
            end.
        end.
        
        for each movim where movim.procod  = produ.procod and
                             movim.desti   = vetbcod      and
                             movim.movdat >= vdata + 1 no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if not avail plani
            then next.
            
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            

            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then est = est + movim.movqtm.


            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then est = est - movim.movqtm.

            if movim.movtdc = 6
            then do:
                if movim.etbcod = vetbcod
                then est = est + movim.movqtm.
            
                if movim.desti = vetbcod
                then est = est - movim.movqtm.
            end.
        end.    
          
        
        
        
        
        
        ac = 0.
        de = 0.
        tot = 0.
        estoq.estmgluc = 0.
        estoq.estmgoper = 0.


        ac = estinvctm - est.
        de = est - estinvctm.

        if est = estinvctm
        then do:
            assign estoq.estmgluc = 0
                   estoq.estmgoper = 0.
            next.
        end.

        if ac > 0
        then assign tot = ac
                    estoq.estmgluc = ac.
        if de > 0
        then  assign tot = de
                     estoq.estmgoper = de.

        if ac >= 0
        then assign tot1 = tot1 + (estcusto * ac)
                    vac  = vac  + ac.

        if de >= 0
        then assign tot2 = tot2 + (estcusto * de)
                    vde  = vde  + de.



    display produ.procod column-label "Codigo"
            produ.pronom FORMAT "x(25)"
            est (TOTAL) column-label "Qtd." format "->>>>9"
            estoq.estinvctm (total) column-label "Dig." format "->>>>9"
            ac when ac > 0 column-label "Acresc."
            de when de > 0 column-label "Decres."
            estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
            (ac * estoq.estcusto)(total) when ac > 0
                    column-label "Vl.Acresc." format "->>>,>>9.99"
            (de * estoq.estcusto)(total) when de > 0
                    column-label "Vl.Decresc." format "->>>,>>9.99"
            (estoq.estcusto * tot)(total)
                    column-label "Total Custo" format ">>,>>>,>>9.99"
                with frame f2 down width 200.
    end.
    put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
             "TOTAL ACRESCIMO     : "       vac skip
             "TOTAL VL. DECRESCIMO: " at 40 tot2
             "TOTAL DECRESCIMO    : "       vde.
    output close.
end.
