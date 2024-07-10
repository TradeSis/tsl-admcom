{admcab.i}
def var totavi like plani.platot.
def var totpre like plani.platot.
def var totcon like plani.platot.
def var varquivo as char format "x(20)".

def temp-table w-demo
    field etbcod  like estab.etbcod
    field wavi    like plani.platot
    field wcon    like plani.platot
    field wpre    like plani.platot.

def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
repeat:
    for each w-demo:
        delete w-demo.
    end.
    update vetbcod with frame f1 side-label width 80.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    else display "GERAL" @ estab.etbnom with frame f1.

    update vdt1 label "Periodo"
           vdt2 no-label with frame f1.
    for each estab where ( if vetbcod = 0
                           then true
                           else estab.etbcod = vetbcod ) no-lock.
        assign totavi = 0
               totcon = 0
               totpre = 0.
        display estab.etbcod with frame ftot side-label centered.
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5     and
                             plani.pladat >= vdt1 and
                             plani.pladat <= vdt2 and
                             plani.crecod = 01 no-lock:

        
            totavi = totavi + 1.
            display totavi with frame f-tot1.
            pause 0.
        end.
        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial >= vdt1 and
                                contrato.dtinicial <= vdt2 no-lock:

            totcon = totcon + 1.
            display totcon with frame f-tot2.
            pause 0.
        end.

        create w-demo.
        assign w-demo.etbcod  = estab.etbcod
               w-demo.wavi    = totavi
               w-demo.wcon    = totcon
               w-demo.wpre    = totpre.
    end.

    varquivo = "..\relat\totvepr" + STRING(month(vdt1),"99").

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""totvepr""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """TOTAL DE VENDAS/CONTRATOS POR FILIAL - PERIODO DE "" +
                                  string(vdt1,""99/99/9999"") + "" A "" +
                                  string(vdt2,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

        for each w-demo:
            display w-demo.etbcod column-label "Filial"
                    wavi(total) 
                       column-label "Total AVista" format ">,>>>,>>9.99"
                    wcon(total) 
                       column-label "Total Contratos" format ">>,>>>,>>9.99"
                    wpre(total) column-label "Total Prestacoes"
                                    with frame f4 down width 200.
        end.
        output close.
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then dos silent value("ved " + varquivo + " > prn").

end.
