{admcab.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field dataInicial   as char
    field dataFinal     as char.
    
hentrada =  temp-table ttparametros:HANDLE.
def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.
def var varquivo2 as char no-undo.
    
update  vdtini colon 15 label "Contratos emitidos de"
        vdtfim label "ate".

CREATE ttparametros.
ttparametros.dataInicial   = string(vdtini,"99/99/9999").
ttparametros.dataFinal     = string(vdtfim,"99/99/9999"). 

hentrada:WRITE-JSON("longchar",lcjsonentrada).

RUN aco13j_run.p (INPUT  lcjsonentrada,
                  OUTPUT varquivo2).

    
message ("Arquivo " + varquivo2 + " gerado com sucesso!") view-as alert-box.

