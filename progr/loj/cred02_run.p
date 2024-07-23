/* PROGRAMA DE EXEMPLO, PARTE DSE EXECUÇÃO */
DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}

{admcab-batch.i}
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field codigoFilial  as char
    field dataInicial   as CHAR
    field dataFinal     as CHAR
    field ordem          AS char.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.

def var ii as int.
def var vdata like plani.pladat.
def var vqtdcli as integer.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.

def temp-table ttcli
    field clicod like clien.clicod.

def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.
def temp-table tt-depen
    field accod as int
    field etbcod like estab.etbcod
    field fone   as char
    field dtnasc like plani.pladat  
    field nome   as char format "x(20)".
    

def new shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.

/*repeat:  -- não tem REPEAT */
    
    for each tt-extrato:
        delete tt-extrato.
    end.
    
    for each tt-depen:
        delete tt-depen.
    end.

    for each ttcli:
        delete ttcli.
    end.

    /* retirada parte que pede parametros */
    
    /* parametrois vem do ttparametros */
    vetbcod = int(ttparametros.codigoFilial).
    find estab where estab.etbcod = vetbcod no-lock.    
    valfa = IF int(ttparametros.ordem) = 1 THEN TRUE ELSE FALSE.

   
    if ttparametros.dataFinal BEGINS "#" then do:
        vdtvenfim = calculadata(ttparametros.dataFinal,TODAY).
    end.
    ELSE DO:
        vdtvenfim =convertedata(ttparametros.dataFinal).
    END.
    if ttparametros.dataInicial BEGINS "#" then do:
        vdtvenini = calculadata(ttparametros.dataInicial,vdtvenfim).
    end.
    ELSE DO:
        vdtvenini  = convertedata(ttparametros.dataInicial).
    END.
 
    if AVAIL tsrelat then do:
        varquivo = "cre02-ID" + STRING(tsrelat.idrelat) + "-" +  
                        STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    end.
    ELSE DO:
        varquivo = "cre02-" + STRING(TODAY,"99999999") +
                        replace(STRING(TIME,"HH:MM:SS"),":","").
    END.

    
    message vetbcod valfa vdtvenini vdtvenfim. pause.
    
    
    {mdadmcab.i
        &Saida     = "VALUE(vdir + varquivo + """.txt""")"
        &Page-Size = "0"
        &Cond-Var  = "145"
        &Page-Line = "0"
        &Nom-Rel   = """cre02_a"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
     &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                       + string(vdtvenini) + "" A "" + string(vdtvenfim) "
        &Width     = "145"
        &Form      = "frame f-cab"}

    assign vqtdcli = 0 VSUBTOT = 0.

    if valfa
    then do:
        do vdata = vdtvenini to vdtvenfim:
            FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no            and
                        titulo.modcod = "CRE"         and
                        titulo.titdtven = vdata       and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        no-lock:
                if titulo.clifor = 1
                then next.
                find clien where clien.clicod = titulo.clifor 
                            no-lock no-error.
                if not avail clien
                then next.
                vsubtot = vsubtot + titulo.titvlcob.
                find first tt-depen where 
                              tt-depen.etbcod = estab.etbcod and
                              tt-depen.accod  = int(recid(titulo)) and
                              tt-depen.nome   = clien.clinom no-error.
                if not avail tt-depen
                then do transaction:
                    create tt-depen.
                    assign tt-depen.etbcod = titulo.etbcod
                           tt-depen.accod  = int(recid(titulo))
                           tt-depen.nome   = clien.clinom
                           tt-depen.dtnas  = titulo.titdtven.
                end.
                /* retirada interações com tela
                output stream stela to terminal.
                    display stream stela
                            titulo.clifor
                            titulo.titnum
                            titulo.titpar
                            titulo.titdtven
                                with frame f-tela centered
                                    1 down side-label. pause 0.

                output stream stela close.
                */
            end.
        end.
        for each tt-depen where tt-depen.etbcod = estab.etbcod
                                            no-lock break by tt-depen.nome
                                                          by tt-depen.dtnas:
                                                          
           find titulo where recid(titulo) = tt-depen.accod 
                        no-lock no-error.
           if not avail titulo
           then next.
            
           find clien where clien.clicod = titulo.clifor 
                        no-lock no-error.
           if avail clien
           then do:
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                            no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.
            end.     
                                            
            find ttcli where ttcli.clicod = titulo.clifor no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = titulo.clifor.
            end.
            
            display titulo.etbcod column-label "Fil." 
                    tt-depen.nome column-label "Nome do Cliente"
                                  format "x(30)"
                    clien.fone column-label "fone" when avail clien
                    clien.fax  column-label "Celular" when avail clien
                    titulo.clifor column-label "Cod."     
                    titulo.titnum column-label "Contr."   
                    titulo.titpar column-label "Pr."      
                    titulo.titdtemi column-label "Dt.Venda" 
                    titulo.titdtven column-label "Vencim."  
                    titulo.titvlcob column-label "Valor Prestacao" 
                    titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
        
    end.
    else do:
        FOR each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no and
                        titulo.modcod = "CRE" and
                        titulo.titdtven >= vdtvenini and
                        titulo.titdtven <= vdtvenfim and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        and
                        can-find(clien where 
                        clien.clicod = titulo.clifor) no-lock,
                     clien where clien.clicod = titulo.clifor no-lock
                                           break by titulo.titdtven.
            if titulo.clifor = 1
            then next.

            vsubtot = vsubtot + titulo.titvlcob.
            
            find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
            if not avail tt-extrato 
            then do: 
                ii = ii + 1.
                create tt-extrato.
                assign tt-extrato.rec = recid(clien)
                       tt-extrato.ord = ii.
            end.

            find ttcli where ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = clien.clicod.
            end.
             
            display titulo.etbcod column-label "Fil."  
                    clien.clinom  column-label "Nome do Cliente" 
                    clien.clicod  column-label "Cod."            
                    clien.fone    column-label "Fone"
                    clien.fax     column-label "Celular"
                    titulo.titnum   column-label "Contr."  
                    titulo.titpar   column-label "Pr."        
                    titulo.titdtemi column-label "Dt.Venda" 
                    titulo.titdtven column-label "Vencim."  
                    titulo.titvlcob column-label "Valor Prestacao"  
                    titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
    end.

    vqtdcli = 0.
    for each ttcli:
        vqtdcli = vqtdcli + 1.
    end.
                    
    display skip(2) 
            "TOTAL CLIENTES:" vqtdcli skip
            "TOTAL GERAL   :" vsubtot with frame ff no-labels no-box.
    output close.
                                      
    /*
    os-command silent /fiscal/lp /admcom/relat/cre02.
    */ 
    
    
    
    
    
    /* substituido pela geracao de pdf
    os-command cat value(varquivo) > /dev/lp0 &.
    */
    
    run pdfout.p (INPUT vdir + varquivo + ".txt",
                  input vdir,
                  input varquivo + ".pdf",
                  input "Landscape", /* Landscape/Portrait */
                  input 7,
                  input 1,
                  output vpdf).
 
    
    
   
   /* retirada as interações com tela
   message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
    
    /*                                
    run visurel.p ("/admcom/relat/cre02", input "").
    */
    
    message "Deseja imprimir extratos" update sresp.
    if sresp 
    then run loj/extrato30.p.
    */
    
/* end. retirada o repeat */
