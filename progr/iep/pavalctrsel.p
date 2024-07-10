/* helio 30052023 310 - Alteração de regra para visualização de contratos IEPRO */
def input param doperacao as char.
def input param pcontnum as int.
def input param pdigita as log.
def input-output param vsel   as int.
def input-output param vabe   as dec.

def buffer btitulo for titulo.
def var vjuro as dec.
{iep/tfilsel.i}
def var vparcela as dec.

find contrato   where contrato.contnum  = pcontnum no-lock.
find clien of contrato no-lock.
find neuclien where neuclien.clicod = clien.clicod no-lock no-error.


    if clien.clinom = ? or
       clien.endereco[1] = ? or
       clien.CIINSC = ? or
       clien.cep[1] = ? or
       clien.cidade[1] = ? or
       clien.bairro[1] = ? or
       clien.ufecod[1] = ? or
       (clien.ciccgc = ? and not avail neuclien) or 
       (avail neuclien and neuclien.cpf = ?)
    then do:
        /*message "contrato" contrato.contnum "dados cadastrais invalidos".
        pause 1.*/
        next.
    end.    
           
 
    /* verifica se o contrato ja esta em algum protesto 
        neste momento não permite 2 protestos */ 
    find first titprotesto where
        titprotesto.operacao = doperacao and
        titprotesto.contnum  = contrato.contnum 
        no-lock no-error.
    if avail titprotesto
    then do:
        /*message "contrato" contrato.contnum "ja possui registro protesto".
        pause 1.*/
        return.        
    end.    
                

    find first ttcontrato where ttcontrato.contnum = contrato.contnum no-lock no-error.
    if avail ttcontrato then next. 


find first ttfiltros.

