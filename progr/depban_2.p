{admcab.i}   /******** novo reldep.p ***********/


def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vtot    as dec.
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
        &Nom-Rel   = ""depban_2""
        &Nom-Sis   = """SISTEMA DE CREDIARIO"""
        &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}

    put "            DEPOSITO     DATA DEP.   HORA       " 
         "BANRISUL          BB         CEF         BCN          DIFERENCA" skip
        fill("-",130) format "x(130)" skip.
    for each depban where depban.datmov >= vdti and
                          depban.datmov <= vdtf no-lock break by depban.etbcod
                                                              by depban.datmov
                                                              by depban.datexp
                                                              by depban.dephor:

        if first-of(depban.etbcod)
        then put "Filial " depban.etbcod. 
        if first-of(depban.datmov)
        then do:
            find deposito where deposito.etbcod = depban.etbcod and
                                deposito.datmov = depban.datmov no-lock.
        
            put deposito.depdep format ">,>>>,>>9.99" at 09.
        end.

        vtot = vtot + depban.valdep.

        
        
        put depban.datexp format "99/99/9999" at 25
            "  "
            string(depban.dephora,"HH:MM").
        
        if bancod = 19
        then put depban.valdep format ">,>>>,>>9.99" at 45 skip.
        
        if bancod = 27
        then put depban.valdep format ">,>>>,>>9.99" at 57 skip.
        
        if bancod = 35
        then put depban.valdep format ">,>>>,>>9.99" at 69 skip.
        

        if bancod = 191
        then put depban.valdep format ">,>>>,>>9.99" at 81 skip.
 
        if last-of(depban.datmov)
        then do:

            find deposito where deposito.etbcod = depban.etbcod and
                                deposito.datmov = depban.datmov no-lock.
            
            put (vtot - deposito.depdep) format "->,>>>,>>9.99" at 99 skip.
            vtot = 0.
        end.

        
        
        find first tt-banco where tt-banco.bancod = depban.bancod no-error.
        if not avail tt-banco
        then do:
            create tt-banco.
            assign tt-banco.bancod = depban.bancod.
        end.
        assign tt-banco.tt-val = tt-banco.tt-val + depban.valdep.

    end.

    put fill("-",130) format "x(130)" skip.
    put "Totais .....................................".
    for each tt-banco no-lock by tt-banco.bancod:
        put tt-banco.tt-val format ">,>>>,>>9.99".
    end.
    put skip fill("-",130) format "x(130)" skip.
 
    output close.
    dos silent type i:\admcom\relat\depban.txt > prn.  
    hide frame ffff no-pause.

end.
