{admcab.i}
def var vprocod like produ.procod.
def var vquan   like estoq.estatual.
def var vpath as char format "x(30)".
def temp-table wcol
    field wcol as char format "x(2)".
def var vcol as char format "x(2)".

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
    for each cotac:
        delete cotac.
    end.
    tot1 = 0.
    tot2 = 0.
    tot  = 0.
    vde  = 0.
    vac  = 0.

    update vcol label "Coletor" with frame f3 side-label centered.

    {confir.i 1 "Confronto com Coletor"}
    /***********************************/
    def var vpro like produ.procod.
    def var vq like estoq.estatual.
    def var vc as char format "x(20)".
    vpath = "m:\coletor\col" + string(vcol,"x(02)") + "\coleta99.txt".
    input from value(vpath).
    output to printer page-size 62.
    repeat:
        vqtd = 0.
        import vlei.
        assign vetb = int(substring(string(vlei),4,2))
               vcod = int(substring(string(vlei),14,7))
               vcod2 = int(substring(string(vlei),14,6))
               vqtd = int(substring(string(vlei),21,6)).
        find produ where produ.procod = vcod no-lock no-error.
        if not avail produ
        then do:
            find produ where produ.procod = vcod2 no-lock no-error.
            if not avail produ
            then next.
        end.
        find estoq where estoq.etbcod = vetb and
                         estoq.procod = produ.procod no-lock.
                
        display vetb
                produ.procod
                produ.pronom
                vqtd (total) 
                estoq.estcusto(total)
                (estoq.estcusto * vqtd)(total) 
                        with frame f-a down width 200.
    end.
    INPUT CLOSE.
    output close.
end.
