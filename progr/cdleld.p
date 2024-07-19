{admcab.i}

DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros serialize-name "parametros"
    field etb_ini       AS INT
    field etb_fim       AS INT.
    
hentrada =  temp-table ttparametros:HANDLE.



/* variaveis usadas na tela para pedir parametros */    
def var etb_ini as int initial 1.
def var etb_fim as int  initial 30.

def var arquivo as char no-undo.

update etb_ini colon 15 label "EP- Clientes com dias de pagamentos de "
    etb_fim label "ate".


CREATE ttparametros.
    ttparametros.etb_ini = etb_ini.
    ttparametros.etb_fim = etb_fim.
    
    hentrada:WRITE-JSON("longchar",lcjsonentrada).
    
    RUN cdleld_run.p (INPUT  lcjsonentrada,
                      OUTPUT arquivo).
    
    
    message ("Arquivo " + arquivo + " gerado com sucesso!") view-as alert-box.






















