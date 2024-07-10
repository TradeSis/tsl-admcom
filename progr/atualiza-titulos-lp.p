{admcab.i new}

def temp-table tt-titulo
    field FIL       as int
    field COD_CLI   as int
    field CONTRATO  as int format ">>>>>>>>>>>>9"
    field PARCELA   as int
    field VALOR_COBRADO as dec
    field VALOR_PAGO    as dec
    field DATA_VENCIMENTO as date
    field DATA_PAGAMENTO  as date
    field FIL_COB         as int.
      
input from value("/admcom/work/lista-titulos2.csv").

repeat:

    create tt-titulo.
    import delimiter ";" tt-titulo.
    
end.


for each tt-titulo no-lock,

    each fin.titulo where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = "cre"
                      and titulo.titdtpag = tt-titulo.data_pagamento
                      and titulo.etbcod   = tt-titulo.fil
                      and titulo.clifor = tt-titulo.cod_cli
                      and titulo.titnum = string(tt-titulo.contrato)
                      and titulo.titpar   = tt-titulo.parcela no-lock.
                      
    find first d.titulo
         where d.titulo.empcod   = fin.titulo.empcod
           and d.titulo.titnat   = fin.titulo.titnat
           and d.titulo.modcod   = fin.titulo.modcod
           and d.titulo.etbcod   = fin.titulo.etbcod
           and d.titulo.clifor   = fin.titulo.clifor
           and d.titulo.titnum   = fin.titulo.titnum
           and d.titulo.titpar   = fin.titulo.titpar exclusive-lock.
    
    if d.titulo.titdtpag = ? and fin.titulo.titdtpag <> ?
    then do: 
    
        display d.titulo.titnum
               fin.titulo.titdtpag
                 d.titulo.titdtpag
                 d.titulo.titvlpag
                 d.titulo.titsit
               fin.titulo.titsit  
                 d.titulo.datexp (count).
    
        assign d.titulo.titdtpag = fin.titulo.titdtpag
               d.titulo.datexp = fin.titulo.datexp
               d.titulo.titvlpag = fin.titulo.titvlpag
               d.titulo.titsit = fin.titulo.titsit.

    end.        
          
end.
