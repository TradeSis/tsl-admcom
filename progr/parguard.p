{admcab.i }

def var vplatot  as dec.
def var vqtd-dias-atraso as int.
def var vprodval as dec.
def var vvalor   as dec.
def var vsenhax as char format "x(6)".
def var vsresp as log format "Sim/Nao".

def var x as int.

do on error undo:
    update vsenhax blank label "Senha" 
       with frame f-senhax side-labels centered.
    
    x = x + 1.
    
    if vsenhax <> "omleto"
    then do:
        message "Senha Invalida".
        if x <> 3
        then undo.
        else leave.
    end.
end.
 
hide frame f-senhax no-pause.
       
form
    "DG001 - VENDAS MAIORES QUE"                skip
    vplatot  label "A partir de R$"           at 9 skip(1)
    "DG003 - PRODUTOS VENDIDOS A MENOR"         skip
    vprodval label "A partir de R$"           at 9 skip(1)
    "DG004 - VENDA PARA CLIENTE EM ATRASO"      skip
    vvalor   label "A partir de R$"           at 9 skip
    vqtd-dias-atraso label "Dias de atraso" at 9 " dias" skip
    with frame f-dgs.
    
/*dg001 - venda maior que*/

update vplatot
       with frame f-dgs width 80 side-labels.

/*dg003 - produtos vendidos a menor */

update vprodval
       with frame f-dgs centered side-labels.

/*dg004 - venda para cliente em atraso */
update vvalor
       vqtd-dias-atraso
       with frame f-dgs centered side-labels.

message "Confirma os parametros definidos?" update vsresp.
if not vsresp then undo.

/*dg001*/
if vplatot <> 0 and vplatot <> ?
then do:
    output to /admcom/dg/lim001.ini.
       put unformatted vplatot.
    output close.
end.
/*dg003*/
if vprodval <> 0 and vprodval <> ?
then do:
    output to /admcom/dg/pro-menor.ini.
       put unformatted vprodval.
    output close.
end.
/*dg004*/
if vvalor <> 0 and vvalor <> ? and vqtd-dias-atraso <> 0 and vqtd-dias-atraso <> ?
then do:
    output to /admcom/dg/valcliatraso.ini.
       put unformatted vvalor ";" vqtd-dias-atraso.
    output close.
end.
