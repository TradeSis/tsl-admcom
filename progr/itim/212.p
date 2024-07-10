
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - temporada   */
def temp-table tt-212
    field VAT_REGION_ID   as char format "x(4)"
    field ORIGIN_ID   as char format "x(12)"
    field VAT_REGION_DESC as char format "x(64)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(14)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(14)"
    .


for each unfed no-lock.
       
            create tt-212.
            assign 
            tt-212.VAT_REGION_ID         = string(unfed.ufecod)      .
            tt-212.ORIGIN_ID             = "LEBES"                 .
            tt-212.VAT_REGION_DESC       = unfed.ufenom            .
            tt-212.RECORD_STATUS         = "A"                     .
            tt-212.CREATE_USER_ID        = "ADMCOM"                .
            tt-212.CREATE_DATETIME       = vsysdata                .
            tt-212.LAST_UPDATE_USER_ID   = "ADMCOM"                .
            tt-212.LAST_UPDATE_DATETIME  = vsysdata
            .
end.            
            

output to value("/admcom/tmp/itim/input/ADMCOM_0212_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-212.
    put                      
        tt-212.VAT_REGION_ID             "|"
        tt-212.ORIGIN_ID                 "|"
        tt-212.VAT_REGION_DESC           "|"
        tt-212.RECORD_STATUS             "|"
        tt-212.CREATE_USER_ID            "|"
        tt-212.CREATE_DATETIME           "|"
        tt-212.LAST_UPDATE_USER_ID       "|"
        tt-212.LAST_UPDATE_DATETIME      
        skip.
        
end.
output close.
