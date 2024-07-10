def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
def temp-table tt-252
    field AGENT_ID    as char format "x(32)"
    field AGENT_DESC  as char format "x(64)"
    field FISCAL_NUMBER   as char format "x(32)"
    field MAIN_AGENT  as char format "x(1)"
    field COUNTRY_ID  as char format "x(10)"
    field STATE   as char format "x(32)"
    field ADD_1   as char format "x(32)"
    field ADD_2   as char format "x(32)"
    field CITY    as char format "x(64)"
    field POST_NUMBER as char format "x(10)"
    field CONTACT_NAME    as char format "x(50)"
    field CONTACT_PHONE   as char format "x(32)"
    field CONTACT_FAX as char format "x(32)"
    field CONTACT_EMAIL   as char format "x(320)"
    field AGENT_ATTR_01_CHAR  as char format "x(64)"
    field AGENT_ATTR_02_CHAR  as char format "x(64)"
    field AGENT_ATTR_03_CHAR  as char format "x(64)"
    field AGENT_ATTR_04_CHAR  as char format "x(64)"
    field AGENT_ATTR_05_CHAR  as char format "x(64)"
    field AGENT_ATTR_06_CHAR  as char format "x(64)"
    field AGENT_ATTR_01_FLAG  as char format "x(1)"
    field ORIGIN_ID   as char format "x(12)"
    field RECORD_STATUS   as char format "x(1)"
    field CREATE_USER_ID  as char format "x(25)"
    field CREATE_DATETIME as char format "x(16)"
    field LAST_UPDATE_USER_ID as char format "x(25)"
    field LAST_UPDATE_DATETIME   as char format "x(16)"
    .

def var vcgc as char.
for each forne no-lock.
    vcgc = replace(forne.forcgc,".","").
    vcgc = replace(forne.forcgc,"-","").
    vcgc = replace(forne.forcgc,"/","").
    if dec(vcgc) = 0
    then next.
    
            create tt-252.
            tt-252.AGENT_ID    =   string(forne.forcod)            .
            tt-252.AGENT_DESC  =   forne.fornom                    .
            tt-252.FISCAL_NUMBER   = forne.forcgc                      .
            tt-252.MAIN_AGENT  =  string(forpai = 0 or 
                                         forpai = forcod ,"Y/N") .
/*          tt-252.COUNTRY_ID  =   caps(forpais)                         .*/
            tt-252.COUNTRY_ID = "BR".
            tt-252.STATE   =   ufecod                              .
            tt-252.ADD_1   =   trim(forrua + string(fornum))      .
            tt-252.ADD_2   =   forcomp                             .
            tt-252.CITY    =   formunic                            .
            tt-252.POST_NUMBER =   forcep                          .
            tt-252.CONTACT_NAME    =   forcont                     .
            tt-252.CONTACT_PHONE   =   forfone                     .
            tt-252.CONTACT_FAX =   forfax                          .
            tt-252.CONTACT_EMAIL   =   email                       .
            tt-252.AGENT_ATTR_01_CHAR  =   forinest                .
            tt-252.AGENT_ATTR_02_CHAR  =   if forpai <> 0 and
                                              forpai <> forcod
                                           then string(forpai)
                                           else "0"
                                                             .
            tt-252.AGENT_ATTR_03_CHAR  =   forctfon                .
            tt-252.AGENT_ATTR_04_CHAR  =   forbairro               .
            tt-252.AGENT_ATTR_05_CHAR  =   string(repcod)                  .
            tt-252.AGENT_ATTR_06_CHAR  =   ufecod                  .
            tt-252.AGENT_ATTR_01_FLAG  =   fortipo                 .
            tt-252.ORIGIN_ID                = "LEBES".
            tt-252.RECORD_STATUS            = "A"                .
            tt-252.CREATE_USER_ID           = "ADMCOM"           .
            tt-252.CREATE_DATETIME          = vsysdata           .
            tt-252.LAST_UPDATE_USER_ID      = "ADMCOM"           .
            tt-252.LAST_UPDATE_DATETIME     = vsysdata           .            
            
end.            
output to value("/admcom/tmp/itim/input/ADMCOM_0252_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-252.
    put         
                 tt-252.AGENT_ID        "|"
                 tt-252.AGENT_DESC      "|"
                 tt-252.FISCAL_NUMBER       "|"
                 tt-252.MAIN_AGENT      "|"
                 tt-252.COUNTRY_ID      "|"
                 tt-252.STATE       "|"
                 tt-252.ADD_1       "|"
                 tt-252.ADD_2       "|"
                 tt-252.CITY        "|"
                 tt-252.POST_NUMBER     "|"
                 tt-252.CONTACT_NAME        "|"
                 tt-252.CONTACT_PHONE       "|"
                 tt-252.CONTACT_FAX     "|"
                 tt-252.CONTACT_EMAIL       "|"
                 tt-252.AGENT_ATTR_01_CHAR      "|"
                 tt-252.AGENT_ATTR_02_CHAR      "|"
                 tt-252.AGENT_ATTR_03_CHAR      "|"
                 tt-252.AGENT_ATTR_04_CHAR      "|"
                 tt-252.AGENT_ATTR_05_CHAR      "|"
                 tt-252.AGENT_ATTR_06_CHAR      "|"
                 tt-252.AGENT_ATTR_01_FLAG      "|"
                 tt-252.ORIGIN_ID       "|"
                 tt-252.RECORD_STATUS       "|"
                 tt-252.CREATE_USER_ID      "|"
                 tt-252.CREATE_DATETIME     "|"
                 tt-252.LAST_UPDATE_USER_ID     "|"
                 tt-252.LAST_UPDATE_DATETIME 
        skip.
        
end.
output close .
