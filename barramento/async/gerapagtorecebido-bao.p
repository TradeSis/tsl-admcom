/* helio 28022022 - iepro */
/*** helio 28012022 - Envio valor acréscimo moedas ECP e EDP **/

def input param vdtini as date.
def input param vgeral as log.
def var hpagtoRecebidoPeriodoEntrada as handle.
def var lcJsonSaida as longchar.
def var lokJson as log.

def var vdt as date. 
def var vcobnom like cobra.cobnom.
def var vvalor as dec.
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'pagtoRecebidoPeriodo'
    FIELD chave as char     serialize-hidden  
    field dataExecucao  as date 
    index x is unique primary chave asc.

def temp-table tt-pgcontrato no-undo serialize-name 'pagtoRecebido'
    FIELD chave as char     serialize-hidden  
    field dataDocumento     like pdvmov.datamov 
    field dataLancamento    like pdvmov.datamov 
    field documentoReferencia like pdvdoc.contnum
    index x dataDocumento asc documentoReferencia asc.
    
def temp-table tt-mov no-undo serialize-name 'movimentos'
    FIELD chave as char     serialize-hidden  
    field dataDocumento     like tt-pgcontrato.dataDocumento serialize-hidden
    field documentoReferencia like tt-pgcontrato.documentoReferencia serialize-hidden
    field carteira          like cobra.cobnom
    field ctmcod            like pdvtmov.ctmnom serialize-name 'operacao'
    field funnom            like func.funnom serialize-name 'usuario'
    field setor             as char 
    field valor             as dec format "->>>>>>>>>9.99" serialize-name 'valor'
    field moeda             as char initial "BRL"
    index x dataDocumento asc documentoReferencia asc.


DEFINE DATASET pagtoRecebidoPeriodoEntrada FOR ttstatus, tt-pgcontrato, tt-mov
  DATA-RELATION for1 FOR ttstatus, tt-pgcontrato
    RELATION-FIELDS(ttstatus.chave,tt-pgcontrato.chave) NESTED 
  DATA-RELATION for2 FOR tt-pgcontrato , tt-mov
    RELATION-FIELDS(tt-pgcontrato.dataDocumento,tt-mov.dataDocumento,
                    tt-pgcontrato.documentoReferencia,tt-mov.documentoReferencia) NESTED .

hpagtoRecebidoPeriodoEntrada = DATASET pagtoRecebidoPeriodoEntrada:HANDLE.


                        
def var vi as int.
def var vtoday as date.
pause 0 before-hide.

if vdtini < 07/01/2020 then vdtini = 07/01/2020.

message "Gerando  pagamentos SAP desde " vdtini string(vgeral,"Geral/Novos") .

