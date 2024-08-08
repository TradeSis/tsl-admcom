/* PROGRAMA DE EXEMPLO, ERA DE TELA SOMENTE */
/* FOI DIVIDIDO EM TELA (ESTE) E EXECUÇÃO - _run.p */
/* helio - fica apenas a parte que pede dados. */

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



/* variaveis usadas na tela para pedir parametros */    
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vetbcod like estab.etbcod.
 def var vpdf as char no-undo.
 
/* elimina variaveis e temp-tables que não serão usadas */
/*

    

def var ii as int.
def stream stela.
def var vdata like plani.pladat.
def var vqtdcli as integer.

def temp-table ttcli
    field clicod like clien.clicod.

def temp-table tt-depen
    field accod as int
    field etbcod like estab.etbcod
    field fone   as char
    field dtnasc like plani.pladat  
    field nome   as char format "x(20)".
*/    

def new shared temp-table tt-extrato 
        field rec as recid
        field ord as int
            index ind-1 ord.

REPEAT:
    /* eklimina o que não é usado para pedir parametros  
    for each tt-extrato:
        delete tt-extrato.
    end.
    
    for each tt-depen:
        delete tt-depen.
    end.

    for each ttcli:
        delete ttcli.
    end.
    */
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
                with row 4 side-labels width 80 1 DOWN .
    def var vclifor like clien.clicod.
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
    
    RUN loj/cred02_run.p (INPUT  lcjsonentrada,
                          OUTPUT vpdf).
    
    /* elimina o restante */
   
    
    message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.
    
    message "Deseja imprimir extratos" update sresp.
    if sresp 
    then run loj/extrato30.p.
end.



