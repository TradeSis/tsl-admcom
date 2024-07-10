{admcab.i}

def var vpdf as char no-undo.

def new shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.

def var ii as int.
def var vqtdcli as int.

def temp-table ttcli
    field clicod like clien.clicod.
    
def buffer btitulo for fin.titulo.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like fin.titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.
def var varquivo as char.

update vetbcod                          colon 20.
find estab where estab.etbcod = vetbcod no-error.
if not avail estab
then do:
    message "Estabelecimento Invalido" .
    undo.
end.
for each tt-extrato.
    delete tt-extrato.
end.
for each ttcli. delete ttcli. end.
ii = 0.


display estab.etbnom no-label.
update
       vdtvenini label "Vencimento Inicial" colon 20
       vdtvenfim label "Final"
       with row 4 side-labels width 80 .

    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    if frame-index = 1
    then valfa = yes.
    else valfa = no.
varquivo = "/usr/admcom/relat/lip" + string(scxacod).
output to value(varquivo).
PUT UNFORMATTED CHR(15)  .
VSUBTOT = 0.
PAGE.

form header
            wempre.emprazsoc
            space(6) "cre03_a"   at 135
            "Pag.: " at 146 page-number format ">>9" skip
            "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
            " Periodo" vdtvenini " A " vdtvenfim
            today format "99/99/9999" at 135
            string(time,"hh:mm:ss") at 148
            skip fill("-",155) format "x(155)" skip
            with frame fcab no-label page-top no-box width 180.
view frame fcab.
        

if valfa
then
FOR EACH ESTAB where estab.etbcod = vetbcod no-lock,
    each fin.titulo use-index titdtven where
        fin.titulo.empcod = wempre.empcod and
        fin.titulo.titnat = no and
        fin.titulo.modcod = "CRE" and
        fin.titulo.titsit = "LIB" and
        fin.titulo.etbcod = ESTAB.etbcod and
        fin.titulo.titdtven >= vdtvenini and
        fin.titulo.titdtven <= vdtvenfim no-lock,
    first clien where clien.clicod = fin.titulo.clifor no-lock
                            break by clien.clinom
                                  by fin.titulo.titdtven.

    find first btitulo use-index iclicod
                where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = "CRE"         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = fin.titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        /*
        form header
            wempre.emprazsoc
                    space(6) "cre03_a"   at 117
                    "Pag.: " at 128 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 117
                    string(time,"hh:mm:ss") at 130
                    skip fill("-",155) format "x(155)" skip
                    with frame fcab no-label page-top no-box width 180.
        view frame fcab.
        */
    vsubtot = vsubtot + fin.titulo.titvlcob.
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error. 
    if not avail tt-extrato  
    then do:  
        ii = ii + 1. 
        create tt-extrato. 
        assign tt-extrato.rec = recid(clien) 
        tt-extrato.ord = ii. 
    end.
             
    find ttcli where ttcli.clicod = fin.titulo.clifor no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = fin.titulo.clifor.
    end.
    
    display
        fin.titulo.etbcod    column-label "Fil."         
        clien.clinom when avail clien    column-label "Nome do Cliente" 
        clien.fone column-label "Fone"
        clien.fax column-label "Celular"
        fin.titulo.clifor     column-label "Cod."           
        fin.titulo.titnum      column-label "Contr."       
        fin.titulo.titpar      column-label "Pr."        
        fin.titulo.titdtemi    column-label "Dt.Venda"  
        fin.titulo.titdtven    column-label "Vencim."   
        fin.titulo.titvlcob    column-label "Valor Prestacao"
        fin.titulo.titdtven - TODAY    column-label "Dias"
                    with width 180 .
end.
else
FOR EACH ESTAB where estab.etbcod = vetbcod no-lock,
    each fin.titulo use-index titdtven where
        fin.titulo.empcod = wempre.empcod and
        fin.titulo.titnat = no and
        fin.titulo.modcod = "CRE" and
        fin.titulo.titsit = "LIB" and
        fin.titulo.etbcod = ESTAB.etbcod and
        fin.titulo.titdtven >= vdtvenini and
        fin.titulo.titdtven <= vdtvenfim
                    no-lock break by fin.titulo.titdtven:

    find clien where clien.clicod = fin.titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    
    find first btitulo use-index iclicod
                where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = "CRE"         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = fin.titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.
        /*
        form header
            wempre.emprazsoc
                    space(6) "POCLI"   at 117
                    "Pag.: " at 128 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 117
                    string(time,"hh:mm:ss") at 130
                    skip fill("-",155) format "x(155)" skip
                    with frame fcabb no-label page-top no-box width 180.
        view frame fcabb.
        */
    vsubtot = vsubtot + fin.titulo.titvlcob.
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error. 
    if not avail tt-extrato  
    then do:  
        ii = ii + 1. 
        create tt-extrato. 
        assign tt-extrato.rec = recid(clien) 
        tt-extrato.ord = ii. 
    end.
     
    
    find ttcli where ttcli.clicod = fin.titulo.clifor no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = fin.titulo.clifor.
    end.

    display
        fin.titulo.etbcod       column-label "Fil."
        clien.clinom when avail clien column-label "Cliente"
        fin.titulo.clifor       column-label "Cod."            
        clien.fone column-label "Fone"
        clien.fax column-label "Celular"
        fin.titulo.titnum      column-label "Contr."       
        fin.titulo.titpar      column-label "Pr."        
        fin.titulo.titdtemi    column-label "Dt.Venda"   
        fin.titulo.titdtven    column-label "Vencim."    
        fin.titulo.titvlcob    column-label "Valor Prestacao" 
        fin.titulo.titdtven - TODAY    column-label "Dias"
        with width 180 .
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
/*
os-command silent /fiscal/lp value(varquivo).
*/

/* substituido pela geracao de pdf
os-command cat value(varquivo) > /dev/lp0 &.
*/

run pdfout.p (input varquivo,
              input "/usr/admcom/kbase/pdfout/",
              input "cred03-" + string(time) + ".pdf",
              input "Portrait",
              input 6.3,
              input 1,
              output vpdf).
     
message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
     
 
/*
run visurel.p (input varquivo, input "").
*/

message "Deseja imprimir extratos" update sresp.
if sresp 
then run extrato30.p.


