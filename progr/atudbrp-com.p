{/admcom/progr/admcab-batch.i}

def shared var dd-rep as int.
def shared var vlog as char.

def var cont-sel as int.
def var cont-atu as int.

FUNCTION acha-pro returns character
    (input par-oque as char,
     input par-onde as char,
     input par-proc as char).
              
    def var vx as int.
    def var vret as char.
  
    vret = ?.
                          
    do vx = 1 to num-entries(par-onde,"|").
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque
        then do:
            vret = entry(2,entry(vx,par-onde,"|"),"=").
            if vret = par-proc
            then leave.
        end.
    end.
    return vret.
END FUNCTION.

def new shared temp-table tt-plani         like com.plani.
def new shared temp-table tt-movim         like com.movim.
def new shared temp-table tt-contnf        like fin.contnf.
def new shared temp-table tt-contrato      like fin.contrato.
def new shared temp-table tt-titulo        like fin.titulo.
def new shared temp-table tt-titpag        like fin.titpag. 
def new shared temp-table tt-nottra        like com.nottra.

def var lg-novo                     as log.
def var i                           as int.
def var vpednum                     like com.pedid.pednum.
def var videal                      as log.

def var vlog1                       as char.
def buffer bpedid                   for com.pedid.

output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Inicio do processo  " format "x(30)" skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu Produ " format "x(30)" skip.
output close.

assign
    cont-sel = 0 cont-atu = 0.

for each com.produ where 
         com.produ.datexp <> ? and
         com.produ.datexp >= today - dd-rep 
         no-lock: 
    cont-sel = cont-sel + 1.
    find first comdbrp.produ where
               comdbrp.produ.procod = com.produ.procod 
               exclusive no-wait no-error.
    if not avail comdbrp.produ
    then do:
        if locked comdbrp.produ
        then.
        else do: 
            create comdbrp.produ.
            {tt-produ.i comdbrp.produ com.produ}
            comdbrp.produ.exportado = yes.
            cont-atu = cont-atu + 1.
        end.
    end.
end.  

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu Produ    "   format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
        format "x(25)"  skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu Unida    " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each comdbrp.unida:
    cont-sel = cont-sel + 1.
    do transaction:
        delete comdbrp.unida.
        cont-atu = cont-atu + 1.
    end.    
end.    
    
for each com.unida no-lock:
    cont-sel = cont-sel + 1.
    find comdbrp.unida where comdbrp.unida.unicod = com.unida.unicod 
        exclusive no-wait no-error.
    if not avail comdbrp.unida
    then do:
        if locked comdbrp.unida
        then .
        else do:
            create comdbrp.unida.
            assign comdbrp.unida.unicod = com.unida.unicod
               comdbrp.unida.uninom = com.unida.uninom.
            cont-atu = cont-atu + 1.
        end.
    end.
end.
               
output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu Unida     " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu) 
            format "x(25)"  skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu Classe    "  format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each com.clase no-lock:
    cont-sel = cont-sel + 1.
    find comdbrp.clase where
         comdbrp.clase.clacod = com.clase.clacod 
         exclusive no-wait no-error.
    if not avail comdbrp.clase
    then do:
        if locked comdbrp.clase
        then.
        else do:
            create comdbrp.clase.
            buffer-copy com.clase to comdbrp.clase.
            cont-atu = cont-atu + 1.
        end.
    end.
end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu Classe     " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string( cont-atu)
          format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu Estoq/Preco " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each com.estoq where com.estoq.datexp >= today - dd-rep   
                           and com.estoq.datexp <> ? 
                           and com.estoq.etbcod = setbcod
                           no-lock:
    cont-sel = cont-sel + 1.
    find first comdbrp.estoq where comdbrp.estoq.procod = com.estoq.procod
                           and comdbrp.estoq.etbcod = com.estoq.etbcod
                           exclusive no-wait no-error.
    if not avail comdbrp.estoq
    then do:
        if locked comdbrp.estoq
        then.
        else do:
            create comdbrp.estoq.
            {tt-estoq.i comdbrp.estoq com.estoq}.
        end.    
    end.        
    else do:
        assign
                comdbrp.estoq.estvenda  = com.estoq.estvenda
                comdbrp.estoq.estcusto  = com.estoq.estcusto
                comdbrp.estoq.estproper = com.estoq.estproper
                comdbrp.estoq.estbaldat = com.estoq.estbaldat
                comdbrp.estoq.estprodat = com.estoq.estprodat
                comdbrp.estoq.estrep    = com.estoq.estrep
                comdbrp.estoq.estmin    = com.estoq.estmin
                comdbrp.estoq.tabcod    = com.estoq.tabcod
                comdbrp.estoq.estinvdat = com.estoq.estinvdat.

    end.
end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu Estoq/Preco "  format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
         format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu ProduAux    " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

