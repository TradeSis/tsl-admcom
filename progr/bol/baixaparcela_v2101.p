/* #H1 helio.neto 30072021 - cria pdvdoc quando titulo já esta pago, para aparecer no histrico somente */

/* Gestao de Boletos   - rotinas
   bol/baixaparcela_v1701.p
    Baixa Parcela vinculada a Boleto de Acordo ou Central de Pagamentos
*/
def input parameter par-pdvmov as recid.
def input parameter par-seqreg  as int.

def input parameter par-bolorigem as recid.
def input parameter par-titdtpag  as date.
def input parameter par-titvlpag  as dec.
def input parameter par-titjuro   as dec.  
def output param    par-ok as log.

def buffer bcybacparcela for cybacparcela.

def buffer bcslpromessa for cslpromessa.
def var vidacordo as int.
def var vcontnum as int.
def var vtitpar as int.

par-ok = no.

find banbolorigem where recid(banbolorigem) = par-bolorigem no-lock.
find banboleto of banbolorigem no-lock.

find pdvmov where recid(pdvmov) = par-pdvmov no-lock.


if banbolorigem.tabelaOrigem = "cybacparcela"
then do:
    find cybacparcela where 
            cybacparcela.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
            cybacparcela.parcela  = int(entry(2,banbolorigem.dadosOrigem))
        no-lock no-error.
    if not avail cybacparcela
    then return.
    find cybacordo of cybacparcela no-lock no-error.
    if not avail cybacordo
    then return.

    if cybacordo.dtefetiva <> ? 
    then do on error undo:
        find first titulo where
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.modcod = cybacordo.modcod and
            titulo.etbcod = cybacordo.etbcod and
            titulo.clifor = cybacordo.clifor and
            titulo.titnum = string(cybacparcela.contnum) and
            titulo.titpar = cybacparcela.parcela
        exclusive no-error.
        if avail titulo
        then do:
            /**
            assign
                titulo.titdtpag = par-titdtpag
                titulo.titvlpag = par-titvlpag
                titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                  then titulo.titvlpag - titulo.titvlcob
                                  else 0
                titulo.titsit   = "PAG"
                titulo.etbcobra = 999
                titulo.moecod   = "BCO".
            **/
            
            find current cybacparcela exclusive.
            assign
                cybacparcela.dtbaixa  = today
                cybacparcela.situacao = "B". /* Baixado */ 
        
            find first bcybacparcela of cybacordo where
                bcybacparcela.parcela > cybacparcela.parcela
                exclusive no-error.
            if avail bcybacparcela
            then do:
                bcybacparcela.situacao = "ENVIARBOLETO". /* Next */
            end.                                
            
            par-ok = yes.
            
    
            create pdvdoc.
          ASSIGN
            pdvdoc.etbcod            = pdvmov.etbcod
            pdvdoc.cmocod            = pdvmov.cmocod
            pdvdoc.DataMov           = pdvmov.DataMov
            pdvdoc.Sequencia         = pdvmov.Sequencia
            pdvdoc.ctmcod            = pdvmov.ctmcod
            pdvdoc.COO               = pdvmov.COO
            pdvdoc.seqreg            = par-seqreg
            pdvdoc.CliFor            = titulo.CliFor
            pdvdoc.ContNum           = string(titulo.titnum)
            pdvdoc.titpar            = titulo.titpar
            pdvdoc.titdtven          = titulo.titdtven.
          ASSIGN
            pdvdoc.pago_parcial      = "N"
            pdvdoc.modcod            = titulo.modcod
            pdvdoc.Desconto_Tarifa   = 0
            pdvdoc.Valor_Encargo     = 0
                        pdvdoc.hispaddesc        = "BAIXA DE BOLETO ACORDO CYB " + string(cybacordo.idacordo). /* antigo "cybacparcela" */
            pdvdoc.valor             = titulo.titvlcob. /*par-titvlpag.*/
            pdvdoc.titvlcob          = titulo.titvlcob.
            pdvdoc.valor_encargo    = par-titvlpag - titulo.titvlcob.
            if pdvdoc.valor_encargo < 0
            then do:
                pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                pdvdoc.valor_encargo = 0.
            end. 
            
            if titulo.titsit = "LIB" /* #H1 */
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                       recid(titulo)).

            else pdvdoc.pstatus = YES.     
            
        end.
    end.
end.



