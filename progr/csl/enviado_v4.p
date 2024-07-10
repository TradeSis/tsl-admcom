/* helio 25022022 - projeto iepro */
/*#2 08.03.17 Helio Atualizar cliente quando alterar o cadastro */
/*#3 10.03.17 Helio Controlar o real vencido, usar campo controle.vlentra */
/*#4 18.12.18 TP 28424872 */
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

{csl/cybcab.i}

def var vatualizarParcela as log.  /* helio 25022022 - projeto iepro */
def var vatualizar_cliente as log. /*#2*/
/**
def var vat as int.
def var vvlraberto as dec.
def var vvlratrasado as dec.
def var vdtultpag as date.
def var vvlrultpag as dec.
def var vparpg as char format "x(40)".
def var vparab as char format "x(40)".
def var vlp as log.
def var vnovacao as log.
def var vdtini as date.
def var vultvencab as date.
**/
def var vclicod as int.
def var vetbcod as int.
def var vcontnum as int.
def var vmodcod as char.
 
pause 0 before-hide. 
def var vtime as int format ">>>>>>>>9".
def var xtime as int format ">>>>>>>>9".
def var vini as log.

vtime = time.
vini = yes.

find estab where estab.etbcod = par-etbcod no-lock.
for each cslog_controle
        where cslog_controle.loja = estab.etbcod and
              cslog_controle.situacao = "ENVIADO" NO-LOCK.
    find contrato where contrato.contnum = cslog_controle.contnum
              no-lock no-error.
    if not avail contrato then next.

    vi = vi + 1.
end.          

message "ESTAB " estab.etbcod estab.etbnom.
 
for each cslog_controle
    where cslog_controle.loja = estab.etbcod and
          cslog_controle.situacao = "ENVIADO".

    find contrato where contrato.contnum = cslog_controle.contnum
              no-lock no-error.
    if not avail contrato then next.

    /***HML {cyb/cyberhml.i} **/
 
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

    if vi mod 5000 = 0 or vi < 1 or vini
    then do:
        vini = no.
        xtime = time - vtime.
        disp cslog_controle.situacao
             vi vat string(xtime,"HH:MM:SS") @ xtime
             estab.etbcod
        /**with 1 down centered 1 col **/ .
    end.
   
    vclicod  = cslog_controle.cliente.
    vcontnum = cslog_controle.contnum.
    vetbcod  = cslog_controle.loja.
    vmodcod  = if avail contrato
               then if contrato.modcod <> ""
                    then contrato.modcod
                    else "CRE"
               else "CRE".

    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien then next.

    if cslog_controle.situacao = "ENVIADO"
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
                cslog_contrato.dtinicial = cslog_controle.dtemissao
                cslog_contrato.banco     = "ENVIADO".
        end.
        **/
        
        find cyber_clien where cyber_clien.clicod = cslog_controle.cliente
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
    vatualizarparcela = no.

    {csl/letitulos_v4.i}

    /*#2*/ /*inicio*/
    find clien where clien.clicod = vclicod no-lock no-error.
    find cyber_clien of clien no-lock no-error.
    
    vatualizar_cliente = no.
  
    if not avail cyber_clien or
       (avail cyber_clien and avail clien and
         (cyber_clien.DtURen = ? or
          cyber_clien.DtURen <> clien.datexp or
          cyber_clien.DtURen >= p-today)
        )
    then do:
        vatualizar_cliente = yes.
    end.
    /*#2*/ /*fim*/

    if vvlraberto   = cybaberto and
       vvlratrasado = cybatrasado and
       vdtultpag    = cybultdtpag and
       vprivencab   = cybprivenab and
       vatualizar_cliente = no /*#2*/ and
       vvlrvencido  = cslog_controle.vlentra /*#3*/
       and vatualizarParcela = no      /* helio 25022022 - projeto iepro */    
    then next.
    
    if vatualizar_cliente = yes /*#2*/  
    then do:
        cslog_controle.situacao = "CADASATUALIZAR". /** ATUALIZAR */
    end.
          
    /**    
    if vvlraberto <= 0
    then do:
        cslog_controle.situacao = "BAIXAR".
    end.
    **/
    if vvlraberto < cybaberto
    then do:
        cslog_controle.situacao = "PAGAR".
    end.
    if vvlraberto > cybaberto or
       vatualizarParcela = yes /* helio 25022022 - projeto iepro */
    then do:
        cslog_controle.situacao = "ATUALIZAR".
    end.
    if vvlratrasado < cybatrasado
    then do:
        cslog_controle.situacao = "PAGAR".
    end.
    if vvlratrasado > cybatrasado or
       vvlrvencido > cslog_controle.vlentra /*#3*/
    then do:
        cslog_controle.situacao = "ATUALIZAR". /** ATUALIZAR */
    end.

    /* #4
    if vvlratrasado <= 0
    then do:
        cslog_controle.situacao = "BAIXAR".
    end.
    */
    
    /* #4 */
    if vvlraberto <= 0
    then cslog_controle.situacao = "BAIXAR".

    if cslog_controle.situacao <> "ENVIADO"
    then do:
        /* #7 15.03.19 */
        find neuclien where neuclien.clicod = cslog_controle.cliente 
                exclusive no-error /*#8 */ NO-WAIT.
        if avail neuclien
        then do:
            neuclien.CompDtUltAlter = today.
        end.
        /* #7 15.03.19 */
        
        cslog_controle.vlentra     = vvlrvencido. /*#3*/
        cslog_controle.vlraberto   = vvlraberto.
        cslog_controle.vlratrasado = vvlratrasado.
        cslog_controle.ultdtpag    = vdtultpag.
        cslog_controle.ultvlrpag   = vvlrultpag.
        cslog_controle.parpg       = vparpg.
        cslog_controle.parab       = vparab.     
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
        
        cslog_controle.ultvenab   = vultvencab.
        cslog_controle.qtdatrasado = vqtdatrasado.
        cslog_controle.vlravencer  = vvlravencer.
        cslog_controle.qtdavencer  = vqtdavencer.
        cslog_controle.vlrjuros    = vvlrjuros.
        cslog_controle.privenab    = vprivencab.
        cslog_controle.qtdpagas    = vqtdpagas.
    end.        
end.          

