def var vjuros as dec.
/*def var vdesconto as dec.    helio 26122023 - desconto = juros negativo */
def var vtitvlcob as dec.
def buffer bcontrato for contrato.
def var vtotal as dec.
def var vtitjuro as dec.
def var prec as recid.

def var pdata as date.
pause 0 before-hide.

for each desenr53 where  desenr53.sequencia = ?  break by cpf.

    vtotal = desenr53.FeeOperador + desenr53.FeeAF + desenr53.valorlancamento /* HELIO 15012024 - NAO SOMAR desenr53.descontoAVista*/ .

    find bcontrato where bcontrato.contnum = desenr53.contnum no-lock no-error.
    if not avail bcontrato then next.
    
    vtitvlcob = 0.
 
    /* Helio 14112023 Baixa de contrato Desenrola - Baixa total **/
    /* Alterado para ler todos os titulso em aberto do cliente **/
    for each titulo use-index iclicod where titulo.empcod = 19 and titulo.titnat = no and 
                              titulo.clifor = bcontrato.clicod and 
                                titulo.titsit = "LIB" 
                no-lock.
        find contrato where contrato.contnum = int(titulo.titnum) no-lock.
    /**
    *for each desenr51tit where desenr51tit.clicod = bcontrato.clicod no-lock.
    *    find contrato where contrato.contnum = desenr51tit.contnum no-lock.
    *   find titulo where titulo.empcod = 19 and titulo.titnat = no and 
    *        titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
    *        titulo.clifor = contrato.clicod and
    *        titulo.titnum = string(contrato.contnum) and titulo.titpar = desenr51tit.titpar
    *        no-lock.
    **/
        if titulo.titsit = "LIB"
        then vtitvlcob = vtitvlcob + titulo.titvlcob.
    end.
    
    if vtitvlcob = 0
    then next.
    
    vjuros = vtotal - vtitvlcob.  /* helio 26122023 - quyando desconto, então o campo juros fica negativo */
      
    if desenr53.sequencia = ?
    then do:
        pdata = if desenr53.datamov = ? then today else desenr53.datamov.
        
        run fin/dsrgerapgto.p (input recid(desenr53), input vtitvlcob, input vjuros, input pdata, output prec).
    
        find pdvmov where recid(pdvmov) = prec no-lock no-error.
        if avail pdvmov
        then do:
            desenr53.sequencia = pdvmov.sequencia.
            desenr53.ctmcod    = pdvmov.ctmcod.
            desenr53.datamov   = pdvmov.datamov.
        end.    
    end.
    
        
 end.
