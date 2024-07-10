/* helio 17112022 - ao */ 
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
 
find aoacparcela where 
        aoacparcela.idacordo = int(entry(1,banbolorigem.dadosOrigem)) and
        aoacparcela.parcela  = int(entry(2,banbolorigem.dadosOrigem))
    no-lock no-error.
if not avail aoacparcela
    then return.
find aoacordo of aoacparcela 
    no-lock no-error.
if not avail aoacordo
    then return.


if aoacordo.dtefetiva = ? 
then do:
    
    run bol/efetivaacordoao.p (par-pdvmov, par-seqreg, /* 16.04.2021 helio */
                             par-bolorigem, 
                             par-titdtpag,
                             par-titvlpag,
                             par-titjuro,
                             output par-ok).

end.

             
                  
        
 
 
 
