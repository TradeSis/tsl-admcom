
def var vsysdata as char.
vsysdata = string(day(today),"99") 
         + string(month(today),"99")
         + string(year(today),"9999")
         + string(time,"hh:mm:ss").
vsysdata = replace(vsysdata,":","").
         
/* Dimensao de Departamento */
def temp-table tt-238
    field MERCH_L2_ID           as char format "x(25)"
    field ORIGIN_ID             as char format "x(12)"
    field MERCH_L2_DESC         as char format "x(64)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)".
    
/* Dimensao de Setor */
def temp-table tt-239
    field MERCH_L2_ID           as char format "x(25)"
    field MERCH_L3_ID           as char format "x(25)"
    field ORIGIN_ID             as char format "x(12)"
    field MERCH_L3_DESC         as char format "x(64)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)".
    
/* Dimensao de Grupo */
def temp-table tt-240
    field MERCH_L3_ID           as char format "x(25)"
    field MERCH_L4_ID           as char format "x(25)"
    field ORIGIN_ID             as char format "x(12)"
    field MERCH_L4_DESC         as char format "x(64)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)".

/* Dimensao de Classe */
def temp-table tt-241
    field MERCH_L4_ID           as char format "x(25)"
    field MERCH_L5_ID           as char format "x(25)"
    field ORIGIN_ID             as char format "x(12)"
    field MERCH_L5_DESC         as char format "x(64)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)".
    
/* Dimensao de Sub-Classe */
def temp-table tt-242
    field MERCH_L5_ID           as char format "x(25)"
    field MERCH_L6_ID           as char format "x(25)"
    field ORIGIN_ID             as char format "x(12)"
    field MERCH_L6_DESC         as char format "x(64)"
    field RECORD_STATUS         as char format "x(1)"
    field CREATE_USER_ID        as char format "x(25)"
    field CREATE_DATETIME       as char format "x(14)"
    field LAST_UPDATE_USER_ID   as char format "x(25)"
    field LAST_UPDATE_DATETIME  as char format "x(14)".

def buffer tt-setor for clase.
def buffer tt-grupo for clase.
def buffer tt-clase for clase.
def buffer tt-sclase for clase.

for each categoria.
    create tt-238.
    tt-238.MERCH_L2_ID           = string(categoria.catcod).
    tt-238.ORIGIN_ID             = "LEBES".
    tt-238.MERCH_L2_DESC         = categoria.catnom.
    tt-238.RECORD_STATUS         = "A".
    tt-238.CREATE_USER_ID        = "ADMCOM".
    tt-238.CREATE_DATETIME       = vsysdata.
    tt-238.LAST_UPDATE_USER_ID   = "ADMCOM".
    tt-238.LAST_UPDATE_DATETIME  = vsysdata.
  
  for each tt-setor where tt-setor.clasup = 0
                      and tt-setor.claper = categoria.catcod no-lock.

        create tt-239.
        tt-239.MERCH_L2_ID          = string(categoria.catcod).
        tt-239.MERCH_L3_ID          = string(tt-setor.clacod).
        tt-239.ORIGIN_ID            = "LEBES".
        tt-239.MERCH_L3_DESC        = tt-setor.clanom.
        tt-239.RECORD_STATUS        = if tt-setor.clanom = "DESATIVADO"
                                      then "D"
                                      else "A".
        tt-239.CREATE_USER_ID       = "ADMCOM".
        tt-239.CREATE_DATETIME      = vsysdata.
        tt-239.LAST_UPDATE_USER_ID  = "ADMCOM".
        tt-239.LAST_UPDATE_DATETIME = vsysdata.
    
    for each tt-grupo where tt-grupo.clasup = tt-setor.clacod no-lock.
        create tt-240.
        tt-240.MERCH_L3_ID           = string(tt-setor.clacod).
        tt-240.MERCH_L4_ID           = string(tt-grupo.clacod).
        tt-240.ORIGIN_ID             = "LEBES".
        tt-240.MERCH_L4_DESC         = tt-grupo.clanom.
        tt-240.RECORD_STATUS         = if tt-grupo.clanom = "DESATIVADO"
                                       then "D"
                                       else "A".
        tt-240.CREATE_USER_ID        = "ADMCOM".
        tt-240.CREATE_DATETIME       = vsysdata.
        tt-240.LAST_UPDATE_USER_ID   = "ADMCOM".
        tt-240.LAST_UPDATE_DATETIME  = vsysdata.
    
      for each tt-clase where tt-clase.clasup = tt-grupo.clacod no-lock.
        create tt-241.
        tt-241.MERCH_L4_ID           = string(tt-grupo.clacod).
        tt-241.MERCH_L5_ID           = string(tt-clase.clacod).
        tt-241.ORIGIN_ID             = "LEBES".
        tt-241.MERCH_L5_DESC         = tt-clase.clanom.
        tt-241.RECORD_STATUS         = if tt-clase.clanom = "DESATIVADO"
                                       then "D"
                                       else "A".
        tt-241.CREATE_USER_ID        = "ADMCOM".
        tt-241.CREATE_DATETIME       = vsysdata.
        tt-241.LAST_UPDATE_USER_ID   = "ADMCOM".
        tt-241.LAST_UPDATE_DATETIME  = vsysdata.
        
        for each tt-sclase where tt-sclase.clasup = tt-clase.clacod no-lock.
        
            create tt-242.
            tt-242.MERCH_L5_ID           = string(tt-clase.clacod).
            tt-242.MERCH_L6_ID           = string(tt-sclase.clacod).
            tt-242.ORIGIN_ID             = "LEBES".
            tt-242.MERCH_L6_DESC         = tt-sclase.clanom.
            tt-242.RECORD_STATUS         = if tt-sclase.clanom = "DESATIVADO"
                                           then "D"
                                           else "A".
            tt-242.CREATE_USER_ID        = "ADMCOM".
            tt-242.CREATE_DATETIME       = vsysdata.
            tt-242.LAST_UPDATE_USER_ID   = "ADMCOM".
            tt-242.LAST_UPDATE_DATETIME  = vsysdata.
            
        end. /* for each tt-sclase ... */            
        
      end. /* for each tt-clase ... */
    end. /* for each tt-grupo ... */
  end. /* for each tt-setor ... */  
