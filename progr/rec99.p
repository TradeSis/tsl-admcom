/*
#1 - 31.08.2017 - Nova novacao - novo filtro de modaildades
*/
{admcab.i}

def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

def buffer btitulo for titulo.

def var vdata   like titulo.titdtemi.
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def buffer bestab for estab.

def temp-table wtit
    field wdata like titulo.titdtpag
    field wpago like titulo.titvlpag
    field wjuro like titulo.titvljur
    field wdesc like titulo.titvldes.

repeat with 1 down side-label width 80 row 3:
    for each wtit:
        delete wtit.
    end.
    update vetbcod colon 20.
    find bestab where bestab.etbcod = vetbcod no-lock.
    display bestab.etbnom no-label.
    update vdt1 label "Data Incial"
           vdt2 label "Data Final" with frame f-date side-label width 80.

    assign sresp = false.
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 with frame f-2.
    if sresp
    then run selec-modal.p ("REC"). /* #1 */
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
    display vmod-sel format "x(40)" no-label with frame f-2.

    do vdata = vdt1 to vdt2:
        for each tt-modalidade-selec,
            each titulo where titulo.etbcobra = vetbcod and
                              titulo.titdtpag = vdata and
                              titulo.modcod = tt-modalidade-selec.modcod
                                    no-lock:
            /* #1
            if titulo.modcod <> "CRE"
            then next.
            */
            if titulo.titpar = 0
            then next.
            if titulo.etbcobra <> vetbcod or titulo.clifor = 1
            then next.
            find first wtit where wtit.wdata = titulo.titdtpag no-error.
            if not avail wtit
            then create wtit.
            wtit.wdata = titulo.titdtpag.
            wtit.wpago = wtit.wpago + titulo.titvlpag
                         - titulo.titjuro + titulo.titdesc.
            if titulo.titjuro = titulo.titdesc
            then.
            else wtit.wjuro = wtit.wjuro + titulo.titjuro.
            if titulo.titjuro = titulo.titdesc
            then.
            else wtit.wdesc = wtit.wdesc + titulo.titdesc.
        end.
    end.
    for each wtit by wdata:
        display wtit with frame f-tit down width 80.
    end.
end.

