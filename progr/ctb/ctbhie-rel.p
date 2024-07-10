{admcab.i}

{/admcom/progr/ctb/extrato12-def.i new}

def temp-table tt-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual
    field est31-1 like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med31-1 like estoq.estatual
    field med35  like estoq.estatual.
 
def var vi as int.
def var vv as int.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vprodu like produ.procod.
def buffer bprodu for produ.
def var varquivo as char.
def var vindex as int.
def var vcusto like ctbhie.ctbcus.
def var tip-custo as char extent 2  FORMAT "x(20)"
        initial["CUSTO NOTA","CUSTO MEDIO"].
def var tipo-rel as char extent 4 FORMAT "x(17)"
        initial[" SINTETICO"," ANALITICO"," ANALITICO+MOV"," NEGATIVOS"].

def var vndx-rel as int.

def buffer bctbhie for ctbhie.

def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.

def var vtotal as dec format ">>>,>>>,>>9.99".

def var vindx-rel as int.

def var vsal_ant as dec.
def var vqtd_ent as dec.
def var vqtd_sai as dec.
def var vsal_atu as dec.

def temp-table tt-clase like clase.
run gera-ttclase.
def var vsetor as char format "x(15)".

def buffer btt-saldo for tt-saldo.
def var vsinal as char format "x".

