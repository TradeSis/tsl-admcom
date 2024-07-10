{admcab.i}  /******** novo reldep.p ***********/


def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def temp-table  tt-banco
    field bancod like depban.bancod
    field tt-val like depban.valdep.

repeat:

    for each tt-banco:
        delete tt-banco.
    end.
    update vdti label "Data Inicial"
           vdtf label "Data Finan"
            with frame f-dat centered width 80 side-label
                        color blue/cyan.
 
    {mdadmcab.i
        &Saida     = "i:\admcom\relat\depban.txt"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""depban_l""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    put "BANRISUL          BB          CEF         BCN" at 40 skip
        fill("-",130) format "x(130)" skip.
    for each depban where depban.datexp >= vdti and
                          depban.datexp <= vdtf no-lock break by depban.etbcod
                                                              by depban.datexp
                                                              by depban.dephor:

        if first-of(depban.etbcod)
        then do:
            put "Filial " depban.etbcod.
        end.
        put depban.datexp format "99/99/9999" at 15
            "  "
            string(depban.dephora,"HH:MM").
        
        if bancod = 19
        then put depban.valdep format "->>,>>9.99" at 38 skip.
        
        if bancod = 27
        then put depban.valdep format "->>,>>9.99" at 50 skip.
        
        if bancod = 35
        then put depban.valdep format "->>,>>9.99" at 63 skip.
        

        if bancod = 191
        then put depban.valdep format "->>,>>9.99" at 74 skip.
        find first tt-banco where tt-banco.bancod = depban.bancod no-error.
        if not avail tt-banco
        then do:
            create tt-banco.
            assign tt-banco.bancod = depban.bancod.
        end.
        assign tt-banco.tt-val = tt-banco.tt-val + depban.valdep.

    end.

    put fill("-",130) format "x(130)" skip.
    put "Totais ............................".
    for each tt-banco no-lock by tt-banco.bancod:
        put tt-banco.tt-val format ">,>>>,>>9.99".
    end.
    put skip fill("-",130) format "x(130)" skip.
 
    output close.
    dos silent type i:\admcom\relat\depban.txt > prn.
    hide frame ffff no-pause.

end.
