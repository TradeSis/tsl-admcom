/* Gestao de Boletos   - rotinas
   bol/baixaacordo_v1701.p
   Verifica se Efetivara um acordo ou se baixa uma parcela de um acordo
*/
/**
    {cabec.i}
**/

def input parameter par-bolorigem as recid.
def input parameter par-titdtpag  as date.
def input parameter par-titvlpag  as dec.
def input parameter par-titjuro   as dec.  
def output param    par-ok as log.

par-ok = no.

find banbolorigem where recid(banbolorigem) = par-bolorigem no-lock.
find banboleto of banbolorigem no-lock.
find bancarteira of banboleto no-lock.
 
find cybacparcela where 
        cybacparcela.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
        cybacparcela.parcela  = int(entry(2,banbolorigem.dadosOrigem))
    no-lock no-error.
if not avail cybacparcela
    then return.
find cybacordo of cybacparcela 
    no-lock no-error.
if not avail cybacordo
    then return.

if cybacordo.dtefetiva = ? 
then do:
    
    run bol/efetivaacordo_v1702.p (par-bolorigem, 
                             par-titdtpag,
                             par-titvlpag,
                             par-titjuro,
                             output par-ok).

    if par-ok
    then do:
    
    end.
end.
else do:
    
    if cybacordo.dtefetiva <> ? 
    then do:
        run bol/baixaparcela_v1702.p  (par-bolorigem, 
                                  par-titdtpag,
                                  par-titvlpag,
                                  par-titjuro,
                                  output par-ok).

    end.
    
end.

             
                  
        
 
 
 
