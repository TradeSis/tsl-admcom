{admcab.i}
def var vimp as char format "x(20)" 
            extent 2 initial ["Consulta","Relatorio"]. 
def var i as i.
def var x as i.
def var vdep    as char format "x(130)".
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def temp-table wfban
    field etb  like depfil.etbcod
    field ban  like depfil.bancod
    field vdep like plani.platot extent 10
    field vdre like plani.platot
    field vglo like plani.platot
    field vdia like plani.platot
    field vpag like plani.platot
    field ord  as i.

def temp-table wtot
    field wdep like plani.platot
    field wdia like plani.platot
    field wdre like plani.platot
    field wglo like plani.platot
    field wpag like plani.platot
    field bancod like depfil.bancod.
def buffer bdepfil for depfil.
repeat:
    i = 0.
    x = 0.
    for each wtot:
        delete wtot.
    end.
    for each wfban:
        delete wfban.
    end.

    update vdti label "Data Deposito"
            with frame f-dat centered width 80 side-label
                        color blue/cyan.

        {mdadmcab.i
            &Saida     = "i:\admcom\relat\reldep.txt"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""reldep""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}
    i = 0.
    vdep = "          ".
    for each depfil no-lock break by depfil.bancod:

        if first-of(depfil.bancod)
        then do:
            i = i + 1.
            find banco where banco.bancod = depfil.bancod no-lock no-error.
            if not avail banco
            then next.
            vdep = vdep + "          " + banco.banfan.
        end.

        create wfban.
        assign wfban.etb = depfil.etbcod.
               wfban.ban = depfil.bancod.
               wfban.ord = i.
    end.
    /*
    vdep = vdep + "     CHEQUE DIA   CH.PRE DRE   CH.PRE GLO   PAGAMENTOS".
    */
    vdep =  "                    BANRISUL          BB         CEF" +
            "         BCN" + 
            "       CHEQUE DIA   CH.PRE DRE   CH.PRE GLO   PAGAMENTOS".
    put vdep.  
    put skip.
    put fill("-",130) format "x(130)" skip.

    i = 0.
    for each wfban no-lock break by wfban.ban:
        if first-of(wfban.ban)
        then i = i + 1.
        find last plani where plani.etbcod = wfban.etb and
                              plani.movtdc = 5         and
                              plani.pladat = vdti      and
                              plani.seguro > 0 no-error.

        if not avail plani
        then next.
        find first depfil where depfil.etbcod = wfban.etb and
                                depfil.bancod = wfban.ban no-lock no-error.
        if avail depfil
        then assign wfban.vdep[i] = plani.seguro
                    wfban.vdia    = plani.iss
                    wfban.vdre    = plani.notpis
                    wfban.vglo    = plani.cusmed
                    wfban.vpag    = plani.notcofins.
        find first wtot where wtot.bancod = depfil.bancod no-error.
        if not avail wtot
        then do:
            create wtot.
            assign wtot.bancod = depfil.bancod.
        end.
        wtot.wdep = wtot.wdep + plani.seguro.
        wtot.wpag = wtot.wpag + plani.notcofins.
        wtot.wdre = wtot.wdre + plani.notpis.
        wtot.wglo = wtot.wglo + plani.cusmed.
        wtot.wdia = wtot.wdia + plani.iss.
    end.

    for each wfban by wfban.etb:
        put "Filial"
             wfban.etb space(6).
        x = 0.
        do x = 1 to i:
            put wfban.vdep[x].
        end.
        put "    "  
            wfban.vdia  format ">>,>>>,>>9.99" 
            wfban.vdre  format ">>,>>>,>>9.99" 
            wfban.vglo  format ">>,>>>,>>9.99" 
            wfban.vpag  format ">>,>>>,>>9.99" skip.
    end.
    i = 0.
    put skip fill("-",130) format "x(130)" skip.
    put "TOTAIS..........".
    for each wtot by wtot.bancod:
        put wtot.wdep.
    end.
    
    find first wtot no-lock.
    put "    " 
        wtot.wdia format ">>,>>>,>>9.99"
        wtot.wdre format ">>,>>>,>>9.99"
        wtot.wglo format ">>,>>>,>>9.99"
        wtot.wpag format ">>,>>>,>>9.99".

    put skip fill("-",130) format "x(130)" skip.
    output close.
    display vimp no-label with frame fimp.
    choose field vimp with frame fimp  centered.
     
    if frame-index = 1
    then do:
        display " Para sair da tela digitar : [f3] [Q] [Y] " 
                        with frame ffff centered row 15. pause.
        dos silent ved i:\admcom\relat\reldep.txt.
    end.
    else dos silent type i:\admcom\relat\reldep.txt > prn.
    hide frame ffff no-pause.

end.
