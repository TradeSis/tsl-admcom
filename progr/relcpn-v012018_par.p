{admcab.i}
{setbrw.i} 

DEF VAR varquivo AS CHAR.
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field etbcod      AS int
    FIELD dti         AS char
    FIELD dtf         AS char.
hentrada =  temp-table ttparametros:HANDLE.

/* variaveis usadas na tela para pedir parametros */    
def var vdti as date format "99/99/9999" label "Periodo emissao".
def var vdtf as date format "99/99/9999".
def var vetbcod like estab.etbcod label "Filial".
def var vpdf as char no-undo.


CREATE ttparametros.
    ttparametros.etbcod   = vetbcod.
    ttparametros.dti    = string(vdti,"99/99/9999").
    ttparametros.dtf      = string(vdtf,"99/99/9999"). 

    hentrada:WRITE-JSON("longchar",lcjsonentrada).

    RUN relcpn-v012018_run.p (INPUT  lcjsonentrada,
                              OUTPUT varquivo,
                              OUTPUT vpdf).


message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.

run visurel.p(varquivo, "").
