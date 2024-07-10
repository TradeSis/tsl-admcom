/* movimpack.p manutencao no movimpack - NAO ENVIAR PARA AS LOJAS */

{admcab.i}

def input parameter par-recid-plani as recid no-undo.
def input parameter par-recid-movimpack as recid no-undo.

def var vetiqueta-etbcod like estab.etbcod.
def var vetiqueta-conserto as int format "999999".
def var vemitente   as int.
def var vdevolucao  as log.
def var vmovqtm     like movimpack.movqtm.
def var vmovdev     like movimpack.movqtm.
def var vtotal      as dec.
def var vmovdes     like movimpack.movdes.
def var vperc       as   dec.
def var vmovacf     like movimpack.movacf.
def var vmovpc      like movimpack.movpc.
def var vbicms      as dec.
/***
def var vmovalicms  like movimpack.movalicms.
def var vmovicms    like movimpack.movicms.
***/
def var vmovbipi    as dec.

form
    pack.paccod    colon 11
    pack.pacnom    no-label
/*  prck.codfis    label "NCM" format ">>>>>>>>>9"
    clafis.pisent   label "Pis Ent"
    clafis.cofinsent label "Cofins Ent"
    clafis.perred*/
    vmovqtm  format "zzz,zz9.9999" colon 11
    vmovpc   format "zzz,zz9.9999" colon 37
    vmovdes          colon 61
/***
    movimpack.movdev     colon 11 label "Frete"
***/
    vmovacf          colon 61 label "Acr Fin"
    vtotal           colon 61 label "Total"
/***
    movimpack.opfcod     colon 11
    movimpack.movcsticms colon 37
    movimpack.movipi     colon 37 format "zzz,zz9.99"
    movimpack.movsubst   colon 61
***/
    skip
/***
    movimpack.movbicms   colon 11
    movimpack.movalicms  colon 37
    movimpack.movicms    colon 61
***/
    with frame f-movimpack centered row 10
            width 78 1 down side-labels overlay.

if par-recid-movimpack <> ? /* alteracao */
then do:
    do with frame f-movimpack on error undo.
        find movimpack where recid(movimpack) = par-recid-movimpack no-lock.
        find plani where plani.etbcod = movimpack.etbcod
                     and plani.placod = movimpack.placod
                   no-lock.
        find pack of movimpack no-lock.
        /*find clafis of pack no-lock no-error.
        if avail clafis
        then disp clafis.pisent clafis.cofinsent clafis.perred.*/

        assign
            vmovqtm = movimpack.movqtm
            vmovpc  = movimpack.movpc
            vmovacf = movimpack.movacf
            vmovdes = movimpack.movdes
            vtotal  = movimpack.movqtm * movimpack.movpc - movimpack.movdes + movimpack.movacf.

        disp pack.paccod
            pack.pacnom
            /*pack.codfis*/
            vmovqtm
            vmovpc
            vmovacf
            vmovdes
            vtotal
            /*movimpack.movipi
            movimpack.movsubst
            movimpack.movcsticms
            movimpack.movbicms
            movimpack.movalicms
            movimpack.movicms
            movimpack.movdev
            movimpack.opfcod
            movimpack.movbpiscof
            movimpack.movcstpiscof
            movimpack.movpis
            movimpack.movcofins*/.

/***
        if sfuncod = 100
        then do.
            if plani.bicms > 0 or plani.icms > 0 or movimpack.movsubst > 0
            then do.
                find current movimpack.
                if movimpack.movalicms = 0
                then do.
                    pause.
                    movimpack.movalicms = round(plani.icms / plani.bicms * 100,2).
                end.
                update movimpack.movbicms
                    movimpack.movalicms movimpack.movicms movimpack.movsubst.
            end.
            else
                pause.
        end.
        else 
***/
            pause.
        hide frame f-movimpack no-pause.
    end.
end.
