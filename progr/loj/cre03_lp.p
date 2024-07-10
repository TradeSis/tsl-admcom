/* helio 28072022 - incluido varquivo */
/* helio 14072022 pacote de melhorias cobanca - ajuste */
/* helio 27062022 pacote de melhorias cobanca */

/*  cre03_lp.p                                                              */
/*  alterado em out/2014                                                    */
/*  Se titulo for da filial 10 e emissão for menor que 01/01/2014, o titulo */
/*  pertence a filial 23 .                                                  */

/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{admcab.i}
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
    
def buffer btitulo for titulo.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 3
      initial ["  Alfabetica  ","  Vencimento  ", "  Novacao "].
def var valfa  as int.
def var varquivo as char.

def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

ii = 0.
for each tt-extrato.
    delete tt-extrato.
end.
for each ttcli.
    delete ttcli.
end.

def var vfil17 as char extent 2 format "x(15)"
    init["Nova","Antiga"].
    
def var vindex as int.

if setbcod = 999
then update vetbcod                          colon 25 with title pmodalidade + " - Posicao II ".
else do:
    vetbcod = setbcod.
    disp vetbcod.
end.    
find estab where estab.etbcod = vetbcod no-error.
if not avail estab
then do:
    message "Estabelecimento Invalido" .
    undo.
end.
display estab.etbnom no-label.
pause 0.
vindex = 0.
if estab.etbcod = 17
    then do:
        disp vfil17 no-label with frame f-17 1 down row 10 centered
             side-label overlay.
        pause 0.     
        choose field vfil17  with frame f-17.
        vindex = frame-index.    
    end.


update
       vdtvenini label "Vencimento Inicial" colon 25
       vdtvenfim label "Final"
       with row 4 side-labels width 80 .

update v-feirao-nome-limpo label "Considerar apenas feirao"
            help "NAO = Geral    SIM = Feirao"
                    colon 25 with side-label .

    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    valfa =  frame-index.

    varquivo = "cre03_lp" + string(setbcod) + "_" + string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","").
    hide message no-pause.
    message "gerando relatorio" varquivo.
      

output to value("/admcom/relat/" + varquivo + ".txt") page-size 62.
PUT UNFORMATTED CHR(15)  .

    message "cre03_lp" pmodalidade " - Posicao II - Ordem" vcont-cli[valfa].

vqtdcli = 0. VSUBTOT = 0.
PAGE.
if valfa = 1
then
    for each ttmodal,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = ttmodal.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim no-lock,
    first clien where clien.clicod = titulo.clifor no-lock
                            break by clien.clinom
                                  by titulo.titdtven.

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


    find first btitulo use-index iclicod
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = titulo.modcod         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "cre03_lp"   at 98
                    "Pag.: " at 110 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 98
                    string(time,"hh:mm:ss") at 112
                    skip fill("-",122) format "x(122)" skip
                    with frame fcab no-label page-top no-box width 130.
        view frame fcab.
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
    
    /* #1 */
    vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.
    
    display
        titulo.etbcod    column-label "Fil."         
        clien.clinom when avail clien   column-label "Cliente"
        format "x(20)"
        clien.fone column-label "Fone"
        clien.fax  column-label "Celular"
        titulo.clifor     column-label "Cod."            
        vtpcontrato
        titulo.titnum      column-label "Contrato"       /* helio 28072022 era "Contr." */
        titulo.titpar      column-label "Par"         
        titulo.titdtemi    column-label "Dt.Venda"   
        format "99/99/99"
        titulo.titdtven    column-label "Vencim."    
        format "99/99/99"
        titulo.titvlcob    column-label "Valor da!Prestacao"
        format ">>>,>>9.99"
        titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with width 180.
end.
if valfa = 2
then 
    for each ttmodal,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = ttmodal.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

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

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    find first btitulo use-index iclicod 
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = titulo.modcod         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "cre03_lp"   at 98
                    "Pag.: " at 110 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 98
                    string(time,"hh:mm:ss") at 112
                    skip fill("-",122) format "x(122)" skip
                    with frame fcabb no-label page-top no-box width 130.
        view frame fcabb.
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
    
    /* #1 */
    vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.
    
    display
        titulo.etbcod      column-label "Fil."        
        clien.clinom when avail clien column-label "Cliente"
        format "x(20)"
        clien.fone when avail clien column-label "Fone"
        clien.fax  when avail clien column-label "Celular"
        titulo.clifor      column-label "Cod."            
        vtpcontrato
        titulo.titnum      column-label "Contrato"        /* helio 28072022 era "Contr." */
        titulo.titpar      column-label "Par"        
        titulo.titdtemi    column-label "Dt.Venda"   
        format "99/99/99"
        titulo.titdtven    column-label "Vencim."    
        format "99/99/99"
        titulo.titvlcob    column-label "Valor da!Prestacao"  
        format ">>>,>>9.99"
        titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with width 180.
end.

if valfa = 3
then 
    for each ttmodal,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = ttmodal.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.tpcontrato = "N" and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

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

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    find first btitulo use-index iclicod 
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = titulo.modcod         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "cre03_lp"   at 98
                    "Pag.: " at 110 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 98
                    string(time,"hh:mm:ss") at 112
                    skip fill("-",122) format "x(122)" skip
                    with frame fcabc no-label page-top no-box width 130.
        view frame fcabc.
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
    
    /* #1 */
    vtpcontrato = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                          then "F"
                          else titulo.tpcontrato.
    
    display
        titulo.etbcod      column-label "Fil."        
        clien.clinom when avail clien column-label "Cliente"
        format "x(20)"
        clien.fone when avail clien column-label "Fone"
        clien.fax  when avail clien column-label "Celular"
        titulo.clifor      column-label "Cod."            
        titulo.modcod
        vtpcontrato
        titulo.titnum      column-label "Contrato"        /* helio 28072022 era "Contr." */
        titulo.titpar      column-label "Par"        
        titulo.titdtemi    column-label "Dt.Venda"   
        format "99/99/99"
        titulo.titdtven    column-label "Vencim."    
        format "99/99/99"
        titulo.titvlcob    column-label "Valor da!Prestacao"  
        format ">>>,>>9.99"
        titulo.titdtven - TODAY    column-label "Dias"
        format "->>>>9"
        with width 180.
end.


vqtdcli = 0.
for each ttcli.
    vqtdcli = vqtdcli + 1.
end.

display skip(2) 
        "TOTAL CLIENTES:" vqtdcli skip
        "TOTAL GERAL   :" vsubtot with frame ff no-labels no-box.
output close.
/*
display "IMPRESSORA PRONTA?" WITH FRAME F-FF ROW 20 CENTERED.
PAUSE.
*/
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
os-command silent /fiscal/lp /admcom/relat/lip. */

message "Deseja gerar PDF do extrato" update sresp.
if sresp
then run loj/extrato3.p.

