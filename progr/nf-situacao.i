def var ind-cancelada as char init "N".
def var ind-situacao  as char init "00".

if avail plani
then
find planiaux where planiaux.etbcod = plani.etbcod and
                         planiaux.emite  = plani.emite and
                         planiaux.serie = plani.serie and
                         planiaux.numero = plani.numero and
                         planiaux.nome_campo = "SITUACAO"
                         NO-LOCK no-error.

else do:

find current placon no-lock no-error.

if avail placon
then
find planiaux where planiaux.etbcod = placon.etbcod and
                         planiaux.emite  = placon.emite and
                         planiaux.serie = placon.serie and
                         planiaux.numero = placon.numero and
                         planiaux.nome_campo = "SITUACAO"
                         NO-LOCK no-error.


end.

if avail planiaux
then do:
    if planiaux.valor_campo = "CANCELADA"
    then ind-situacao = "02".     
    else if planiaux.valor_campo = "INUTILIZADA"
        then ind-situacao = "05".
        else if planiaux.valor_campo = "DENEGADA"
            then ind-situacao = "04".
            else ind-situacao = "00".
end.
else if avail plani and plani.modcod = "CAN"
    then ind-situacao = "02".
    else ind-situacao = "00".  

if ind-situacao = "00"
then ind-cancelada = "N".
else ind-cancelada = "S".

if avail plani and ind-cancelada = "N" and plani.movtdc = 27
then ind-situacao = "08".
if avail plani and plani.movtdc = 75
then ind-situacao = "08".

if avail tipmov 
then do:
    if /*tipmov.movtdc = 48 or*/
       tipmov.movtnom begins "estorno"
    then ind-situacao = "08".
end.


/************
00 Documento regular
01 Documento regular extemporâneo
02 Documento cancelado
03 Documento cancelado extemporâneo
04 NFe denegada
05 Nfe . Numeração inutilizada
06 Documento Fiscal Complementar
07 Documento Fiscal Complementar extemporâneo.
08 Documento Fiscal emitido com base em Regime Especial ou Norma Específica
***************/

