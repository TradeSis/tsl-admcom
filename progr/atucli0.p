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
vdti = today - 3.
vdtf = today.

output to ../work/titcli.log append.
    put "Inicio do processo - Periodo " vdti " Ate " vdtf 
        " Hora: " string(time,"HH:MM:SS") skip. 
output close.


do vdata = vdti to vdtf:
    /* display vdata. pause 0. */
    for each estab no-lock: 
        for each titulo use-index titdtpag where titulo.empcod = 19 and
                             titulo.titnat = no and
                             titulo.modcod = "CRE" and
                             titulo.titdtpag = vdata  and
                             titulo.etbcod = estab.etbcod no-lock 
                                             break by titulo.clifor:
            if first-of(titulo.clifor)
            then do:
               /*  display estab.etbcod titulo.clifor.
                                    with frame f1 centered row 5
                                        1 down side-label. pause 0. */ 
                for each tt-cli:
                    delete tt-cli.
                end.
    
                do transaction:
                    for each titcli where titcli.clicod = titulo.clifor:
                        delete titcli.
                    end.
                end.
    
                xx = 0.
    
                for each btitulo use-index iclicod 
                                      where btitulo.empcod = 19    and    
                                            btitulo.titnat = no    and
                                            btitulo.modcod = "CRE" and
                                            btitulo.clifor = titulo.clifor and
                                            btitulo.titsit = "LIB" no-lock.
                    find first tt-cli where 
                               tt-cli.etbcod = btitulo.etbcod and
                               tt-cli.clicod = btitulo.clifor no-error.
                    if not avail tt-cli
                    then do:
                        create tt-cli.
                        assign tt-cli.etbcod = btitulo.etbcod
                               tt-cli.clicod = btitulo.clifor.
                        xx = xx + 1.
                    end.
                end.
                if xx <= 1
                then next.
                for each tt-cli:
                    do transaction:
                        find titcli where titcli.clicod = tt-cli.clicod and
                                          titcli.etbcod = tt-cli.etbcod 
                                                                    no-error.
                        if not avail titcli
                        then do:
                            create titcli.
                            assign titcli.etbcod = tt-cli.etbcod
                                   titcli.clicod = tt-cli.clicod 
                                   titcli.dtexp  = today
                                   titcli.flag   = yes.
                        end.
                    end.
                end.
            end.
        end.
        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial = vdata no-lock
                                        break by contrato.clicod:
    
            if first-of(contrato.clicod)
            then do:
                /*
                display estab.etbcod contrato.clicod
                                    with frame f2 centered row 10
                                        1 down side-label. pause 0. */ 
                for each tt-cli:
                    delete tt-cli.
                end.
    
                do transaction:
                    for each titcli where titcli.clicod = contrato.clicod:
                        delete titcli.
                    end.
                end.
    
                xx = 0.
    
                for each btitulo use-index iclicod where 
                                           btitulo.empcod = 19    and    
                                           btitulo.titnat = no    and
                                           btitulo.modcod = "CRE" and
                                           btitulo.clifor = contrato.clicod and
                                           btitulo.titsit = "LIB" no-lock.
                    find first tt-cli where 
                                tt-cli.etbcod = btitulo.etbcod and
                                tt-cli.clicod = btitulo.clifor no-error.
                    if not avail tt-cli
                    then do:
                        create tt-cli.
                        assign tt-cli.etbcod = btitulo.etbcod
                               tt-cli.clicod = btitulo.clifor.
                        xx = xx + 1.
                    end.
                end.
                if xx <= 1
                then next.
                for each tt-cli:
                    do transaction:
                        find titcli where titcli.clicod = tt-cli.clicod and
                                          titcli.etbcod = tt-cli.etbcod 
                                                            no-error.
                        if not avail titcli
                        then do:
                            create titcli.
                            assign titcli.etbcod = tt-cli.etbcod
                                   titcli.clicod = tt-cli.clicod 
                                   titcli.dtexp  = today
                                   titcli.flag   = yes.
                        end.
                    end.
                end.
            end.
        end.
    end.
end.


for each titcli no-lock break by clicod
                              by etbcod.

    if first-of(titcli.clicod)
    then assign ss = 0
                nn = 0.
                
    if titcli.etbcod = 01 or
       titcli.etbcod = 06 or
       titcli.etbcod = 17
    then ss = ss + 1.
    else nn = nn + 1.
    
    if last-of(titcli.clicod)
    then do:
        
        if ss > 0 and
           nn = 0
        then do:
            for each btitcli where btitcli.clicod = titcli.clicod.
            
                delete btitcli. 
                
            end.
        end.  
        ss = 0.
        nn = 0.
    end.
    
end.

for each titcli no-lock break by clicod
                              by etbcod.

    if first-of(titcli.clicod)
    then assign ss = 0
                nn = 0.
                
    if titcli.etbcod = 10 or
       titcli.etbcod = 23
    then ss = ss + 1.
    else nn = nn + 1.
    
    if last-of(titcli.clicod)
    then do:
        
        if ss > 0 and
           nn = 0
        then do:
            for each btitcli where btitcli.clicod = titcli.clicod.
            
                delete btitcli. 
                
            end.
        end.  
        ss = 0.
        nn = 0.
    end.
    
end.




for each titcli no-lock break by clicod
                              by etbcod.

    if first-of(titcli.clicod)
    then assign ss = 0
                nn = 0.
                
    if titcli.etbcod = 15 or
       titcli.etbcod = 34 
    then ss = ss + 1.
    else nn = nn + 1.
    
    if last-of(titcli.clicod)
    then do:
        
        if ss > 0 and
           nn = 0
        then do:
            for each btitcli where btitcli.clicod = titcli.clicod.
            
                delete btitcli. 
                
            end.
        end.  
        ss = 0.
        nn = 0.
    end.
    
end.

for each estab no-lock: 
    for each titulo where titulo.empcod = 19    and
                          titulo.titnat = no    and
                          titulo.modcod = "GLO" and
                          titulo.titsit = "LIB" and
                          titulo.etbcod = estab.etbcod 
                                no-lock break by titulo.clifor:
        if first-of(titulo.clifor)
        then do:

            find titcli where titcli.clicod = titulo.clifor and
                              titcli.etbcod = titulo.etbcod no-error.
            if not avail titcli
            then do:
                create titcli.
                assign titcli.etbcod = tt-cli.etbcod
                       titcli.clicod = tt-cli.clicod 
                       titcli.dtexp  = today
                       titcli.flag   = yes.
            end.
        end.
    end.
end.

connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d.

run atudrag.p.

if connected ("d") 
then disconnect d.

output to ../work/titcli.log append.
    put "Final do processo - Periodo " vdti " Ate " vdtf 
        " Hora: " string(time,"HH:MM:SS") skip. 
output close.

/* message "P R O C E S S O   E N C E R R A D O".  */

return.
 
