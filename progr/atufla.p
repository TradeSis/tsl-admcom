/*************************  CRIA TABELA TITCLI **********************/

def var ss as i.
def var nn as i.
def buffer btitcli for titcli.
                
def var vdata like plani.pladat.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
                
def temp-table tt-cli
    field clicod like clien.clicod
    field etbcod like estab.etbcod.

def var xx as int.
def buffer btitulo for titulo.


/**************** VERIFICA OS CLIENTES A SEREM PROCESSADOS ******************/

output to /admcom/logs/flag.log append.
    put "Inicio do processo dia " today format "99/99/9999"
        " Hora: " string(time,"HH:MM:SS") skip. 
output close.



/*

connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.

*/

run atudrag.p.

if connected ("d") 
then disconnect d.

output to /admcom/logs/flag.log append.
    put "Final do processo dia " today format "99/99/9999"
        " Hora: " string(time,"HH:MM:SS") skip. 
output close.


return.
 
