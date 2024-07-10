def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - Fabricante   */
def temp-table tt-217
    field STYLE_ID    as char format "x(25)"
    field ORIGIN_ID   as char format "x(12)"
    field STYLE_DESC  as char format "x(128)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)"
    .

for each produsku no-lock,
    produ of produsku no-lock break by produ.procod.
    if first-of(produ.procod)
    then do.
            create tt-217.
            assign 
            tt-217.STYLE_ID                 = string(produ.procod).
            tt-217.ORIGIN_ID                = "LEBES".
            tt-217.STYLE_DESC               = produ.pronom      .
            tt-217.RECORD_STATUS            = "A"                .
            tt-217.CREATE_USER_ID           = "ADMCOM"           .
            tt-217.CREATE_DATETIME          = vsysdata           .
            tt-217.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-217.LAST_UPDATE_DATETIME     = vsysdata           .
            .
    end.
end.            
output to value("/admcom/progr/itim/ADMCOM_0217_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-217.
    put                      
        tt-217.STYLE_ID                  "|"
        tt-217.ORIGIN_ID                 "|"
        tt-217.STYLE_DESC                "|"
        tt-217.RECORD_STATUS             "|"
        tt-217.CREATE_USER_ID            "|"
        tt-217.CREATE_DATETIME           "|"
        tt-217.LAST_UPDATE_USER_ID       "|"
        tt-217.LAST_UPDATE_DATETIME    
        skip.
        
end.
output close .