if banbolorigem.tabelaorigem = "promessa" or (banbolorigem.tabelaOrigem = ? and   banbolorigem.ChaveOrigem = "idacordo,contnum,parcela") 
then do:
    
    find CSLPromessa where 
            CSLPromessa.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
            CSLPromessa.contnum  = int(entry(2,banbolorigem.dadosOrigem)) and
            CSLPromessa.parcela  = int(entry(3,banbolorigem.dadosOrigem))
        no-lock no-error.
    if avail CSLPromessa
    then  find cybacordo of CSLPromessa no-lock no-error.

    vidacordo = int(entry(1,banbolorigem.dadosOrigem)) .
        
    vcontnum = int(entry(2,banbolorigem.dadosOrigem)).
    vtitpar  = int(entry(3,banbolorigem.dadosOrigem)).
          
    if true /*cybacordo.dtefetiva = ? */
    then do on error undo:
        find contrato where contrato.contnum = vcontnum no-lock.
        find first titulo where
            titulo.empcod = 19 and
            titulo.titnat = no and
            titulo.modcod = contrato.modcod and
            titulo.etbcod = contrato.etbcod and
            titulo.clifor = contrato.clicod and
            titulo.titnum = string(vcontnum) and
            titulo.titpar = vtitpar
        exclusive no-error.
        if avail titulo
        then do:

            /**
            assign
                titulo.titdtpag = par-titdtpag
                titulo.titvlpag = par-titvlpag
                titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                  then titulo.titvlpag - titulo.titvlcob
                                  else 0
                titulo.titsit   = "PAG"
                titulo.etbcobra = 999
                titulo.moecod   = "BCO".
            **/
            
            titulo.titobs[2] = "PROMESSA=" + string(vIDACORDO).
            if avail cybacordo
            then do:
                find current cybacordo exclusive.
                cybacordo.dtefetiva = today.
                find current CSLPromessa exclusive.
                assign
                    CSLPromessa.dtbaixa  = today
                    CSLPromessa.situacao = "B". /* Baixado */ 
        
                find first bCSLPromessa of cybacordo where
                    bCSLPromessa.parcela > CSLPromessa.parcela
                    exclusive no-error.
                if avail bCSLPromessa
                then     do:
                    bCSLPromessa.situacao = "ENVIARBOLETO". /* Next */
                end.                                
            end.
            
            par-ok = yes.
            
    
            create pdvdoc.
          ASSIGN
            pdvdoc.etbcod            = pdvmov.etbcod
            pdvdoc.cmocod            = pdvmov.cmocod
            pdvdoc.DataMov           = pdvmov.DataMov
            pdvdoc.Sequencia         = pdvmov.Sequencia
            pdvdoc.ctmcod            = pdvmov.ctmcod
            pdvdoc.COO               = pdvmov.COO
            pdvdoc.seqreg            = par-seqreg
            pdvdoc.CliFor            = titulo.CliFor
            pdvdoc.ContNum           = string(titulo.titnum)
            pdvdoc.titpar            = titulo.titpar
            pdvdoc.titdtven          = titulo.titdtven.
          ASSIGN
            pdvdoc.pago_parcial      = "N"
            pdvdoc.modcod            = titulo.modcod
            pdvdoc.Desconto_Tarifa   = 0
            pdvdoc.Valor_Encargo     = 0
            pdvdoc.hispaddesc        = "BAIXA DE BOLETO ACORDO CSL " + string(vidacordo) /* promessa */.
            pdvdoc.valor             = par-titvlpag.
            pdvdoc.titvlcob          = titulo.titvlcob.
            pdvdoc.valor_encargo    = par-titvlpag - titulo.titvlcob.
            if pdvdoc.valor_encargo < 0
            then do:
                pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                pdvdoc.valor_encargo = 0.
            end.
        
            if titulo.titsit = "LIB" /* #H1 */
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                       recid(titulo)).

            else pdvdoc.pstatus = YES.     
        end.
    end.
end.


if (banbolorigem.tabelaOrigem = "titulo" or banbolorigem.tabelaOrigem = ?)         and
   banBolOrigem.ChaveOrigem = "contnum,titpar"
then do:  

    find contrato where
            contrato.contnum = int(entry(1,banbolorigem.dadosorigem)) 
         no-lock no-error.    
    if avail contrato
    then do:  
        find first  titulo where   
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = contrato.modcod and 
                titulo.etbcod = contrato.etbcod and 
                titulo.clifor = contrato.clicod and 
                titulo.titnum = string(contrato.contnum) and 
                titulo.titpar = int(entry(2,banbolorigem.dadosorigem)) 
                exclusive no-error.
        if avail titulo
        then do:
            if titulo.titsit = "LIB"
                or titulo.titsit = "PAG" /* #H1 */
            then do:
                par-ok = yes.
                /**
                assign            
                    titulo.titdtpag = par-titdtpag
                    titulo.titvlpag = par-titvlpag
                    titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                      then titulo.titvlpag - titulo.titvlcob
                                      else 0
                    titulo.titsit   = "PAG"
                    /* 12.12.17 */
                    titulo.etbcobra = 999
                    titulo.moecod   = "BCO".
                    
                **/
                
               create pdvdoc.
              ASSIGN
                pdvdoc.etbcod            = pdvmov.etbcod
                pdvdoc.cmocod            = pdvmov.cmocod
                pdvdoc.DataMov           = pdvmov.DataMov
                pdvdoc.Sequencia         = pdvmov.Sequencia
                pdvdoc.ctmcod            = pdvmov.ctmcod
                pdvdoc.COO               = pdvmov.COO
                pdvdoc.seqreg            = par-seqreg
                pdvdoc.CliFor            = titulo.CliFor
                pdvdoc.ContNum           = string(titulo.titnum)
                pdvdoc.titpar            = titulo.titpar
                pdvdoc.titdtven          = titulo.titdtven.
              ASSIGN
                pdvdoc.pago_parcial      = "N"
                pdvdoc.modcod            = titulo.modcod
                pdvdoc.Desconto_Tarifa   = 0
                pdvdoc.Valor_Encargo     = 0
                pdvdoc.hispaddesc        = "BAIXA DE BOLETO " + string(banboleto.nossonumero). /* banbolorigem.tabelaOrigem = "titulo"  */
                pdvdoc.valor             = par-titvlpag.
                pdvdoc.titvlcob          = titulo.titvlcob.
                pdvdoc.valor_encargo    = par-titvlpag - titulo.titvlcob.
                if pdvdoc.valor_encargo < 0
                then do:
                    pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                    pdvdoc.valor_encargo = 0.
                end.
        
                if titulo.titsit = "LIB" /* #H1 */
                then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                       recid(titulo)).

                else pdvdoc.pstatus = YES.     
                    
            end.
        end.      
    end.
end.

