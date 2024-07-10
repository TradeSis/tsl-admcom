
/* Gestao de Boletos   - procs
   bol/baixaboleto_v1701.p
   Efetiva o Pagamento ou Baixa de um Boleto
*/
/**
    {cabec.i}
**/

def input param par-recboleto   as recid.
def input param par-ocbcod      as int.
def input param par-titdtpag    as date.
def input param par-titvlpag    as dec.
def input param par-titjuro     as dec.


find banboleto where recid(banboleto) = par-recboleto exclusive.

if banboleto.bancod = 104
then
find first banocorr where 
        banocorr.bancod = banboleto.bancod and
        banocorr.ocbtipo   = no 
   no-lock no-error.
else 
find banocorr where 
        banocorr.bancod = banboleto.bancod and
        banocorr.ocbtipo   = no and /* retorno */
        banocorr.ocbcod = par-ocbcod
   no-lock no-error.
   
    

banboleto.ocbcod   = par-ocbcod.


if avail banocorr
then do:
    if banocorr.ocbbaixa
    then do: 
        banboleto.situacao = "B".
        banboleto.dtbaixa = today.
        banboleto.hrbaixa = time.
    end.

    if banocorr.ocbliquida
    then do:
        banboleto.situacao = "L".
        banboleto.dtbaixa = today.
        banboleto.hrbaixa = time.
        banboleto.dtPagamento = par-titdtpag.
        banboleto.vlPagamento = par-titvlpag.
        banBoleto.vlJuros     = par-titjuro.
    end.

end.
