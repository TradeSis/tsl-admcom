        {mdadmcab.i
            &Saida     = "i:\admcom\relat\dep2.txt"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""dep2.i""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"") + "" ATE "" +
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame dep2"}
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
    vdep =  "   FILIAIS         CHEQUE DIA   CH.PRE DRE   CH.PRE GLO  " + 
            " PAGAMENTOS". 
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
            then assign wfban.vdep[i] = wfban.vdep[i] + deposito.depdep
                        wfban.vdia    = wfban.vdia + deposito.chedia
                        wfban.vdre    = wfban.vdre + deposito.chedre
                        wfban.vglo    = wfban.vglo + deposito.cheglo
                        wfban.vpag    = wfban.vpag + deposito.deppag.
            find first wtot where wtot.bancod = 1 /* depfil.bancod */ no-error.
            if not avail wtot
            then do:
                create wtot.
                assign wtot.bancod = depfil.bancod.
            end.
            wtot.wdep = wtot.wdep + deposito.depdep.
            wtot.wpag = wtot.wpag + deposito.deppag.
            wtot.wdre = wtot.wdre + deposito.chedre.
            wtot.wglo = wtot.wglo + deposito.cheglo.
            wtot.wdia = wtot.wdia + deposito.chedia.
        end.
    end.
    find first wtot no-lock no-error.
    if not avail wtot
    then do:
        message "Nao tem nenhum deposito neste dia".
        undo, retry.
    end.
   
    for each wfban by wfban.etb:
        put "Filial"
             wfban.etb space(6).
        put wfban.vdia  format ">>,>>>,>>9.99" 
            wfban.vdre  format ">>,>>>,>>9.99" 
            wfban.vglo  format ">>,>>>,>>9.99" 
            wfban.vpag  format ">>,>>>,>>9.99" skip.
    end.
    i = 0.
    put skip fill("-",130) format "x(130)" skip.
    
    put "TOTAIS..........".

    assign vdia = 0 
           vdre = 0
           vglo = 0
           vpag = 0.
           
    for each wtot:
        assign vdia = vdia + wtot.wdia
               vdre = vdre + wtot.wdre
               vglo = vglo + wtot.wglo
               vpag = vpag + wtot.wpag.
    end.

            
    
    put vdia format ">>,>>>,>>9.99"
        vdre format ">>,>>>,>>9.99"
        vglo format ">>,>>>,>>9.99"
        vpag format ">>,>>>,>>9.99".

    put skip fill("-",130) format "x(130)" skip.
    
    
    output close.
    hide frame ffff no-pause.
    display " Para sair da tela digitar : [f3] [Q] [Y] " 
                        with frame ffff centered row 15. pause.
    dos silent ved i:\admcom\relat\dep2.txt.
    hide frame ffff no-pause.

