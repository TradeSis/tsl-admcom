
DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}

{admcab-batch.i}
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field posicao       as int
    field codigoFilial  as int
    field dataInicial   as CHAR
    field dataFinal     as CHAR
    field alfa          AS log.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if not avail ttparametros then return.

def shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.

def var ii as int.
def var vqtdcli as int.

def temp-table ttcli
    field clicod like clien.clicod.
    
def buffer btitulo for titulo.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.


vetbcod = ttparametros.codigoFilial.
find estab where estab.etbcod = vetbcod no-lock.    
valfa = ttparametros.alfa.


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
    varquivo = replace(tsrelat.nomerel," ","") +
    "-ID" + STRING(tsrelat.idrelat) + "-" +  
     STRING(TODAY,"99999999") +
     replace(STRING(TIME,"HH:MM:SS"),":","").
end.
ELSE DO:
    varquivo = "cred01_II-" + STRING(TODAY,"99999999") +
                    replace(STRING(TIME,"HH:MM:SS"),":","").
END.

output to value(vdir + varquivo + ".txt").
PUT UNFORMATTED CHR(15)  .
VSUBTOT = 0.
PAGE.

form header
            wempre.emprazsoc
            space(6) "cred01_II"   at 135
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
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = "CRE" and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim no-lock,
    first clien where clien.clicod = titulo.clifor no-lock
                            break by clien.clinom
                                  by titulo.titdtven.

    find first btitulo use-index iclicod
                where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = "CRE"         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
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
    vsubtot = vsubtot + titulo.titvlcob.
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error. 
    if not avail tt-extrato  
    then do:  
        ii = ii + 1. 
        create tt-extrato. 
        assign tt-extrato.rec = recid(clien) 
        tt-extrato.ord = ii. 
    end.
             
    find ttcli where ttcli.clicod = titulo.clifor no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = titulo.clifor.
    end.
    
    display
        titulo.etbcod    column-label "Fil."         
        clien.clinom when avail clien    column-label "Nome do Cliente" 
        clien.fone column-label "Fone"
        clien.fax column-label "Celular"
        titulo.clifor     column-label "Cod."           
        titulo.titnum      column-label "Contr."       
        titulo.titpar      column-label "Pr."        
        titulo.titdtemi    column-label "Dt.Venda"  
        titulo.titdtven    column-label "Vencim."   
        titulo.titvlcob    column-label "Valor Prestacao"
        titulo.titdtven - TODAY    column-label "Dias"
                    with width 180 .
end.
else
FOR EACH ESTAB where estab.etbcod = vetbcod no-lock,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = "CRE" and
        titulo.titsit = "LIB" and
        titulo.etbcod = ESTAB.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    
    find first btitulo use-index iclicod
                where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = "CRE"         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
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
    vsubtot = vsubtot + titulo.titvlcob.
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error. 
    if not avail tt-extrato  
    then do:  
        ii = ii + 1. 
        create tt-extrato. 
        assign tt-extrato.rec = recid(clien) 
        tt-extrato.ord = ii. 
    end.
     
    
    find ttcli where ttcli.clicod = titulo.clifor no-error.
    if not avail ttcli
    then do:
        create ttcli.
        assign ttcli.clicod = titulo.clifor.
    end.

    display
        titulo.etbcod       column-label "Fil."
        clien.clinom when avail clien column-label "Cliente"
        titulo.clifor       column-label "Cod."            
        clien.fone column-label "Fone"
        clien.fax column-label "Celular"
        titulo.titnum      column-label "Contr."       
        titulo.titpar      column-label "Pr."        
        titulo.titdtemi    column-label "Dt.Venda"   
        titulo.titdtven    column-label "Vencim."    
        titulo.titvlcob    column-label "Valor Prestacao" 
        titulo.titdtven - TODAY    column-label "Dias"
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

run pdfout.p (INPUT vdir + varquivo + ".txt",
        input vdir,
        input varquivo + ".pdf",
        input "Landscape", /* Landscape/Portrait */
        input 7,
        input 1,
output vpdf).


     

