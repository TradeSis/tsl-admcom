/* #1 helio 25.05.2018 - trocado de dtinicial para o datexp, devido a criação da tabela contrato muito depois dos 30 dias do controle , exemplo foi o contrato 15161461 em PRD que não tinha a tabela CONTRATO, foi criada em 28.03.2018 com DTINICIAL 16.01.2016 e como o controle eh de 30 dias nao pegou mais, fazendo por datexp, se acertar esta data na tabela de contrato ele sera verificada */
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

pause 0 before-hide. 
def var vtime as int format ">>>>>>>>9".
def var xtime as int format ">>>>>>>>9".

vtime = time.
for each estab where estab.etbcod = par-etbcod
    no-lock.
message "ESTAB " estab.etbcod estab.etbnom.

find first cyber_controle use-index etb_dtini
        where
        cyber_controle.loja = estab.etbcod and
        cyber_controle.dtemissao <> ?
        no-lock no-error.
vdtini = if avail cyber_controle
         then cyber_controle.dtemissao - 60
         else 01/01/1901.
message vdtini.
if vdtini  = ? then vdtini = 01/01/1901.
message vdtini.

for each contrato use-index mala

    where   contrato.etbcod = estab.etbcod and
            contrato.datexp >= vdtini /** teste novos **/ /* #1 */
            
            and
            contrato.datexp < p-today  /* #1 */
                    /**date(month(today),01,year(today))
                    **/
        
        no-lock.


        /***HML {cyb/cyberhml.i} **/
        
         
        /**
        by contrato.etbcod by contrato.dtinicial. 
        **/
        

                 /**
            find clien where clien.clicod = contrato.clicod no-lock no-error. 
            if not avail clien
            then next.
                  **/
        
    vi = vi + 1.  
   
    xtime = time - vtime.    
    if vi mod 10000 = 0 or vi < 3 or (xtime mod 60 = 0 and vi > 10000) 
    then do:
        disp "NOVO" vi vat string(xtime,"HH:MM:SS") @ xtime
                contrato.etbcod
                contrato.modcod
                contrato.dtinicial format "99/99/9999"
        /**with 1 down centered 1 col **/ .
        pause 1 no-message.
    end.
    
    
    if can-find( cyber_controle where 
        cyber_controle.contnum = contrato.contnum
        no-lock )
    then next.
        /**no-error.
    if avail cyber_controle 
    then next.
           **/
         

    def var vclicod as int.
    def var vetbcod as int.
    def var vcontnum as int.
    def var vmodcod as char.

        find cyber_contrato where cyber_contrato.contnum = contrato.contnum
            no-lock no-error.
        vclicod = if avail cyber_contrato
                  then cyber_contrato.clicod
                  else contrato.clicod.  
        vcontnum = contrato.contnum.
        vetbcod  = contrato.etbcod.
        vmodcod = if avail contrato
                  then if contrato.modcod <> ""
                       then contrato.modcod
                       else "CRE"
                  else "CRE".
             
            
    {cyb/letitulos.i}
    
    if vvlraberto <> 0
    then do:
        vat = vat + 1.
        /**
        if vi mod 1000 = 0 or vi < 10 
        then disp
            vvlraberto vvlratrasado vparpg vparab vnovacao vlp
            vultvencab.
        **/         
            
        find cyber_controle where
            cyber_controle.contnum = contrato.contnum
          exclusive  no-error.
        if not avail cyber_controle
        then do:
            create cyber_controle.
            cyber_controle.contnum      = contrato.contnum.
            cyber_controle.dtemissao    = contrato.dtinicial.
            cyber_controle.cliente      = contrato.clicod.
            cyber_controle.loja         = contrato.etbcod.
            cyber_controle.cybaberto   = 0.
            cyber_controle.cybatrasado   = 0.
            cyber_controle.cybultdtpag  = ?.
            
        end.

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

        cyber_controle.dtlimite    = p-today - 
                                      (if vnovacao 
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
        
                
        if vvlratrasado > 0
        then do:
            cyber_controle.situacao = if vprocessa
                                       then "ENVIAR"
                                       else "ACOMPANHADO".
        end.
        else cyber_controle.situacao = "ACOMPANHADO".

        if cyber_controle.situacao = "ENVIAR"
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
                cyber_contrato.vlentra   = contrato.vlentra
                cyber_contrato.etbcod    = cyber_controle.loja
                cyber_contrato.dtinicial = cyber_controle.dtemissao.
                cyber_contrato.banco     = "NOVO".
                
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

        xtime = time - vtime.
        disp vi vat string(xtime,"HH:MM:SS") @ xtime.
end.
        
        
