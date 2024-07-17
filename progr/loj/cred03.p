{admcab.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field posicao       as int
    field codigoFilial  as int
    field dataInicial   as date
    field dataFinal     as date
    field ordem         as int.
hentrada =  temp-table ttparametros:HANDLE.

/* variaveis usadas na tela para pedir parametros */
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vetbcod like estab.etbcod.
def var vpdf as char no-undo.


update vetbcod                          colon 20.
find estab where estab.etbcod = vetbcod no-error.
if not avail estab
then do:
    message "Estabelecimento Invalido" .
    undo.
end.


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
    ttparametros.posicao        = 1.
    ttparametros.codigofilial   = vetbcod.
    ttparametros.datainicial    = vdtvenini.
    ttparametros.datafinal      = vdtvenfim.
    ttparametros.ordem          = IF valfa THEN 1 ELSE 0.
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN loj/cred03_run.p (INPUT  lcjsonentrada,
                          OUTPUT vpdf).
                     

message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
 
/*
run visurel.p (input varquivo, input "").
*/

message "Deseja imprimir extratos" update sresp.
if sresp 
then run loj/extrato30.p.


