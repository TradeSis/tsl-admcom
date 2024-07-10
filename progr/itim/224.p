def var vcep as int.
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Label - temporada   */
def temp-table tt-224
    field STORE_ID    as char format "x(10)"
    field ORIGIN_ID   as char format "x(12)"
    field VAT_REGION_ID   as char format "x(4)"
    field STORE_FORMAT_ID as char format "x(25)"
    field STORE_DESC  as char format "x(64)"
    field ADDRESS as char format "x(100)"
    field CITY    as char format "x(50)"
    field STATE   as char format "x(20)"
    field POSTAL_CODE as char format "x(8)"
    field STORE_TYPE  as char format "x(1)"
    field STORE_ATTR_01_CHAR  as char format "x(40)"
    field STORE_ATTR_02_CHAR  as char format "x(40)"
    field STORE_ATTR_03_CHAR  as char format "x(40)"
    field STORE_ATTR_04_CHAR  as char format "x(40)"
    field STORE_ATTR_05_CHAR  as char format "x(40)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(14)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME    as char format "x(14)"
    
    

    
    .


for each estab no-lock.
    def var vtipoLoja as char.
    vtipoLoja = if estab.tipoLoja = "Normal"
                then "S"
                else
                if estab.tipoLoja = "CD"
                then "W"
                else
                if estab.tipoLoja = "Outlet"
                then "O"
                else 
                if estab.tipoLoja = "ECOMMERCE"
                then "E"
                else "S".
    
    find regiao of estab no-lock no-error.
    find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "CEP" no-lock no-error.
                if avail tabaux
                then vcep = int(tabaux.valor_campo).
                else vcep = 0.
    find unfed of estab no-lock.
    create tt-224.
    assign                      
    STORE_ID            = string(estab.etbcod)               .
    ORIGIN_ID           = "LEBES"                    .
    VAT_REGION_ID       = unfed.ufecod               .
    STORE_FORMAT_ID     = estab.tamanho              .
    STORE_DESC          = estab.etbnom               .
    ADDRESS             = estab.endereco             .
    CITY                = estab.munic                .
    STATE               = unfed.ufenom               .
    POSTAL_CODE         = string(vcep)                       .
    STORE_TYPE          = vtipoLoja             .
    STORE_ATTR_01_CHAR  = etbinsc                    .
    STORE_ATTR_02_CHAR  = etbcgc                     .
    STORE_ATTR_03_CHAR  = estab.etbserie             .
    STORE_ATTR_05_CHAR  = string(regiao.regnom)               .
    RECORD_STATUS       = "A"                        .
    CREATE_USER_ID      = "ADMCOM"                   .
    CREATE_DATETIME     = vsysdata                   .
    LAST_UPDATE_USER_ID = "ADMCOM"                   .
    LAST_UPDATE_DATETIME = vsysdata
    .

end.            
            

output to value("/admcom/tmp/itim/input/ADMCOM_0224_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-224.
    put                      
        tt-224.STORE_ID                "|"
        tt-224.ORIGIN_ID               "|"
        tt-224.VAT_REGION_ID           "|"
        tt-224.STORE_FORMAT_ID         "|"
        tt-224.STORE_DESC              "|"
        tt-224.ADDRESS                 "|"
        tt-224.CITY                    "|"
        tt-224.STATE                   "|"
        tt-224.POSTAL_CODE             "|"
        tt-224.STORE_TYPE              "|"
        tt-224.STORE_ATTR_01_CHAR      "|"
        tt-224.STORE_ATTR_02_CHAR      "|"
        tt-224.STORE_ATTR_03_CHAR      "|"
        tt-224.STORE_ATTR_04_CHAR      "|"
        tt-224.STORE_ATTR_05_CHAR      "|"
        tt-224.RECORD_STATUS           "|"
        tt-224.CREATE_USER_ID          "|"
        tt-224.CREATE_DATETIME         "|"
        tt-224.LAST_UPDATE_USER_ID     "|"
        tt-224.LAST_UPDATE_DATETIME    
        
        skip.
        
end.
output close.
       
       
