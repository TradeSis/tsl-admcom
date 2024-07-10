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

{cyb/cybcab.i}

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
for each cyber_controle
    where cyber_controle.loja = estab.etbcod and
          situacao = "ACOMPANHADO".

        find contrato where contrato.contnum = cyber_controle.contnum
              no-lock no-error.
        if not avail contrato then next.

        /***HML {cyb/cyberhml.i} **/
     
    if cyber_controle.dtemissao > p-today
        then next.
        
/**
    if vprocessa_normal and cyber_controle.novacao = no
    then.
    else if vprocessa_novacao and cyber_controle.novacao = yes
         then.
         else if vprocessa_lp and cyber_controle.lp = yes
              then.
              else next.
**/
    
    
    vi = vi + 1.
end.          
end.

for each estab where estab.etbcod = par-etbcod
    no-lock.
vini = yes.

for each cyber_controle
    where cyber_controle.loja = estab.etbcod and
          situacao = "ACOMPANHADO".

         find contrato where contrato.contnum = cyber_controle.contnum
              no-lock no-error.
        if not avail contrato then next.

        /***HML {cyb/cyberhml.i} **/
    
    if cyber_controle.dtemissao > p-today
        then next.
    
    /**
    if vprocessa_normal and cyber_controle.novacao = no
    then.
    else if vprocessa_novacao and cyber_controle.novacao = yes
         then.
         else if vprocessa_lp and cyber_controle.lp = yes
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

        vclicod  = cyber_controle.cliente.
        vcontnum = cyber_controle.contnum.
        vetbcod  = cyber_controle.loja.
 
    find contrato where contrato.contnum = cyber_controle.contnum
        no-lock no-error.

                vmodcod = if avail contrato
                  then if contrato.modcod <> ""
                       then contrato.modcod
                       else "CRE"
                  else "CRE".
        
    {cyb/letitulos_v4.i}

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
        cyber_controle.novacao     = vnovacao.
        cyber_controle.lp          = vlp.
        cyber_controle.ptoday      = p-today.
        cyber_controle.ndias      =  (if vnovacao 
                                      then vdias_novacao 
                                      else if vlp
                                           then vdias_lp
                                           else if vmodcod begins "CP"
                                                then vdias_cp
                                                else vdias) .

        cyber_controle.dtlimite    = p-today - (if vnovacao 
                                      then vdias_novacao 
                                      else if vlp
                                           then vdias_lp
                                           else if vmodcod begins "CP"
                                                then vdias_cp
                                                else vdias) .
           
        cyber_controle.qtdatrasado = vqtdatrasado.
        cyber_controle.vlravencer  = vvlravencer.
        cyber_controle.qtdavencer  = vqtdavencer.
        cyber_controle.vlrjuros    = vvlrjuros.
        cyber_controle.privenab    = vprivencab.
        cyber_controle.qtdpagas    = vqtdpagas.
 
        cyber_controle.situacao = "NULO".
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
        cyber_controle.situacao = "ELIMINAR".
        cyber_controle.vlraberto = vvlraberto.
        cyber_controle.vlratrasado = vvlratrasado.
        next.
    end.
    if vvlratrasado > 0 /**vlratrasado**/
    then do:
        if vprocessa
        then do:
            vat = vat + 1.
            find cyber_contrato of cyber_controle no-lock no-error.
            cyber_controle.situacao = if avail cyber_contrato
                                      then "ATUALIZAR"
                                      else "ENVIAR".
        end.    
    end. 
    
    cyber_controle.vlraberto   = vvlraberto. 
    cyber_controle.vlratrasado = vvlratrasado.

    cyber_controle.vlentra     = vvlrvencido. /*#3*/

    if cyber_controle.situacao <> "ACOMPANHADO"
    then do:
        /* #7 15.03.19 */
        find neuclien where neuclien.clicod = cyber_controle.cliente 
                exclusive no-error /*#8 */ NO-WAIT.
        if avail neuclien
        then do:
            neuclien.CompDtUltAlter = today.
        end.
        /* #7 15.03.19 */
    
        cyber_controle.ultvlrpag   = vvlrultpag.
        cyber_controle.ultdtpag    = vdtultpag.
        cyber_controle.parpg       = vparpg.
        cyber_controle.parab       = vparab.     
        
        cyber_controle.ultvenab   = vultvencab.        

                
        cyber_controle.qtdatrasado = vqtdatrasado.
        cyber_controle.vlravencer  = vvlravencer.
        cyber_controle.qtdavencer  = vqtdavencer.
        cyber_controle.vlrjuros    = vvlrjuros.
        cyber_controle.privenab    = vprivencab.
        cyber_controle.qtdpagas    = vqtdpagas.
 
        if cyber_controle.situacao = "NULO"
        then cyber_controle.situacao = "ACOMPANHADO".
        
    end.

        if cyber_controle.situacao = "ENVIAR" or
           cyber_controle.situacao = "ATUALIZAR"
        then do:
            find cyber_contrato where
                cyber_contrato.contnum = cyber_controle.contnum
                no-error.    
            if not avail cyber_contrato
            then do:            
                create cyber_contrato.
                ASSIGN
                cyber_contrato.clicod    = cyber_controle.cliente
                cyber_contrato.contnum   = cyber_controle.contnum
                cyber_contrato.Situacao  = yes                    
                cyber_contrato.vlentra   = if avail contrato
                                           then contrato.vlentra
                                           else 0
                cyber_contrato.etbcod    = cyber_controle.loja
                cyber_contrato.dtinicial = cyber_controle.dtemissao.
                cyber_contrato.banco     = "ENVIAR".

            end.
            
            find cyber_clien where
                cyber_clien.clicod = cyber_controle.cliente
                no-error.
            if not avail cyber_clien 
            then do:
                create cyber_clien.
                assign
                cyber_clien.clicod = cyber_controle.cliente
                cyber_clien.situacao = yes
                cyber_clien.dturen   = today.
            end.   
            
        end.
            
end.          

end.

