def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
def temp-table tt-291
    field INSTALLMENT_PAYMENT_ID  as char format "x(12)"
    field INSTALLMENT_PAYMENT_DESC    as char format "x(64)"
    field INSTALLMENTS_NUMBER as int format "99"
    field FULL_INTEREST_RATE    as dec format ">>>>>>>>>>>>>>>>9999"
    field DOWN_PAYMENT          as dec format ">>>>>>>>>>>>>>>>9999"
    field FIRST_PAYMENT_GAP     as dec format ">>>>>>>>>>>>>>>>9999"
    field INST_PAYMENT_PLANS_ATTR_01_FLAG as char format "x(1)"
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
            create tt-291.
            assign 
                tt-291.INSTALLMENT_PAYMENT_ID  =   string(fincod)           .
                tt-291.INSTALLMENT_PAYMENT_DESC    =   finnom       .
                tt-291.INSTALLMENTS_NUMBER =   finnpc               .
                tt-291.FULL_INTEREST_RATE  =   finfat  * 10000             .
                tt-291.DOWN_PAYMENT    =   (if finent then 1 else 0) * 10000  .
                tt-291.FIRST_PAYMENT_GAP   =  finan.DPriPag  * 10000           .
                tt-291.INST_PAYMENT_PLANS_ATTR_01_FLAG = if avail tabaux
                                then "Y" else "N"
                        
                        .

            
            tt-291.RECORD_STATUS            = "A"                .
            tt-291.CREATE_USER_ID           = "ADMCOM"           .
            tt-291.CREATE_DATETIME          = vsysdata           .
            tt-291.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-291.LAST_UPDATE_DATETIME     = vsysdata           .
            .

end.            
output to value("/admcom/tmp/itim/input/ADMCOM_0291_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-291.
    put                      
    tt-291.INSTALLMENT_PAYMENT_ID  "|"
    tt-291.INSTALLMENT_PAYMENT_DESC    "|"
    tt-291.INSTALLMENTS_NUMBER "|"
    tt-291.FULL_INTEREST_RATE  "|"
    tt-291.DOWN_PAYMENT    "|"
    tt-291.FIRST_PAYMENT_GAP   "|"
    tt-291.INST_PAYMENT_PLANS_ATTR_01_FLAG "|"

    RECORD_STATUS    "|"
    CREATE_USER_ID      "|"
    CREATE_DATETIME        "|"
    LAST_UPDATE_USER_ID       "|"
    LAST_UPDATE_DATETIME

    
    
        skip.
        
end.
output close .
