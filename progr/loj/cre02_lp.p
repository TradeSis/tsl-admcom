/* helio 28072022 - incluido varquivo */

/*  cre02_lp.p                                                              */
/*  alterado em out/2014                                                    */
/*  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo */
/*  pertence a filial 23 .                                                  */
/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{admcab.i}
def var varquivo as char.
def input param pmodalidade as char.

def temp-table ttmodal no-undo
    field modcod like modal.modcod.
if pmodalidade = "CREDIARIO"
then do:
    create ttmodal. ttmodal.modcod = "CRE". 
end.
if pmodalidade = "EMPRESTIMOS"
then do:
    create ttmodal. ttmodal.modcod = "CP0". 
    create ttmodal. ttmodal.modcod = "CP1". 
    create ttmodal. ttmodal.modcod = "CPN". 
end.   

def var vtpcontrato as char format "x(1)" label "T". /*#1 */
def var vpdf as char no-undo.

def new shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.
def var ii as int.

def var vqtdcli as integer.
def temp-table ttcli
    field clicod like clien.clicod.

def stream stela.
def var vdata like plani.pladat.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 3
      initial ["  Alfabetica  ","  Vencimento  ", "  Novacao  "].
def var valfa  as int.
def temp-table tt-depen
    field accod as int
    field etbcod like estab.etbcod
    field fone   as char
    field dtnasc like plani.pladat  
    field nome   as char format "x(20)".
    
def var vfil17 as char extent 2 format "x(15)"
    init["Nova","Antiga"].
    
def var vindex as int.

def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

repeat:
    for each tt-depen:
        delete tt-depen.
    end.
    for each tt-extrato.
        delete tt-extrato.
    end.
    for each ttcli.
        delete ttcli.
    end.
    
    ii = 0. vqtdcli = 0.

    if setbcod = 999
    then update vetbcod colon 25 with title pmodalidade + " - Posicao I " .
    else do:
        vetbcod = setbcod.
        disp vetbcod.
    end.    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido" .
        undo.
    end.
    display estab.etbnom no-label.
    vindex = 0.
    if estab.etbcod = 17
    then do:
        disp vfil17 no-label with frame f-17 1 down row 10 centered
             side-label overlay.
        pause 0.     
        choose field vfil17  with frame f-17.
        vindex = frame-index.    
    end.

    update vdtvenini label "Vencimento Inicial" colon 25
           vdtvenfim label "Final"
                with row 4 side-labels width 80 .

    update v-feirao-nome-limpo label "Considerar apenas feirao"
            help "NAO = Geral    SIM = Feirao"
                    colon 25 with side-label .
                    
    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    valfa =  frame-index.

    varquivo = "cre02_lp" + string(setbcod) + "_" + string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","").
    hide message no-pause.
    message "gerando relatorio" varquivo.
      
    {mdadmcab.i
        &Saida     = "value(""/admcom/relat/"" + varquivo + "".txt"")"
        &Page-Size = "0"
        &Cond-Var  = "121"
        &Page-Line = "66"
        &Nom-Rel   = """cre02_lp"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """POSICAO FINANCEIRA GERAL P/FILIAL - CLIENTE - PERIODO DE ""
                       + string(vdtvenini) + "" A "" + string(vdtvenfim) "
        &Width     = "121"
        &Form      = "frame f-cab"}

    message "cre02_lp" pmodalidade " - Posicao I - Ordem" vcont-cli[valfa].
    
    VSUBTOT = 0.
    if valfa = 1
    then do:
        do vdata = vdtvenini to vdtvenfim:
            for each ttmodal,
             each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no            and
                        titulo.modcod = ttmodal.modcod        and
                        titulo.titdtven = vdata       and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        no-lock:
                if titulo.clifor = 1
                then next.
                
                if v-feirao-nome-limpo
                then do:
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then.
                    else next.
                end.

                if estab.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.
                if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.

