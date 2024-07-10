
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
def var vprocessa as log.

{cyb/cybcab.i}

/*#2 08.03.17 Helio Atualizar cliente quando alterar o cadastro */
/*#3 10.03.17 Helio Controlar o real vencido, usar campo controle.vlentra */
/*#4 18.12.18 TP 28424872 */

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
for each cyber_controle
        where cyber_controle.loja = estab.etbcod and
              cyber_controle.situacao = "ENVIADO" NO-LOCK.
    find contrato where contrato.contnum = cyber_controle.contnum
              no-lock no-error.
    if not avail contrato then next.

    /***HML {cyb/cyberhml.i} **/

    vi = vi + 1.
end.          

message "ESTAB " estab.etbcod estab.etbnom.
 
for each cyber_controle
    where cyber_controle.loja = estab.etbcod and
          cyber_controle.situacao = "ENVIADO".

    find contrato where contrato.contnum = cyber_controle.contnum
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
        disp cyber_controle.situacao
             vi vat string(xtime,"HH:MM:SS") @ xtime
             estab.etbcod
        /**with 1 down centered 1 col **/ .
    end.
   
    vclicod  = cyber_controle.cliente.
    vcontnum = cyber_controle.contnum.
    vetbcod  = cyber_controle.loja.
    vmodcod  = if avail contrato
               then if contrato.modcod <> ""
                    then contrato.modcod
                    else "CRE"
               else "CRE".

    if cyber_controle.situacao = "ENVIADO"
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
                cyber_contrato.dtinicial = cyber_controle.dtemissao
                cyber_contrato.banco     = "ENVIADO".
        end.

        find cyber_clien where cyber_clien.clicod = cyber_controle.cliente
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

    {cyb/letitulos.i}

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
       vvlrvencido  = cyber_controle.vlentra /*#3*/
    then next.
    
    if vatualizar_cliente = yes /*#2*/  
    then do:
        cyber_controle.situacao = "CADASATUALIZAR". /** ATUALIZAR */
    end.
          
    /**    
    if vvlraberto <= 0
    then do:
        cyber_controle.situacao = "BAIXAR".
    end.
    **/
    if vvlraberto < cybaberto
    then do:
        cyber_controle.situacao = "PAGAR".
    end.
    if vvlraberto > cybaberto
    then do:
        cyber_controle.situacao = "ATUALIZAR".
    end.
    if vvlratrasado < cybatrasado
    then do:
        cyber_controle.situacao = "PAGAR".
    end.
    if vvlratrasado > cybatrasado or
       vvlrvencido > cyber_controle.vlentra /*#3*/
    then do:
        cyber_controle.situacao = "ATUALIZAR". /** ATUALIZAR */
    end.

    /* #4
    if vvlratrasado <= 0
    then do:
        cyber_controle.situacao = "BAIXAR".
    end.
    */
    
    /* #4 */
    if vvlraberto <= 0
    then cyber_controle.situacao = "BAIXAR".

    if cyber_controle.situacao <> "ENVIADO"
    then do:
        cyber_controle.vlentra     = vvlrvencido. /*#3*/
        cyber_controle.vlraberto   = vvlraberto.
        cyber_controle.vlratrasado = vvlratrasado.
        cyber_controle.ultdtpag    = vdtultpag.
        cyber_controle.ultvlrpag   = vvlrultpag.
        cyber_controle.parpg       = vparpg.
        cyber_controle.parab       = vparab.     
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
        
        cyber_controle.ultvenab   = vultvencab.
        cyber_controle.qtdatrasado = vqtdatrasado.
        cyber_controle.vlravencer  = vvlravencer.
        cyber_controle.qtdavencer  = vqtdavencer.
        cyber_controle.vlrjuros    = vvlrjuros.
        cyber_controle.privenab    = vprivencab.
        cyber_controle.qtdpagas    = vqtdpagas.
    end.        
end.          

