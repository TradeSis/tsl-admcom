/*
#1 03.01.19 - TP 28689564
*/
for each titulo where 
        titulo.empcod = 19 and 
        titulo.titnat = no and 
        titulo.modcod = contrato.modcod and 
        titulo.etbcod = contrato.etbcod and 
        titulo.clifor = contrato.clicod and 
        titulo.titnum = string(contrato.contnum) 
        no-lock.

/* #1
        if titulo.modcod = "CHQ" or
           titulo.modcod = "DEV" or
           titulo.modcod = "BON" or
           length(titulo.titnum) > 11 /* Sujeira de banco */
        then next. /*** ***/
*/
    /* #1 */
    if (titulo.modcod <> "CRE" and
        titulo.modcod <> "CP0" and
        titulo.modcod <> "CP1" and
        titulo.modcod <> "CPN")  or
       length(titulo.titnum) > 11 /* Sujeira de banco */
    then next.    

            /*
            if titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.
            */

        var-qtdtit =  var-qtdtit + 1.        
       
        var-vlrcontrato = var-vlrcontrato + titulo.titvlcob.
        
        if titulo.titsit = "LIB"
        then do:
            var-contrato_aberto = yes.
            var-PARCABERT = var-PARCABERT + 1.        
            var-salaberto = var-salaberto + titulo.titvlcob.
        end.
        else do:
            if titulo.titsit = "PAG"
            then do:
                var-DTULTPAGTO = if var-dtultpagto = ?
                                 then titulo.titdtpag   
                                 else max(var-DTULTPAGTO,titulo.titdtpag).
                var-PARCPAG = var-PARCPAG + 1.
                var-pagasdb = var-pagasdb + 1.
                var-VLRPAGO = var-VLRPAGO + titulo.titvlcob.
                if titulo.titdtpag <= titulo.titdtven or
                   (year(titulo.titdtpag)   = year(titulo.titdtven) and
                    month(titulo.titdtpag)  = month(titulo.titdtven))
                then var-PONTUAL = var-PONTUAL + 1.    
            end.
        end.

        if var-dtultcpa = ?
        then var-dtultcpa = titulo.titdtemi.
        else var-DTULTCPA = max(var-DTULTCPA,titulo.titdtemi).
       
        var-atrasoparcela = if titulo.titsit = "LIB"
                             then if titulo.titdtven < today
                                  then (today - titulo.titdtven)
                                  else 0
                             else titulo.titdtpag - titulo.titdtven.

        if titulo.titpar <> 0
            and (var-atrasoparcela < 0 /* nao fui eu, é o admcom que é assim, email 10.11.2017*/
                 or
                 var-atrasoparcela > 0
                 or
                 var-atrasoparcela = 0)
        then do:
            if var-atrasoparcela > 0
            then do:
                var-MAIORATRASO = max(var-MAIORATRASO,var-atrasoparcela).
            end.
             
            if titulo.titsit = "LIB" and titulo.titdtpag = ?
            then do:
                var-ATRASOATUAL     = max(var-ATRASOATUAL,var-atrasoparcela).
                var-DTMAIORATRASO   = min(var-DTMAIORATRASO,titulo.titdtven).
                if titulo.titdtven = var-DTMAIORATRASO 
                then var-VLRPARCVENC = titulo.titvlcob.               
            end.
            else do:                    
                if titulo.titsit = "PAG" 
                then do:
                    if var-atrasoparcela <= 15
                    then var-ATRASOPARCate15 =  var-ATRASOPARCate15 + 1.
                    else if var-atrasoparcela <= 45
                         then var-ATRASOPARCate45 = var-ATRASOPARCate45 + 1.
                         else var-ATRASOPARCmaior45 = var-ATRASOPARCmaior45 + 1.
                end.
            end.       
        end.           
        
        if titulo.tpcontrato = "N"
        then do:
            var-contrato_novacao = yes.
            if titulo.titsit = "LIB"
            then do:
                var-saldototnov = var-saldototnov + titulo.titvlcob.
                if titulo.titdtven < today
                then var-saldovencnov = var-saldovencnov + titulo.titvlcob.
            end.       
            if (titulo.titdtpag = ? and titulo.titdtven < today) or
               (titulo.titdtpag <> ? and titulo.titdtven < titulo.titdtpag)
            then var-atrasonov = max(var-atrasonov,(if titulo.titdtpag = ?
                                                    then today
                                                    else titulo.titdtpag) - titulo.titdtven).
        
        end.


        find first tt-mes where
            tt-mes.ano = year(titulo.titdtven) and
            tt-mes.mes = month(titulo.titdtven)
            no-error.
        if not avail tt-mes
        then do:
            create tt-mes.
            tt-mes.ano = year(titulo.titdtven).
            tt-mes.mes = month(titulo.titdtven).
        end.
        tt-mes.titvlcob = tt-mes.titvlcob + titulo.titvlcob.

    end. /* titulos */

 