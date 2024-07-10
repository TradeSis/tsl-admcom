def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
def temp-table tt-363
    field PLAN_ID as char format "x(25)"
    field MERCH_LEVEL_ID  as char format "x(25)"
    field START_DATE  as char format "x(14)"    
    field END_DATE    as char format "x(14)"
    field ORIGIN_ID   as char format "x(12)"
    
    
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)".



for each finan where finan.fincod < 100 and
            FINAN.finfat < 9
                        no-lock.

    find first tabaux where tabaux.tabela = "PLANOBIZ" and
                           tabaux.valor_campo = string(finan.fincod)
                           no-lock no-error.
    for each finesp of finan no-lock.
        find clase where clase.clasup = 0 and 
                         clase.clatip and 
                         clase.claper = finesp.catcod no-lock no-error.
            if not avail clase then next.
            create tt-363.
            assign 
                tt-363.PLAN_ID  =   string(fincod)           .
                tt-363.MERCH_LEVEL_ID    =   string(clase.clacod)       .
                tt-363.START_DATE   = string(finesp.datain,"99999999").
                tt-363.END_DATE     = string(finesp.datafi,"99999999").                          tt-363.ORIGIN_ID = "LEBES".
                
            
            tt-363.RECORD_STATUS            = "A"                .
            tt-363.CREATE_USER_ID           = "ADMCOM"           .
            tt-363.CREATE_DATETIME          = vsysdata           .
            tt-363.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-363.LAST_UPDATE_DATETIME     = vsysdata           .
            .

    end.
end.            
output to value("/admcom/tmp/itim/input/ADMCOM_0363_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-363.
    put                      
    PLAN_ID           "|"
    MERCH_LEVEL_ID    "|"
    START_DATE        "|"
    END_DATE          "|"
    ORIGIN_ID         "|"
    RECORD_STATUS     "|"
    CREATE_USER_ID    "|"
    CREATE_DATETIME   "|"
    LAST_UPDATE_USER_ID  "|"
    LAST_UPDATE_DATETIME
    
    
        skip.
        
end.
output close .
