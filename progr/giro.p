/*                                                             qtdvend.p
*               Relatorio de Quantidades Vendidas
*/

{admcab.i}

def stream stela.

def buffer bestoq for estoq.

def var vtotest     like estoq.estatual format "->>>9"
                    column-label "Est.".
def var vtotven     like estoq.estatual format "->>>9"
                    column-label "Ven.".

def var vdti        as date label "Dt.Inicial".
def var vdtf        as date label "Dt.Final".
def var vetbcod1    like plani.etbcod.
def var vgerdesc    like plani.descprod format ">>>,>>9.99".
def var vgeracre    like plani.acfprod format ">>>,>>9.99".
def var vgerdevol   like plani.platot format ">>>,>>9.99".
def var vgerdevolcicm   like plani.platot format ">>>,>>9.99".
def var vgerdevolsicm   like plani.platot format ">>>,>>9.99".
def var vmarsicm    as dec format "->9.99" label "MK.S".
def var vmarcicm    as dec format "->9.99" label "MK.C".
def var vmarsger    as dec format "->9.99".
def var vmarcger    as dec format "->9.99".
def var vvalmarstot as dec format "->9.99".
def var vvalmarctot as dec format "->9.99".
def var vtotliq     as dec format ">>>,>>9.99".
def var vtotliq2    as dec format ">>>,>>9.99".
def var vtotliq3    as dec format ">>>,>>9.99".
def var valsici     as dec format "->>,>>9.99".
def var valsisi     as dec format "->>,>>9.99".
def var vtotl1      as int format ">>9" label "L.1".
def var vtotl2      as int format ">>9" label "L.2".
def var vtotloj     as int format ">>>9" label "TOTAL".
def var vvalven     as dec format ">>>,>>9.99" label "Pc.Venda ".
def var vvalsicm    as dec format ">>>,>>9.99" label "Pc.Custo ".
def var vvalcicm    as dec format ">>>,>>9.99" label "Pc.Custo ".
def var vtotl1ger   as int format ">>9" label "L.1".
def var vtotl2ger   as int format ">>9" label "L.2".
def var vtotlojger  as int format ">>>9" label "TOTAL".
def var vvalvenger  as dec format ">>>,>>9.99" label "Pc.Venda ".
def var vvalsicmger as dec format ">>>,>>9.99" label "Pc.S/ICMS".
def var vvalcicmger as dec format ">>>,>>9.99" label "Pc.C/ICMS".
def var vtotl1gertot   as int format ">>>9" label "L.1".
def var vtotl2gertot   as int format ">>>9" label "L.2".
def var vtotlojgertot  as int format ">>>9" label "TOTAL".
def var vvalvengertot  as dec format ">>>,>>9.99" label "Pc.Venda ".
def var vvalsicmgertot as dec format ">>>,>>9.99" label "Pc.S/ICMS".
def var vvalcicmgertot as dec format ">>>,>>9.99" label "Pc.C/ICMS".
def var vplacod like plani.placod.
def var vetbcod like movim.etbcod.
def var vfabcod like fabri.fabcod.
def var vgiro   as dec.
def temp-table wfcla
    field cla like clase.clacod.

