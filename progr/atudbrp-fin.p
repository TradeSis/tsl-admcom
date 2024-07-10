{/admcom/progr/admcab-batch.i}

def shared var dd-rep as int.
def shared var vlog as char.

def var cont-sel as int.
def var cont-atu as int.

def new shared temp-table tt-plani         like com.plani.
def new shared temp-table tt-movim         like com.movim.
def new shared temp-table tt-contnf        like fin.contnf.
def new shared temp-table tt-contrato      like fin.contrato.
def new shared temp-table tt-titulo        like fin.titulo.
def new shared temp-table tt-titpag        like fin.titpag. 
def new shared temp-table tt-nottra        like com.nottra.

def buffer bestab   for ger.estab.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Inicio do processo  " format "x(30)" skip
       .
output close.

assign
    cont-sel = 0 cont-atu = 0.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Ini atu ContNF    " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each tt-contnf:
    cont-sel = cont-sel + 1.
    find findbrp.contnf where 
         findbrp.contnf.etbcod  = tt-contnf.etbcod and
         findbrp.contnf.placod  = tt-contnf.placod and
         findbrp.contnf.contnum = tt-contnf.contnum  
         exclusive no-wait no-error.
    if locked findbrp.contnf
    then next.
    
    if not avail findbrp.contnf
    then create findbrp.contnf.
    
    ASSIGN
        findbrp.contnf.contnum   = tt-contnf.contnum
        findbrp.contnf.PlaCod    = tt-contnf.PlaCod
        findbrp.contnf.notanum   = tt-contnf.notanum
        findbrp.contnf.notaser   = tt-contnf.notaser
        findbrp.contnf.EtbCod    = tt-contnf.EtbCod.
                           
    cont-atu = cont-atu + 1.

end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Fim atu ContNF    " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Ini atu Contrato  " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each tt-contrato:
    cont-sel = cont-sel + 1.
    find findbrp.contrato where 
         findbrp.contrato.contnum = tt-contrato.contnum  
         exclusive no-wait no-error.
    if locked findbrp.contrato
    then next.
    
    if not avail findbrp.contrato
    then create findbrp.contrato.

    ASSIGN
        findbrp.contrato.contnum   = tt-contrato.contnum
        findbrp.contrato.clicod    = tt-contrato.clicod
        findbrp.contrato.autoriza  = tt-contrato.autoriza
        findbrp.contrato.dtinicial = tt-contrato.dtinicial
        findbrp.contrato.etbcod    = tt-contrato.etbcod
        findbrp.contrato.banco     = tt-contrato.banco
        findbrp.contrato.vltotal   = tt-contrato.vltotal
        findbrp.contrato.vlentra   = tt-contrato.vlentra
        findbrp.contrato.situacao  = tt-contrato.situacao
        findbrp.contrato.indimp    = tt-contrato.indimp
        findbrp.contrato.lotcod    = tt-contrato.lotcod
        findbrp.contrato.crecod    = tt-contrato.crecod
        findbrp.contrato.vlfrete   = tt-contrato.vlfrete
        findbrp.contrato.datexp    = tt-contrato.datexp.
        
    cont-atu = cont-atu + 1.

end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Fim atu Contrato  "  format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip.
output close.

assign cont-sel = 0 cont-atu = 0.


output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Ini atu Titulo  " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.


run /admcom/progr/atudbrp-tit.p.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-fin.p " format "x(25)"
        " - Fim atu Titulo " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Final do processo " format "x(30)" skip.
output close.        




