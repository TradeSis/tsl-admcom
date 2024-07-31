{admcab.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field posicao       as int
    field codigoFilial  as int
    field dataInicial   as CHAR
    field dataFinal     as CHAR
    field alfa          AS log.
hentrada =  temp-table ttparametros:HANDLE.

def new shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.

def var ii as int.
def var vqtdcli as int.

def buffer btitulo for titulo.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.
def var varquivo as char.
def var vpdf as char no-undo.
 
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
/*for each ttcli. delete ttcli. end.*/
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

    CREATE ttparametros.
    ttparametros.codigofilial   = vetbcod.
    ttparametros.datainicial    = string(vdtvenini,"99/99/9999").
    ttparametros.datafinal      = string(vdtvenfim,"99/99/9999"). 
    ttparametros.alfa           = valfa.
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN loj/cred03_run.p (INPUT  lcjsonentrada,
                          OUTPUT vpdf).
     
message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
 

message "Deseja imprimir extratos" update sresp.
if sresp 
then run loj/extrato30.p.