end. /* for each categoria ... */  
    

output to value("/admcom/progr/itim/ADMCOM_0238_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-238.
    put                      
        tt-238.MERCH_L2_ID             "|"
        tt-238.ORIGIN_ID               "|"
        tt-238.MERCH_L2_DESC           "|"
        tt-238.RECORD_STATUS           "|"
        tt-238.CREATE_USER_ID          "|"
        tt-238.CREATE_DATETIME         "|"
        tt-238.LAST_UPDATE_USER_ID     "|"
        tt-238.LAST_UPDATE_DATETIME    
        skip.
        
end.
output close.
output to value("/admcom/progr/itim/ADMCOM_0239_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-239.
    put 
        tt-239.MERCH_L2_ID             "|"
        tt-239.MERCH_L3_ID             "|"
        tt-239.ORIGIN_ID               "|"
        tt-239.MERCH_L3_DESC           "|"
        tt-239.RECORD_STATUS           "|"
        tt-239.CREATE_USER_ID          "|"
        tt-239.CREATE_DATETIME         "|"
        tt-239.LAST_UPDATE_USER_ID     "|"
        tt-239.LAST_UPDATE_DATETIME
        skip.
        
end.
output close.
output to value("/admcom/progr/itim/ADMCOM_0240_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-240.
    put 
        tt-240.MERCH_L3_ID              "|"
        tt-240.MERCH_L4_ID              "|"
        tt-240.ORIGIN_ID                "|"
        tt-240.MERCH_L4_DESC            "|"
        tt-240.RECORD_STATUS            "|"
        tt-240.CREATE_USER_ID           "|"
        tt-240.CREATE_DATETIME          "|"
        tt-240.LAST_UPDATE_USER_ID      "|"
        tt-240.LAST_UPDATE_DATETIME     
        skip.
end.
output close.
output to value("/admcom/progr/itim/ADMCOM_0241_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-241.
    put 
        tt-241.MERCH_L4_ID              "|"
        tt-241.MERCH_L5_ID              "|"
        tt-241.ORIGIN_ID                "|"
        tt-241.MERCH_L5_DESC            "|"
        tt-241.RECORD_STATUS            "|"
        tt-241.CREATE_USER_ID           "|"
        tt-241.CREATE_DATETIME          "|"
        tt-241.LAST_UPDATE_USER_ID      "|"
        tt-241.LAST_UPDATE_DATETIME
        skip.
end.
output close.
output to value("/admcom/progr/itim/ADMCOM_0242_"  +
                    string(year(today),"9999")     +
                    string(month(today),"99")      +
                    string(day(today),"99")        + "1.DAT") .
for each tt-242.
    put 
        tt-242.MERCH_L5_ID              "|"
        tt-242.MERCH_L6_ID              "|"
        tt-242.ORIGIN_ID                "|"
        tt-242.MERCH_L6_DESC            "|"
        tt-242.RECORD_STATUS            "|"
        tt-242.CREATE_USER_ID           "|"
        tt-242.CREATE_DATETIME          "|"
        tt-242.LAST_UPDATE_USER_ID      "|"
        tt-242.LAST_UPDATE_DATETIME
        skip.
        
end.
output close.
