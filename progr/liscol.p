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
repeat:
    for each wcol:
        delete wcol.
    end.
    for each orcam:
        delete orcam.
    end.
    tot1 = 0.
    tot2 = 0.
    tot  = 0.
    vde  = 0.
    vac  = 0.

    repeat:
        update vcol label "Coletor" with frame f3 side-label centered.
        find first wcol where wcol.wcol = vcol no-error.
        if not avail wcol
        then do:
            create wcol.
            assign wcol.wcol = vcol.
        end.
    end.
    update vetbcod with frame f4 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f4.

    message "Confirma Confronto com Coletor" update sresp.
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
            find orcam where orcam.etbcod = produ.procod no-error.
            if not avail orcam
            then do:
                create orcam.
                assign orcam.etbcod = produ.procod.
            end.
            assign orcam.orcnum = orcam.orcnum + vqtd.
            display orcam.etbcod format ">>>>>9"
                    orcam.orcnum with 1 down. pause 0.
        end.
        INPUT CLOSE.
    end.

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """LISCOL"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE"" +
                        string(estab.etbnom,""x(30)"")"
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each orcam no-lock by orcam.etbcod:
        find produ where produ.procod = orcam.etbcod no-lock.
        find estoq where estoq.etbcod = vetbcod      and
                         estoq.procod = produ.procod no-lock.
        disp produ.procod
             produ.pronom
             orcam.orcnum(total) column-label "QTD" 
             estoq.estcusto(total) 
             (estoq.estcusto * orcam.orcnum)(total) 
                    with frame ff down width 200.
    end.
    output close.
end.
