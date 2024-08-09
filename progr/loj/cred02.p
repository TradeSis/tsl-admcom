{admcab.i}

def var vpdf as char no-undo.

def var ii as int.
def stream stela.
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

repeat:
    
    for each tt-extrato:
        delete tt-extrato.
    end.
    
    for each tt-depen:
        delete tt-depen.
    end.

    for each ttcli:
        delete ttcli.
    end.

    update vetbcod colon 20.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido" .
        undo.
    end.
    display estab.etbnom no-label.
    update vdtvenini label "Vencimento Inicial" colon 20
           vdtvenfim label "Final"
                with row 4 side-labels width 80 .
    def var vclifor like clien.clicod.
    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    if frame-index = 1
    then valfa = yes.
    else valfa = no.

    {mdadmcab.i
        &Saida     = "/admcom/relat/cre02"
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
                output stream stela to terminal.
                    display stream stela
                            titulo.clifor
                            titulo.titnum
                            titulo.titpar
                            titulo.titdtven
                                with frame f-tela centered
                                    1 down side-label. pause 0.

                output stream stela close.
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
    
    def var varquivo as char.
    varquivo = "/admcom/relat/cre02".
    
    /* substituido pela geracao de pdf
    os-command cat value(varquivo) > /dev/lp0 &.
    */
    
    run pdfout.p (input varquivo,
                  input "/admcom/kbase/pdfout/",
                  input "cred02-" + string(time) + ".pdf",
                  input "Portrait",
                  input 6.8,
                  input 1,
                  output vpdf).
              
     message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
    
    /*                                
    run visurel.p ("/admcom/relat/cre02", input "").
    */
    
    message "Deseja imprimir extratos" update sresp.
    if sresp 
    then run loj/extrato30.p.
end.