do vtoday = vdtini to today:
    message "log " vtoday.
    
    for each ttstatus. delete ttstatus. end.
    for each tt-pgcontrato. delete tt-pgcontrato. end.
    for each tt-mov. delete tt-mov. end.
    
    create ttstatus.
    ttstatus.dataExecucao = today . 

    for each cmon no-lock.
        for each pdvtmov where pdvtmov.expsap = yes and (pdvtmov.ctmcod = "AOB" or pdvtmov.ctmcod = "BAO") no-lock.
            for each pdvdoc where 
                    pdvdoc.etbcod = cmon.etbcod and
                    pdvdoc.ctmcod = pdvtmov.ctmcod and
                    pdvdoc.datamov = vtoday and
                    pdvdoc.cmocod = cmon.cmocod.

                if vgeral = no
                then if pdvdoc.dtenvsap = ?
                     then .
                     else next.
                
                if pdvdoc.pstatus = yes
                then.
                else next.
                find pdvmov of pdvdoc no-lock.
                find func where func.etbcod = pdvdoc.etbcod  and
                                func.funcod = int(pdvmov.codigo_operador)
                        no-lock no-error.

                    find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
                    find titulo where titulo.contnum = int(pdvdoc.contnum) and
                                      titulo.titpar  = pdvdoc.titpar
                            no-lock no-error.
                    if not avail titulo
                    then do:
                        find titulo where titnat = no and titulo.empcod = 19 and 
                            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
                            titulo.titpar = pdvdoc.titpar
                            no-lock no-error.
                    end.                                
                    if avail titulo
                    then do:
                        find cobra of titulo no-lock.
                        message "   log" vtoday pdvtmov.ctmcod titulo.titnum .
                        
                        find first tt-pgcontrato where
                            tt-pgcontrato.dataDocumento         = pdvdoc.datamov and
                            tt-pgcontrato.dataLancamento        = pdvdoc.datamov and
                            tt-pgcontrato.documentoReferencia   = titulo.titnum
                            no-error.      
                        if not avail tt-pgcontrato
                        then do:
                            create tt-pgcontrato.
                            tt-pgcontrato.dataDocumento         = pdvdoc.datamov.
                            tt-pgcontrato.dataLancamento        = pdvdoc.datamov.
                            tt-pgcontrato.documentoReferencia   = titulo.titnum.      
                        end.
                        find first tt-mov where
                            tt-mov.dataDocumento            = tt-pgcontrato.dataDocumento and
                            tt-mov.documentoReferencia      = tt-pgcontrato.documentoReferencia and
                            tt-mov.carteira                 = trim(cobra.cobnom) and
                            tt-mov.ctmcod                   = pdvdoc.ctmcod and
                            tt-mov.funnom                   = if avail func
                                                              then func.funnom
                                                              else ""
                                                          no-error.
                         if not avail tt-mov
                         then do:
                            create tt-mov.
                            tt-mov.dataDocumento            = tt-pgcontrato.dataDocumento.
                            tt-mov.documentoReferencia      = tt-pgcontrato.documentoReferencia.
                            tt-mov.carteira                 = trim(cobra.cobnom).
                            tt-mov.ctmcod                   = pdvdoc.ctmcod.
                            tt-mov.funnom                   = if avail func
                                                          then func.funnom
                                                          else "".
                        end.       
                        do:
                            if pdvdoc.ctmcod = "IEP" /* helio 28022022 - iepro */
                            then do:
                                vvalor = if cobra.cobcod = 1 or cobra.cobcod = 2 /* 27052022 helio - pedido isis */
                                         then pdvdoc.titvlcob
                                         else pdvdoc.valor.
                                
                                tt-mov.valor                    = tt-mov.valor + 
                                                                (if vvalor < 0
                                                                 then (vvalor * -1)
                                                                 else vvalor) .                                                          

                            end.
                            else do:
                                tt-mov.valor                    = tt-mov.valor + 
                                                                (if pdvdoc.valor < 0
                                                                 then (pdvdoc.valor * -1)
                                                                 else pdvdoc.valor) .                                                          
                            end.
                        end.
                        
                        if pdvdoc.ctmcod = "IEP" /* helio 28022022 - iepro */
                           and
                           pdvdoc.titvlrcustas > 0
                        then do:
                            find first tt-mov where
                                tt-mov.dataDocumento            = tt-pgcontrato.dataDocumento and
                                tt-mov.documentoReferencia      = tt-pgcontrato.documentoReferencia and
                                tt-mov.carteira                 = trim(cobra.cobnom) and
                                tt-mov.ctmcod                   = ("CUSTAS") and
                                tt-mov.funnom                   = if avail func
                                                                  then func.funnom
                                                                  else ""
                                                              no-error.
                             if not avail tt-mov
                             then do:
                                create tt-mov.
                                tt-mov.dataDocumento            = tt-pgcontrato.dataDocumento.
                                tt-mov.documentoReferencia      = tt-pgcontrato.documentoReferencia.
                                tt-mov.carteira                 = trim(cobra.cobnom).
                                tt-mov.ctmcod                   = "CUSTAS".
                                tt-mov.funnom                   = if avail func
                                                              then func.funnom
                                                              else "".
                            end.       
                            tt-mov.valor                    = tt-mov.valor + 
                                                                (if pdvdoc.titvlrcustas < 0
                                                                 then (pdvdoc.titvlrcustas * -1)
                                                                 else pdvdoc.titvlrcustas) .                                                          
                            
                        end.
                        if pdvdoc.ctmcod = "IEP" /* helio 28022022 - iepro */
                           and pdvdoc.Valor_Encargo > 0
                           and (cobra.cobcod = 1 or cobra.cobcod = 2) /* 27052022 helio - pedido isis */
                        then do:
                            find first tt-mov where
                                tt-mov.dataDocumento            = tt-pgcontrato.dataDocumento and
                                tt-mov.documentoReferencia      = tt-pgcontrato.documentoReferencia and
                                tt-mov.carteira                 = trim(cobra.cobnom) and
                                tt-mov.ctmcod                   = ("IEPJUR") and
                                tt-mov.funnom                   = if avail func
                                                                  then func.funnom
                                                                  else ""
                                                              no-error.
                             if not avail tt-mov
                             then do:
                                create tt-mov.
                                tt-mov.dataDocumento            = tt-pgcontrato.dataDocumento.
                                tt-mov.documentoReferencia      = tt-pgcontrato.documentoReferencia.
                                tt-mov.carteira                 = trim(cobra.cobnom).
                                tt-mov.ctmcod                   = "IEPJUR".
                                tt-mov.funnom                   = if avail func
                                                              then func.funnom
                                                              else "".
                            end.       
                            tt-mov.valor                    = tt-mov.valor + 
                                                                (if (pdvdoc.Valor_Encargo - pdvdoc.desconto) < 0
                                                                 then ((pdvdoc.Valor_Encargo - pdvdoc.desconto) * -1)
                                                                 else (pdvdoc.Valor_Encargo - pdvdoc.desconto)) .                                                          
                            
                        end.
                        
                        
                        /*** helio 28012022 - Envio valor acréscimo moedas ECP e EDP
                        if pdvdoc.ctmcod = "ECP" or pdvdoc.ctmcod = "EDP"
                        then do:
                            
                            vvalor = 0.
                            find contrsite where 
                                contrsite.contnum = int(titulo.titnum)
                                no-lock no-error.
                            if avail contrsite
                            then do:
                                for each contrsitbai of contrsite where
                                    contrsitbai.contnum     = contrsite.contnum and
                                    contrsitbai.titpar      = titulo.titpar and
                                    contrsitbai.titdtpag    = pdvdoc.datamov and
                                    contrsitbai.titvlbai    = pdvdoc.titvlcob
                                    no-lock.
                                    vvalor = vvalor + contrsitbai.titvlfrete + contrsitbai.titvlprod.
                                end.
                            end.                                     

                            tt-mov.valor                    = tt-mov.valor + 
                                                                (if vvalor = 0
                                                                 then pdvdoc.valor
                                                                 else vvalor) .                                                          
                        
                        end.
                        else ***/ 
                        
                        vi = vi + 1.                        
                        pdvdoc.dtenvsap = today.
                    end.

            end.
        end. /* fim loop */
        
    end.         
    
    find first tt-pgcontrato no-error. 
    if avail tt-pgcontrato 
    then do: 
        lokJson = hpagtoRecebidoPeriodoEntrada:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE) no-error. 
        if lokJson 
        then do:  
            create verusjsonout. 
            ASSIGN  
                verusjsonout.interface     = "pagtoRecebidoPeriodo".  
                verusjsonout.jsonStatus    = "NP".  
                verusjsonout.dataIn        = today.  
                verusjsonout.horaIn        = time.  
            copy-lob from lcJsonSaida to verusjsonout.jsondados.
    
            hpagtoRecebidoPeriodoEntrada:WRITE-JSON("FILE","pagtoRecebidoPeriodoEntrada.json", true).
        end.
    end.
    
end.    


