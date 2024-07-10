def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - Fabricante   */
def temp-table tt-218
    field LINE_ID     as char format "x(25)"
    field ORIGIN_ID   as char format "x(12)"
    field LINE_DESCC  as char format "x(100)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)"
    index LINE_ID is primary unique LINE_ID.
    .

for each producor no-lock.
    find produ of producor no-lock.
    find cores of producor no-lock.
            create tt-218.
            assign 
            tt-218.LINE_ID     = trim(string((producor.procod)) + "-" +
                                      string((producor.cor)))  .
            tt-218.ORIGIN_ID                = "LEBES".
            tt-218.LINE_DESCC  = trim(string(trim(produ.pronom))  + " " +
                                      string(trim(cores.Desc_cor)))
                                             .
            tt-218.RECORD_STATUS            = "A"                .
            tt-218.CREATE_USER_ID           = "ADMCOM"           .
            tt-218.CREATE_DATETIME          = vsysdata           .
            tt-218.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-218.LAST_UPDATE_DATETIME     = vsysdata           .
            .
end.            
output to value("/admcom/progr/itim/ADMCOM_0218_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-218.
    put                      
        tt-218.LINE_ID                   "|"
        tt-218.ORIGIN_ID                 "|"
        tt-218.LINE_DESCC                "|"
        tt-218.RECORD_STATUS             "|"
        tt-218.CREATE_USER_ID            "|"
        tt-218.CREATE_DATETIME           "|"
        tt-218.LAST_UPDATE_USER_ID       "|"
        tt-218.LAST_UPDATE_DATETIME    
        skip.
        
end.
output close .
