/* #H1 helio.neto 30072021 - mudou para pegar a versao 2101, estava versao 1701*/

/* Gestao de Boletos   - rotinas
   bol/baixaacordo_v2101.p
   Verifica se Efetivara um acordo ou se baixa uma parcela de um acordo
*/
/**
    {cabec.i}
**/
def input parameter par-pdvmov as recid.
def input parameter par-seqreg  as int.

def input parameter par-bolorigem as recid.
def input parameter par-titdtpag  as date.
def input parameter par-titvlpag  as dec.
def input parameter par-titjuro   as dec.  
def output param    par-ok as log.

par-ok = no.

find banbolorigem where recid(banbolorigem) = par-bolorigem no-lock.
find banboleto of banbolorigem no-lock.
/*find bancarteira of banboleto no-lock.*/
 
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
    
    run bol/efetivaacordo_v2101.p (par-pdvmov, par-seqreg, /* 16.04.2021 helio */
                             par-bolorigem, 
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
        /* #H1 */
        run bol/baixaparcela_v2101.p  ( par-pdvmov, par-seqreg,
                                        par-bolorigem,
                                        par-titdtpag, 
                                        par-titvlpag,
                                        par-titjuro, 
                                        output par-ok).


    end.
    
end.

             
                  
        
 
 
 
