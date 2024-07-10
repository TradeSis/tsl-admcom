
    def input parameter par-recid-titulo as recid.
    def input parameter par-data as date.
    def output parameter par-parcial     as log format "ParcelaParcial/ParcelaOriginal".
    def output parameter par-parorigem   as int.
    def output parameter par-titdtemi   as date.
    def output parameter par-tpcontrato as char.
    def output parameter par-titvlcob   as dec.
    def output parameter par-titdtpag   as date.
    def output parameter  par-titvlpag as dec.
    def output parameter par-titdesc as dec.
    def output parameter par-titjuro as dec.
    def output parameter par-saldo as dec.

    def buffer xtitulo for titulo.
    def buffer xatitulo for titulo.
    def buffer xbtitulo for titulo.
    def buffer xctitulo for titulo.
    def buffer xttitulo for titulo. 

    def var aux-titvlcob as dec. 
    def var vparcial as char.
    def var vemissao as char.
    def var vtitdtemi   as date.
    def var vtitpar as int.
    def var vi as int.
    def var aux-pos as int.
    def var aux-dtemi as date.
    def var aux-par as int.
    
    find xtitulo where recid(xtitulo) = par-recid-titulo no-lock.
    par-tpcontrato = xtitulo.tpcontrato.
    
    
    if xtitulo.titpar = 0 /* pode ser Novacao */
    then do:  
        find first xttitulo where  
            xttitulo.empcod = xtitulo.empcod and 
            xttitulo.titnat = xtitulo.titnat and 
            xttitulo.etbcod = xtitulo.etbcod and 
            xttitulo.modcod = xtitulo.modcod and  
            xttitulo.clifor = xtitulo.clifor and  
            xttitulo.titnum = xtitulo.titnum and  
            xttitulo.titpar = 31 
            no-lock no-error.

        if avail xttitulo
        then do:
            find first xttitulo where  
                xttitulo.empcod = xtitulo.empcod and 
                xttitulo.titnat = xtitulo.titnat and 
                xttitulo.etbcod = xtitulo.etbcod and 
                xttitulo.modcod = xtitulo.modcod and  
                xttitulo.clifor = xtitulo.clifor and  
                xttitulo.titnum = xtitulo.titnum and  
                xttitulo.titpar < 31 and
                xttitulo.titpar > 28
                no-lock no-error.

            if not avail xttitulo
            then par-tpcontrato = "N".                    

        end.
        find first xttitulo where  
            xttitulo.empcod = xtitulo.empcod and 
            xttitulo.titnat = xtitulo.titnat and 
            xttitulo.etbcod = xtitulo.etbcod and 
            xttitulo.modcod = xtitulo.modcod and  
            xttitulo.clifor = xtitulo.clifor and  
            xttitulo.titnum = xtitulo.titnum and  
            xttitulo.titpar = 51 
            no-lock no-error.
        if avail xttitulo
        then do:
            find first xttitulo where  
                xttitulo.empcod = xtitulo.empcod and 
                xttitulo.titnat = xtitulo.titnat and 
                xttitulo.etbcod = xtitulo.etbcod and 
                xttitulo.modcod = xtitulo.modcod and  
                xttitulo.clifor = xtitulo.clifor and  
                xttitulo.titnum = xtitulo.titnum and  
                xttitulo.titpar < 51 and
                xttitulo.titpar > 48
                no-lock no-error.
            if not avail xttitulo
            then par-tpcontrato = "L".                    
        end.
    end.
     
    if xtitulo.titpar >= 31 /* pode ser Novacao */
    then do:    
        find first xttitulo where  
            xttitulo.empcod = xtitulo.empcod and 
            xttitulo.titnat = xtitulo.titnat and 
            xttitulo.etbcod = xtitulo.etbcod and 
            xttitulo.modcod = xtitulo.modcod and  
            xttitulo.clifor = xtitulo.clifor and  
            xttitulo.titnum = xtitulo.titnum and  
            xttitulo.titpar < 31 and
            xttitulo.titpar > 28
            no-lock no-error.
        if not avail xttitulo
        then par-tpcontrato = "N".                    
    end.
        
    if xtitulo.titpar >= 51 /* pode ser LP */ 
    then do:    
        find first xttitulo where  
            xttitulo.empcod = xtitulo.empcod and 
            xttitulo.titnat = xtitulo.titnat and 
            xttitulo.etbcod = xtitulo.etbcod and 
            xttitulo.modcod = xtitulo.modcod and  
            xttitulo.clifor = xtitulo.clifor and  
            xttitulo.titnum = xtitulo.titnum and  
            xttitulo.titpar < 51 and
            xttitulo.titpar > 48
            no-lock no-error.
        if not avail xttitulo
        then par-tpcontrato = "L".                    
    end.
   

    
    par-parcial = no.
    vparcial = "".
    vemissao  = "".
    vtitdtemi = ?.
    for each xbtitulo where  
            xbtitulo.empcod = xtitulo.empcod and 
            xbtitulo.titnat = xtitulo.titnat and  
            xbtitulo.etbcod = xtitulo.etbcod and  
            xbtitulo.modcod = xtitulo.modcod and  
            xbtitulo.clifor = xtitulo.clifor and  
            xbtitulo.titnum = xtitulo.titnum and  
            xbtitulo.titdtven = xtitulo.titdtven
        by xbtitulo.titpar.
    
        if xbtitulo.titpar = xtitulo.titpar
        then do:
            if vemissao = ""
            then par-titdtemi = xtitulo.titdtemi.
            else par-titdtemi = vtitdtemi.
        end.
        vparcial = vparcial + 
                if vparcial = ""
                then string(xbtitulo.titpar)
                else "," + string(xbtitulo.titpar).
        vemissao = vemissao + 
                if vemissao = ""
                then string(xbtitulo.titdtemi)
                else "," + if vtitdtemi = ?
                           then ""
                           else string(vtitdtemi).

        vtitdtemi = xbtitulo.titdtpag.

    end.    

    if num-entries(vparcial) = 1 
    then do:
        par-titvlcob = if xtitulo.titdtemi > par-data
                       then 0
                       else xtitulo.titvlcob.
        if xtitulo.titdtemi <= par-data
        then do:
            par-titdtpag = if xtitulo.titdtpag > par-data
                           then ?
                           else xtitulo.titdtpag.
            par-titdesc  = if par-titdtpag = ?
                           then 0
                           else if par-titvlcob > xtitulo.titvlpag
                                then par-titvlcob - xtitulo.titvlpag
                               else 0.
            par-titjuro  = if par-titdtpag = ?
                           then 0
                           else if xtitulo.titvlpag > par-titvlcob
                                then xtitulo.titvlpag - par-titvlcob
                                else 0.
            par-titvlpag = if par-titdtpag = ?
                           then 0
                           else par-titvlcob.
            par-saldo    = par-titvlcob - par-titvlpag.                  
        end.
    end.
    else do:
        /*acha a proxima */
        do vi = 1 to num-entries(vparcial).
            vtitpar   = int(entry(vi,vparcial)).  
            if vtitpar > xtitulo.titpar
            then leave.
            vtitdtemi = date(entry(vi,vemissao)).
            if vi > 1
            then do:
                par-parcial = yes.
                par-parorigem = aux-par.
            end.    
            aux-par = vtitpar.
        end.  
    
        if vtitpar = xtitulo.titpar
        then do:
            if vtitdtemi <= par-data
            then do:
                par-titvlcob = if xtitulo.titdtemi > par-data
                           then 0
                           else xtitulo.titvlcob.
            
                par-titdtpag = if xtitulo.titdtpag > par-data
                               then ?
                               else xtitulo.titdtpag.
                par-titdesc  = if par-titdtpag = ?
                               then 0
                               else if par-titvlcob > xtitulo.titvlpag
                                    then par-titvlcob - xtitulo.titvlpag
                                   else 0.
                par-titjuro  = if par-titdtpag = ?
                               then 0
                               else if xtitulo.titvlpag > par-titvlcob
                                    then xtitulo.titvlpag - par-titvlcob
                                    else 0.
                par-titvlpag = if par-titdtpag = ?
                               then 0
                               else par-titvlcob.
                par-saldo    = par-titvlcob - par-titvlpag.                  
            end.
        
        end.
        else do:
            
            find first xatitulo where  
                    xatitulo.empcod = xtitulo.empcod and 
                    xatitulo.titnat = xtitulo.titnat and  
                    xatitulo.etbcod = xtitulo.etbcod and  
                    xatitulo.modcod = xtitulo.modcod and  
                    xatitulo.clifor = xtitulo.clifor and  
                    xatitulo.titnum = xtitulo.titnum and  
                    xatitulo.titdtven = xtitulo.titdtven and
                    xatitulo.titpar = vtitpar
                    no-lock.     

            if vtitdtemi <= par-data
            then do:
            
                par-titdtpag = if xtitulo.titdtpag > par-data
                               then ?
                               else xtitulo.titdtpag.
                par-titvlcob = xtitulo.titvlcob - if par-titdtpag = ?
                                                  then 0
                                                  else xatitulo.titvlcob.
        
                par-titdesc  = if par-titdtpag = ?
                               then 0
                               else if xtitulo.titvlpag - (xtitulo.titvlcob - xatitulo.titvlcob) < 0
                                    then  xtitulo.titvlpag - (xtitulo.titvlcob - xatitulo.titvlcob) 
                                    else 0.
                par-titjuro  = if par-titdtpag = ?
                               then 0
                               else if xtitulo.titvlpag - (xtitulo.titvlcob - xatitulo.titvlcob) > 0
                                    then  xtitulo.titvlpag - (xtitulo.titvlcob - xatitulo.titvlcob)
                                    else 0.
                par-titvlpag = if par-titdtpag = ?
                               then 0
                               else par-titvlcob.
                par-saldo    = par-titvlcob - par-titvlpag.                  
        end.    
                    
    end.     

end.

