
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - temporada   */
def temp-table tt-215
    field COLOUR_ID             as char format "x(10)" 
    field ORIGIN_ID             as char format "x(12)" 
    field COLOUR_DESC           as char format "x(64)" 
    field RECORD_STATUS         as char format "x(1)" 
    field CREATE_USER_ID        as char format "x(25)" 
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)"
    .


for each cores     no-lock.
       
            create tt-215.
            assign 
            tt-215.COLOUR_ID             = string(cores.cor)
            tt-215.ORIGIN_ID             = "LEBES"
            tt-215.COLOUR_DESC           = cores.Desc_cor
            tt-215.RECORD_STATUS         = "A"
            tt-215.CREATE_USER_ID        = "ADMCOM"
            tt-215.CREATE_DATETIME       = vsysdata
            tt-215.LAST_UPDATE_USER_ID   = "ADMCOM"
            tt-215.LAST_UPDATE_DATETIME  = vsysdata
            .
end.            
            

output to value("/admcom/progr/itim/ADMCOM_0215_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-215.
    put                      
        tt-215.COLOUR_ID               "|"
        tt-215.ORIGIN_ID               "|"
        tt-215.COLOUR_DESC             "|"
        tt-215.RECORD_STATUS           "|"
        tt-215.CREATE_USER_ID          "|"
        tt-215.CREATE_DATETIME         "|"
        tt-215.LAST_UPDATE_USER_ID     "|"
        tt-215.LAST_UPDATE_DATETIME    
        
        skip.
        
end.
output close.
