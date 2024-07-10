
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - temporada   */
def temp-table tt-219
    field SEASON_ID             as char format "x(10)"
    field ORIGIN_ID             as char format "x(12)"
    field SEASON_DESC           as char format "x(64)"
    field START_DATE            as char format "x(14)"
    field END_DATE              as char format "x(14)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)"
    
    .


for each temporada no-lock.
       
            create tt-219.
            assign 
            tt-219.SEASON_ID             = string(temporada.temp-cod)      .
            tt-219.ORIGIN_ID             = "LEBES"                 .
            tt-219.SEASON_DESC           = temporada.tempnom       .
            tt-219.START_DATE            = string(temporada.dtini,"99999999")
                                .
            tt-219.END_DATE              = string(temporada.dtfim,"99999999")         
            .
            tt-219.RECORD_STATUS         = "A"                     .
            tt-219.CREATE_USER_ID        = "ADMCOM"                .
            tt-219.CREATE_DATETIME       = vsysdata                .
            tt-219.LAST_UPDATE_USER_ID   = "ADMCOM"                .
            tt-219.LAST_UPDATE_DATETIME  = vsysdata
            .
end.            
            

output to value("/admcom/tmp/itim/input/ADMCOM_0219_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-219.
    put                      
        tt-219.SEASON_ID              "|"
        tt-219.ORIGIN_ID              "|"
        tt-219.SEASON_DESC            "|"
        tt-219.START_DATE             "|"
        tt-219.END_DATE               "|"
        tt-219.RECORD_STATUS          "|"
        tt-219.CREATE_USER_ID         "|"
        tt-219.CREATE_DATETIME        "|"
        tt-219.LAST_UPDATE_USER_ID    "|"
        tt-219.LAST_UPDATE_DATETIME   
        
        skip.
        
end.
output close.
