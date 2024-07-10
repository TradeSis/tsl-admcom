/* Movim.p manutencao no movim
#1 04/19 - Projeto ICMS Efetivo
*/
{admcab.i}

def input parameter par-recid-plani as recid no-undo.
def input parameter par-recid-movim as recid no-undo.

def var vmovqtm     like movim.movqtm.
def var vtotal      as dec.
def var vmovdes     like movim.movdes.
def var vmovacf     like movim.movacf.
def var vmovpc      like movim.movpc.

form
    produ.procod    colon 11 format ">>>>>>>>9"
    produ.pronom    no-label
    produ.codfis    label "NCM" format ">>>>>>>>>9"
    clafis.pisent   label "Pis Ent"
    clafis.cofinsent label "Cofins Ent"
    clafis.perred
    vmovqtm  format "zzz,zz9.9999" colon 11
    vmovpc   format "zzz,zz9.9999" colon 38
    vmovdes          colon 62
    movim.movdev     colon 11 label "Frete"
    vmovacf          colon 62 label "Acr Fin"
    vtotal           colon 62 label "Total"
    movim.opfcod     colon 11
    movim.movcsticms colon 38
    movim.movipi     colon 11 format "zzz,zz9.99"
    movim.movalipi   format ">9.99%" no-label
    movim.movbsubst  colon 38
    movim.movsubst   colon 62
    skip
    movim.movbicms   colon 11
    movim.movalicms  colon 38
    movim.movicms    colon 62
    movim.movbpiscof
    movim.movcstpiscof
    movim.movpis     colon 38
    movim.movcofins  colon 62
    with frame f-movim centered row 10 1 down side-labels overlay.

/* #1 */
def var esqcom         as char format "x(14)" extent 5
    initial [" Dados "," Impostos ","Cad.Tributacao",""].

form esqcom
    with frame f-com row screen-lines no-box no-labels column 1 centered.


if par-recid-movim <> ? /* alteracao */
then do with frame f-movim on error undo.
    find movim where recid(movim) = par-recid-movim no-lock.
    find plani where plani.etbcod = movim.etbcod
                 and plani.placod = movim.placod
               no-lock.
    run mostra-dados.
    repeat.
        disp esqcom with frame f-com.
        choose field esqcom with frame f-com.
        if frame-index = 1
        then run mostra-dados.
        if frame-index = 2
        then do.
            hide frame esqcom.
            run not_movimimp.p (par-recid-movim).
            view frame f-movim.
        end.
        else if frame-index = 3
        then
            if avail produ
            then do.
                hide frame esqcom.
                run cad_protribu.p ("", input recid(produ)).
                view frame f-movim.
            end.
    end.
end.
hide frame f-movim no-pause.


procedure mostra-dados.

    do with frame f-movim.

    find produ of movim no-lock no-error.
    if avail produ
    then do.
        find clafis of produ no-lock no-error.
        if avail clafis
        then disp clafis.pisent clafis.cofinsent clafis.perred.
        disp
            produ.pronom
            produ.codfis.
    end.
    else do.
        find prodnewfree of movim no-lock no-error.
        if avail prodnewfree
        then disp
                "(NF)" + prodnewfree.pronom @ produ.pronom
                prodnewfree.codfis @ produ.codfis.
    end.

    assign
        vmovqtm = movim.movqtm
        vmovpc  = movim.movpc
        vmovacf = movim.movacf
        vmovdes = movim.movdes
        vtotal  = movim.movqtm * movim.movpc - movim.movdes + movim.movacf.

    disp
        movim.procod @ produ.procod
        vmovqtm
        vmovpc
        vmovacf
        vmovdes
        vtotal
        movim.movalipi
        movim.movipi
        movim.movbsubst
        movim.movsubst
        movim.movcsticms
        movim.movbicms
        movim.movalicms
        movim.movicms
        movim.movdev
        movim.opfcod
        movim.movbpiscof
        movim.movcstpiscof
        movim.movpis
        movim.movcofins.

/***
        if sfuncod = 100
        then do.
            if plani.bicms > 0 or plani.icms > 0 or movim.movsubst > 0
            then do.
                find current movim.
                if movim.movalicms = 0
                then do.
                    pause.
                    movim.movalicms = round(plani.icms / plani.bicms * 100,2).
                end.
                update movim.movbicms
                    movim.movalicms movim.movicms movim.movsubst.
            end.
            else
                pause.
        end.
        else 
***/
    end.

end procedure.