repeat:
    vdti = today - 30.
    vdtf = today.
    update vetbcod colon 27 skip with frame f-dat.
    update vfabcod colon 27 skip with frame f-dat.
    update vdti colon 27
           vdtf colon 49 with frame f-dat centered
                        side-label color blue/cyan row 5.

    for each produ where produ.fabcod = vfabcod and
                         produ.clacod > 0 no-lock
                         break by produ.clacod
                               by produ.procod.

        disp produ.procod with 1 down centered color red/white.
        pause 0.

        vtotest = 0.

        if vetbcod > 0 then do:
            find estoq where estoq.etbcod = vetbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            vtotest = estoq.estatual.

        end.
        else do:
            for each estoq where estoq.procod = produ.procod:
                vtotest = vtotest + estoq.estatual.
            end.
        end.
        for each movim use-index datsai where
                         movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= vdti and
                         movim.movdat <= vdtf and
                         (if vetbcod = 0 then true
                          else movim.etbcod = vetbcod)
                          no-lock :

            vtotven = vtotven + movim.movqtm.


        end.

        if vtotven <> 0 or vtotest <> 0
        then do:

            find first bestoq of produ no-lock no-error.
            if not avail bestoq
            then next.

            find first wfcla where wfcla.cla = produ.clacod no-error.
            if not avail wfcla
            then do:
                create wfcla.
                assign wfcla.cla = produ.clacod.
            end.

        end.
        vvalven = 0.
        vvalcicm = 0.
        vmarcicm = 0.
        vtotest  = 0.
        vtotven  = 0.

    end.










    output stream stela to terminal.

    /*if opsys = "MSDOS"
    then
        varqsai = "..\impress\relsicm" + string(time).
    else
        varqsai = "../impress/relsicm" + string(time).*/



    {mdadmcab.i
        &Saida     = "printer" /*"value(varqsai)"*/
        &Page-Size = "64"
        &Cond-Var  = "134"
        &Page-Line = "66"
        &Nom-Rel   = ""GIRO""
        &Nom-Sis   = """ADMINISTRACAO"""
        &Tit-Rel   = """ANALISE DE GIRO - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
        &Width     = "134"
        &Form      = "frame f-cabcab"}
    form with frame flin down.

    if vetbcod <> 0 then do:
        find estab where estab.etbcod = vetbcod.
        disp "Loja:" colon 18
        estab.etbnom colon 30 no-label.
    end.
    else do:
        disp "Loja: TODAS" colon 18.
    end.

    find fabri where fabri.fabcod = vfabcod.
    disp "Fabricante:" colon 18
    fabri.fabnom colon 30 no-label.


    put fill("-",134) format "x(134)" skip.

    for each wfcla by wfcla.cla:
    for each produ where produ.fabcod = vfabcod and
                         produ.clacod = wfcla.cla no-lock
                         break by produ.clacod
                               by produ.procod.

        disp stream stela produ.procod with 1 down centered.
        pause 0.

        vtotest = 0.

        if vetbcod > 0 then do:
            find estoq where estoq.etbcod = vetbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            vtotest = estoq.estatual.

        end.
        else do:
            for each estoq where estoq.procod = produ.procod:
                vtotest = vtotest + estoq.estatual.
            end.
        end.
        for each movim use-index datsai where
                         movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= vdti and
                         movim.movdat <= vdtf and
                         (if vetbcod = 0 then true
                          else movim.etbcod = vetbcod)
                          no-lock :

            vtotven = vtotven + movim.movqtm.


        end.

        if vtotven <> 0 or vtotest <> 0
        then do:

            find first bestoq of produ no-lock no-error.
            if not avail bestoq
            then next.
            vvalven =  bestoq.estvenda.
            vvalcicm = bestoq.estcusto.
            vmarcicm    = vvalven / vvalcicm.


            find fabri of produ no-lock.

            vgiro = (vtotven / (vtotest + vtotven) * 100).
            if vgiro = ?
            then vgiro = 0.
            disp produ.procod
                 produ.pronom format "x(40)"
                 fabri.fabfant format "x(15)"
                 vvalven
                 vvalcicm
                 vmarcicm (AVERAGE by produ.clacod)
                 vtotest  (TOTAL by produ.clacod)
                 vtotven  (TOTAL by produ.clacod)
                 vgiro (AVERAGE by produ.clacod)
                                             format "->>9.99 %"
                                             column-label "Giro %"
                                             with frame fff width 134 down.

        end.
        vvalven = 0.
        vvalcicm = 0.
        vmarcicm = 0.
        vtotest  = 0.
        vtotven  = 0.

    end.
    end.

    output close.

end.
