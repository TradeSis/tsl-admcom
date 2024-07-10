/***************************************************************************
** Programa        : atudbrp.p
** Objetivo        : Atualiza dados do DB para DBRP
****************************************************************************/

{/admcom/progr/admcab-batch.i new}.

def shared var dd-rep as int.
def shared var vlog as char.

def var vult        as dec.
def var i as int.
def var lg-atuger   as log initial no   no-undo.
def var lg-atufin   as log initial no   no-undo.
def var lg-atucom   as log initial no   no-undo.
def var cont as int.
def var t-cont as int.

def new shared temp-table tt-plani         like com.plani.
def new shared temp-table tt-movim         like com.movim.
def new shared temp-table tt-contnf        like fin.contnf.
def new shared temp-table tt-contrato      like fin.contrato.
def new shared temp-table tt-titulo        like fin.titulo.
def new shared temp-table tt-titpag        like fin.titpag. 
def new shared temp-table tt-nottra        like com.nottra.

def shared var vcom as dec.
def shared var vfin as dec.
def shared var vger as dec.

for each tt-plani: delete tt-plani. end.
for each tt-movim: delete tt-movim. end.
for each tt-contnf: delete tt-contnf. end.
for each tt-contrato: delete tt-contrato. end.
for each tt-titulo: delete tt-titulo. end.
for each tt-titpag: delete tt-titpag. end.    
for each tt-nottra: delete tt-nottra. end.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - INICIO DO PROCESSO " format "x(30)" skip
        string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Inicio gera temp    " format "x(30)" skip
        string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Ini temp Plani     " format "x(30)" skip.
output close.

assign t-cont = 0 cont = 0.

for each com.plani where com.plani.datexp >= today - dd-rep no-lock.
    find first com.movim where movim.etbcod = plani.etbcod and
                movim.placod = plani.placod and
                movim.movtdc = plani.movtdc and
                movim.movdat = plani.pladat and
                movim.datexp = 01/01/1970
                no-lock no-error.
    if avail com.movim then next.
    
    create tt-plani.
    buffer-copy com.plani to tt-plani.

    cont = cont + 1.
    
    lg-atucom = yes.
end.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Fim temp Plani " format "x(30)"
        " RL " + string(cont) format "x(20)" skip
        string(time,"HH:MM:SS") + " atudbrp.p" format "x(25)"
        " - Ini temp Movim " format "x(30)" skip.
output close.

assign
    t-cont = t-cont + cont
    cont = 0.

for each com.movim where movim.datexp >= today - dd-rep no-lock:

    if com.movim.datexp = 01/01/1970
    then next.
    
    create tt-movim.
    buffer-copy com.movim to tt-movim.

    cont = cont + 1.
        
    lg-atucom = yes.
end.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p" format "x(25)"
        " - Fim temp Movim "  format "x(30)"
        " RL " + string(cont) format "x(20)" skip
        string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Ini temp Contrato/ContNF "  format "x(30)" skip.
output close.

assign
    t-cont = t-cont + cont
    cont = 0.

for each fin.contrato where contrato.dtinicial >= today - dd-rep no-lock.

    if fin.contrato.datexp = 01/01/1970
    then next.
    
    create tt-contrato.
    buffer-copy fin.contrato to tt-contrato.
    
    cont = cont + 1.

    for each fin.contnf where contnf.etbcod  = contrato.etbcod and
                          contnf.contnum = contrato.contnum no-lock.
    
        create tt-contnf.
        buffer-copy fin.contnf to tt-contnf.
    
        cont = cont + 1.

    end.    
    lg-atufin = yes.
end.    

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Fim temp Contrato/ContNF "  format "x(30)"
        " RL " + string(cont) format "x(20)"  skip 
        string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Ini temp Titulos" format "x(30)" skip.
output close.

assign
    t-cont = t-cont + cont
    cont = 0.

for each fin.titulo where   titulo.datexp = today - dd-rep and
                        titulo.exportado = no no-lock.
    if fin.titulo.datexp = 01/01/1970
    then next.

    create tt-titulo.
    buffer-copy fin.titulo to tt-titulo.

    cont = cont + 1.
    
    lg-atufin = yes.

end.
/*
for each fin.titulo where   titulo.titdtpag = today - 5 and
                            titulo.etbcobra = setbcod no-lock.
    if fin.titulo.datexp = 01/01/1970
    then next.

    create tt-titulo.
    buffer-copy fin.titulo to tt-titulo.

    cont = cont + 1.
    
    lg-atufin = yes.

end.
*/

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Fim temp Titulos " format "x(30)"
        " RL " + string(cont) format "x(20)"  skip 
        string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
         " - Ini temp TitPag" format "x(30)" skip.  
output close.

assign
    t-cont = t-cont + cont
    cont = 0.

for each fin.titpag where   titpag.datexp = today - dd-rep and
                        titpag.exportado = no no-lock:

    create tt-titpag.
    buffer-copy fin.titpag to tt-titpag.
    
    cont = cont + 1.
    
    lg-atufin = yes.

end.    
 
output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Fim temp TitPag" format "x(30)"
        " RL " + string(cont) format "x(20)"  skip 
        string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
        " - Ini temp NotTra " format "x(30)" skip.
output close.

assign
    t-cont = t-cont + cont
    cont = 0.

for each com.nottra where nottra.datexp >= today - dd-rep no-lock.

    create tt-nottra.
    buffer-copy com.nottra to tt-nottra.

    cont = cont + 1.

    lg-atuger = yes.

end.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p" format "x(25)"
        " - Fim temp NotTra  "   format "x(30)"
        " RL " + string(cont) format "x(20)" skip 
        string(time,"HH:MM:SS") + " atudbrp.p" format "x(25)"
        " - Fim gera temp    " format "x(30)" skip.
output close.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - PARADA DE 5s  " format "x(30)" skip.
output close.

pause 5 no-message.

if connected("comdbrp")
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - Iniciando atudbrp-com.p  " format "x(30)" skip.
    output close.

    run /admcom/progr/atudbrp-com.p.

end.
else do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - Banco COMDBRP desconectado " format "x(30)" skip.
    output close.
end.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
    " - PARADA DE 5s  " format "x(30)" skip.
output close.

pause 5 no-message.

if connected("findbrp")
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - Iniciando atudbrp-fin.p  " format "x(30)" skip.
    output close.

    run /admcom/progr/atudbrp-fin.p.
end.
else do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - Banco FINDBRP desconectado " format "x(30)" skip.
    output close.
end.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
    " - PARADA DE 5s  " format "x(30)" skip.
output close.

pause 5 no-message.

if connected("gerdbrp")
then do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - Iniciando atudbrp-fin.p  " format "x(30)" skip.
    output close.

    run /admcom/progr/atudbrp-ger.p.
end.
else do:
    output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
     " - Banco GERDBRP desconectado " format "x(30)" skip.
    output close.
end.


output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp.p " format "x(25)"
    " - FIM DO PROCESSO "  format "x(30)" skip.
output close.

