/* helio 16052023 - parametro marcado */
/* helio 18042023 - CSLOG - Importação de Contrato - Qualitor 23211 marcar contrato.datexp para subir contrato no cslog */
/* #1 helio 25.05.2018 - trocado de dtinicial para o datexp, devido a criação da tabela contrato muito depois dos 30 dias do controle , exemplo foi o contrato 15161461 em PRD que não tinha a tabela CONTRATO, foi criada em 28.03.2018 com DTINICIAL 16.01.2016 e como o controle eh de 30 dias nao pegou mais, fazendo por datexp, se acertar esta data na tabela de contrato ele sera verificada */
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

pause 0 before-hide. 
def var vtime as int format ">>>>>>>>9".
def var xtime as int format ">>>>>>>>9".

form with frame f down width 150 .
vtime = time.
find estab where estab.etbcod = par-etbcod no-lock.
vdtini = ?.
find first tab_ini where
    tab_ini.parametro = "CSLOG_PROCESSA" and
        tab_ini.etbcod    = par-etbcod
            no-lock no-error.
if avail tab_ini 
then do: 
    if tab_ini.dtinclu >= today - 3 /* Conserta para quando for loja nova cadastrada, varrer toda a base, por causa do arrasto */
    then do: 
        vdtini = 01/01/1902. 
    end. 
end.
                                
if vdtini = ? 
then do:
    find first cslog_controle use-index etb_dtini
        where
        cslog_controle.loja = estab.etbcod and
        cslog_controle.dtemissao <> ?
        no-lock no-error.
    vdtini = if avail cslog_controle
             then cslog_controle.dtemissao - 60
             else 01/01/1901.
    if vdtini  = ? then vdtini = 01/01/1901.
end.    
message string(time, "hh:mm:ss") "ESTAB" estab.etbcod "INICIAL" vdtini.
vi = 0.

if vdtini < today - 60
then do: /* carga */ 
    
    for each contrato use-index mala
        where   contrato.etbcod = estab.etbcod and
                contrato.dtinicial >= vdtini /** teste novos **/ /* #1 */ and
                contrato.dtinicial <= today  
            no-lock.
        run P ("novo"). /* helio 16052023 */       
    end.
    vdtini = today - 5.
end.
for each contrato use-index datexp

    where   contrato.etbcod = estab.etbcod and
            contrato.datexp >= today - 1  and /* datexp eh marcado, pegar soh do dia */
            contrato.datexp <=  today  /* #1 */
                    /**date(month(today),01,year(today))
                    **/
        no-lock.
    run P ("marcado").  /* helio 16052023      */
end.

procedure P.
    def input param ptipo as char.        

    do on error undo:
    vi = vi + 1.  
   
    xtime = time - vtime.    
    if vi mod 20000 = 0 or vi < 2 or (xtime mod 60 = 0 and vi > 10000) 
    then do:
        disp "NOVO" vdtini format "99/99/9999" vi vat string(xtime,"HH:MM:SS") @ xtime
                contrato.etbcod
                contrato.modcod
                contrato.contnum   format ">>>>>>>>>>9"
                contrato.dtinicial format "99/99/9999"
                with frame f down.
                down with frame f.
        pause 1 no-message.
    end.
    
    if can-find(cslog_controle where cslog_controle.contnum = contrato.contnum
        no-lock)
    then do:
        if ptipo = "novo"
        then return.
         
        /* helio 18042023 - CSLOG - Importação de Contrato - Qualitor 23211 marcar contrato.datexp para subir contrato no cslog */
        find cslog_controle where cslog_controle.contnum = contrato.contnum exclusive no-wait no-error.
        if avail cslog_controle
        then do: 
            if ptipo = "marcado" /* helio 16052023 */
            then do:
                cslog_controle.situacao =  "ENVIAR" . /* helio 23052023 */
            end.
        end.
        
        next.
    end.    

    def var vclicod as int.
    def var vetbcod as int.
    def var vcontnum as int.
    def var vmodcod as char.

        vclicod =  contrato.clicod.  
        vcontnum = contrato.contnum.
        vetbcod  = contrato.etbcod.
        vmodcod = if avail contrato
                  then if contrato.modcod <> ""
                       then contrato.modcod
                       else "CRE"
                  else "CRE".
    
    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien then next.
                     
    {csl/letitulos_v4.i}
    
    if vvlraberto <> 0
    then do:
        vat = vat + 1.
        /**
        if vi mod 1000 = 0 or vi < 10 
        then disp
            vvlraberto vvlratrasado vparpg vparab vnovacao vlp
            vultvencab.
        **/         
            
        find cslog_controle where cslog_controle.contnum = contrato.contnum
          exclusive no-error.
        if not avail cslog_controle
        then do:
            create cslog_controle.
            cslog_controle.contnum      = contrato.contnum.
            cslog_controle.dtemissao    = contrato.dtinicial.
            cslog_controle.cliente      = contrato.clicod.
            cslog_controle.loja         = contrato.etbcod.
            cslog_controle.cybaberto   = 0.
            cslog_controle.cybatrasado   = 0.
            cslog_controle.cybultdtpag  = ?.
            
        end.

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

        cslog_controle.dtlimite    = p-today - 
                                      (if vnovacao 
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
                        
        if vvlratrasado > 0
        then do:
            cslog_controle.situacao = if vprocessa
                                       then "ENVIAR"
                                       else "ACOMPANHADO".
        end.
        else cslog_controle.situacao = "ACOMPANHADO".
        
        /* #7 15.03.19 */
        find neuclien where neuclien.clicod = cslog_controle.cliente 
                exclusive no-error /*#8 */ NO-WAIT.
        if avail neuclien
        then do:
            neuclien.CompDtUltAlter = today.
        end.
        /* #7 15.03.19 */

        if cslog_controle.situacao = "ENVIAR"
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
                cslog_contrato.vlentra   = contrato.vlentra
                cslog_contrato.etbcod    = cslog_controle.loja
                cslog_contrato.dtinicial = cslog_controle.dtemissao.
                cslog_contrato.banco     = "NOVO".
            end.
            */
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
end procedure.

xtime = time - vtime.
disp vi vat string(xtime,"HH:MM:SS") @ xtime.

