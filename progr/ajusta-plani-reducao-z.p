{admcab.i new}

def var vlinha as char.

def temp-table tt-plani
    field etbcod            as integer
    field pladat            as date
    field cxacod            as integer
    field diferenca         as decimal.

def buffer bplani for plani.

def buffer btt-plani for tt-plani.

def var vufemi-aux as char.

def var vcont1      as integer.

def var vcont2      as integer.

/*
unix silent
   value("/usr/dlc/bin/quoter /admcom/audit/importar-lmn.csv
                    > /admcom/audit/importar-lmn2.csv").
*/                                                            
input from value("/admcom/audit/importar-lmn.csv").

repeat:

    import vlinha.
    
    create tt-plani.
    assign tt-plani.etbcod    = integer(entry(1,vlinha,";"))
           tt-plani.pladat    = date(entry(2,vlinha,";"))
           tt-plani.cxacod    = integer(entry(3,vlinha,";"))
           tt-plani.diferenca = decimal(entry(4,vlinha,";")).

end.

for each tt-plani no-lock.

    release bplani.
    release plani.
    release btt-plani.
    assign vufemi-aux = "".

    find first plani where plani.movtdc = 5
                       and plani.etbcod = tt-plani.etbcod
                       and plani.pladat = tt-plani.pladat
                       and plani.cxacod = tt-plani.cxacod
                       and plani.platot = tt-plani.diferenca
                                exclusive-lock no-error.
                                
    if avail plani
    then do:
                
        find first btt-plani where btt-plani.etbcod = tt-plani.etbcod
                               and btt-plani.pladat = tt-plani.pladat 
                               and btt-plani.cxacod <> tt-plani.cxacod  
                               and btt-plani.diferenca
                                    = (tt-plani.diferenca * - 1)
                                        no-lock no-error.
        if avail btt-plani
        then do:
            
            find first plani where plani.movtdc = 5
                               and plani.etbcod = tt-plani.etbcod
                               and plani.pladat = tt-plani.pladat
                               and plani.cxacod = tt-plani.cxacod
                               and plani.platot = tt-plani.diferenca
                                        exclusive-lock no-error.

            assign vcont1 = vcont1 + 1.

        end.
        
    end.    
    else do: assign vcont2 = vcont2 + 1.
                                         /*
        display tt-plani.etbcod   
        tt-plani.pladat   
        tt-plani.cxacod   
        tt-plani.diferenca .
                                           */

    end.
    

end.



display vcont1
        vcont2.
