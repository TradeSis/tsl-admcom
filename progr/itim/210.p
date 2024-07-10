
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - Fabricante   */
def temp-table tt-210
    field LABEL_ID              as char format "x(25)"
    field ORIGIN_ID             as char format "x(12)"
    field LABEL_DESC            as char format "x(64)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)"
    .
    
def temp-table tt-225
    field SUPPLIER_ID as char format "x(10)" 
    field ORIGIN_ID   as char format "x(12)" 
    field VAT_REGION_ID   as char format "x(4)" 
    field SUPPLIER_DESC   as char format "x(64)" 
    field RECORD_STATUS   as char format "x(1)" 
    field CREATE_USER_ID  as char format "x(25)" 
    field CREATE_DATETIME as char format "x(14)" 
    field LAST_UPDATE_USER_ID as char format "x(25)" 
    field LAST_UPDATE_DATETIME    as char format "x(14)"        
    .

for each fabri    no-lock.
       
            create tt-210.
            assign 
            tt-210.LABEL_ID                 = string(fabri.fabcod).
            tt-210.ORIGIN_ID                = "LEBES".
            tt-210.LABEL_DESC               = fabri.fabnom       .
            tt-210.RECORD_STATUS            = "A"                .
            tt-210.CREATE_USER_ID           = "ADMCOM"           .
            tt-210.CREATE_DATETIME          = vsysdata           .
            tt-210.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-210.LAST_UPDATE_DATETIME     = vsysdata           .
            .
    create tt-225.
    tt-225.SUPPLIER_ID              = string(fabri.fabcod).
    tt-225.ORIGIN_ID                = "LEBES".
    tt-225.VAT_REGION_ID            = "RS".
    tt-225.SUPPLIER_DESC            = fabri.fabnom       .
    
    tt-225.RECORD_STATUS            = "A"                . 
    tt-225.CREATE_USER_ID           = "ADMCOM"           .     tt-225.CREATE_DATETIME          = vsysdata           .
    tt-225.LAST_UPDATE_USER_ID      = "ADMCOM"           .
    tt-225.LAST_UPDATE_DATETIME     = vsysdata           .    

end.            
            

output to value("/admcom/tmp/itim/input/ADMCOM_0210_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-210.
    put                      
        tt-210.LABEL_ID                  "|"
        tt-210.ORIGIN_ID                 "|"
        tt-210.LABEL_DESC                "|"
        tt-210.RECORD_STATUS             "|"
        tt-210.CREATE_USER_ID            "|"
        tt-210.CREATE_DATETIME           "|"
        tt-210.LAST_UPDATE_USER_ID       "|"
        tt-210.LAST_UPDATE_DATETIME      
        skip.
        
end.
output close.
output to value("/admcom/tmp/itim/input/ADMCOM_0225_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-225.
    put                      
        SUPPLIER_ID       "|"
        tt-225.ORIGIN_ID         "|"
        VAT_REGION_ID      "|"
        SUPPLIER_DESC         "|"
        tt-225.RECORD_STATUS             "|"
        tt-225.CREATE_USER_ID            "|"
        tt-225.CREATE_DATETIME           "|"
        tt-225.LAST_UPDATE_USER_ID       "|"
        tt-225.LAST_UPDATE_DATETIME      
        skip.
        
end.
output close.

