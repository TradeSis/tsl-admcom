/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inlcui Elegiveis Feirao */
/** #7 **/ /*  03.2019 helio.neto - inclusao de registro no campo neuclien.CompDtUltAlter para marcar que comportamnto mudou
#8 24.07.19 Tratamento de Lock
*/

def input parameter p-today as date.
def input param par-etbcod as int. 
def input param vprocessa_normal as log.
def input param vprocessa_novacao as log.
def input param vprocessa_lp as log.
def input param vprocessa_cp as log.
def input param vdias as int.
def input param vdias_novacao as int.
def input param vdias_lp as int.
def input param vdias_boleto as int.
def input param vdias_cp as int.
def input param vprocessa_ef as log.
def input param vef_modcod as char.
def input param vef_dataemi as date.
def input param vef_dias as int.

def var vprocessa as log.
def var vatualizarParcela as log.  /* helio 25022022 - projeto iepro */

{csl/cybcab.i}

/**
def var vi as int format ">>>>>>>>>>>9".
def var vat as int.
def var vvlraberto as dec.
def var vvlratrasado as dec.
def var vvlrultpag as dec.
def var vdtultpag as date.
def var vparpg as char format "x(40)".
def var vparab as char format "x(40)".
def var vlp as log.
def var vnovacao as log.
def var vdtini as date.
def var vultvencab as date.
**/

pause 0 before-hide. 
def var vtime as int format ">>>>>>>>9".
def var xtime as int format ">>>>>>>>9".
def var vini as log.
vtime = time.
vini = yes.

for each estab where estab.etbcod = par-etbcod
    no-lock.
for each cslog_controle
    where cslog_controle.loja = estab.etbcod and
          situacao = "ACOMPANHADO".

        find contrato where contrato.contnum = cslog_controle.contnum
              no-lock no-error.
        if not avail contrato then next.

        /***HML {csl/cyberhml.i} **/
     
    if cslog_controle.dtemissao > p-today
        then next.
        
/**
    if vprocessa_normal and cslog_controle.novacao = no
    then.
    else if vprocessa_novacao and cslog_controle.novacao = yes
         then.
         else if vprocessa_lp and cslog_controle.lp = yes
              then.
              else next.
**/
    
    
    vi = vi + 1.
end.          
end.

for each estab where estab.etbcod = par-etbcod
    no-lock.
vini = yes.

