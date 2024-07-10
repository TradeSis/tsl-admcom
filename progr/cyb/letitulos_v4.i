
/*4*/ /* 22.02.18 Helio - Considerar titsit NOV como pago */
/*#3*/ /* 21.03.17 Helio - Considerar titsit EXC como pago */
/*#1*/ /* 13.03.17 Helio - Considera pago titsit = PAG , e todas as demais situacoes considera aberto */
/*#2*/ /* 13.03.17 Helio - Guarda numa variavel o efetivo valor vencido, pois no vlratrasado, pode ter valor a vencer, o vlratrasado serve de controle */
/*#4      18.09.2017 Helio - Projeto Boletos, parametro titulo associado a boleto */   
/*#5      19.12.2017 Helio - Projeto Param CP Cyber */
/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inlcui Elegiveis Feirao */

    def var vvlrvencido as dec. /*#2*/
    def var vtitdtpag   like titulo.titdtpag. /*#3*/
    
    vprocessa = vprocessa_normal.
    vvlraberto   = 0.
    vvlratrasado = 0.
    vvlrvencido  = 0. /*#2*/
    vdtultpag    = ?.
    vvlrultpag = 0.
    vparpg       = "".
    vparab       = "".
    vlp = no.
    vnovacao = no.
    vboleto = no. /* #4 */
    vultvencab = ?.
    
    vqtdatrasado = 0.
    vvlravencer = 0.
    vqtdavencer = 0.
    vvlrjuros   = 0.
    vprivencab = ?.
    vqtdpagas  = 0.
    
    for each titulo where 
        titulo.empcod = 19 and 
        titulo.titnat = no and 
        titulo.modcod = vmodcod and 
        titulo.etbcod = vetbcod and 
        titulo.clifor = vclicod and 
        titulo.titnum = string(vcontnum) 
        no-lock
            by titulo.titpar.
     
            if titulo.clifor <= 1 or
               titulo.clifor = ? or
               titulo.titpar = 0 or
               titulo.titnum = "" or
               titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.

        if titulo.titsit = "PAG" /*#1*/
           or titulo.titsit = "EXC" /*#3*/
           or titulo.titsit = "NOV" /* #4 */
        then do:
            vtitdtpag = if titulo.titdtpag = ? /*#3*/
                        then titulo.titdtven
                        else titulo.titdtpag.
            if vtitdtpag <> ? /*#3*/
            then do:
                vparpg = vparpg + 
                         if vparpg = ""
                         then string(titulo.titpar)
                         else ("," + string(titulo.titpar)).
                vdtultpag = if vdtultpag = ?
                            then vtitdtpag /*#3*/
                            else max(vdtultpag,vtitdtpag).
                vvlrultpag = if vdtultpag = vtitdtpag
                             then titulo.titvlpag
                             else vvlrultpag.
                vqtdpagas = vqtdpagas + 1.
                
            end.       
            next. /*#3*/
        end.       
        vef_elegivelfeirao = no.
        if vprocessa_ef
        then do:
            if (vef_modcod <> "" and
                vef_modcod = titulo.modcod) or
                vef_modcod = ""
            then do:
                if titulo.titdtemi < vef_dataemi
                then do:
                    vef_elegivelfeirao = yes.
                    vprocessa = yes.
                end.
            end.
        end.
        
        if titulo.tpcontrato <> "" /*** titulo.titpar > 30 ***/
        then do:
           vnovacao = yes.
           vprocessa = vprocessa_novacao.
           if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" /* L&P */ 
           then do:
                VLP = yes.
                vprocessa = vprocessa_lp.
            end.
        end.     
        /* #5 */
        if titulo.modcod begins "CP"
        then vprocessa = vprocessa_cp.
        

        /* #4 */
        /* teste se associado a boleto para CADA titulo */
        
        find first cybacparcela where
                cybacparcela.contnum = int(titulo.titnum) and
                cybacparcela.parcela = titulo.titpar
            no-lock no-error.
        if avail cybacparcela
        then vboleto = yes.
        else vboleto = no.
        
        
        vparab = vparab +  
                    if vparab = "" 
                    then string(titulo.titpar) 
                    else ("," + string(titulo.titpar)).

        vvlraberto = vvlraberto + titulo.titvlcob.

        
        if titulo.titdtven <= p-today - 
                                     (if vboleto /* #4 */
                                      then vdias_boleto
                                      else if vef_elegivelfeirao
                                           then vef_dias
                                           else if vnovacao 
                                                then vdias_novacao 
                                                else if vlp
                                                     then vdias_lp
                                                     else if vmodcod begins "CP" /* #5 */
                                                          then vdias_cp
                                                          else vdias) 
        then do:
            vvlratrasado = vvlratrasado + titulo.titvlcob.
            
            if titulo.titdtven < today /*#2*/
            then vvlrvencido = vvlrvencido + titulo.titvlcob.
            
            vqtdatrasado = vqtdatrasado + 1.
            
            run juro_titulo.p (0,
                               titulo.titdtven,
                               titulo.titvlcob,
                               output par-juros).
            vvlrjuros = vvlrjuros + par-juros.
            
        end.    
        else do:
            vvlravencer = vvlravencer + titulo.titvlcob.
            vqtdavencer = vqtdavencer + 1.
        end.
        
        vultvencab = if vultvencab = ?
                     then titulo.titdtven
                     else max(vultvencab,titulo.titdtven).
        vprivencab = if vprivencab = ?
                     then titulo.titdtven
                     else min(vprivencab,titulo.titdtven).
                     
    end.
 
