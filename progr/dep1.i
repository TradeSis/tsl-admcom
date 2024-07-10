
    {mdadmcab.i
         &Saida     = "i:\admcom\relat\dep1.txt"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""reldep""
         &Nom-Sis   = """SISTEMA DE ESTOQUE"""
         &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"") + "" ATE "" +
                          string(vdtf,""99/99/9999"")"
         &Width     = "130"
         &Form      = "frame dep1"}
    
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
    vdep =  "                    BANRISUL          BB         CEF" +
            "         BCN". 
    put vdep.  
    put skip.
    put fill("-",130) format "x(130)" skip.

    i = 0.
    for each wfban no-lock break by wfban.ban:
        if first-of(wfban.ban)
        then i = i + 1.
        for each deposito where deposito.etbcod = wfban.etb and
                                deposito.datmov >= vdti     and
                                deposito.datmov <= vdtf no-lock:

            find first depfil where depfil.etbcod = wfban.etb and
                                    depfil.bancod = wfban.ban no-lock no-error.
            if avail depfil
            then assign wfban.vdep[i] = wfban.vdep[i] + deposito.depdep.
            find first wtot where wtot.bancod = depfil.bancod no-error.
            if not avail wtot
            then do:
                create wtot.
                assign wtot.bancod = depfil.bancod.
            end.
            wtot.wdep = wtot.wdep + deposito.depdep.
        end.
    end.

    for each wfban by wfban.etb:
        put "Filial"
             wfban.etb space(6).
        x = 0.
        do x = 1 to i:
            put wfban.vdep[x].
        end.
        put skip.
    end.
    i = 0.
    put skip fill("-",130) format "x(130)" skip.
    put "TOTAIS..........".
    for each wtot by wtot.bancod:
        put wtot.wdep.
    end.

    put skip fill("-",130) format "x(130)" skip.
    output close.
    hide frame ffff no-pause.
    display " Para sair da tela digitar : [f3] [Q] [Y] " 
                    with frame ffff centered row 15. pause.
    dos silent ved i:\admcom\relat\dep1.txt.
    hide frame ffff no-pause.

