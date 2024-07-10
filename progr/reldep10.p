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
def temp-table tt-banco like banco
    field seq as int.
def temp-table wfban
    field etb  like depfil.etbcod
    field ban  like depfil.bancod
    field vdep like plani.platot extent 11
    field vdre like plani.platot
    field vglo like plani.platot
    field vdia like plani.platot
    field vpag like plani.platot
    field ord  as i
    field num  like banco.numban.

def temp-table wtot
    field wdep like plani.platot
    field wdia like plani.platot
    field wdre like plani.platot
    field wglo like plani.platot
    field wpag like plani.platot
    field bancod like depfil.bancod
    field num like banco.numban
    field ord as int.
    
def var vtot as dec.
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

    def var w-width as int.
    w-width = 160.
    if opsys = "unix"
    then varquivo = "/admcom/relat/reldep" + string(time).
    else varquivo = "..\relat\reldep" + string(time).

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = w-width
            &Page-Line = "66"
            &Nom-Rel   = ""reldep1""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """RELATORIO DE DEPOSITOS FILIAL - "" + "" "" +
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = w-width
            &Form      = "frame f-cabcab"}
    i = 0.
    for each tt-banco. delete tt-banco. end.
    vdep = "                ".
    for each banco where
             banco.situacao no-lock
             by banco.numban:
        vdep = vdep + "          " + string(banco.numban,"999").
        i = i + 1.
        create tt-banco.
        buffer-copy banco to tt-banco.
        tt-banco.seq = i.

        create wtot.
        assign wtot.bancod = banco.banco
               wtot.num    = banco.numban
               wtot.ord    = i.

    end.
                 
    vdep = vdep +  "        TOTAL   CHEQUE DIA  CHE.PRE DRE    ".
    w-width = length(vdep).
    

    for each depfil no-lock break by depfil.bancod:

        find first tt-banco where tt-banco.bancod = depfil.bancod and
                         tt-banco.situacao no-lock no-error.
        if not avail tt-banco then next.
        
        create wfban.
        assign wfban.etb = depfil.etbcod
               wfban.ban = depfil.bancod
               wfban.num = tt-banco.numban
               wfban.ord = tt-banco.seq
               .
    end.
    
    put vdep format "x(160)".  
    put skip.
    put fill("-",160) format "x(160)" skip.

    for each wfban no-lock break by wfban.num:

        find first wtot where wtot.bancod = wfban.ban no-error.
        if not avail wtot
        then do:
            create wtot.
            assign wtot.bancod = wfban.ban
                   wtot.num    = wfban.num
                   wtot.ord    = wfban.ord.
        end.

        i = wfban.ord.
        
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
        vtot = 0.
        do x = 1 to i:
            put wfban.vdep[x] format ">>,>>>,>>9.99".
            vtot = vtot + wfban.vdep[x].
        end.
        
        put vtot format ">>,>>>,>>9.99"  
            wfban.vdia  format ">>,>>>,>>9.99" 
            wfban.vdre  format ">>,>>>,>>9.99" 
            /* wfban.vglo  format ">>,>>>,>>9.99" */
            /*wfban.vpag  format ">>,>>>,>>9.99"*/
            .
        put skip.
    end.
    
    i = 0.
    put skip fill("-",160) format "x(160)" skip.
    put "TOTAIS..........".

    vtot = 0.
    for each wtot where wtot.ord > 0 by wtot.num:

        put wtot.wdep format "zz,zzz,zz9.99" .
        vtot = vtot + wtot.wdep.
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

            
    
    put vtot format ">>,>>>,>>9.99" 
        vdia format ">>,>>>,>>9.99"  
        vdre format ">>,>>>,>>9.99" 
        /* vglo format ">>>,>>>,>>9.99" to 119 */
        /*vpag format ">>>,>>>,>>9.99" to 119*/.

    put skip.
    put "TOTAL GERAL..."   format "x(20)"
        vtot + vdia + vdre format ">>,>>>,>>9.99"
        skip.
        
    put skip fill("-",160) format "x(160)" skip.
    output close.
    
    if opsys = "unix"
    then run visurel.p (input varquivo, input "").
    
    hide frame ffff no-pause.

end.
