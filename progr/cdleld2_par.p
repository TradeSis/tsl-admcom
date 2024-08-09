{admcab.i}
DEF VAR lcJsonEntrada AS LONGCHAR.
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field etb_ini     as int
    field etb_fim     as int.
    
hentrada =  temp-table ttparametros:HANDLE.

def var etb_ini as int initial 1.
def var etb_fim as int  initial 30.

def var varquivo1 as character.

update etb_ini colon 15 label "CRE- Clientes com dias de pagamentos de "
        etb_fim label "ate".

CREATE ttparametros.
ttparametros.etb_ini   = etb_ini.
ttparametros.etb_fim   = etb_fim. 

hentrada:WRITE-JSON("longchar",lcjsonentrada).

display "Gerando Arquivos Pagos".

RUN cdleld2_run.p (INPUT  lcjsonentrada,
                   OUTPUT varquivo1).
   
    
message "Arquivo gerado: " varquivo1.
pause.


