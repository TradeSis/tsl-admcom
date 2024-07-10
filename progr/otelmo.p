def var vpropath        as char format "x(150)".
def var vtprnom         as char. /* like tippro.tprnom.   */
input from l:\propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".
{l:\progr\admcab.i new}

def var funcao          as char.
def var parametro       as char.
def var v-ok            as log.
def var vok             as log.

input from l:\work\admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
    if funcao = "CAIXA"
    then scxacod = int(parametro).
    if funcao = "CLIEN"
    then scliente = parametro.
    if funcao = "RAMO"
    then stprcod = int(parametro).
    else stprcod = ?.
end.

input close.
find admcom where admcom.cliente = scliente.
wdata = today.

on F5 help.
on PF5 help.
on PF7 help.
on F7 help.
on f6 help.
on PF6 help.
def var vfuncod like func.funcod.

def var opcoes    as char format "x(15)" extent 4
    initial ["  Vendedores  ","  Performance  ","  Clientes  ","  Sair  "].

form opcoes with frame f-opcoes
        row 4 no-labels side-labels column 1 centered title " MENU "
        color cyan/black.

repeat:
display opcoes with frame f-opcoes.

        
    choose field opcoes with frame f-opcoes.
        hide frame f-opcoes no-pause.
    if frame-index = 1 
    then run corkven9.p.
    if frame-index = 2 
    then run convgenw.p.
    if frame-index = 3 
    then run market.p.
    if frame-index = 4 
    then leave.
end.    

quit.