repeat:

    for each tt-estoq: delete tt-estoq. end.
    
    update vetbi label "Filial Inicial"
           vetbf label "Filial Final"
           with frame f1 centered color blue/cyan side-labels
                    width 80.
        
    if vetbi = 0 or vetbf = 0 or
       vetbi > vetbf
    then undo.
    
    /*
    find last ctbhie where ctbhie.etbcod = vetbcod no-lock no-error.
    if avail ctbhie
    then assign
            vmes = ctbhie.ctbmes
            vano = ctbhie.ctbano
            .
    */
    
    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f1.
 
    vdata2 = date(if vmes = 12 then 01 else vmes + 1,01,
                  if vmes = 12 then vano + 1 else vano) - 1.
    vdata1 = date(month(vdata2),01,year(vdata2)).    
    
    vindex = 2.
    vindx-rel = 1.
    disp tipo-rel no-label with frame f-trel 1 down centered.
    choose field tipo-rel with frame f-trel.
    vindx-rel = frame-index.

    vprodu = 0.
    if vindx-rel = 3 /*or vindx-rel = 4*/
    then do:
        update vdata1 label "Periodo movimento"
               vdata2
               vprodu at 1
               with frame f-dd 1 down side-label width 80
               .
    end.
    
    {confir.i 1 "Listagem de inventario"}

    varquivo = "/admcom/relat/inv_" 
                    + lc(trim(tipo-rel[vindx-rel])) + "_"
                    + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + "." + string(time).
            
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = """."""
        &Nom-Sis   = """."""
        &Tit-Rel   = """SALDO DE ESTOQUE  "" + 
                        "" EM "" + string(vmes,""99"") +
                        ""/"" + string(vano,""9999"")"
        &Width     = "130"
        &Form      = "frame f-cab"}
        
    disp with frame f1.
    /*put tipo-rel[vindx-rel] skip.
      */
      
    pause 0.
    vtotal = 0.
    
    if vindx-rel = 3
    then do:
        disp with frame f-dd.
        
        def var vdocumento as log format "Sim/Nao".
        vdocumento = no.
        message "Por documento? " update vdocumento.
        if not vdocumento
        then do:

        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:
            vetbcod = estab.etbcod.
            if estab.etbcod = 22 then next.
            for each ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano  and
                          (if vprodu > 0 then ctbhie.procod = vprodu else true)
                          no-lock:
        
                /*if ctbhie.ctbest < 1
                then next.*/
                if ctbhie.ctbcus <= 0
                then next.
                find produ where produ.procod = ctbhie.procod no-lock no-error.
                if not avail produ
                then next.
                if ctbhie.ctbmed > 0
                then vcusto = ctbhie.ctbmed.
                else do:
                    vcusto = ctbhie.ctbcus.
                
                    find last bctbhie where
                        bctbhie.etbcod = 0 and
                        bctbhie.procod = produ.procod and
                        bctbhie.ctbano = vano and
                        bctbhie.ctbmes <= vmes 
                        no-lock no-error.
                    if not avail bctbhie
                    then do vi = 1 to 10:
                        find last bctbhie use-index ind-2 where
                             bctbhie.etbcod = 0 and
                             bctbhie.procod = produ.procod and
                             bctbhie.ctbano = vano - vi 
                             no-lock no-error.
                        if avail bctbhie
                        then do:
                            leave.
                        end.
                    end.     
                    if avail bctbhie and bctbhie.ctbcus <> ?
                    then vcusto = bctbhie.ctbcus.
                end.
                
                if vcusto = ?
                then vcusto = 0.      

                if vcusto = 0 then next.
                
                vtotal = vtotal + (vcusto * ctbhie.ctbest).
                
                vsetor = "".
                
                vsetor = "OUTROS".
                if produ.catcod = 31
                then do:
                    find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                    if avail tt-clase
                    then vsetor = "ELETRO".
                    else vsetor = "MOVEIS".
                end.
                else if produ.catcod = 41
                then vsetor = "MODA".
                
                for each tt-saldo: delete tt-saldo. end.
                for each tt-movest: delete tt-movest. end.
                sal-atu = 0.
                sal-ant = 0.
                vprocod = produ.procod.
                vdisp = no.
    
                if vetbcod = 981
                then run movest11-e.p.
                else run /admcom/progr/ctb/movest11.p. 

                /****
                find first tt-saldo where
                           tt-saldo.ano-cto = 0  and
                           tt-saldo.mes-cto = 0  and
                           tt-saldo.etbcod = estab.etbcod and
                           tt-saldo.procod = vprocod 
                           no-lock no-error.
                if avail tt-saldo
                then do:
                    find first btt-saldo where
                                        btt-saldo.ano-cto = 0  and
                                        btt-saldo.mes-cto = 0  and
                                        btt-saldo.etbcod = estab.etbcod and
                                        btt-saldo.procod = vprocod
                                        no-lock no-error.
                    if not avail btt-saldo
                    then do:
                        create btt-saldo.
                        buffer-copy tt-saldo to btt-saldo.
                    end.
                end. 
                ***********/
                   
                if vetbcod = 900 or
                   vetbcod = 995
                then do:
                    for each tabaux where
                             tabaux.tabela = "DEPOSITO_VIRTUAL" and
                             tabaux.nome_campo = "DEPOSITO_" + 
                                                  STRING(VETBCOd,"999")
                             NO-LOCK:
             
                        vetbcod = int(valor_campo).                                                    if vetbcod = 981
                        then run movest11-e.p.
                        else run /admcom/progr/ctb/movest11.p.
                        
                        /******
                        find first tt-saldo where
                                tt-saldo.ano-cto = 0  and
                                tt-saldo.mes-cto = 0  and
                                tt-saldo.etbcod = vetbcod and
                                tt-saldo.procod = vprocod 
                                no-lock no-error.
                        if avail tt-saldo
                        then do:
                            find first btt-saldo where
                                        btt-saldo.ano-cto = 0  and
                                        btt-saldo.mes-cto = 0  and
                                        btt-saldo.etbcod = estab.etbcod and
                                        btt-saldo.procod = vprocod
                                        no-lock no-error.
                            if not avail btt-saldo
                            then do:
                                create btt-saldo.
                                assign
                                    btt-saldo.ano-cto = 0
                                    btt-saldo.mes-cto = 0
                                    btt-saldo.etbcod  = estab.etbcod
                                    btt-saldo.procod  = vprocod
                                    btt-saldo.sal-ant = tt-saldo.sal-ant
                                    btt-saldo.sal-atu = tt-saldo.sal-atu
                                    .
                            end.
                            else assign
                                    btt-saldo.sal-ant =
                                        btt-saldo.sal-ant + tt-saldo.sal-ant
                                    btt-saldo.sal-atu = 
                                        btt-saldo.sal-atu  + tt-saldo.sal-atu
                                    btt-saldo.qtd-ent =
                                        btt-saldo.qtd-ent + tt-saldo.qtd-ent
                                    btt-saldo.qtd-sai =
                                        btt-saldo.qtd-sai + tt-saldo.qtd-sai
                                    .    
                                        
                        end.
                        ********/
                    end.
                end.   
                vetbcod = estab.etbcod.
                
                /***********
                find first btt-saldo where
                       btt-saldo.ano-cto = 0  and
                        btt-saldo.mes-cto = 0  and
                        btt-saldo.etbcod = estab.etbcod and
                        btt-saldo.procod = vprocod 
                      no-lock no-error.
                if not avail btt-saldo
                then do:
                    create btt-saldo.
                    assign
                        btt-saldo.ano-cto = 0
                        btt-saldo.mes-cto = 0
                        btt-saldo.etbcod = estab.etbcod
                        btt-saldo.procod = vprocod
                        btt-saldo.sal-ant = ctbhie.ctbest
                        btt-saldo.sal-atu = ctbhie.ctbest
                        .
                end.
                **********/
                vsal_ant = 0.
                vqtd_ent = 0.
                vqtd_sai = 0.
                vsal_atu = 0.
                for each tt-saldo where 
                         tt-saldo.ano-cto = 0 and
                         tt-saldo.mes-cto = 0:
                    vsal_ant = vsal_ant + tt-saldo.sal-ant.
                    vqtd_ent = vqtd_ent + tt-saldo.qtd-ent.
                    vqtd_sai = vqtd_sai + tt-saldo.qtd-sai.
                    vsal_atu = vsal_atu + tt-saldo.sal-atu.

                end.

                display 
                    estab.etbcod column-label "Fil"
                    produ.procod column-label "Codigo" 
                    produ.pronom FORMAT "x(50)"
                    vsetor       column-label "Grupo"
                    ctbhie.ctbest format ">>>>>>9"
                    vcusto column-label "Pc.Custo" format ">>,>>9.99"
                    (vcusto * ctbhie.ctbest)(total)
                        column-label "Subtotal" format ">>,>>>,>>9.99"
                    vsal_ant column-label "Aterior"
                    vqtd_ent column-label "Entradas"
                    vqtd_sai column-label "Saidas"
                    vsal_atu column-label "Atual"
                    
                    /*
                    btt-saldo.sal-ant when avail btt-saldo    
                    btt-saldo.qtd-ent when avail btt-saldo
                    btt-saldo.qtd-sai when avail btt-saldo
                    btt-saldo.sal-atu when avail btt-saldo
                    */
                    with frame f3 down width 200.
                down with frame f3.
                
            end.
        end.
        end.
        else do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:
            vetbcod = estab.etbcod.
            if estab.etbcod = 22 then next.
            for each ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano and  
                          (if vprodu > 0 then ctbhie.procod = vprodu else true)
                           no-lock:
        
                /*if ctbhie.ctbest < 1
                then next.*/
                if ctbhie.ctbcus <= 0
                then next.
                find produ where produ.procod = ctbhie.procod no-lock no-error.
                if not avail produ
                then next.
        
                if ctbhie.ctbmed > 0
                then vcusto = ctbhie.ctbmed.
                else do:
                    vcusto = ctbhie.ctbcus.
                
                    find last bctbhie where
                        bctbhie.etbcod = 0 and
                        bctbhie.procod = produ.procod and
                        bctbhie.ctbano = vano and
                        bctbhie.ctbmes <= vmes 
                        no-lock no-error.
                    if not avail bctbhie
                    then do vi = 1 to 10:
                        find last bctbhie use-index ind-2 where
                             bctbhie.etbcod = 0 and
                             bctbhie.procod = produ.procod and
                             bctbhie.ctbano = vano - vi 
                             no-lock no-error.
                        if avail bctbhie
                        then do:
                            leave.
                        end.
                    end.     
                    if avail bctbhie and bctbhie.ctbcus <> ?
                    then vcusto = bctbhie.ctbcus.
                end.
                
                if vcusto = ?
                then vcusto = 0.      

                if vcusto = 0 then next.
                
                vtotal = vtotal + (vcusto * ctbhie.ctbest).
                
                vsetor = "".
                
                vsetor = "OUTROS".
                if produ.catcod = 31
                then do:
                    find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                    if avail tt-clase
                    then vsetor = "ELETRO".
                    else vsetor = "MOVEIS".
                end.
                else if produ.catcod = 41
                then vsetor = "MODA".
                
                for each tt-saldo: delete tt-saldo. end.
                for each tt-movest: delete tt-movest. end.
                sal-atu = 0.
                sal-ant = 0.
                vprocod = produ.procod.
                vdisp = no.
    
                if vetbcod = 981
                then run movest11-e.p.
                else run /admcom/progr/ctb/movest11.p.
    
                if vetbcod = 900 or
                   vetbcod = 995
                then do:
                    for each tabaux where
                             tabaux.tabela = "DEPOSITO_VIRTUAL" and
                             tabaux.nome_campo = "DEPOSITO_" + 
                                                  STRING(VETBCOd,"999")
                             NO-LOCK:
             
                        vetbcod = int(valor_campo).                                                    if vetbcod = 981
                        then run movest11-e.p.
                        else run /admcom/progr/ctb/movest11.p.
                        
                        /*******
                        find first tt-saldo where
                                tt-saldo.ano-cto = 0  and
                                tt-saldo.mes-cto = 0  and
                                tt-saldo.etbcod = vetbcod and
                                tt-saldo.procod = vprocod 
                                no-lock no-error.
                        if avail tt-saldo
                        then do:
                            find first btt-saldo where
                                        btt-saldo.ano-cto = 0  and
                                        btt-saldo.mes-cto = 0  and
                                        btt-saldo.etbcod = estab.etbcod and
                                        btt-saldo.procod = vprocod
                                        no-lock no-error.
                            if not avail btt-saldo
                            then do:
                                create btt-saldo.
                                assign
                                    btt-saldo.ano-cto = 0
                                    btt-saldo.mes-cto = 0
                                    btt-saldo.etbcod  = estab.etbcod
                                    btt-saldo.procod  = vprocod
                                    btt-saldo.sal-ant = tt-saldo.sal-ant
                                    btt-saldo.sal-atu = tt-saldo.sal-atu
                                    .
                            end.
                            else assign
                                    btt-saldo.sal-ant =
                                        btt-saldo.sal-ant + tt-saldo.sal-ant
                                    btt-saldo.sal-atu = 
                                        btt-saldo.sal-atu  + tt-saldo.sal-atu
                                    btt-saldo.qtd-ent =
                                        btt-saldo.qtd-ent + tt-saldo.qtd-ent
                                    btt-saldo.qtd-sai =
                                        btt-saldo.qtd-sai + tt-saldo.qtd-sai
                                    .    
                                        
                        end.
                        **********/
                    end.
                end. 
                vetbcod = estab.etbcod.
                /*
                find first tt-saldo where
                       tt-saldo.ano-cto = 0  and
                        tt-saldo.mes-cto = 0  and
                        tt-saldo.etbcod = vetbcod and
                        tt-saldo.procod = vprocod 
                      no-lock no-error.
                if not avail tt-saldo
                then do:
                    create tt-saldo.
                    assign
                        tt-saldo.ano-cto = 0
                        tt-saldo.mes-cto = 0
                        tt-saldo.etbcod = vetbcod
                        tt-saldo.procod = vprocod
                        tt-saldo.sal-ant = ctbhie.ctbest
                        tt-saldo.sal-atu = ctbhie.ctbest
                        .
                end.
                */
                vsal_ant = 0.
                for each tt-saldo where 
                         tt-saldo.ano-cto = 0 and
                         tt-saldo.mes-cto = 0:
                    vsal_ant = vsal_ant + tt-saldo.sal-ant.
                end.
                    
                display 
                    estab.etbcod column-label "Fil"
                    produ.procod column-label "Codigo" 
                    produ.pronom FORMAT "x(50)"
                    vsetor       column-label "Grupo"
                    vsal_ant     
                    with frame fm3 down width 200.
 
                for each extrato-movim: delete extrato-movim. end.
                
                run e-movim.

                for each extrato-movim where
                         /*extrato-movim.etbcod = vetbcod and*/
                         extrato-movim.procod = vprocod
                         no-lock:
                    if extrato-movim.qtd-ent > 0
                    then vsinal = "+".
                    else if extrato-movim.qtd-sai > 0
                        then vsinal = "-".
                    disp         
                         vsinal no-label
                         extrato-movim.data
                         extrato-movim.tipmov
                         extrato-movim.numero
                         extrato-movim.serie
                         extrato-movim.emite
                         extrato-movim.desti format ">>>>>>>>>9"
                         extrato-movim.movqtm
                         extrato-movim.movpc
                         extrato-movim.sal-atu
                         with frame fm3.
                         .
                    down with frame fm3.
                end.         
                down with frame fm3.
 
                 /*****************
                for each tt-movest where
                         /*tt-movest.etbcod = vetbcod and*/
                         tt-movest.procod = vprocod
                         no-lock:
                    disp         
                         tt-movest.data
                         tt-movest.movtnom
                         tt-movest.numero
                         tt-movest.serie
                         tt-movest.emite
                         tt-movest.desti format ">>>>>>>>>9"
                         tt-movest.movqtm
                         tt-movest.movpc
                         tt-movest.sal-atu
                         with frame fm3.
                         .
                    down with frame fm3.
                end.         
                down with frame fm3.
                ************/
            end.
        end.   
        end.
        put skip(1) "TOTAL GERAL: " vtotal skip.
          
    end.
    if vindx-rel = 2
    then do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:

            if estab.etbcod = 22 then next.
            for each ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock:
        
                /*if ctbhie.ctbest < 1
                then next.*/
                if ctbhie.ctbcus <= 0
                then next.
                find produ where produ.procod = ctbhie.procod no-lock no-error.
                if not avail produ
                then next.
                if ctbhie.ctbmed > 0
                then vcusto = ctbhie.ctbmed.
                else do:
                    vcusto = ctbhie.ctbcus.
                
                    find last bctbhie where
                        bctbhie.etbcod = 0 and
                        bctbhie.procod = produ.procod and
                        bctbhie.ctbano = vano and
                        bctbhie.ctbmes <= vmes 
                        no-lock no-error.
                    if not avail bctbhie
                    then do vi = 1 to 10:
                        find last bctbhie use-index ind-2 where
                             bctbhie.etbcod = 0 and
                             bctbhie.procod = produ.procod and
                             bctbhie.ctbano = vano - vi 
                             no-lock no-error.
                        if avail bctbhie
                        then do:
                            leave.
                        end.
                    end.     
                    if avail bctbhie and bctbhie.ctbcus <> ?
                    then vcusto = bctbhie.ctbcus.
                end.
                
                if vcusto = ?
                then vcusto = 0.      

                if vcusto = 0 then next.
                
                vtotal = vtotal + (vcusto * ctbhie.ctbest).
                
                vsetor = "".
                
                vsetor = "OUTROS".
                if produ.catcod = 31
                then do:
                    find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                    if avail tt-clase
                    then vsetor = "ELETRO".
                    else vsetor = "MOVEIS".
                end.
                else if produ.catcod = 41
                then vsetor = "MODA".
                
                display 
                    estab.etbcod column-label "Fil"
                    produ.procod column-label "Codigo" 
                    produ.pronom FORMAT "x(50)"
                    vsetor       column-label "Grupo"
                    ctbhie.ctbest format ">>>>>>9"
                    vcusto column-label "Pc.Custo" format ">>,>>9.99"
                    (vcusto * ctbhie.ctbest)(total)
                        column-label "Subtotal" format ">>,>>>,>>9.99"
                    with frame f2 down width 130.
                down with frame f2.
            end.
        end.  
        put skip(1) "TOTAL GERAL: " vtotal skip.
          
    end.
    else if vindx-rel = 1
    then do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:
                                 
        if estab.etbcod = 22 then next.
        
        for each ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock:
        
            /*if ctbhie.ctbest < 1
            then next.*/
            if ctbhie.ctbcus <= 0
            then next.
            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then next.
            if ctbhie.ctbmed > 0
            then vcusto = ctbhie.ctbmed.
            else do:
                vcusto = ctbhie.ctbcus.

                find last bctbhie where
                     bctbhie.etbcod = 0 and
                     bctbhie.procod = produ.procod and
                     bctbhie.ctbano = vano and
                     bctbhie.ctbmes <= vmes 
                     no-lock no-error.
                if not avail bctbhie
                then do vi = 1 to 10:
                    find last bctbhie use-index ind-2 where
                         bctbhie.etbcod = 0 and
                         bctbhie.procod = produ.procod and
                         bctbhie.ctbano = vano - vi 
                         no-lock no-error.
                    if avail bctbhie
                    then do:
                        leave.
                    end.
                end.     
                if avail bctbhie and bctbhie.ctbcus <> ?
                then vcusto = bctbhie.ctbcus.
                /*else vcusto = 0. */
            end.
            if vcusto = ?
            then vcusto = 0.
            if vcusto = 0 then next.
            
            find first tt-estoq where tt-estoq.etbcod = ctbhie.etbcod no-error.
            if not avail tt-estoq
            then do:
                create  tt-estoq.
                assign  tt-estoq.etbcod = ctbhie.etbcod.
            end.
            
            if produ.catcod = 31
            then do:
                find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                if avail tt-clase
                then assign
                    tt-estoq.est31-1 = tt-estoq.est31-1 
                                        + (vcusto * ctbhie.ctbest)
                    tt-estoq.med31-1 = tt-estoq.med31-1 
                                        + (vcusto * ctbhie.ctbest)
                    .
                else assign
                    tt-estoq.est31 = tt-estoq.est31 + (vcusto * ctbhie.ctbest)
                    tt-estoq.med31 = tt-estoq.med31 + (vcusto * ctbhie.ctbest)
                    .      
            end.                           
            if produ.catcod = 41
            then assign
                    tt-estoq.est41 = tt-estoq.est41 + (vcusto * ctbhie.ctbest)
                    tt-estoq.med41 = tt-estoq.med41 + (vcusto * ctbhie.ctbest)
                    .

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then assign
                    tt-estoq.est35 = tt-estoq.est35 + (vcusto * ctbhie.ctbest)
                    tt-estoq.med35 = tt-estoq.med35 + (vcusto * ctbhie.ctbest)
                    .
        end.
        end.

    for each tt-estoq by tt-estoq.etbcod:
        disp "Filial - " 
             tt-estoq.etbcod column-label "Filial" 
             tt-estoq.med31(total) column-label "CtoMedio Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med31-1(total) column-label "CtoMedio Eletro"
                                             format "->>,>>>,>>9.99"
             tt-estoq.med41(total) column-label "CtoMedio Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med35(total) column-label "CtoMedio Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.med31 + tt-estoq.med31-1 +
                tt-estoq.med41 + tt-estoq.med35)(total) 
                            column-label "CtoMedio Total" 
                         format "->>,>>>,>>9.99"                
             with frame f-imp width 130 down.
 
    end.
    end.

    if vindx-rel = 4 /*Negativos*/
    then do:

        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:
            vetbcod = estab.etbcod.
            if estab.etbcod = 22 then next.
            for each hiest where hiest.etbcod = estab.etbcod and
                          hiest.hiemes = vmes    and
                          hiest.hieano = vano    and
                          hiest.hiestf < 0 no-lock:
        
                find produ where produ.procod = hiest.procod no-lock no-error.
                if not avail produ
                then next.

                vcusto = hiest.hiepcf.
                
                find last bctbhie where
                        bctbhie.etbcod = 0 and
                        bctbhie.procod = produ.procod and
                        bctbhie.ctbano = vano and
                        bctbhie.ctbmes <= vmes 
                        no-lock no-error.
                if not avail bctbhie
                then do vi = 1 to 10:
                        find last bctbhie use-index ind-2 where
                             bctbhie.etbcod = 0 and
                             bctbhie.procod = produ.procod and
                             bctbhie.ctbano = vano - vi 
                             no-lock no-error.
                        if avail bctbhie
                        then do:
                            leave.
                        end.
                end.     
                if avail bctbhie and bctbhie.ctbcus <> ?
                then vcusto = bctbhie.ctbcus.
                else vcusto = 0.
                
                if vcusto = ?
                then vcusto = 0.      

                if vcusto = 0 then next.
                
                vtotal = vtotal + (vcusto * hiest.hiestf).
                
                vsetor = "".
                
                vsetor = "OUTROS".
                if produ.catcod = 31
                then do:
                    find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                    if avail tt-clase
                    then vsetor = "ELETRO".
                    else vsetor = "MOVEIS".
                end.
                else if produ.catcod = 41
                then vsetor = "MODA".
                
                for each tt-saldo: delete tt-saldo. end.
                for each tt-movest: delete tt-movest. end.
                sal-atu = 0.
                sal-ant = 0.
                vprocod = produ.procod.
                vdisp = no.
                /*
                if vetbcod = 981
                then run movest11-e.p.
                else run /admcom/progr/ctb/movest11.p.
    
                find first tt-saldo where
                       tt-saldo.ano-cto = 0  and
                        tt-saldo.mes-cto = 0  and
                        tt-saldo.etbcod = vetbcod and
                        tt-saldo.procod = vprocod 
                      no-lock no-error.
                if not avail tt-saldo
                then do:
                    create tt-saldo.
                    assign
                        tt-saldo.ano-cto = 0
                        tt-saldo.mes-cto = 0
                        tt-saldo.etbcod = vetbcod
                        tt-saldo.procod = vprocod
                        tt-saldo.sal-ant = hiest.hiestf
                        tt-saldo.sal-atu = hiest.hiestf
                        .
                end.
                */
                display 
                    estab.etbcod column-label "Fil"
                    produ.procod column-label "Codigo" 
                    produ.pronom FORMAT "x(50)"
                    vsetor       column-label "Grupo"
                    hiest.hiestf format "->>>>>>9"
                    vcusto column-label "Pc.Custo" format "->>,>>9.99"
                    (vcusto * hiest.hiestf)(total)
                        column-label "Subtotal" format "->>,>>>,>>9.99"
                    /*tt-saldo.sal-ant when avail tt-saldo    
                    tt-saldo.qtd-ent when avail tt-saldo
                    tt-saldo.qtd-sai when avail tt-saldo
                    tt-saldo.sal-atu when avail tt-saldo
                    */
                    with frame fn3 down width 200.
                down with frame fn3.
            end.
        end.  
        put skip(1) "TOTAL GERAL: " vtotal format "->>>,>>>,>>9.99" skip.
          
    end.
    
    output close. 

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    
    leave.
end. 

procedure gera-ttclase:
    def buffer grupo for clase.
    def buffer sub-clase for clase.
    for each grupo where grupo.clasup = 103000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end.
    for each grupo where grupo.clasup = 114000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end. 
    for each grupo where grupo.clasup = 128000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end. 
    for each grupo where grupo.clasup = 129000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end. 
    for each grupo where grupo.clasup = 130000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end.
    for each grupo where grupo.clasup = 140000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end.              
end procedure.
         

procedure e-movim.
    def var vseq as int.
    vseq = 0.
    def var vsal-ant as dec.
    vsal-ant = vsal_ant.
    for each tt-movest use-index i1:
        create extrato-movim.
        assign
            extrato-movim.etbcod = tt-movest.etbcod
            extrato-movim.procod = tt-movest.procod
            extrato-movim.data = tt-movest.data
            extrato-movim.hora = tt-movest.hora
            extrato-movim.movtdc = tt-movest.movtdc
            extrato-movim.tipmov = tt-movest.movtnom
            extrato-movim.numero = tt-movest.numero
            extrato-movim.serie = tt-movest.serie
            extrato-movim.emite = tt-movest.emite
            extrato-movim.desti = tt-movest.desti
            extrato-movim.movqtm = tt-movest.movqtm
            extrato-movim.movpc = tt-movest.movpc
            extrato-movim.sal-ant = tt-movest.sal-ant
            extrato-movim.sal-atu = tt-movest.sal-atu
            extrato-movim.cus-ent = tt-movest.cus-ent
            extrato-movim.cus-med = tt-movest.cus-med
            extrato-movim.qtd-ent = tt-movest.qtd-ent
            extrato-movim.qtd-sai = tt-movest.qtd-sai
        .

        vseq = vseq + 1.

        assign
            extrato-movim.seq = vseq
            extrato-movim.sal-atu = vsal-ant + 
                (tt-movest.qtd-ent - tt-movest.qtd-sai)
            vsal-ant = vsal-ant + (tt-movest.qtd-ent - tt-movest.qtd-sai)
        .
    
    end.

end procedure.