/********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .  
   *************/
                if estab.etbcod = 10 and 
                   titulo.titdtemi < 01/01/2014
                then next. 
                
                
                find clien where clien.clicod = titulo.clifor 
                            no-lock no-error.
                if not avail clien
                then next.

                vsubtot = vsubtot + titulo.titvlcob.
                find first tt-depen where tt-depen.etbcod = estab.etbcod and
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
            
            find ttcli where ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.clicod = clien.clicod.
            end.

            vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.
            
            display titulo.etbcod   column-label "Fil." 
                    tt-depen.nome     column-label "Cliente" 
                    format "x(20)"
                    clien.fone when   avail clien column-label "Fone"
                    clien.fax  when   avail clien column-label "Celular"
                    titulo.clifor   column-label "Cod."          
                    titulo.modcod
                    vtpcontrato column-label "T"
                    titulo.titnum   column-label "Contrato"        /* helio 28072022 era "Contr." */
                    titulo.titpar   column-label "Par"
                    titulo.titdtemi column-label "Dt.Venda"
                    format "99/99/99"
                    titulo.titdtven column-label "Vencim."   
                    format "99/99/99"
                    titulo.titvlcob column-label "Valor da!Prestacao"
                    format ">>>,>>9.99"
                    titulo.titdtven - TODAY    column-label "Dias"
                    format "->>>>9"
                        with width 180.
        end.
    end.
    if valfa = 2
    then do:
        for each ttmodal,
         each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no and
                        titulo.modcod = ttmodal.modcod and
                        titulo.titdtven >= vdtvenini and
                        titulo.titdtven <= vdtvenfim and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        and
                        can-find(clien where clien.clicod = titulo.clifor)
                        no-lock,
                        clien where clien.clicod = titulo.clifor no-lock
                                                    break by titulo.titdtven.
            if titulo.clifor = 1
            then next.

            if v-feirao-nome-limpo
            then do:
                if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                then.
                else next.
            end.

            if estab.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.

            if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.

            /********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .  
   *************/
                if estab.etbcod = 10 and 
                   titulo.titdtemi < 01/01/2014
                then next. 
            
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
            

            vsubtot = vsubtot + titulo.titvlcob.
            
            vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.
                          
            display titulo.etbcod    column-label "Fil." 
                    clien.clinom       column-label "Cliente" 
                    format "x(20)"
                    clien.clicod       column-label "Cod."    
                    clien.fone         column-label "Fone"
                    clien.fax          column-label "Celular"
                    titulo.modcod
                    vtpcontrato column-label "T"
                    titulo.titnum    column-label "Contrato" /* helio 28072022 era "Contr." */
                    titulo.titpar    column-label "Par"   
                    titulo.titdtemi  column-label "Dt.Venda"
                    format "99/99/99"
                    titulo.titdtven  column-label "Vencim." 
                    format "99/99/99"
                    titulo.titvlcob  column-label "Valor da!Prestacao"
                    format ">>>,>>9.99"
                    titulo.titdtven - TODAY    column-label "Dias"
                    format "->>>>9"
                        with width 180.
        end.
    end.
    
    if valfa = 3
    then do:
        for each ttmodal,
            each titulo use-index titdtven where
                        titulo.empcod = wempre.empcod and
                        titulo.titnat = no and
                        titulo.modcod = ttmodal.modcod and
                        titulo.titdtven >= vdtvenini and
                        titulo.titdtven <= vdtvenfim and
                        titulo.etbcod = ESTAB.etbcod and
                        titulo.titsit = "LIB"        and
                        titulo.tpcontrato = "N" and
                        can-find(clien where clien.clicod = titulo.clifor)
                        no-lock,
                        clien where clien.clicod = titulo.clifor no-lock
                                                    break by titulo.titdtven.
            if titulo.clifor = 1
            then next.

            if v-feirao-nome-limpo
            then do:
                if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                then.
                else next.
            end.

            if estab.etbcod = 17 and
                   vindex = 2 and
                   titulo.titdtemi >= 10/20/2010
                then next.
                else if estab.etbcod = 17 and
                    vindex = 1 and
                    titulo.titdtemi < 10/20/2010
                then next.

            if setbcod = 23 and
                   estab.etbcod = 10 and
                   titulo.titdtemi > 04/30/2011
                then next.

            /********
  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo
  pertence a filial 23 .  
   *************/
                if estab.etbcod = 10 and 
                   titulo.titdtemi < 01/01/2014
                then next. 
            
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
            

            vsubtot = vsubtot + titulo.titvlcob.
            
            vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.
                          
            display titulo.etbcod    column-label "Fil." 
                    clien.clinom       column-label "Cliente" 
                    format "x(20)"
                    clien.clicod       column-label "Cod."    
                    clien.fone         column-label "Fone"
                    clien.fax          column-label "Celular"
                    titulo.modcod
                    vtpcontrato column-label "T"
                    titulo.titnum    column-label "Contrato" /* helio 28072022 era "Contr." */
                    titulo.titpar    column-label "Par"   
                    titulo.titdtemi  column-label "Dt.Venda"
                    format "99/99/99"
                    titulo.titdtven  column-label "Vencim." 
                    format "99/99/99"
                    titulo.titvlcob  column-label "Valor da!Prestacao"
                    format ">>>,>>9.99"
                    titulo.titdtven - TODAY    column-label "Dias"
                    format "->>>>9"
                        with width 180.
        end.
    end.
    

    vqtdcli = 0.
    for each ttcli.
        vqtdcli = vqtdcli + 1.
    end.
    
    display skip(2) 
            "TOTAL CLIENTES:" vqtdcli skip
            "TOTAL GERAL   :" vsubtot with frame ff no-labels no-box.
    output close.
    hide message no-pause.
        
    run pdfout.p (input "/admcom/relat/" + varquivo + ".txt",
                  input "/admcom/kbase/pdfout/",
                  input varquivo + ".pdf",
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).
              
    message ("Arquivo " + vpdf + " gerado com sucesso!").
      
    /* substituido pela geracao de PDF
    os-command silent /fiscal/lp /admcom/relat/cre02. */    
    
    message "Deseja gerar um PDF do extrato" update sresp.
    if sresp
    then run loj/extrato3.p.
    
end.
