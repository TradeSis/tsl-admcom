def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
def temp-table tt-220
    field UDA_ID  as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field UDA_DESC    as char format "x(40)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(16)".

for each subcarac no-lock.

    if subcarac.subdes matches ("*NAO USAR*") or
       subcarac.subdes matches "*INATIVO*"
    then next.
    
            create tt-220.
            assign 
            tt-220.UDA_ID                   = string(subcarac.subcod) .
            tt-220.ORIGIN_ID                = "LEBES".
            tt-220.UDA_DESC                 = subcarac.subdes.
            tt-220.RECORD_STATUS            = "A"                .
            tt-220.CREATE_USER_ID           = "ADMCOM"           .
            tt-220.CREATE_DATETIME          = vsysdata           .
            tt-220.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-220.LAST_UPDATE_DATETIME     = vsysdata           .
            .
end.          
  
output to value("/admcom/tmp/itim/input/ADMCOM_0220_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-220.
    put                      
        tt-220.UDA_ID                    "|"
        tt-220.ORIGIN_ID                 "|"
        tt-220.UDA_DESC                  "|"
        tt-220.RECORD_STATUS             "|"
        tt-220.CREATE_USER_ID            "|"
        tt-220.CREATE_DATETIME           "|"
        tt-220.LAST_UPDATE_USER_ID       "|"
        tt-220.LAST_UPDATE_DATETIME    
        skip.
        
end.
output close .
