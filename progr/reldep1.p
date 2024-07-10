{admcab.i}  /******** novo reldep.p ***********/


def var vimp as char format "x(20)" 
            extent 2 initial ["Consulta","Relatorio"]. 


def var vcon as char format "x(08)" 
            extent 2 initial ["Deposito","Cheque"]. 

def var varquivo as char.

 def var vdia as dec format ">>,>>>,>>9.99".
 def var vdre as dec format ">>,>>>,>>9.99".
 def var vglo as dec format ">>,>>>,>>9.99".
 def var vpag as dec format ">>,>>>,>>9.99".

 

def var i as i.
def var x as i.
def var vdep    as char format "x(130)".
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
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

    update vdti label "Data Inicial"
           vdtf label "Data Finan"
            with frame f-dat centered width 80 side-label
                        color blue/cyan.
    /*
    display vimp no-label with frame fimp.
    choose field vimp with frame fimp  centered.

    
    if frame-index = 1
    then do:

        display vcon no-label with frame fcon.
        choose field vcon with frame fcon  centered.

        if frame-index = 1
        then do:
            {dep1.i}
            undo, retry.
        end.
        else do:
            {dep2.i}
            undo, retry.
        end.
    end.
    */
    if opsys = "unix"
    then varquivo = "/admcom/relat/reldep" + string(time).
    else varquivo = "..\relat\reldep" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "132"
            &Page-Line = "66"
            &Nom-Rel   = ""reldep1""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "132"
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
    vdep =  "                    BANRISUL          BB         CEF" +
            "        HSBC         BCN" + 
            "       CHEQUE DIA   CH.PRE DRE   PAGAMENTOS             ".
    put vdep.  
    put skip.
    put fill("-",132) format "x(132)" skip.

    i = 0.
    for each wfban no-lock break by wfban.ban:
        if first-of(wfban.ban)
        then i = i + 1.
        
        find first wtot where wtot.bancod = wfban.ban no-error.
        if not avail wtot
        then do:
            create wtot.
            assign wtot.bancod = wfban.ban.
        end.

        for each deposito where deposito.etbcod = wfban.etb and
                                deposito.datmov >= vdti     and
                                deposito.datmov <= vdtf no-lock.

            find first depfil where depfil.etbcod = wfban.etb and
                                    depfil.bancod = wfban.ban no-lock no-error.
            if avail depfil
            then assign wfban.vdep[i] = wfban.vdep[i] + deposito.depdep
                        wfban.vdia    = wfban.vdia + deposito.chedia
                        wfban.vdre    = wfban.vdre + deposito.chedre
                        wfban.vglo    = wfban.vglo + deposito.cheglo
                        wfban.vpag    = wfban.vpag + deposito.deppag.
            
            wtot.wdep = wtot.wdep + deposito.depdep.
            wtot.wpag = wtot.wpag + deposito.deppag.
            wtot.wdre = wtot.wdre + deposito.chedre.
            wtot.wglo = wtot.wglo + deposito.cheglo.
            wtot.wdia = wtot.wdia + deposito.chedia.
            
        end.
    end.
    find first wtot no-error.
    if not avail wtot
    then do:
        message "Nao existe nenhum deposito neste dia".
        undo, retry.
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
            /* wfban.vglo  format ">>,>>>,>>9.99" */
            wfban.vpag  format ">>,>>>,>>9.99" skip.
    end.
    
    i = 0.
    put skip fill("-",132) format "x(132)" skip.
    put "TOTAIS..........".

    for each wtot by wtot.bancod:

        put wtot.wdep format "zz,zzz,zz9.99".
    
    end.
    
    
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

            
    
    put vdia format ">>>,>>>,>>9.99" to 93 
        vdre format ">>>,>>>,>>9.99" to 106
        /* vglo format ">>>,>>>,>>9.99" to 119 */
        vpag format ">>>,>>>,>>9.99" to 119.


    put skip fill("-",132) format "x(132)" skip.
    output close.
    
    if opsys = "unix"
    then run visurel.p (input varquivo, input "").
    else {mrod.i} .
    
    hide frame ffff no-pause.

end.
