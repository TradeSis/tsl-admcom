/* Gestao de Boletos   - rotinas
   bol/baixaparcela_v1701.p
    Baixa Parcela vinculada a Boleto de Acordo ou Central de Pagamentos
#1 06.08.19 TP 32000697
*/
def input parameter par-bolorigem as recid.
def input parameter par-titdtpag  as date.
def input parameter par-titvlpag  as dec.
def input parameter par-titjuro   as dec.  
def output param    par-ok as log.

def buffer bcybacparcela for cybacparcela.

par-ok = no.

find banbolorigem where recid(banbolorigem) = par-bolorigem no-lock.
find banboleto of banbolorigem no-lock.

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
            assign
                titulo.titdtpag = par-titdtpag
                titulo.titvlpag = par-titvlpag
                titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                  then titulo.titvlpag - titulo.titvlcob
                                  else 0
                titulo.titsit   = "PAG"
                titulo.etbcobra = 999
                titulo.moecod   = "BCO".
        
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
        end.
    end.
end.

if banbolOrigem.tabelaOrigem = "titulo" or
/*#1*/ banBolOrigem.ChaveOrigem = "contnum,titpar"
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
            then do:
                par-ok = yes.
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
            end.
        end.      
    end.
end.

