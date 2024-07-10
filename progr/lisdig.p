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

    update vetbcod with frame f4 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f4.


    message "Confirma Listagem ?" update sresp.
    if not sresp
    then leave.
    /***********************************/
    def var vpro like produ.procod.
    def var vq like estoq.estatual.
    def var vc as char format "x(20)".

    {mdadmcab.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """CMPCOL01"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE "" +
                        string(estab.etbnom,""x(30)"") +
                        ""Data do Estoque => "" + string(today,""99/99/9999"")"
        &Width     = "160"
        &Form      = "frame f-cab"}

    for each coletor where coletor.etbcod = vetbcod no-lock:
        find produ where produ.procod = coletor.procod no-lock.
        if produ.catcod <> 31
        then next.
        find estoq where estoq.etbcod = vetbcod and
                         estoq.procod = produ.procod no-lock.
        disp produ.procod
             produ.pronom
             coletor.colqtd (total) column-label "Qtd.Estoque" 
             estoq.estcusto column-label "P.Custo"
             (coletor.colqtd * estoq.estcusto) (total)
                column-label "Total Custo"
                                        with frame ff down width 120.
    end.
    output close.

end.
