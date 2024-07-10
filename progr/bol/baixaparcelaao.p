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

def buffer baoacparcela for aoacparcela.

def buffer baoacorigem for aoacorigem.
def var vidacordo as int.
def var vcontnum as int.
def var vtitpar as int.

par-ok = no.

find banbolorigem where recid(banbolorigem) = par-bolorigem no-lock.
find banboleto of banbolorigem no-lock.

find pdvmov where recid(pdvmov) = par-pdvmov no-lock.


if banbolorigem.tabelaorigem = "api/acordo,parcelasboleto" 
then do:
    
    find aoacorigem where 
            aoacorigem.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
            aoacorigem.contnum  = int(entry(2,banbolorigem.dadosOrigem)) and
            aoacorigem.titpar  = int(entry(3,banbolorigem.dadosOrigem))
        no-lock no-error.
    if avail aoacorigem
    then  find aoacordo of aoacorigem no-lock no-error.

    vidacordo = int(entry(1,banbolorigem.dadosOrigem)) .
        
    vcontnum = int(entry(2,banbolorigem.dadosOrigem)).
    vtitpar  = int(entry(3,banbolorigem.dadosOrigem)).
          
    if true /*aoacordo.dtefetiva = ? */
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
            
            titulo.titobs[2] = "AOACORDO=" + string(vIDACORDO).
            if avail aoacordo
            then do:
                find current aoacordo exclusive.
                aoacordo.dtefetiva = today.
                aoacordo.situacao = "E".
                par-ok = yes.
                
                /**
                find current aoacorigem exclusive.
                assign
                    aoacorigem.dtbaixa  = today
                    aoacorigem.situacao = "B". /* Baixado */ 
        
                find first baoacorigem of aoacordo where
                    baoacorigem.parcela > aoacorigem.parcela
                    exclusive no-error.
                if avail baoacorigem
                then     do:
                    baoacorigem.situacao = "ENVIARBOLETO". /* Next */
                end. 
                */                                               
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
            pdvdoc.hispaddesc        = "BAIXA DE BOLETO ACORDO AO " + string(vidacordo) .
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