for each cslog_controle
    where cslog_controle.loja = estab.etbcod and
          situacao = "ACOMPANHADO".

         find contrato where contrato.contnum = cslog_controle.contnum
              no-lock no-error.
        if not avail contrato then next.

        /***HML {csl/cyberhml.i} **/
    
    if cslog_controle.dtemissao > p-today
        then next.
    
    /**
    if vprocessa_normal and cslog_controle.novacao = no
    then.
    else if vprocessa_novacao and cslog_controle.novacao = yes
         then.
         else if vprocessa_lp and cslog_controle.lp = yes
              then.
              else next.
    **/
                  
    vi = vi - 1.  
    /**
    vvlraberto   = 0.
    vvlratrasado = 0.
    vdtultpag    = ?.
    vvlrultpag   = 0.
    vparpg       = "".
    vparab       = "".
    vlp = no.
    vnovacao = no.
    vultvencab = ?.
     **/
     
    if vi mod 5000 = 0 or vi < 5 or vini
    then do:
        vini = no.
        xtime = time - vtime.
        disp    situacao
                vi vat string(xtime,"HH:MM:SS") @ xtime
                estab.etbcod
        /**with 1 down centered 1 col **/ .
    end.
    
    
    def var vclicod as int.
    def var vetbcod as int.
    def var vcontnum as int.
    def var vmodcod as char.

        vclicod  = cslog_controle.cliente.
        vcontnum = cslog_controle.contnum.
        vetbcod  = cslog_controle.loja.
 
    find contrato where contrato.contnum = cslog_controle.contnum
        no-lock no-error.

    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien then next.

                vmodcod = if avail contrato
                  then if contrato.modcod <> ""
                       then contrato.modcod
                       else "CRE"
                  else "CRE".
        
    {csl/letitulos_v4.i}

    if vlraberto = ? or
       vlratrasado = ?
    then do:
        vlraberto = vvlraberto.
        vlratrasado = vvlratrasado.        
        ultvlrpag   = vvlrultpag.
        ultdtpag    = vdtultpag. 
        ultvenab = vultvencab.
        parpg = vparpg.
        parab = vparab.
        cslog_controle.novacao     = vnovacao.
        cslog_controle.lp          = vlp.
        cslog_controle.ptoday      = p-today.
        cslog_controle.ndias      =  (if vnovacao 
                                      then vdias_novacao 
                                      else if vlp
                                           then vdias_lp
                                           else if vmodcod begins "CP"
                                                then vdias_cp
                                                else vdias) .

        cslog_controle.dtlimite    = p-today - (if vnovacao 
                                      then vdias_novacao 
                                      else if vlp
                                           then vdias_lp
                                           else if vmodcod begins "CP"
                                                then vdias_cp
                                                else vdias) .
           
        cslog_controle.qtdatrasado = vqtdatrasado.
        cslog_controle.vlravencer  = vvlravencer.
        cslog_controle.qtdavencer  = vqtdavencer.
        cslog_controle.vlrjuros    = vvlrjuros.
        cslog_controle.privenab    = vprivencab.
        cslog_controle.qtdpagas    = vqtdpagas.
 
        cslog_controle.situacao = "NULO".
    end.
    /**   
    else do:
        if vvlraberto = vlraberto and
           vvlratrasado = vlratrasado
        then next.
    end.
    **/
    
    if vvlraberto = 0
    then do:
        cslog_controle.situacao = "ELIMINAR".
        cslog_controle.vlraberto = vvlraberto.
        cslog_controle.vlratrasado = vvlratrasado.
        next.
    end.
    if vvlratrasado > 0 /**vlratrasado**/
    then do:
        if vprocessa
        then do:
            vat = vat + 1.
            /*find cslog_contrato of cslog_controle no-lock no-error.*/
            cslog_controle.situacao = if cslog_controle.situacao = "ENVIADO"
                                      then "ATUALIZAR"
                                      else "ENVIAR".
        end.    
    end. 
    
    cslog_controle.vlraberto   = vvlraberto. 
    cslog_controle.vlratrasado = vvlratrasado.

    cslog_controle.vlentra     = vvlrvencido. /*#3*/

    if cslog_controle.situacao <> "ACOMPANHADO"
    then do:
        /* #7 15.03.19 */
        find neuclien where neuclien.clicod = cslog_controle.cliente 
                exclusive no-error /*#8 */ NO-WAIT.
        if avail neuclien
        then do:
            neuclien.CompDtUltAlter = today.
        end.
        /* #7 15.03.19 */
    
        cslog_controle.ultvlrpag   = vvlrultpag.
        cslog_controle.ultdtpag    = vdtultpag.
        cslog_controle.parpg       = vparpg.
        cslog_controle.parab       = vparab.     
        
        cslog_controle.ultvenab   = vultvencab.        

                
        cslog_controle.qtdatrasado = vqtdatrasado.
        cslog_controle.vlravencer  = vvlravencer.
        cslog_controle.qtdavencer  = vqtdavencer.
        cslog_controle.vlrjuros    = vvlrjuros.
        cslog_controle.privenab    = vprivencab.
        cslog_controle.qtdpagas    = vqtdpagas.
 
        if cslog_controle.situacao = "NULO"
        then cslog_controle.situacao = "ACOMPANHADO".
        
    end.

        if cslog_controle.situacao = "ENVIAR" or
           cslog_controle.situacao = "ATUALIZAR"
        then do:
            /**
            find cslog_contrato where
                cslog_contrato.contnum = cslog_controle.contnum
                no-error.    
            if not avail cslog_contrato
            then do:            
                create cslog_contrato.
                ASSIGN
                cslog_contrato.clicod    = cslog_controle.cliente
                cslog_contrato.contnum   = cslog_controle.contnum
                cslog_contrato.Situacao  = yes                    
                cslog_contrato.vlentra   = if avail contrato
                                           then contrato.vlentra
                                           else 0
                cslog_contrato.etbcod    = cslog_controle.loja
                cslog_contrato.dtinicial = cslog_controle.dtemissao.
                cslog_contrato.banco     = "ENVIAR".

            end.
            **/
            find cyber_clien where
                cyber_clien.clicod = cslog_controle.cliente
                no-error.
            if not avail cyber_clien 
            then do:
                create cyber_clien.
                assign
                cyber_clien.clicod = cslog_controle.cliente
                cyber_clien.situacao = yes
                cyber_clien.dturen   = today.
            end.   
            
        end.
            
end.          

end.

