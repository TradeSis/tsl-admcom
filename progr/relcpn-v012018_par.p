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

form vetbcod at 2 label "Filial"
     estab.etbnom no-label
     vdti at 1 format "99/99/9999" label "Periodo emissao"
     vdtf format "99/99/9999" no-label
     with frame f-1 1 down width 80 side-label.

update vetbcod with frame f-1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom with frame f-1.
end.
    
update vdti vdtf with frame f-1. 

CREATE ttparametros.
    ttparametros.etbcod   = vetbcod.
    ttparametros.dti    = string(vdti,"99/99/9999").
    ttparametros.dtf      = string(vdtf,"99/99/9999"). 

    hentrada:WRITE-JSON("longchar",lcjsonentrada).

    RUN relcpn-v012018_run.p (INPUT  lcjsonentrada,
                              OUTPUT varquivo,
                              OUTPUT vpdf).


message ("Arquivo " + vpdf + " gerado com sucesso!") view-as alert-box.

/* run visurel.p(varquivo, ""). */
