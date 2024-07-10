{admcab.i}

def var vpdf as char no-undo.

def var ii as int.
def stream stela.
def var vdata like plani.pladat.
def var vqtdcli as integer.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like fin.titulo.titvlcob.
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
        &Saida     = "/usr/admcom/relat/cre02"
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
            FOR each fin.titulo use-index titdtven where
                        fin.titulo.empcod = wempre.empcod and
                        fin.titulo.titnat = no            and
                        fin.titulo.modcod = "CRE"         and
                        fin.titulo.titdtven = vdata       and
                        fin.titulo.etbcod = ESTAB.etbcod and
                        fin.titulo.titsit = "LIB"        no-lock:
                if fin.titulo.clifor = 1
                then next.
                find clien where clien.clicod = fin.titulo.clifor 
                            no-lock no-error.
                if not avail clien
                then next.
                vsubtot = vsubtot + fin.titulo.titvlcob.
                find first tt-depen where 
                              tt-depen.etbcod = estab.etbcod and
                              tt-depen.accod  = int(recid(fin.titulo)) and
                              tt-depen.nome   = clien.clinom no-error.
                if not avail tt-depen
                then do transaction:
                    create tt-depen.
                    assign tt-depen.etbcod = fin.titulo.etbcod
                           tt-depen.accod  = int(recid(fin.titulo))
                           tt-depen.nome   = clien.clinom
                           tt-depen.dtnas  = fin.titulo.titdtven.
                end.
                output stream stela to terminal.
                    display stream stela
                            fin.titulo.clifor
                            fin.titulo.titnum
                            fin.titulo.titpar
                            fin.titulo.titdtven
                                with frame f-tela centered
                                    1 down side-label. pause 0.

                output stream stela close.
            end.
        end.
        for each tt-depen where tt-depen.etbcod = estab.etbcod
                                            no-lock break by tt-depen.nome
                                                          by tt-depen.dtnas:
                                                          
           find fin.titulo where recid(fin.titulo) = tt-depen.accod 
                        no-lock no-error.
           if not avail fin.titulo
           then next.
            
           find clien where clien.clicod = fin.titulo.clifor 
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
                                            
            find ttcli where ttcli.clicod = fin.titulo.clifor no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = fin.titulo.clifor.
            end.
            
            display fin.titulo.etbcod column-label "Fil." 
                    tt-depen.nome column-label "Nome do Cliente"
                                  format "x(30)"
                    clien.fone column-label "fone" when avail clien
                    clien.fax  column-label "Celular" when avail clien
                    fin.titulo.clifor column-label "Cod."     
                    fin.titulo.titnum column-label "Contr."   
                    fin.titulo.titpar column-label "Pr."      
                    fin.titulo.titdtemi column-label "Dt.Venda" 
                    fin.titulo.titdtven column-label "Vencim."  
                    fin.titulo.titvlcob 
                                    column-label "Valor Prestacao" 
                    fin.titulo.titdtven - TODAY    column-label "Dias"
                        with width 180.
        end.
        
    end.
    else do:
        FOR each fin.titulo use-index titdtven where
                        fin.titulo.empcod = wempre.empcod and
                        fin.titulo.titnat = no and
                        fin.titulo.modcod = "CRE" and
                        fin.titulo.titdtven >= vdtvenini and
                        fin.titulo.titdtven <= vdtvenfim and
                        fin.titulo.etbcod = ESTAB.etbcod and
                        fin.titulo.titsit = "LIB"        and
                        can-find(clien where 
                        clien.clicod = fin.titulo.clifor) no-lock,
                     clien where clien.clicod = fin.titulo.clifor no-lock
                                           break by fin.titulo.titdtven.
            if fin.titulo.clifor = 1
            then next.

            vsubtot = vsubtot + fin.titulo.titvlcob.
            
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
             
            display fin.titulo.etbcod column-label "Fil."  
                    clien.clinom  column-label "Nome do Cliente" 
                    clien.clicod  column-label "Cod."            
                    clien.fone    column-label "Fone"
                    clien.fax     column-label "Celular"
                    fin.titulo.titnum   column-label "Contr."  
                    fin.titulo.titpar   column-label "Pr."        
                    fin.titulo.titdtemi column-label "Dt.Venda" 
                    fin.titulo.titdtven column-label "Vencim."  
                    fin.titulo.titvlcob 
                            column-label "Valor Prestacao"  
                    fin.titulo.titdtven - TODAY    column-label "Dias"
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
    os-command silent /fiscal/lp /usr/admcom/relat/cre02.
    */ 
    
    def var varquivo as char.
    varquivo = "/usr/admcom/relat/cre02".
    
    /* substituido pela geracao de pdf
    os-command cat value(varquivo) > /dev/lp0 &.
    */
    
    run pdfout.p (input varquivo,
                  input "/usr/admcom/kbase/pdfout/",
                  input "cred02-" + string(time) + ".pdf",
                  input "Portrait",
                  input 6.8,
                  input 1,
                  output vpdf).
              
     message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
              
    
    /*                                
    run visurel.p ("/usr/admcom/relat/cre02", input "").
    */
    
    message "Deseja imprimir extratos" update sresp.
    if sresp 
    then run extrato30.p.
end.