def var vtitpar as int.
do on error undo:


    create ttcontrato.
    ttcontrato.clicod  = contrato.clicod.
    ttcontrato.clinom  = clien.clinom . 
    ttcontrato.contnum  = contrato.contnum.
    ttcontrato.titdtemi = contrato.dtinicial.
    ttcontrato.modcod = contrato.modcod.
    ttcontrato.tpcontrato = contrato.tpcontrato.
    ttcontrato.marca    = ?.
    ttcontrato.diasatraso = 0.
    


    /* calculos do contrato */
    vparcela = ?.
    for each btitulo where btitulo.empcod = 19 and btitulo.titnat = no and     
            btitulo.etbcod = contrato.etbcod and btitulo.modcod = contrato.modcod and
            btitulo.clifor = contrato.clicod and btitulo.titnum = string(contrato.contnum)
            no-lock.
        if btitulo.titpar = 0 then next.
        
        if vparcela = ?
        then vparcela = btitulo.titvlcob.
        
        if btitulo.titsit = "PAG"
        then do:
            ttcontrato.vlrpag = ttcontrato.vlrpag + btitulo.titvlcob.
            ttcontrato.qtdpag = ttcontrato.qtdpag + 1.
        end.
        if btitulo.titsit = "LIB"
        then do:
            ttcontrato.vlrabe = ttcontrato.vlrabe + btitulo.titvlcob.

            if  btitulo.titdtven < today /* helio 30052023 */
            then do:
                ttcontrato.titdtven = if ttcontrato.titdtven = ?
                                      then btitulo.titdtven
                                      else /* 30052023 min(ttcontrato.titdtven,btitulo.titdtven). */
                                                       max(ttcontrato.titdtven,btitulo.titdtven). /* helio 30052023 */
                ttcontrato.diasatraso = if ttcontrato.diasatraso = 0
                                        then today - btitulo.titdtven
                                        else /*max*/ min(ttcontrato.diasatraso,today - btitulo.titdtven) . /* helio 30052023*/ 
                
            end.
            else do:
            end.
                    
            if btitulo.titdtven < today
            then do:
                ttcontrato.vlratr = ttcontrato.vlratr + btitulo.titvlcob.

                /* helio 11012022 - IEPRO */
                vjuro = 0.
                run juro_titulo.p (if clien.etbcad = 0 then btitulo.etbcod else clien.etbcad,
                               btitulo.titdtven,
                               btitulo.titvlcob,
                               output vjuro).
                ttcontrato.vlrjur = ttcontrato.vlrjur + vjuro.

                create ttparcela.
                ttparcela.contnum = contrato.contnum.
                ttparcela.titpar  = btitulo.titpar.
                ttparcela.titvljur = vjuro.
                ttparcela.trecid = recid(btitulo).
                            
            end.    
        end.      
    end. 
    ttcontrato.vlrdiv = ttcontrato.vlrdiv + ttcontrato.vlratr + ttcontrato.vlrjur.

  if ttcontrato.vlrabe > 0
  then do:
    
    if avail neuclien 
    then do:
        if neuclien.cpf = ?
        then ttcontrato.marca = no.
    end.
    else do:
        ttcontrato.marca = no.
    end.
    if (ttfiltros.vlrctrmin > 0 or ttfiltros.vlrctrmax > 0) and ttcontrato.marca = ?
    then do:
        if contrato.vltotal >= ttfiltros.vlrctrmin and contrato.vltotal <= ttfiltros.vlrctrmax
        then ttcontrato.marca = yes.
        else ttcontrato.marca = no.
    end.
    if (ttfiltros.vlrabemin > 0 or ttfiltros.vlrabemax > 0) and  ttcontrato.marca = ?  
    then do:        
        if ttcontrato.vlrabe >= ttfiltros.vlrabemin and ttcontrato.vlrabe <= ttfiltros.vlrabemax
        then ttcontrato.marca = yes.
        else ttcontrato.marca = no.
    end.

        if (ttfiltros.vlrparcmin > 0 or ttfiltros.vlrparcmax > 0) and ttcontrato.marca = ?
    then do:
        if vparcela >= ttfiltros.vlrparcmin and vparcela <= ttfiltros.vlrparcmax
        then ttcontrato.marca = yes.
        else ttcontrato.marca = no.
    end.

    if (ttfiltros.diasatrasmin > 0 or ttfiltros.diasatrasmax > 0) and  ttcontrato.marca = ?  
    then do:        
        if ttcontrato.diasatraso >= ttfiltros.diasatrasmin and ttcontrato.diasatraso <= ttfiltros.diasatrasmax
        then ttcontrato.marca = yes.
        else ttcontrato.marca = no.
    end.

    
/*    if ttcontrato.vlratr = ttcontrato.vlrabe
    then ttcontrato.marca = no.
*/    

    if ttcontrato.titdtven = ? or ttcontrato.vlratr <= 0
    then ttcontrato.marca = no.
    
    if ttcontrato.marca = ? and ttcontrato.vlrabe > 0
    then ttcontrato.marca = yes.
    if pdigita 
    then ttcontrato.marca = yes.
    
  end.
    
    if ttcontrato.marca = no or
       ttcontrato.marca = ?
    then do:
        for each ttparcela where ttparcela.contnum = ttcontrato.contnum.
            delete ttparcela.
        end.    
        delete ttcontrato.
    end.    
    else do:
        vsel = vsel + 1.
        vabe = vabe + ttcontrato.vlrabe.
        
            ttcontrato.nossonumero = string(contrato.contnum) + "/".
            for each ttparcela where ttparcela.contnum = ttcontrato.contnum
                break by ttparcela.titpar.
                
                if first(ttparcela.titpar)            
                then ttcontrato.nossonumero = ttcontrato.nossonumero + string(ttparcela.titpar) .
                if last(ttparcela.titpar) and not first(ttparcela.titpar)           
                then ttcontrato.nossonumero = ttcontrato.nossonumero + "-" + string(ttparcela.titpar).
        
            end.        
        
        
    end.    

end.