def buffer bproduaux for comdbrp.produaux.
for each com.produaux where
         com.produaux.exportar = yes and
         com.produaux.datexp <> ? and
         com.produaux.datexp >= today - 1
         no-lock:

    if ((com.produaux.nome_campo = "inc-mix" or
        com.produaux.nome_campo  = "exc-mix") and
       int(com.produaux.valor_campo) = setbcod) 
    then.
    else if com.produaux.nome_campo <> "produ-equivalente" and
            com.produaux.nome_campo <> "ST"
        then next.

    cont-sel = cont-sel + 1.
    find comdbrp.produaux where 
         comdbrp.produaux.procod = com.produaux.procod and
         comdbrp.produaux.nome_campo = com.produaux.nome_campo and
         comdbrp.produaux.valor_campo = com.produaux.valor_campo
         exclusive no-wait no-error.
    if not avail comdbrp.produaux 
    then do:
        if locked comdbrp.produaux
        then.
        else do:
            if com.produaux.nome_campo = "exc-mix"
            then do:
                find comdbrp.produaux where 
                  comdbrp.produaux.procod = com.produaux.procod and
                  comdbrp.produaux.nome_campo = "inc-mix" and
                  comdbrp.produaux.valor_campo = com.produaux.valor_campo
                  exclusive no-wait no-error.
                if avail comdbrp.produaux
                then do:
                    find bproduaux where 
                        bproduaux.procod = com.produaux.procod and
                        bproduaux.nome_campo = "exc-mix" and
                        bproduaux.valor_campo = com.produaux.valor_campo
                        exclusive no-wait no-error.
                    if avail bproduaux
                    then delete bproduaux.
                    buffer-copy com.produaux to comdbrp.produaux.
                end.
                else do:
                    create comdbrp.produaux.
                    buffer-copy com.produaux to comdbrp.produaux.
                end.
            end.
            else if com.produaux.nome_campo = "inc-mix"
            then do:
                find comdbrp.produaux where 
                  comdbrp.produaux.procod = com.produaux.procod and
                  comdbrp.produaux.nome_campo = "exc-mix" and
                  comdbrp.produaux.valor_campo = com.produaux.valor_campo
                  exclusive no-wait no-error.
                if avail comdbrp.produaux
                then do:
                    find bproduaux where 
                        bproduaux.procod = com.produaux.procod and
                        bproduaux.nome_campo = "inc-mix" and
                        bproduaux.valor_campo = com.produaux.valor_campo
                        exclusive no-wait no-error.
                    if avail bproduaux
                    then delete bproduaux.
                    buffer-copy com.produaux to comdbrp.produaux.
                end.
                else do:
                    create comdbrp.produaux.
                    buffer-copy com.produaux to comdbrp.produaux.
                end.
            end.
            else if not avail comdbrp.produaux and not locked comdbrp.produaux
            then do:
                create comdbrp.produaux.
                buffer-copy com.produaux to comdbrp.produaux.
            end.
            cont-atu = cont-atu + 1.
        end.
    end.
    else do:
        if com.produaux.nome_campo = "exc-mix"
        then do:
            find comdbrp.produaux where 
                  comdbrp.produaux.procod = com.produaux.procod and
                  comdbrp.produaux.nome_campo = "inc-mix" and
                  comdbrp.produaux.valor_campo = com.produaux.valor_campo
                  exclusive no-wait no-error.
            if avail comdbrp.produaux
            then do:
                find bproduaux where 
                  bproduaux.procod = com.produaux.procod and
                  bproduaux.nome_campo = "exc-mix" and
                  bproduaux.valor_campo = com.produaux.valor_campo
                  exclusive no-wait no-error.
                if avail bproduaux
                then delete bproduaux.
                buffer-copy com.produaux to comdbrp.produaux.
            end.
            else do:
                create comdbrp.produaux.
                buffer-copy com.produaux to comdbrp.produaux.
            end.
        end.
        else if com.produaux.nome_campo = "inc-mix"
        then do:
            find comdbrp.produaux where 
                  comdbrp.produaux.procod = com.produaux.procod and
                  comdbrp.produaux.nome_campo = "exc-mix" and
                  comdbrp.produaux.valor_campo = com.produaux.valor_campo
                  exclusive no-wait no-error.
            if avail comdbrp.produaux
            then do:
                find bproduaux where 
                  bproduaux.procod = com.produaux.procod and
                  bproduaux.nome_campo = "inc-mix" and
                  bproduaux.valor_campo = com.produaux.valor_campo
                  exclusive no-wait no-error.
                if avail bproduaux
                then delete bproduaux.

                buffer-copy com.produaux to comdbrp.produaux.
            end.
            else do:
                create comdbrp.produaux.
                buffer-copy com.produaux to comdbrp.produaux.
            end.
        end.
        else comdbrp.produaux.datexp = com.produaux.datexp.
        cont-atu = cont-atu + 1.
    end.
end.             
             
output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu ProduAux    "  format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
         format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu Plani    " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each tt-plani:
 
    cont-sel = cont-sel + 1.
    find first comdbrp.plani where comdbrp.plani.etbcod = tt-plani.etbcod
                               and comdbrp.plani.placod = tt-plani.placod 
                               and comdbrp.plani.movtdc = tt-plani.movtdc
                               exclusive no-wait no-error.
    if not avail comdbrp.plani
    then do:
        if locked comdbrp.plani
        then.
        else do:
            create comdbrp.plani.
            {t-plani.i comdbrp.plani tt-plani}.
            cont-atu = cont-atu + 1.
        end.
    end.
end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu Plani    "  format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
         format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Ini atu Movim    " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each tt-movim:
    cont-sel = cont-sel + 1.
    find first comdbrp.movim where 
                       comdbrp.movim.etbcod = tt-movim.etbcod
                   and comdbrp.movim.placod = tt-movim.placod
                   and comdbrp.movim.procod = tt-movim.procod 
                   exclusive no-wait no-error.
    if not avail comdbrp.movim
    then do:
        if locked comdbrp.movim
        then.
        else do:
        create comdbrp.movim.
        {t-movim.i comdbrp.movim tt-movim}.
        cont-atu = cont-atu + 1.
    end.
end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-com.p " format "x(25)"
        " - Fim atu Movim  " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

output to value(vlog)  append.
        " - Final do processo " format "x(30)" skip.
output close.        


