{admcab.i new}
def var vv as int.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vetbcod like estab.etbcod.
def var vmes as int format "99".
def var vano as int format "9999".
def var varquivo as char.
def var vindex as int.
def var vcusto like ctbhie.ctbcus.
def var tip-custo as char extent 2  FORMAT "x(20)"
        initial["CUSTO NOTA","CUSTO MEDIO"].

def buffer bctbhie for ctbhie.

repeat:
    update vetbcod with frame f1 side-label.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    
    /*
    vmes = 12.
    vano = year(today) - 1.
    */
    
    find last ctbhie where ctbhie.etbcod = vetbcod no-lock no-error.
    if avail ctbhie
    then assign
            vmes = ctbhie.ctbmes
            vano = ctbhie.ctbano
            .
    update vmes label "MES"
           vano label "ANO"
                with frame f1 width 80.
    /*
    disp tip-custo with frame f-tit 1 down centered no-label.
    choose field tip-custo with frame f-tit.
    vindex = frame-index.
    */
    vindex = 2.
    
    {confir.i 1 "Listagem de inventario"}
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/inv_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999").
    else varquivo = "l:\relat\inv_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999").
            
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = """."""
        &Nom-Sis   = """."""
        &Tit-Rel   = """INVENTARIO "" + estab.etbnom + ""  "" +
                        "" Periodo: "" + string(vmes,""99"") +
                        ""/"" + string(vano,""9999"")"
        &Width     = "130"
        &Form      = "frame f-cab"}
        
    do vv = 1 to 125:
        put "" skip.
    end.    
    
    
    for each ctbhie where ctbhie.etbcod = vetbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock:
        
        if ctbhie.ctbest < 1
        then next.
        if ctbhie.ctbcus <= 0
        then next.
        find produ where produ.procod = ctbhie.procod no-lock no-error.
        if not avail produ
        then next.

        vcusto = ctbhie.ctbcus.
        find last bctbhie where bctbhie.etbcod = 0 and
                                bctbhie.procod = produ.procod and
                                bctbhie.ctbano <= vano
                                no-lock no-error.
        if avail bctbhie and vindex = 2
        then vcusto = bctbhie.ctbcus.
        
        if vcusto = ?
        then vcusto = 0.      

        display produ.procod column-label "Codigo" at 20
                produ.pronom FORMAT "x(50)"
                ctbhie.ctbest format ">>>>>>9"
                vcusto column-label "Pc.Custo" format ">>,>>9.99"
                (vcusto * ctbhie.ctbest)
                    column-label "Subtotal" format ">>,>>>,>>9.99"
                with frame f2 down width 200.
        down with frame f2.
    end.
    
    find ctbcad where ctbcad.ctbmes = vmes    and
                      ctbcad.ctbano = vano    and
                      ctbcad.etbcod = vetbcod no-lock no-error.
    if avail ctbcad
    then do:
    put                       "-------------" at 100 skip
        ctbcad.salfin  format ">>,>>>,>>9.99" at 100
        " TOTAL".
        
    end.    

    output close. 
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do: 
    {mrod.i}
    end.

    
end. 
