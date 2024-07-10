{/admcom/progr/admcab-batch.i}

def shared var dd-rep as int.
def shared var vlog as char.

def var cont-sel as int.
def var cont-atu as int.

def var i as int.


output to value(vlog) append.
    put string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Inicio do processo  " format "x(30)" skip
        string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Ini atu Clien     " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each ger.clien where 
             ger.clien.datexp <> ? and
             ger.clien.datexp >= today - dd-rep
             no-lock:
    if ger.clien.clinom = ""
    then next.
    if ger.clien.clicod = 0 
    then next.
    
    cont-sel = cont-sel + 1.
    
    find first gerdbrp.clien where
                 gerdbrp.clien.clicod = ger.clien.clicod 
                 exclusive no-wait no-error.
    if locked gerdbrp.clien
    then next.
            
    if not avail gerdbrp.clien
    then do:
        create gerdbrp.clien.
        {tt-clien.i gerdbrp.clien ger.clien}
            
        find ger.carro where 
                    ger.carro.clicod = gerdbrp.clien.clicod 
                            no-lock no-error.
        if avail ger.carro
        then do:
            find gerdbrp.carro where 
                 gerdbrp.carro.clicod = ger.carro.clicod
                       exclusive no-wait no-error.
            if locked gerdbrp.carro
            then next.
            if not avail gerdbrp.carro
            then do:
                    create gerdbrp.carro.
                    assign gerdbrp.carro.clicod = ger.carro.clicod.
            end.
            assign gerdbrp.carro.carsit = ger.carro.carsit
                       gerdbrp.carro.datexp = ger.carro.datexp
                       gerdbrp.carro.carsit = ger.carro.carsit
                       gerdbrp.carro.modelo = ger.carro.modelo
                       gerdbrp.carro.marca  = ger.carro.marca
                       gerdbrp.carro.ano    = ger.carro.ano.
            
        end.
        cont-atu = cont-atu + 1.
    end.
end.    

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Fim atu Clien     " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
        format "x(25)"  skip
        string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Ini atu CpClien    "  format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each ger.cpclien where 
             ger.cpclien.datexp <> ? and
             ger.cpclien.datexp >= today -dd-rep      no-lock.
    cont-sel = cont-sel + 1.
    find gerdbrp.cpclien where  
             gerdbrp.cpclien.clicod = ger.cpclien.clicod
             exclusive no-wait no-error.
    if locked gerdbrp.cpclien
    then next.    
    if not avail gerdbrp.cpclien
    then do:
             create gerdbrp.cpclien.
             buffer-copy ger.cpclien to gerdbrp.cpclien.
    end.
    cont-atu = cont-atu + 1.
    
end.
         
output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Fim atu CpClien   "  format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
            " - Ini atu Func       " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each ger.func where ger.func.fundtcad >= today - dd-rep 
                            no-lock .
    cont-sel = cont-sel + 1.
         
    find first  gerdbrp.func where 
                gerdbrp.func.funcod = ger.func.funcod
            and gerdbrp.func.etbcod = ger.func.etbcod
            exclusive no-wait  no-error.
    if locked gerdbrp.func
    then next.    
    if not avail gerdbrp.func
    then do:
        create gerdbrp.func.
        {tt-func.i gerdbrp.func ger.func}.
        cont-atu = cont-atu + 1.
    end.
end.
    
output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Fim atu Func      "  format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip.
output close.        

    
output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " aturep03-ger.p " format "x(25)"
            " - Ini atu Estab       " format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.

for each ger.estab no-lock:    
    cont-sel = cont-sel + 1.
    find gerdbrp.estab where gerdbrp.estab.etbcod = ger.estab.etbcod 
        exclusive no-wait no-error.
    if locked gerdbrp.estab
    then next.
    
    if not avail gerdbrp.estab
    then do:
        create gerdbrp.estab.
        assign gerdbrp.estab.etbcod = ger.estab.etbcod.
        {estab.i gerdbrp.estab ger.estab} .
        cont-atu = cont-atu + 1.
    end.
end.

output to value(vlog)  append.
    put string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Fim atu Estab    " format "x(30)"
        " RL " + string(cont-sel) + " RA " + string(cont-atu)
          format "x(25)" skip
        string(time,"HH:MM:SS") + " atudbrp-ger.p " format "x(25)"
        " - Final do processo "  format "x(30)" skip.
output close.        

assign cont-sel = 0 cont-atu = 0.


